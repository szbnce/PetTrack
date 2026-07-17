#!/bin/bash
echo "======================================"
echo "   PetTrack Installer (Linux/Ubuntu)  "
echo "======================================"

if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y python3 python3-venv python3-pip nodejs npm
elif command -v dnf &> /dev/null; then
    sudo dnf install -y python3 python3-pip nodejs
elif command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm python python-pip nodejs npm
else
    echo "Could not detect package manager. Please install Python 3 and Node.js manually."
    exit 1
fi

echo "Installation finished! You can now run ./run_linux_and_macos.sh"