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
        for connection in self.active.connections:
            await connection.send_bytes(data)

    async def broadcast_text(self, text: str):
        for connection in self.active.connections:
            await connection.send_text(text)

manager = ConnectionManager()
client_manager = ConnectionManager()