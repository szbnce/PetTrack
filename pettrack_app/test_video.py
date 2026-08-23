import cv2
import numpy as np

for codec, ext in [('mp4v', 'mp4'), ('avc1', 'mp4'), ('vp80', 'webm'), ('vp09', 'webm')]:
    try:
        fourcc = cv2.VideoWriter_fourcc(*codec)
        writer = cv2.VideoWriter(f"test.{ext}", fourcc, 5.0, (640, 480))
        if writer.isOpened():
            print(f"Codec {codec} works!")
            writer.write(np.zeros((480, 640, 3), dtype=np.uint8))
            writer.release()
        else:
            print(f"Codec {codec} failed to open.")
    except Exception as e:
        print(f"Codec {codec} error: {e}")
