from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class RiskFactorItem(BaseModel):
    feature: str
    impact: float
    message: str

class RiskPredictRequest(BaseModel):
    user_id: str
    receiver_id: str
    amount: float
    transaction_type: str = "SEND_MONEY"
    device_id: str = "DEVICE001"
    location: str = "Dhaka"
    timestamp: Optional[str] = None
    account_age: Optional[int] = None
    receiver_age: Optional[int] = None
    velocity: Optional[int] = None
    failed_attempts: Optional[int] = 0

class RiskPredictResponse(BaseModel):
    transaction_id: str
    risk_score: int # 0 - 100
    risk_level: str # LOW, MEDIUM, HIGH
    decision: str # ALLOW, VERIFY, HOLD, BLOCK
    customer_message: str
    risk_factors: List[RiskFactorItem] = Field(default_factory=list)
    anomaly_score: Optional[float] = None
    model_probabilities: Optional[Dict[str, float]] = None

class AdminActionRequest(BaseModel):
    transaction_id: str
    action: str # REVIEW, HOLD, BLOCK, MONITOR, FLAG_ACCOUNT, ESCALATE
    analyst_id: str = "ADMIN001"
    notes: Optional[str] = None

class AdminActionRecord(BaseModel):
    action_id: str
    transaction_id: str
    action: str
    analyst_id: str
    timestamp: str
    notes: Optional[str] = None

class FraudCase(BaseModel):
    case_id: str
    user_id: str
    transaction_id: str
    amount: float
    risk_score: int
    risk_level: str
    reason: str
    status: str # Open, Under Review, Confirmed Suspicious, Resolved, False Positive
    assigned_analyst: str
    created_time: str
    timeline: List[Dict[str, Any]] = Field(default_factory=list)

class BanglaScamCheckRequest(BaseModel):
    text: str

class BanglaScamCheckResponse(BaseModel):
    text: str
    is_scam: bool
    category: str # Credential Request, Phishing, Prize Scam, Impersonation, Normal
    confidence: float
    detected_keywords: List[str]
