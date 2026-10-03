from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from .services.risk_engine import RiskEngine
from .services.event_broadcaster import EventBroadcaster
from .api.routes import health, transactions, risk, admin, websocket

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize shared EventBroadcaster and RiskEngine on startup
    print("[Startup] Initializing EventBroadcaster, RiskEngine, ML models, and NetworkX Graph...")
    broadcaster = EventBroadcaster()
    app.state.broadcaster = broadcaster
    engine = RiskEngine(broadcaster=broadcaster)
    
    # Pre-seed realistic transactions for immediate demo and testing
    seed_txns = [
        {
            'transaction_id': 'TXN-10342',
            'user_id': 'USER001',
            'receiver_id': 'USER_ROGUE_99',
            'receiver_name': 'Unknown Receiver',
            'receiver_phone': '01999887766',
            'amount': 50000.0,
            'device_id': 'DEVICE009',
            'location': 'Chattogram',
            'velocity': 8,
            'failed_attempts': 3,
        },
        {
            'transaction_id': 'TXN-10341',
            'user_id': 'USER001',
            'receiver_id': 'USER_NEW_45',
            'receiver_name': 'Anisur Rahman',
            'receiver_phone': '01799887766',
            'amount': 8000.0,
            'device_id': 'DEVICE001',
            'location': 'Dhaka',
            'velocity': 2,
            'failed_attempts': 0,
        },
        {
            'transaction_id': 'TXN-10340',
            'user_id': 'USER001',
            'receiver_id': 'USER102',
            'receiver_name': 'Karim Ahmed',
            'receiver_phone': '01819283746',
            'amount': 500.0,
            'device_id': 'DEVICE001',
            'location': 'Dhaka',
            'velocity': 1,
            'failed_attempts': 0,
        },
    ]
    for st in seed_txns:
        engine.evaluate_and_record(st)

    app.state.risk_engine = engine
    print(f"[Startup] RiskEngine ready with {len(engine.transaction_history)} seeded transactions.")
    yield

app = FastAPI(
    title="upay Trust & Risk Intelligence API",
    description="Backend API for real-time MFS fraud detection, SHAP explainability, and graph analytics",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration allowing Flutter Mobile & Web connections
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes with /api/v1 prefix
app.include_router(health.router, prefix="/api/v1")
app.include_router(transactions.router, prefix="/api/v1")
app.include_router(risk.router, prefix="/api/v1")
app.include_router(admin.router, prefix="/api/v1")
app.include_router(websocket.router, prefix="/api/v1")

@app.get("/")
def root():
    return {
        "message": "upay Trust & Risk Intelligence Platform API",
        "documentation": "/docs",
        "health": "/api/v1/health"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.app.main:app", host="0.0.0.0", port=8000, reload=True)

