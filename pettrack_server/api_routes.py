import os
import glob
from fastapi import APIRouter, Depends, HTTPException, Query, Header, Response, Request
from fastapi.responses import FileResponse
from typing import List, Dict
import time
import asyncio
from database import get_events, get_zones, save_zones, get_pet, save_pet, get_medical_data, save_medical_data
from schemas import ZoneConfig, Point, MonitorUpdate, LoginRequest, PetProfile, MedicalDataSync
from email.utils import formatdate
import jwt
from cryptography.fernet import Fernet
import base64
import hashlib
import secrets
from dotenv import load_dotenv, set_key
from pydantic import BaseModel
from manager import client_manager

load_dotenv()

SECRET_TOKEN = os.getenv("PETTRACK_SECRET")
if not SECRET_TOKEN:
    print("No secret found! Generating a new ultra-secure 64-char token...")
    new_secret = secrets.token_urlsafe(48)
    set_key(".env", "PETTRACK_SECRET", new_secret)
    SECRET_TOKEN = new_secret

def get_fernet_key(secret: str) -> bytes:
    digest = hashlib.sha256(secret.encode()).digest()
    return base64.urlsafe_b64encode(digest)

fernet = Fernet(get_fernet_key(SECRET_TOKEN))

async def verify_token(token: str = Query(None), x_api_token: str = Header(None)):
    req_token = token or x_api_token
    if not req_token:
        raise HTTPException(status_code=401, detail="Token missing")

    try:
        payload = jwt.decode(req_token, SECRET_TOKEN, algorithms=["HS256"])
    except jwt.PyJWTError:
        if req_token != SECRET_TOKEN:
            raise HTTPException(status_code=401, detail="Invalid token")

router = APIRouter(dependencies=[Depends(verify_token)])
auth_router = APIRouter()

monitor_state = {
    "online": False,
    "frame_count": 0,
}
active_zones: Dict[str, List[Point]] = {}

latest_frame_info = {
    "data": None,
    "timestamp": 0.0,
}

def update_latest_frame(data: bytes):
    latest_frame_info["data"] = data
    latest_frame_info["timestamp"] = time.time()

class PinRequest(BaseModel):
    pin: str


@router.get("/api/status")
async def get_status():
    is_online = monitor_state.get("online", False)
    if is_online and time.time() - monitor_state.get("last_seen", time.time()) > 5:
        monitor_state["online"] = False
        is_online = False
        
    return {
        "monitor_online": is_online,
        "frame_count": monitor_state.get("frame_count", 0),
        "monitor_id": monitor_state.get("id", "unnamed_monitor"),
        "battery_level": monitor_state.get("battery_level", 100),
        "is_charging": monitor_state.get("is_charging", False),
    }

@router.post("/api/frame/web")
async def receive_web_frame(request: Request, token: str = ""):
    if token != SECRET_TOKEN:
        return {"error": "Invalid token"}
    data = await request.body()
    update_latest_frame(data)
    
    # Broadcast to WebSocket clients
    encrypted_data = fernet.encrypt(data)
    asyncio.create_task(client_manager.broadcast_bytes(encrypted_data))

    monitor_state["online"] = True
    monitor_state["last_seen"] = time.time()
    monitor_state["frame_count"] = monitor_state.get("frame_count", 0) + 1
    
    # Run vision every 30 frames
    if monitor_state["frame_count"] % 30 == 0:
        from vision import process_and_save_frame
        asyncio.create_task(process_and_save_frame(data))
        
    return {"status": "ok"}

@auth_router.post("/api/auth/login")
async def login(req: LoginRequest):
    if req.secret != SECRET_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid secret")
    
    encoded_jwt = jwt.encode({"auth": "ok", "exp": time.time() + 86400 * 3650}, SECRET_TOKEN, algorithm="HS256")
    return {"token": encoded_jwt}

