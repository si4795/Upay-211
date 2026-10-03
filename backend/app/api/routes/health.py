from fastapi import APIRouter
from datetime import datetime

router = APIRouter(prefix="/health", tags=["Health"])

@router.get("")
def health_check():
    return {
        "status": "healthy",
        "service": "upay Trust & Risk Intelligence Engine",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "track": "Track 01 — Trust & Risk Intelligence",
        "components": {
            "xgboost_model": "active",
            "isolation_forest": "active",
            "shap_explainer": "active",
            "networkx_graph": "active",
            "bangla_nlp": "active"
        }
    }

