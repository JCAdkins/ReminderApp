from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.models.oauth_token import OAuthToken
from app.db import get_db

# ---------- Save or update Google OAuth tokens ----------
def save_google_tokens(
    db: Session,
    user_id: int,
    access_token: str,
    refresh_token: str | None = None,
    expires_in: int | None = None
) -> OAuthToken:
    """
    Save Google OAuth tokens for a user.
    If a token for this user/provider exists, update it.
    
    expires_in: seconds until token expires (from Google)
    """
    # Calculate expiry datetime
    expires_at = None
    if expires_in:
        expires_at = datetime.utcnow() + timedelta(seconds=expires_in)

    # Check if token exists
    token = db.query(OAuthToken).filter_by(user_id=user_id, provider="google").first()

    if token:
        token.access_token = access_token
        token.refresh_token = refresh_token
        token.expires_at = expires_at
        db.commit()
        db.refresh(token)
        return token

    # Create new token
    token = OAuthToken(
        provider="google",
        user_id=user_id,
        access_token=access_token,
        refresh_token=refresh_token,
        expires_at=expires_at
    )
    db.add(token)
    db.commit()
    db.refresh(token)
    return token


# ---------- Retrieve Google OAuth tokens ----------
def get_google_tokens(db: Session, user_id: int) -> OAuthToken | None:
    """
    Retrieve the Google OAuth token for a specific user.
    """
    return db.query(OAuthToken).filter_by(user_id=user_id, provider="google").first()
