# pyrefly: ignore [missing-import]
import aiosqlite
import json
import time

DB_PATH = "pettrack.db"

async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
        CREATE TABLE IF NOT EXISTS events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp REAL NOT NULL,
            event_type TEXT NOT NULL,
            zone_name TEXT,
            details TEXT
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS zones (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                polygon TEXT NOT NULL
                )
        """)
        await db.commit()
        print("Database initialized!", flush=True)

async def log_event(event_type: str, zone_name: str = None, details: str = None):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT INTO events (timestamp, event_type, zone_name, details) VALUES (?, ?, ?, ?)",
            (time.time(), event_type, zone_name, details)
        )
        await db.commit()

async def get_events(limit: int = 50):
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute(
            "SELECT * FROM events ORDER BY timestamp DESC LIMIT ?",
            (limit,)
        )
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]

async def save_zones(zones_data):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("DELETE FROM zones")
        for zone in zones_data:
            polygon_json = json.dumps([{"x": p.x, "y": p.y} for p in zone.polygon])
            await db.execute(
                "INSERT INTO zones (name, polygon) VALUES (?, ?)",
                (zone.name, polygon_json)
            )
        await db.commit()

async def get_zones():
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute("SELECT * FROM zones")
        rows = await cursor.fetchall()
        return [{"name": row["name"],"polygon": json.loads(row["polygon"])} for row in rows]