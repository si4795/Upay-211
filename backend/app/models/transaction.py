from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field
from datetime import datetime

class TransactionCreateRequest(BaseModel):
    user_id: str = "USER001"
    receiver_id: str = "USER245"
    receiver_name: Optional[str] = "Receiver"
    receiver_phone: Optional[str] = "01819283746"
    amount: float = Field(..., gt=0)
    transaction_type: str = "SEND_MONEY"
    device_id: str = "DEVICE001"
    location: str = "Dhaka"
    timestamp: Optional[str] = None
    velocity: Optional[int] = None
    failed_attempts: Optional[int] = 0

class CustomerTransactionResponse(BaseModel):
    transaction_id: str
    user_id: str
    receiver_id: str
    receiver_name: str
    receiver_phone: str
    amount: float
    fee: float = 5.0
    total: float
    timestamp: str
    transaction_type: str
    status: str # SUCCESS, VERIFY_REQUIRED, HOLD, BLOCKED
    customer_message: str

class AdminTransactionResponse(BaseModel):
    transaction_id: str
    user_id: str
    receiver_id: str
    receiver_name: str
    receiver_phone: str
    amount: float
    fee: float
    total: float
    timestamp: str
    transaction_type: str
    device_id: str
    location: str
    status: str
    risk_score: int
    risk_level: str
    decision: str
    customer_message: str
    risk_factors: List[Dict[str, Any]] = Field(default_factory=list)
    anomaly_score: Optional[float] = None
