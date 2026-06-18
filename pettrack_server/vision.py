import cv2
import numpy as np
import time
import os
from api_routes import active_zones
from database import log_event

os.makedirs("captured_images", exist_ok=True)

_last_zones: set = set()

async def process_and_save_frame(image_bytes: bytes):
    global _last_zones

    timestamp = int(time.time())
    file_path = f"captured_images/frame_{timestamp}.png"

    with open(file_path, "wb") as f:
        f.write(image_bytes)

    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        print("Failed to decode image", flush=True)
        return

    height, width = img.shape[:2]
    cx, cy = int(width / 2), int(height / 2)
    pet_center = (cx, cy)

    current_zones = set()

    for zone_name, polygon_points in active_zones.items():
        pts = np.array([[p.x, p.y] for p in polygon_points], np.int32)
        pts = pts.reshape((-1, 1, 2))

        is_inside = cv2.pointPolygonTest(pts, pet_center, measureDist=False)

        if is_inside >=0:
            current_zones.add(zone_name)

    entered = current_zones - _last_zones
    for zone in entered:
        print(f"Event: PET ENTERED {zone}", flush=True)
        await log_event("zone_enter", zone_name=zone)

    exited = _last_zones - current_zones
    for zone in exited:
        print(f"Event: PET EXITED {zone}", flush=True)
        await log_event("zone_exit", zone_name=zone)

    _last_zones = current_zones