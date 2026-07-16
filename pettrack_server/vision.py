import cv2
import numpy as np
import time
import os
from api_routes import active_zones
from database import log_event

os.makedirs("captured_images", exist_ok=True)

_last_zones: set = set()
_last_pet_center = None

_bg_subtractor = cv2.createBackgroundSubtractorMOG2(history=500, varThreshold=50, detectShadows=False)

async def process_and_save_frame(image_bytes: bytes):
    global _last_zones, _last_pet_center

    timestamp = int(time.time())
    file_path = f"captured_images/frame_{timestamp}.png"

    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        print("Failed to decode image", flush=True)
        return
    
    height, width = img.shape[:2]

    small_img = cv2.resize(img, (320, 240))
    gray = cv2.cvtColor(small_img, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (21, 21), 0)

    fg_mask = _bg_subtractor.apply(gray)

    thresh = cv2.threshold(fg_mask, 25, 255, cv2.THRESH_BINARY)[1]
    thresh = cv2.dilate(thresh, None, iterations=2)

    contours, _ = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    current_pet_center = None
    largest_area = 0

    for contour in contours:
        area = cv2.contourArea(contour)
        if area > 300 and area > largest_area:
            largest_area = area
            (x, y, w, h) = cv2.boundingRect(contour)

            scale_x = width / 320
            scale_y = height / 240
            cx = int((x + w / 2) * scale_x)
            cy = int((y + h / 2) * scale_y)
            current_pet_center = (cx, cy)
    
    if current_pet_center is not None:
        _last_pet_center = current_pet_center
    
    current_zones = set()

    if _last_pet_center is not None:
        for zone_name, polygon_points in active_zones.items():
            pts = np.array([[int(p["x"] * width), int(p["y"] * height)] for p in polygon_points], np.int32)
            pts = pts.reshape((-1, 1, 2))

            is_inside = cv2.pointPolygonTest(pts, _last_pet_center, measureDist=False)

            if is_inside >= 0:
                current_zones.add(zone_name)
    
    if len(current_zones) > 0 and current_pet_center is not None:
        with open(file_path, "wb") as f:
            f.write(image_bytes)
    
    entered = current_zones - _last_zones
    for zone in entered:
        print(f"Event: MOVEMENT DETECTED IN ZONE {zone}", flush=True)
        await log_event("zone_enter", zone_name=zone)

    exited = _last_zones - current_zones
    for zone in exited:
        print(f"Event: LEFT ZONE {zone}", flush=True)
        await log_event("zone_exit", zone_name=zone)

    _last_zones = current_zones
