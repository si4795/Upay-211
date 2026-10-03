from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import json

router = APIRouter(tags=["Real-Time WebSockets"])

@router.websocket("/ws/risk-events")
async def websocket_risk_events(websocket: WebSocket):
    broadcaster = websocket.app.state.broadcaster
    await broadcaster.connect(websocket)

    # Send initial welcome payload and recent events
    try:
        recent = broadcaster.get_recent_events(10)
        await websocket.send_text(json.dumps({
            "type": "CONNECTION_ESTABLISHED",
            "message": "Connected to real-time Trust & Risk Event Stream",
            "recent_events": recent,
        }))

        while True:
            # Keep connection alive & listen for client pings
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text(json.dumps({"type": "PONG"}))
    except WebSocketDisconnect:
        broadcaster.disconnect(websocket)
    except Exception as e:
        print(f"[WebSocket] Client connection terminated: {e}")
        broadcaster.disconnect(websocket)
