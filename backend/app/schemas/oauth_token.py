from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class OAuthToken(BaseModel):
    access_token: str
    refresh_token: str
    token_type: Optional[str] = "Bearer"
    expires_at: Optional[datetime] = None

    class Config:
        orm_mode = True

        model_config = {
        "from_attributes": True  # <-- allows conversion from ORM objects
    }
