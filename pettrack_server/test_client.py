import asyncio
import websockets

async def test_ws():
    uri = "ws://127.0.0.1:8001/ws?token=MYSUPERSECRETTOKEN"
    async with websockets.connect(uri) as websocket:
        print("Client Connected!")
        for i in range(5):
            await websocket.send(b"fake_image_data")
            await asyncio.sleep(0.01)

asyncio.run(test_ws())
