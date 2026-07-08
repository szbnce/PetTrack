from pydantic import BaseModel
from typing import List

class Point(BaseModel):
    x: float
    y: float

class ZoneConfig(BaseModel):
    name: str
    polygon: List[Point]
    type: str = "safe"

class MonitorUpdate(BaseModel):
    battery_level: int
    is_charging: bool

class PetProfile(BaseModel):
    name: str
    type: str
    profile_pic: str | None = None

class LoginRequest(BaseModel):
    secret: str