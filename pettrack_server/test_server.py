import asyncio
import sys
from fastapi import FastAPI, WebSocket
import uvicorn
from types import SimpleNamespace

app = FastAPI()

class ConnectionManager:
    def __init__(self):
        self.active = SimpleNamespace()
        self.active.connections = []
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active.connections.append(websocket)

manager = ConnectionManager()

@app.websocket("/ws")
async def tracker_websocket(websocket: WebSocket, token: str = None):
    await manager.connect(websocket)
    print("Connected")
    sys.stdout.flush()
    try:
        while True:
            data = await websocket.receive_bytes()
            print("Got bytes:", len(data))
            sys.stdout.flush()
    except Exception as e:
        print("Error:", e)
        sys.stdout.flush()

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8001)
