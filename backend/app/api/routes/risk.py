from fastapi import APIRouter, Depends, Request
from ...models.risk import RiskPredictRequest, RiskPredictResponse, RiskFactorItem

router = APIRouter(prefix="/predict-risk", tags=["Risk Intelligence"])

@router.post("", response_model=RiskPredictResponse)
def predict_transaction_risk(payload: RiskPredictRequest, request: Request):
    engine = request.app.state.risk_engine
    result = engine.evaluate_and_record(payload.model_dump(), record_history=False)
    
    return RiskPredictResponse(
        transaction_id=result["transaction_id"],
        risk_score=result["risk_score"],
        risk_level=result["risk_level"],
        decision=result["decision"],
        customer_message=result["customer_message"],
        risk_factors=[RiskFactorItem(**rf) for rf in result["risk_factors"]],
        anomaly_score=result["anomaly_score"],
        model_probabilities={
            "supervised_fraud_prob": result["supervised_probability"]
        },
        what_happened=result.get("what_happened"),
        why_risky=result.get("why_risky"),
        what_next=result.get("what_next"),
    )
