#!/bin/bash
echo "======================================"
echo "      PetTrack Runner (Linux/Mac)     "
echo "======================================"


if [ ! -d "pettrack_server/static" ]; then
    echo "[1/2] Building Web Dashboard..."
    cd pettrack_web
    npm install
    npm run build
    cp -r dist ../pettrack_server/static
    cd ..
fi

echo "[2/2] Setting up and Starting PetTrack server..."
cd pettrack_server
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt

echo "======================================"
echo "PetTrack is now running natively!"
echo "======================================"

python3 main.py