import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.services.oauth_google_service import save_google_tokens, get_google_tokens
from app.db import get_db
from app.schemas.oauth_token import OAuthTokenCreate   # ✅ Use Pydantic schema
from app.oauth.require_access_token import require_access_token


router = APIRouter(prefix="/oauth/google", tags=["Google OAuth"])

@router.post("/store")
def store_google_tokens(
    data: OAuthTokenCreate,
    payload=Depends(require_access_token),
    db: Session = Depends(get_db)
):
    expires_in = None
    if data.expires_at:
        expires_in = (data.expires_at - datetime.datetime.utcnow()).total_seconds()

    token = save_google_tokens(
        db=db,
        user_id=int(payload["sub"]),
        access_token=data.access_token,
        refresh_token=data.refresh_token,
        expires_in=expires_in,
    )

    return {"status": "stored", "expires_at": token.expires_at}


@router.get("/get")
def fetch_tokens(
    user_id: int,
    db: Session = Depends(get_db)
):
    token = get_google_tokens(db, user_id)
    if not token:
        return {"error": "No token found"}

    return {
        "access_token": token.access_token,
        "refresh_token": token.refresh_token,
        "expires_at": token.expires_at
    }
