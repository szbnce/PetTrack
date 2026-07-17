#!/bin/bash
echo "======================================"
echo "      PetTrack Runner (Linux/Mac)     "
echo "======================================"

# Check dependencies
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please run the install script first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "Node.js (npm) is not installed. Please run the install script first."
    exit 1
fi

echo "[1/3] Setting up Python backend..."
cd pettrack_server
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt

echo "[2/3] Starting backend server..."
python3 main.py &
BACKEND_PID=$!
cd ..

echo "[3/3] Setting up and starting frontend..."
cd pettrack_web
npm install
npm run build
npm run preview -- --host &
FRONTEND_PID=$!

echo "======================================"
echo "PetTrack is now running natively!"
echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:4173 (or your local IP)"
echo "Press Ctrl+C to stop all processes."
echo "======================================"

trap "kill $BACKEND_PID $FRONTEND_PID" EXIT
wait