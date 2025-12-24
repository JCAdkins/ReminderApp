from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime
from app.db import get_db
from app.services.oauth.oauth_service import save_oauth_tokens
from app.oauth.jwt import verify_token

router = APIRouter(prefix="/oauth", tags=["oauth"])


class OAuthTokenRequest(BaseModel):
    provider: str
    access_token: str
    refresh_token: str | None = None
    expires_at: datetime | None = None


def require_access_token(token: str):
    payload = verify_token(token, "access")
    if not payload:
        raise HTTPException(401, "Invalid access token")
    return payload


@router.post("/store")
def store_oauth_tokens(
    data: OAuthTokenRequest,
    payload=Depends(require_access_token),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])

    token = save_oauth_tokens(
        db=db,
        user_id=user_id,
        provider=data.provider.lower(),
        access_token=data.access_token,
        refresh_token=data.refresh_token,
        expires_at=data.expires_at,
    )

    return {"status": "stored", "provider": token.provider}
