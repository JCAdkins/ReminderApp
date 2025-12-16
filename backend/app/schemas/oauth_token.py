from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class OAuthTokenCreate(BaseModel):
    access_token: str
    refresh_token: str
    token_type: Optional[str] = "Bearer"
    expires_at: Optional[datetime] = None
