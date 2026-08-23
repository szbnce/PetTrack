#!/bin/bash
echo "======================================"
echo "       PetTrack Installer (macOS)     "
echo "======================================"

if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing Python and Node.js..."
brew install python node

echo "Installation finished! You can now run ./run_linux_and_macos.sh"