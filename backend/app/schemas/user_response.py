# schemas.py
from pydantic import BaseModel
from datetime import date
from typing import Optional
from uuid import UUID

class UserResponse(BaseModel):
    id: UUID
    email: str
    first_name: str
    last_name: str
    dob: Optional[date] = None

    class Config:
        from_attributes = True
