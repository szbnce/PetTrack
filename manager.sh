#!/bin/bash

# PetTrack Manager Script

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}        PetTrack Project Manager        ${NC}"
echo -e "${CYAN}========================================${NC}"

build_web() {
    echo -e "${YELLOW}Building Web (Static)...${NC}"
    cd pettrack_app || exit
    flutter build web --release
    echo -e "${YELLOW}Deploying to backend...${NC}"
    rm -rf ../pettrack_server/static
    cp -r build/web ../pettrack_server/static
    cd ..
    echo -e "${GREEN}Web Build Complete!${NC}"
}

build_android() {
    echo -e "${YELLOW}Building Android (APK)...${NC}"
    cd pettrack_app || exit
    flutter build apk --release
    cp build/app/outputs/flutter-apk/app-release.apk ../PetTrack.apk
    cd ..
    echo -e "${GREEN}Android Build Complete! (PetTrack.apk)${NC}"
}

build_ios() {
    echo -e "${YELLOW}Building iOS (Unsigned IPA)...${NC}"
    cd pettrack_app || exit
    flutter build ios --release --no-codesign
    echo -e "${YELLOW}Packaging IPA...${NC}"
    mkdir -p build/ios/Payload
    cp -r build/ios/iphoneos/Runner.app build/ios/Payload/
    zip -qr ../PetTrack.ipa build/ios/Payload
    rm -rf build/ios/Payload
    cd ..
    echo -e "${GREEN}iOS Build Complete! (PetTrack.ipa)${NC}"
}

install_android() {
    echo -e "${YELLOW}Installing to connected Android device...${NC}"
    if [ ! -f "PetTrack.apk" ]; then
        echo -e "${RED}Error: PetTrack.apk not found. Build it first!${NC}"
        return
    fi
    adb install -r PetTrack.apk
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Android Installation Complete!${NC}"
    else
        echo -e "${RED}Android Installation Failed! (Is USB debugging enabled?)${NC}"
    fi
}

install_ios() {
    echo -e "${YELLOW}Opening Sideloadly for iOS Installation...${NC}"
    if [ ! -f "PetTrack.ipa" ]; then
        echo -e "${RED}Error: PetTrack.ipa not found. Build it first!${NC}"
        return
    fi
    open -a Sideloadly PetTrack.ipa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Sideloadly opened! Follow the instructions there.${NC}"
    else
        echo -e "${RED}Error: Could not open Sideloadly. Is it installed?${NC}"
    fi
}

show_menu() {
    echo ""
    echo "1) Build Web"
    echo "2) Build Android (APK)"
    echo "3) Build iOS (IPA)"
    echo "4) Build EVERYTHING (Web + Android + iOS)"
    echo "5) Install Android via ADB"
    echo "6) Install iOS via Sideloadly"
    echo "7) Exit"
    echo ""
    read -p "Select an option [1-7]: " choice

    case $choice in
        1) build_web; show_menu ;;
        2) build_android; show_menu ;;
        3) build_ios; show_menu ;;
        4) build_web; build_android; build_ios; show_menu ;;
        5) install_android; show_menu ;;
        6) install_ios; show_menu ;;
        7) echo -e "${CYAN}Bye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; show_menu ;;
    esac
}

show_menu
