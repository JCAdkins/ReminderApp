from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class OAuthTokenCreate(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    expires_at: Optional[datetime] = None
