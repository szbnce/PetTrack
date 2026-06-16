# PetTrack

**Turn your dusty old phone into a lightweight surveillance system for your small pets.**

---

## Current Status: MVP

This project just started out, there isn't a magical all-in-one working app *yet*. Development is broken into these phases:

* **1: The Monitor (HW/Data Collection):** Finished/Working state. The goal is to get the old phone's camera reliably to the server.
* **2: The Backend (The brain):** MVP in progress. Once the data is being sent reliably, we use server-side logic to process it. This will be shoved into a Docker container.
* **3: The Frontend (The Client):** MVP in progress. This will be the last part. This will be the shiny UI that will be used daily to see what the furballs are up to.

---

## The Shiny Visuals
*(Note: This will be replaced with actual screenshots when the project gets to that point.)

![PetTrack Dashboard Placeholder](https://placehold.co/800x400.png?text=Imagine+a+beautiful+dashboard+here)

---

## Installation

### Prerequisites
* A machine running **Docker** and **Docker Compose**
* An old Android Phone (The "Monitor") (Minimal API requirement is 24, Android 7+)
* Your main phone (The "Client")

### Get it running from scratch

First off, before anything, you need to clone this repository.

```bash
git clone https://github.com/szbnce/PetTrack.git
```

1: Compiling the monitor app
```bash
# 1. Install Flutter & Android Studio & Docker
# Follow the official guide for your OS: https://docs.flutter.dev/get-started/install
# Run `flutter doctor` to ensure everything is set up correctly.

# 1. Navigate into the Monitor app folder
cd PetTrack/pettrack_monitor

# 2. Install dependencies
flutter pub get

# 3. Compile the Android App (APK)
flutter build apk

# The compiled APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk
```

2: Compiling the backend
```bash
# 1: Go into the backend folder
cd PetTrack/pettrack_server

# 2: Copy the environment file (fill it with your own database credentials)
cp .env.example .env

# Run the backend
docker-compose up --build -d
```

3: Compiling the frontend app
```bash
# 1: Navigate into the client (frontend) folder
cd PetTrack/pettrack_client

# 2: Install dependencies
flutter pub get

# 3: Compile the Android App (APK)
flutter build apk

# The compiled APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Credits
Bence Szabó (szbnce)
