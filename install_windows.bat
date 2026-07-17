@echo off
echo ======================================
echo      PetTrack Installer (Windows)     
echo ======================================

echo This will use Windows Package Manager (winget) to install Python and Node.js.
winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
winget install -e --id OpenJS.NodeJS --accept-package-agreements --accept-source-agreements

echo ======================================
echo Installation finished! PLEASE RESTART your terminal/computer, then you can run run_windows.bat!
echo ======================================
pause