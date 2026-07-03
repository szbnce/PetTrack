import argparse
import uvicorn
import os
import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect

from manager import manager
from api_routes import router as zones_router, monitor_state, active_zones
from tasks import cleanup_old_images
from vision import process_and_save_frame
from database import init_db, get_zones

app = FastAPI()

app.include_router(zones_router)

@app.on_event("startup")
async def startup_event():
    await init_db()
    
    # Load saved zones from database into memory
    zones = await get_zones()
    for z in zones:
        active_zones[z["name"]] = z["polygon"]
        
    asyncio.create_task(cleanup_old_images())

SECRET_TOKEN = os.getenv("PETTRACK_SECRET", "MYSUPERSECRETTOKEN")

@app.get("/")
def read_root():
    return {"message": "PetTrack server is running"}

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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the PetTrack Server")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging")
    args = parser.parse_args()

    log_level = "debug" if args.verbose else "info"

    if args.verbose:
        print("Verbose logging enabled, setting uvicorn log level to 'debug'.")

    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level=log_level, reload=True)