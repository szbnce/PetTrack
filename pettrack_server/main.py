import argparse
import uvicorn
import os
import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect

from manager import manager
from api_routes import router as zones_router
from tasks import cleanup_old_images
from vision import process_and_save_frame

app = FastAPI()

app.include_router(zones_router)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(cleanup_old_images())

SECRET_TOKEN = os.getenv("PETTRACK_SECRET", "MYSUPERSECRETTOKEN")

@app.get("/")
def read_root():
    return {"message": "PetTrack server is running"}

@app.websocket("/ws")
async def tracker_websocket(websocket: WebSocket, token: str = None):
    if token != SECRET_TOKEN:
        print(f"Connection rejected: Invalid token '{token}'")
        await websocket.close(code=1008)
        return
    
    monitor_id = "flutter_client"
    await manager.connect(websocket)
    print(f"Monitor {monitor_id} connected!", flush=True)

    frame_counter = 0

    try:
        while True:
            data = await websocket.receive_bytes()
            frame_counter += 1
            if frame_counter % 10 == 0:
                print(f"Received camera frame from {monitor_id}: {len(data)} bytes", flush=True)

            if frame_counter % 30 == 0:
                asyncio.create_task(process_and_save_frame(data))
    
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        print(f"Monitor {monitor_id} disconnected normally.", flush=True)
    except Exception as e:
        manager.disconnect(websocket)
        print(f"Error: {e}", flush=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the PetTrack server")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging")
    args = parser.parse_args()

    log_level = "debug" if args.verbose else "info"

    if args.verbose:
        print("Verbose logging enabled, setting uvicorn log level to 'debug'.")

    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level=log_level, reload=True)