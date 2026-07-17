@echo off
echo ======================================
echo       PetTrack Runner (Windows)
echo ======================================

where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Python is not installed. Please run install_windows.bat first.
    exit /b 1
)

where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Node.js (npm) is not installed. Please run install_windows.bat first.
    exit /b 1
)

echo [1/3] Setting up Python backend...
cd pettrack_server
if not exist venv (
    python -m venv venv
)
call venv\Scripts\activate.bat
pip install -r requirements.txt

echo [2/3] Starting backend server...
start "PetTrack Backend" cmd /c "python main.py"
cd ..

echo [3/3] Setting up and starting frontend...
cd pettrack_web
call npm install
call npm run build
echo Starting frontend in a new window....
start "PetTrack Frontend" cmd /k "npm run preview -- --host"

echo ======================================
echo PetTrack is now running natively!
echo Backend: http://localhost:8000
echo Frontend: http://localhost:4173 (or your local IP)
echo Close the two new windows to stop the servers.
echo ======================================
pause
