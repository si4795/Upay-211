from typing import List, Optional
from pydantic import BaseModel, Field

class UserProfile(BaseModel):
    user_id: str
    name: str
    phone: str
    email: str
    account_age_days: int = 320
    avg_amount: float = 2500.0
    trusted_devices: List[str] = Field(default_factory=lambda: ["DEVICE001", "DEVICE002"])
    current_device_id: str = "DEVICE001"
    home_location: str = "Dhaka"
    current_location: str = "Dhaka"
    is_flagged: bool = False
    status: str = "ACTIVE"

class UserLoginRequest(BaseModel):
    phone: str
    pin: str
    device_id: Optional[str] = "DEVICE001"
    location: Optional[str] = "Dhaka"
