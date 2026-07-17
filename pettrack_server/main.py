import argparse
import uvicorn
import os
import asyncio
import json
import random
import jwt
import socket
import qrcode
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from manager import manager, client_manager
from api_routes import router as zones_router, auth_router, monitor_state, active_zones, update_latest_frame, SECRET_TOKEN, fernet, set_key
from tasks import cleanup_old_images
from vision import process_and_save_frame
from database import init_db, get_zones

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(zones_router)
app.include_router(auth_router)

@app.on_event("startup")
async def startup_event():
    await init_db()
    
    # Load saved zones from database into memory
    zones = await get_zones()
    for z in zones:
        active_zones[z["name"]] = z["polygon"]
        
    asyncio.create_task(cleanup_old_images())

    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
    except:
        ip = "127.0.0.1"
    
    secret = os.getenv("PETTRACK_SECRET")
    qr_data = f'{{"ip": "{ip}:8000", "secret": "{secret}"}}'
    qr_img = qrcode.make(qr_data)
    qr = qrcode.QRCode()
    qr.add_data(qr_data)
    qr.make(fit=True)

    web_pin = os.getenv("PETTRACK_WEB_PIN")
    if not web_pin:
        web_pin = f"{random.randint(1000, 9999):04d}"
        set_key(".env", "PETTRACK_WEB_PIN", web_pin)
        os.environ["PETTRACK_WEB_PIN"] = web_pin

    print("\n" + "="*55)
    print("SCAN THIS QR CODE WITH PETTRACK CLIENT!")
    print("="*55)
    qr.print_ascii(invert=True)
    print("="*55)
    print("OR ENTER THESE DETAILS MANUALLY:")
    print(f"Server IP: {ip}:8000")
    print(f"Secret Token: {secret}")
    print("="*55)
    print(f"WEB DASHBOARD PIN: {web_pin}")
    print("="*55 + "\n")

from fastapi.staticfiles import StaticFiles

# Serve the static files from the React build
if os.path.exists("static"):
    app.mount("/", StaticFiles(directory="static", html=True), name="static")
else:
    @app.get("/")
    def read_root():
        return {"message": "PetTrack server is running (Web Dashboard not built)"}

@app.websocket("/ws")
async def tracker_websocket(websocket: WebSocket, token: str = None, client_id: str = "unknown"):
    if token != SECRET_TOKEN:
        print(f"Connection rejected: Invalid Token '{token}'", flush=True)
        await websocket.close(code=1008)
        return

    monitor_id = client_id
    await manager.connect(websocket)
    monitor_state["online"] = True
    monitor_state["frame_count"] = 0
    monitor_state["id"] = monitor_id
    print(f"Monitor {monitor_id} connected!", flush=True)

    try:
        while True:
            data = await websocket.receive_bytes()
            monitor_state["frame_count"] += 1
            update_latest_frame(data)

            encrypted_data = fernet.encrypt(data)
            asyncio.create_task(client_manager.broadcast_bytes(encrypted_data))
            
            if monitor_state["frame_count"] % 10 == 0:
                print(f"Received frame #{monitor_state['frame_count']} from {monitor_id}: {len(data)} bytes", flush=True)

            if monitor_state["frame_count"] % 30 == 0:
                asyncio.create_task(process_and_save_frame(data))

    except WebSocketDisconnect:
        manager.disconnect(websocket)
        monitor_state["online"] = False
        print(f"Monitor {monitor_id} disconnected normally.", flush=True)
    except Exception as e:
        manager.disconnect(websocket)
        monitor_state["online"] = False
        print(f"Error: {e}", flush=True)

@app.websocket("/ws/client")
async def client_websocket(websocket: WebSocket, token: str = None):
    if not token:
        await websocket.close(code=1008)
        return
    if token != SECRET_TOKEN:
        try:
            jwt.decode(token, SECRET_TOKEN, algorithms=["HS256"])
        except Exception:
            await websocket.close(code=1008)
            return
    await client_manager.connect(websocket)
    asyncio.create_task(manager.broadcast_text(json.dumps({"action": "set_fps", "fps": 5})))
    try:
        while True:
            await websocket.receive()
    except Exception:
        client_manager.disconnect(websocket)
        if len(client_manager.active.connections) == 0:
            asyncio.create_task(manager.broadcast_text(json.dumps({"action": "set_fps", "fps": 0.5})))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the PetTrack Server")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging")
    args = parser.parse_args()

    log_level = "debug" if args.verbose else "info"

    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level=log_level)