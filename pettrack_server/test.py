import os
import asyncio
import requests
import websockets
from dotenv import load_dotenv
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
import time
import uuid

load_dotenv()

API_URL = "http://127.0.0.1:8000/api"
WS_URL = "ws://127.0.0.1:8000/ws"

TOKEN = os.getenv("PETTRACK_SECRET")
HEADERS = {"x-api-token": TOKEN}

console = Console()

def test_rest_endpoints():
    table = Table(title="REST API TEST", show_header=True, header_style="bold magenta")
    table.add_column("Endpoint", style="cyan", width=30)
    table.add_column("Method", style="blue")
    table.add_column("Status", justify="right")
    table.add_column("Response", justify="right", style="yellow")
    table.add_column("Result", style="white")

    original_zones = []
    try:
        res = requests.get(f"{API_URL}/zones", headers=HEADERS)
        if res.status_code == 200:
            original_zones = res.json().get("zones", [])
    except Exception:
        pass

    endpoints = [
        ("GET", f"{API_URL}/status"),
        ("GET", f"{API_URL}/activity"),
        ("GET", f"{API_URL}/zones"),
        ("GET", f"{API_URL}/frame/latest"),
    ]

    for method, url in endpoints:
        start_time = time.time()
        try:
            res = requests.get(url, headers=HEADERS)

            elapsed = (time.time() - start_time) * 1000
            status_code = res.status_code

            if status_code in [200, 201]:
                status_color = f"[bold green]{status_code}[/bold green]"
                result = "OK"
            elif status_code == 404 and "frame/latest" in url:
                status_color = f"[bold yellow]{status_code}[/bold yellow]"
                result = "NO FRAMES"
            elif status_code == 401:
                status_color = f"[bold red]{status_code}[/bold red]"
                result = "UNAUTHORIZED/BAD TOKEN"
            else:
                status_color = f"[bold red]{status_code}[/bold red]"
                result = f"ERROR: {res.text[:20]}..."

            table.add_row(url.replace(API_URL, "/api"), method, status_color, f"{elapsed:.2f} ms", result)
        except Exception as e:
            table.add_row(url.replace(API_URL, "/api"), method, "[bold red]ERROR[/bold red]", "-", f"{str(e)}")

        #POST Zones TeST
        start_time = time.time()
        try:
            sample_zone = {
                "name": f"TestZone_{uuid.uuid4().hex[:4]}",
                "polygon": [{"x": 10, "y": 10}, {"x": 20, "y": 20}, {"x": 10, "y": 20}]
            }
            test_payload = original_zones + [sample_zone]

            res = requests.post(f"{API_URL}/zones", headers=HEADERS, json=test_payload)
            elapsed = (time.time() - start_time) * 1000

            if res.status_code == 200:
                table.add_row("/api/zones", "POST", "[bold green]200[/bold green]", f"{elapsed:.2f} ms", "OK")
            elif res.status_code == 401:
                table.add_row("/api/zones", "POST", "[bold red]401[/bold red]", f"{elapsed:.2f} ms", "UNAUTHORIZED/BAD TOKEN")
            else:
                table.add_row("/api/zones", "POST", f"[bold red]{res.status_code}[/bold red]", f"{elapsed:.2f} ms", f"Error: {res.text[:20]}...")
    
            if res.status_code == 200:
                requests.post(f"{API_URL}/zones", headers=HEADERS, json=original_zones)
        
        except Exception as e:
            table.add_row("/api/zones", "POST", "[bold red]ERROR[/bold red]", "-", f"{str(e)}")

        console.print(table)

async def test_websocket():
    panel_title = "[bold cyan]Websocket test,,,[/bold cyan]"

    uri = f"{WS_URL}?token={TOKEN}&client_id=test_script"
    try:
        async with websockets.connect(uri) as ws:
            success_msg = "[bold green]Successful connection to WS[/bold green]\n"
            success_msg += f"[white]sending fake frame data[/white]\n"

            await ws.send(b"fake_image_data_test_123")
            success_msg += "[bold green]fake frame data sent[/bold green]"
            
            await asyncio.sleep(0.5)
            console.print(Panel(success_msg, title=panel_title, border_style="green"))
    except websockets.exceptions.InvalidStatusCode as e:
        if e.status_code == 403 or e.status_code == 401:
            error_msg = f"[bold red] Websocket test failed:[/bold red] Unauthorized"
        else:
            error_msg = f"[bold red] Websocket test failed:[/bold red] {e}"
        console.print(Panel(error_msg, title=panel_title, border_style="red"))
    except Exception as e:
        error_msg = f"[bold red]Websocket test failed:[/bold red] {e}"
        console.print(Panel(error_msg, title=panel_title, border_style="red"))

async def main():
    console.print("\n")
    console.rule("Starting Tests")
    
    test_rest_endpoints()
    
    console.print("\n")
    
    await test_websocket()

if __name__ == "__main__":
    asyncio.run(main())
