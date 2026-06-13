from fastapi import APIRouter
from typing import List, Dict
from schemas import ZoneConfig, Point

router = APIRouter()

active_zones: Dict[str, List[Point]] = {}

@router.post("/api/zones")
async def update_zones(zones: List[ZoneConfig]):
    global active_zones
    active_zones.clear()
    for z in zones:
        active_zones[z.name] = z.polygon
    return {"message": "Zones updated successfully!"}

