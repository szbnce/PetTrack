import os
import glob
from fastapi import APIRouter, Depends, HTTPException, Query, Header
from fastapi.responses import FileResponse
from typing import List, Dict
from schemas import ZoneConfig, Point
from database import save_zones, get_zones, get_events

SECRET_TOKEN = os.getenv("PETTRACK_SECRET", "MYSUPERSECRETTOKEN")

async def verify_token(token: str = Query(None), x_api_token: str = Header(None)):
    req_token = token or x_api_token
    if req_token != SECRET_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid token")

router = APIRouter(dependencies=[Depends(verify_token)])

monitor_state = {
    "online": False,
    "frame_count": 0,
}
active_zones: Dict[str, List[Point]] = {}

@router.get("/api/status")
async def get_status():
    return {
        "monitor_online": monitor_state["online"],
        "frame_count": monitor_state["frame_count"],
    }

@router.get("/api/activity")
async def get_activity(limit: int = 50):
    events = await get_events(limit)
    return {"events": events}

@router.get("/api/zones")
async def get_zones_list():
    zones = await get_zones()
    return {"zones": zones}

@router.post("/api/zones")
async def update_zones(zones: List[ZoneConfig]):
    global active_zones
    active_zones.clear()
    for z in zones:
        active_zones[z.name] = [{"x": p.x, "y": p.y} for p in z.polygon]
    await save_zones(zones)
    return {"message": "Zones updated successfully!"}

@router.get("/api/frame/latest")
async def get_latest_frame():
    folder = "captured_images"
    if not os.path.exists(folder):
        return {"error": "No images found"}

    files = glob.glob(os.path.join(folder, "*.png"))
    if not files:
        return {"error": "No images found"}

    latest = max(files, key=os.path.getmtime)
    return FileResponse(latest, media_type="image/png")