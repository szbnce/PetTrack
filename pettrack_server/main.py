import argparse
import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List

app = FastAPI()

class ConnectionManager:
    def __init__(self):
        # Store active websocket connections
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast_bytes(self, data: bytes):
        """Sends binary data (like a camera frame) to all connected clients."""
        for connection in self.active_connections:
            await connection.send_bytes(data)

manager = ConnectionManager()

@app.get("/")
def read_root():
    return {"message": "PetTrack server is running"}

@app.websocket("/ws")
async def tracker_websocket(websocket: WebSocket):
    monitor_id = "flutter_client"
    await manager.connect(websocket)
    print(f"Monitor {monitor_id} connected!")

    try:
        while True:
            data = await websocket.receive_bytes()
            print(f'Received camera frame from {monitor_id}: {len(data)} bytes')            
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        print(f"Monitor {monitor_id} disconnected normally.")
    except Exception as e:
        manager.disconnect(websocket)
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the PetTrack server")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging")
    args = parser.parse_args()

    log_level = "debug" if args.verbose else "info"
    
    if args.verbose:
        print("Verbose logging enabled. Setting uvicorn log level to 'debug'.")
        
uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level=log_level, reload=True)