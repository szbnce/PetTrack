@echo off
echo ======================================
echo       PetTrack Runner (Windows)
echo ======================================

if not exist pettrack_server\static (
    echo [1/2] Building Web Dashboard...
    cd pettrack_web
    call npm install
    call npm run build
    xcopy /E /I dist ..\pettrack_server\static
    cd ..
)

echo [2/2] Setting up and Staring PetTrack server...
cd pettrack_server
if not exist venv (
    python -m venv venv
)
call venv\Scripts\activate.bat
pip install -r requirements.txt


echo ======================================
echo PetTrack is now running natively!
echo ======================================

python main.py
pause
