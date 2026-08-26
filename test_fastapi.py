from fastapi import FastAPI, Request
from fastapi.testclient import TestClient
import os
from fastapi.responses import StreamingResponse
import re

app = FastAPI()

with open("test_vid.mp4", "wb") as f:
    f.write(b"0123456789")

def range_requests_response(request: Request, file_path: str, content_type: str):
    file_size = os.stat(file_path).st_size
    range_header = request.headers.get("range")

    headers = {
        "content-type": content_type,
        "accept-ranges": "bytes",
        "content-encoding": "identity",
        "content-length": str(file_size),
        "access-control-expose-headers": (
            "content-type, accept-ranges, content-length, "
            "content-range, content-encoding"
        ),
    }
    start = 0
    end = file_size - 1
    status_code = 200

    if range_header is not None:
        range_match = re.match(r"bytes=(\d+)-(\d*)", range_header)
        if range_match:
            start = int(range_match.group(1))
            end = int(range_match.group(2)) if range_match.group(2) else file_size - 1
            
        size = end - start + 1
        headers["content-length"] = str(size)
        headers["content-range"] = f"bytes {start}-{end}/{file_size}"
        status_code = 206

    def send_bytes_range_requests(f_path: str, st: int, en: int):
        with open(f_path, mode="rb") as f:
            f.seek(st)
            pos = st
            while pos <= en:
                read_size = min(1024 * 1024, en - pos + 1)
                data = f.read(read_size)
                if not data:
                    break
                pos += len(data)
                yield data

    return StreamingResponse(
        send_bytes_range_requests(file_path, start, end),
        headers=headers,
        status_code=status_code,
    )

@app.get("/vid")
async def get_vid(request: Request):
    return range_requests_response(request, "test_vid.mp4", "video/mp4")

client = TestClient(app)
resp = client.get("/vid", headers={"Range": "bytes=0-"})
print(resp.status_code)
print(resp.headers)
print(resp.content)
