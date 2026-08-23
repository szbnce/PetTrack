import os
import time
import asyncio

async def cleanup_old_images():
    folder_path = "captured_images"

    while True:
        if os.path.exists(folder_path):
            try:
                files = []
                for filename in os.listdir(folder_path):
                    file_path = os.path.join(folder_path, filename)
                    if os.path.isfile(file_path):
                        files.append((file_path, os.path.getmtime(file_path)))

                files.sort(key=lambda x: x[1])

                current_time = time.time()
                cutoff_time = current_time - (12 * 60 * 60)

                for file_path, mtime in files[:]:
                    if mtime < cutoff_time:
                        os.remove(file_path)
                        files.remove((file_path, mtime))

                max_files = 500
                if len(files) > max_files:
                    for file_path, _ in files[:len(files) - max_files]:
                        os.remove(file_path)
            except Exception as e:
                print(f"Error in image cleanup task: {e}")
        
        # Cleanup replays
        replays_path = "replays"
        if os.path.exists(replays_path):
            try:
                files = []
                for filename in os.listdir(replays_path):
                    if filename.endswith(".mp4"):
                        file_path = os.path.join(replays_path, filename)
                        files.append((file_path, os.path.getmtime(file_path)))
                
                files.sort(key=lambda x: x[1])
                current_time = time.time()
                # Keep replays for 24 hours
                cutoff_time = current_time - (24 * 60 * 60)
                
                for file_path, mtime in files[:]:
                    if mtime < cutoff_time:
                        os.remove(file_path)
                        files.remove((file_path, mtime))
                
                max_replays = 100
                if len(files) > max_replays:
                    for file_path, _ in files[:len(files) - max_replays]:
                        os.remove(file_path)
            except Exception as e:
                print(f"Error in replay cleanup task: {e}")

        await asyncio.sleep(600)

        