@auth_router.post("/api/auth/set_pin")
async def set_pin(req: PinRequest, x_api_token: str = Header(None)):
    try:
        jwt.decode(x_api_token, SECRET_TOKEN, algorithms=["HS256"])
    except:
        raise HTTPException(status_code=401, detail="Unauthorized to set PIN")

    set_key(".env", "PETTRACK_WEB_PIN", req.pin)
    os.environ["PETTRACK_WEB_PIN"] = req.pin
    return {"status": "success"}
    
@auth_router.post("/api/auth/login_pin")
async def login_pin(req: PinRequest):
    if req.pin != os.getenv("PETTRACK_WEB_PIN"):
        raise HTTPException(status_code=401, detail="Invalid PIN")
    return {"secret": SECRET_TOKEN}


@router.get("/api/pet")
async def get_pet_profile():
    pet = await get_pet()
    return pet if pet else {"name": "Unknown", "type": "Unknown", "profile_pic": None}

@router.post("/api/pet")
async def update_pet_profile(pet: PetProfile):
    await save_pet(pet.name, pet.type, pet.profile_pic)
    return {"status": "ok"}

@router.post("/api/monitor/update")
async def update_monitor_status(update: MonitorUpdate):
    monitor_state["battery_level"] = update.battery_level
    monitor_state["is_charging"] = update.is_charging
    return {"status": "ok"}

@router.get("/api/activity")
async def get_activity(limit: int = 50):
    events = await get_events(limit)
    return {"events": events}

@router.get("/api/zones")
async def get_zones_list():
    zones = await get_zones()
    return {"zones": zones}

@router.post("/api/zones")
async def update_zones(zones: List[ZoneConfig]):
    print(f"DEBUG INCOMING ZONES: {zones}", flush=True)
    global active_zones
    active_zones.clear()
    for z in zones:
        active_zones[z.name] = [{"x": p.x, "y": p.y} for p in z.polygon]
    await save_zones(zones)
    return {"message": "Zones updated successfully!"}

@router.get("/api/medical")
async def get_medical_route(token: str = None):
    data = await get_medical_data()
    return data

@router.post("/api/medical")
async def update_medical_route(data: MedicalDataSync, token: str = None):
    await save_medical_data(data.medications, data.vaccines)
    return {"status": "ok"}

@router.get("/api/frame/latest")
async def get_latest_frame():
    if latest_frame_info["data"]:
        headers = {
            "Last-Modified": formatdate(latest_frame_info["timestamp"], usegmt=True)
        }
        encrypted_data = fernet.encrypt(latest_frame_info["data"])
        return Response(content=encrypted_data, media_type="application/octet-stream", headers=headers)
    
    folder = "captured_images"
    if not os.path.exists(folder):
        return {"error": "No images found"}

    files = glob.glob(os.path.join(folder, "*.png"))
    if not files:
        return {"error": "No images found"}

    latest = max(files, key=os.path.getmtime)
    with open(latest, "rb") as f:
        img_data = f.read()
    encrypted_data = fernet.encrypt(img_data)
    headers = {
        "Last-Modified": formatdate(os.path.getmtime(latest), usegmt=True)
    }
    return Response(content=encrypted_data, media_type="application/octet-stream", headers=headers)


@router.get("/api/frame/web")
async def get_web_frame():
    if latest_frame_info["data"]:
        headers = {
            "Last-Modified": formatdate(latest_frame_info["timestamp"], usegmt=True)
        }
        return Response(content=latest_frame_info["data"], media_type="image/jpeg", headers=headers)

    folder = "captured_images"
    if not os.path.exists(folder):
        return {"error": "No images found"}
        
    files = glob.glob(os.path.join(folder, "*.png"))
    if not files:
        return {"error": "No images found"}
    
    latest = max(files, key=os.path.getmtime)
    with open(latest, "rb") as f:
        img_data = f.read()
    headers = {
        "Last-Modified": formatdate(os.path.getmtime(latest), usegmt=True)
    }
    return Response(content=img_data, media_type="image/jpeg", headers=headers)