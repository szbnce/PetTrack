# Stage 1: Build the React Web Dashboard
FROM node:22-alpine AS frontend-builder

WORKDIR /app/web
COPY pettrack_web/package*.json ./
RUN npm install

COPY pettrack_web/ ./
RUN npm run build

# Stage 2: Build the FastAPI Backend
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/*

COPY pettrack_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY pettrack_server/ .

# Copy the built React app from the frontend builder
COPY --from=frontend-builder /app/web/dist ./static

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
