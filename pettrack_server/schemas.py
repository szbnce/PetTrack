from pydantic import BaseModel
from typing import List

class Point(BaseModel):
    x: float
    y: float

class ZoneConfig(BaseModel):
    name: str
    polygon: List[Point]

class MonitorUpdate(BaseModel):
    battery_level: int
    is_charging: bool