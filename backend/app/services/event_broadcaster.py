import json
import asyncio
from typing import List, Dict, Any
from fastapi import WebSocket

class EventBroadcaster:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
        self.event_storage: List[Dict[str, Any]] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        print(f"[WebSocket] Admin client connected. Active: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            print(f"[WebSocket] Admin client disconnected. Active: {len(self.active_connections)}")

    async def broadcast_risk_event(self, event: Dict[str, Any]):
        """
        Stores event in event ring buffer and broadcasts to all active admin dashboards.
        """
        self.event_storage.insert(0, event)
        if len(self.event_storage) > 200:
            self.event_storage.pop()

        payload_str = json.dumps(event)
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_text(payload_str)
            except Exception as e:
                print(f"[WebSocket] Broadcast error to client: {e}")
                disconnected.append(connection)

        for conn in disconnected:
            self.disconnect(conn)

    def broadcast_sync(self, event: Dict[str, Any]):
        try:
            loop = asyncio.get_running_loop()
            loop.create_task(self.broadcast_risk_event(event))
        except RuntimeError:
            pass

    def get_recent_events(self, limit: int = 50) -> List[Dict[str, Any]]:
        return self.event_storage[:limit]
