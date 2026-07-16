from fastapi import WebSocket
from typing import List
from types import SimpleNamespace

class ConnectionManager:
    def __init__(self):
        self.active = SimpleNamespace()
        self.active.connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active.connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active.connections:
            self.active.connections.remove(websocket)

    async def broadcast_bytes(self, data: bytes):
        disconnected = []
        for connection in self.active.connections:
            try:
                await connection.send_bytes(data)
            except Exception:
                disconnected.append(connection)
        for d in disconnected:
            self.disconnect(d)

    async def broadcast_text(self, text: str):
        disconnected = []
        for connection in self.active.connections:
            try:
                await connection.send_text(text)
            except Exception:
                disconnected.append(connection)
        for d in disconnected:
            self.disconnect(d)

manager = ConnectionManager()
client_manager = ConnectionManager()