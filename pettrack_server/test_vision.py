import cv2
import numpy as np

# Create a dummy image
img = np.zeros((1080, 1920, 3), dtype=np.uint8)
cv2.rectangle(img, (500, 500), (600, 600), (255, 255, 255), -1)
gray = cv2.cvtColor(cv2.resize(img, (320, 240)), cv2.COLOR_BGR2GRAY)
bg = cv2.createBackgroundSubtractorMOG2(history=500, varThreshold=50, detectShadows=False)

# apply blank then apply shape to simulate motion
bg.apply(np.zeros((240, 320), dtype=np.uint8))
fg_mask = bg.apply(gray)

thresh = cv2.threshold(fg_mask, 25, 255, cv2.THRESH_BINARY)[1]
thresh = cv2.dilate(thresh, None, iterations=2)
contours, _ = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

print("Contours:", len(contours))
largest_area = 0
pet_center = None
for contour in contours:
    area = cv2.contourArea(contour)
    if area > 100:
        largest_area = area
        (x, y, w, h) = cv2.boundingRect(contour)
        cx = int((x + w / 2) * (1920 / 320))
        cy = int((y + h / 2) * (1080 / 240))
        pet_center = (cx, cy)

print("Pet center:", pet_center)
if pet_center:
    pts = np.array([[0, 0], [1920, 0], [1920, 1080], [0, 1080]], np.int32).reshape((-1, 1, 2))
    # Test point polygon test with float and int
    print("Inside int:", cv2.pointPolygonTest(pts, pet_center, False))
    print("Inside float:", cv2.pointPolygonTest(pts, (float(pet_center[0]), float(pet_center[1])), False))
