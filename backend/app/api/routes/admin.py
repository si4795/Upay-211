from fastapi import APIRouter, Request, HTTPException
from typing import List, Dict, Any
from datetime import datetime
import re
from ...models.risk import AdminActionRequest, AdminActionRecord, FraudCase, BanglaScamCheckRequest, BanglaScamCheckResponse
from ...models.transaction import AdminTransactionResponse

router = APIRouter(prefix="/admin", tags=["Admin Fraud Intelligence"])

@router.get("/risk-events")
def get_risk_events(request: Request):
    engine = request.app.state.risk_engine
    return engine.risk_events[:30]

@router.get("/transactions", response_model=List[AdminTransactionResponse])
def get_admin_transactions(request: Request):
    engine = request.app.state.risk_engine
    return [AdminTransactionResponse(**t) for t in engine.transaction_history[:100]]

@router.post("/actions", response_model=AdminActionRecord)
def take_admin_action(payload: AdminActionRequest, request: Request):
    engine = request.app.state.risk_engine
    
    # Check if transaction exists
    matching = [t for t in engine.transaction_history if t["transaction_id"] == payload.transaction_id]
    if matching:
        # Update transaction status
        if payload.action == "BLOCK":
            matching[0]["status"] = "BLOCKED"
        elif payload.action == "HOLD":
            matching[0]["status"] = "HOLD"
        elif payload.action == "REVIEW":
            matching[0]["status"] = "UNDER_REVIEW"

    # Also update any linked case
    for case in engine.fraud_cases:
        if case["transaction_id"] == payload.transaction_id:
            case["status"] = "Under Review" if payload.action in ["REVIEW", "HOLD"] else ("Confirmed Suspicious" if payload.action == "BLOCK" else case["status"])
            case["timeline"].append({
                "time": datetime.now().isoformat(),
                "event": f"Action {payload.action} taken by {payload.analyst_id}"
            })

    record = AdminActionRecord(
        action_id=f"ACT-{len(engine.admin_actions) + 1}",
        transaction_id=payload.transaction_id,
        action=payload.action,
        analyst_id=payload.analyst_id,
        timestamp=datetime.now().isoformat(),
        notes=payload.notes
    )
    engine.admin_actions.insert(0, record.model_dump())
    return record

@router.get("/cases", response_model=List[FraudCase])
def get_fraud_cases(request: Request):
    engine = request.app.state.risk_engine
    return [FraudCase(**c) for c in engine.fraud_cases]

@router.put("/cases/{case_id}")
def update_case_status(case_id: str, payload: Dict[str, str], request: Request):
    engine = request.app.state.risk_engine
    for case in engine.fraud_cases:
        if case["case_id"] == case_id:
            if "status" in payload:
                case["status"] = payload["status"]
            if "assigned_analyst" in payload:
                case["assigned_analyst"] = payload["assigned_analyst"]
            case["timeline"].append({
                "time": datetime.now().isoformat(),
                "event": f"Case updated to {case['status']} by {case.get('assigned_analyst', 'Analyst')}"
            })
            return case
    raise HTTPException(status_code=404, detail="Case not found")

