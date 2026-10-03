from fastapi import APIRouter, Request, HTTPException
from typing import List
from ...models.transaction import TransactionCreateRequest, CustomerTransactionResponse

router = APIRouter(prefix="/transactions", tags=["Transactions"])

@router.post("", response_model=CustomerTransactionResponse)
def create_transaction(payload: TransactionCreateRequest, request: Request):
    engine = request.app.state.risk_engine
    
    # Process through risk engine
    result = engine.evaluate_and_record(payload.model_dump())
    
    # Return strictly customer-safe response (NO risk score or ML labels exposed to customer!)
    return CustomerTransactionResponse(
        transaction_id=result["transaction_id"],
        user_id=result["user_id"],
        receiver_id=result["receiver_id"],
        receiver_name=result["receiver_name"],
        receiver_phone=result["receiver_phone"],
        amount=result["amount"],
        fee=result["fee"],
        total=result["total"],
        timestamp=result["timestamp"],
        transaction_type=result["transaction_type"],
        status=result["status"],
        customer_message=result["customer_message"],
    )

@router.get("/{user_id}", response_model=List[CustomerTransactionResponse])
def get_user_transactions(user_id: str, request: Request):
    engine = request.app.state.risk_engine
    txns = [t for t in engine.transaction_history if t["user_id"] == user_id]
    
    # Map to safe customer response
    return [
        CustomerTransactionResponse(
            transaction_id=t["transaction_id"],
            user_id=t["user_id"],
            receiver_id=t["receiver_id"],
            receiver_name=t.get("receiver_name", "Recipient"),
            receiver_phone=t.get("receiver_phone", ""),
            amount=t["amount"],
            fee=t.get("fee", 5.0),
            total=t.get("total", t["amount"] + 5.0),
            timestamp=t["timestamp"],
            transaction_type=t["transaction_type"],
            status=t["status"],
            customer_message=t["customer_message"],
        )
        for t in txns
    ]

