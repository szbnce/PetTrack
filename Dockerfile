FROM python:3.12-slim

WORKDIR /app

# Install system dependencies for OpenCV and other packages
RUN apt-get update && apt-get install -y libgl1 libglib2.0-0 ffmpeg && rm -rf /var/lib/apt/lists/*

COPY pettrack_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire server directory (this includes the already compiled Flutter web app in 'static/')
COPY pettrack_server/ .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