@router.get("/analytics")
def get_security_analytics(request: Request):
    engine = request.app.state.risk_engine
    txns = engine.transaction_history
    
    total = len(txns)
    high_risk = sum(1 for t in txns if t.get("risk_level") == "HIGH")
    med_risk = sum(1 for t in txns if t.get("risk_level") == "MEDIUM")
    low_risk = sum(1 for t in txns if t.get("risk_level") == "LOW")
    blocked = sum(1 for t in txns if t.get("status") in ["BLOCKED", "HOLD"])
    under_review = sum(1 for t in txns if t.get("status") in ["UNDER_REVIEW", "VERIFY_REQUIRED"])

    # Score distribution brackets
    brackets = {
        "0-20": sum(1 for t in txns if 0 <= t.get("risk_score", 0) <= 20),
        "21-40": sum(1 for t in txns if 21 <= t.get("risk_score", 0) <= 40),
        "41-60": sum(1 for t in txns if 41 <= t.get("risk_score", 0) <= 60),
        "61-80": sum(1 for t in txns if 61 <= t.get("risk_score", 0) <= 80),
        "81-100": sum(1 for t in txns if 81 <= t.get("risk_score", 0) <= 100),
    }

    return {
        "total_transactions": 25430 + total,
        "high_risk_count": 42 + high_risk,
        "medium_risk_count": 186 + med_risk,
        "low_risk_count": 25202 + low_risk,
        "blocked_count": 31 + blocked,
        "under_review_count": 18 + under_review,
        "risk_distribution": brackets,
        "recent_trend": [
            {"day": "Mon", "normal": 4200, "flagged": 28},
            {"day": "Tue", "normal": 3950, "flagged": 34},
            {"day": "Wed", "normal": 4600, "flagged": 22},
            {"day": "Thu", "normal": 4100, "flagged": 41},
            {"day": "Fri", "normal": 4800, "flagged": 48},
            {"day": "Sat", "normal": 3700, "flagged": 31},
            {"day": "Sun", "normal": 3200, "flagged": 24},
        ]
    }

@router.get("/graph")
def get_graph_intelligence(request: Request):
    engine = request.app.state.risk_engine
    return engine.graph_analyzer.analyze_network()

@router.post("/scam-nlp", response_model=BanglaScamCheckResponse)
def analyze_bangla_scam_text(payload: BanglaScamCheckRequest):
    """
    Bangla Scam NLP prototype detecting credential requests, lottery phishing,
    and agent impersonation schemes.
    """
    text = payload.text.lower()
    
    # Patterns
    pin_patterns = [r'pin\s*দিন', r'পিন\s*দিন', r'গোপন\s*পিন', r'pin\s*confirm', r'পিন\s*কনফার্ম']
    otp_patterns = [r'otp\s*দিন', r'ওটিপি\s*দিন', r'কোড\s*দিন', r'সিকিউরিটি\s*কোড']
    impersonation_patterns = [r'upay\s*থেকে\s*বলছি', r'উপায়\s*অফিস', r'উপায়\s*হেড\s*অফিস', r'সার্ভার\s*আপডেট']
    prize_patterns = [r'পুরস্কার', r'লটারি', r'বিজয়ী', r'verification\s*fee', r'ফি\s*পাঠান']
    account_block_patterns = [r'বন্ধ\s*হয়ে\s*যাবে', r'অ্যাকাউন্ট\s*ব্লক', r'লক\s*হয়ে']

    matched_keywords = []
    category = "Normal"
    is_scam = False
    confidence = 0.10

    if any(re.search(p, text) for p in pin_patterns):
        matched_keywords.append("PIN Request")
        category = "Credential Request"
        is_scam = True
        confidence = 0.96

    if any(re.search(p, text) for p in otp_patterns):
        matched_keywords.append("OTP Solicitation")
        category = "Credential Request"
        is_scam = True
        confidence = 0.95

    if any(re.search(p, text) for p in impersonation_patterns):
        matched_keywords.append("Official Impersonation")
        if category == "Normal":
            category = "Impersonation"
        is_scam = True
        confidence = max(confidence, 0.92)

    if any(re.search(p, text) for p in prize_patterns):
        matched_keywords.append("Prize / Advance Fee Scam")
        category = "Prize Scam"
        is_scam = True
        confidence = max(confidence, 0.94)

    if any(re.search(p, text) for p in account_block_patterns):
        matched_keywords.append("Urgent Threat / Account Closure")
        if not is_scam:
            category = "Phishing"
        is_scam = True
        confidence = max(confidence, 0.91)

    return BanglaScamCheckResponse(
        text=payload.text,
        is_scam=is_scam,
        category=category,
        confidence=confidence,
        detected_keywords=matched_keywords
    )
