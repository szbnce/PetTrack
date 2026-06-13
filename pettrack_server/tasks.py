import os
import time
import asyncio

async def cleanup_old_images():
    folder_path = "captured_frames"

    while True:
        if os.path.exists(folder_path):
            current_time = time.time()

            cutoff_time = current_time - (12 * 60 * 60)

            for filename in os.listdir(folder_path):
                file_path = os.path.join(folder_path, filename)

                if os.path.getmtime(file_path) < cutoff_time:
                    try:
                        os.remove(file_path)
                        print(f"Deleted old image: {filename}")
                    except Exception as e:
                        print(f"Error deleting file {filename}: {e}")
        await asyncio.sleep(600)

        