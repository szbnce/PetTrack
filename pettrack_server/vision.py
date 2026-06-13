import cv2
import numpy as np
import time
import os
from api_routes import active_zones

os.makedirs("captured_images", exist_ok=True)

async def process_and_save_frame(image_bytes: bytes):
    timestamp = int(time.time())
    file_path = f"captured_images/frame_{timestamp}.jpg"

    with open(file_path, "wb") as f:
        f.write(image_bytes)

    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        print("Failed to decode image")
        return

    height, width, _ = img.shape[:2]
    cx, cy = int(width / 2), int(height / 2)
    pet_center = (cx, cy)

    for zone_name, polygon_points in active_zones.items():
        pts = np.array([[p.x, p.y] for p in polygon_points], np.int32)
        pts = pts.reshape((-1, 1, 2))

        is_inside = cv2.pointPolygonTest(pts, pet_center, mesureDist=False)

        if is_inside >= 0:
            print(f"Activity Detected: Pet is in the {zone_name}.")
            