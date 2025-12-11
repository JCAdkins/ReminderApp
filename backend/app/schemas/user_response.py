# schemas.py
from pydantic import BaseModel
from datetime import date
from typing import Optional

class UserResponse(BaseModel):
    id: int
    email: str
    first_name: str
    last_name: str
    dob: Optional[date] = None

    class Config:
        orm_mode = True
