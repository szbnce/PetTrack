# PetTrack

**Turn your dusty old phone into a lightweight surveillance system for your small pets.**

---

## Current Status: MVP

This project just started out, there isn't a magical all-in-one working app *yet*. Development is broken into these phases:

* **1: The Monitor (HW/Data Collection):** Currently working on this part. The goal is to get the old phone's camera reliably to the server.
* **2: The Backend (The brain):** Once the data is being sent reliably, we use server-side logic to process it. This will be shoved into a Docker container.
* **3: The Frontend (The Client):** This will be the last part. This will be the shiny UI that will be used daily to see what the furballs are up to.

---

## The Shiny Visuals
*(Note: This will be replaced with actual screenshots when the project gets to that point.)

![PetTrack Dashboard Placeholder](https://placehold.co/800x400.png?text=Imagine+a+beautiful+dashboard+here)

---

## Installation

### Prerequisites
* A machine running **Docker** and **Docker Compose**
* An old Android Phone (The "Monitor")
* Your main phone (The "Client")

### Get it running from scratch

```bash
# 1. Clone this chaotic repo
git clone https://github.com/szbnce/PetTrack.git

# 2. Navigate into the repo
cd PetTrack

# 3. Copy the example environment variables (DO NOT SKIP!)
cp .env.example .env

# 4. Fire up the backend server
docker-compose up -d