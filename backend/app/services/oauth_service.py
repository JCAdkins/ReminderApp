from sqlalchemy.orm import Session
from datetime import datetime
from app.models.oauth_token import OAuthToken


def save_oauth_tokens(
    db: Session,
    user_id: int,
    provider: str,
    access_token: str,
    refresh_token: str | None,
    expires_at: datetime | None
):
    # Upsert: if existing token for provider, update it
    existing = db.query(OAuthToken).filter_by(
        user_id=user_id,
        provider=provider
    ).first()

    if existing:
        existing.access_token = access_token
        existing.refresh_token = refresh_token
        existing.expires_at = expires_at
        db.commit()
        db.refresh(existing)
        return existing

    token = OAuthToken(
        provider=provider,
        user_id=user_id,
        access_token=access_token,
        refresh_token=refresh_token,
        expires_at=expires_at
    )
    db.add(token)
    db.commit()
    db.refresh(token)
    return token


def get_oauth_tokens(db: Session, user_id: int, provider: str):
    return db.query(OAuthToken).filter_by(
        user_id=user_id,
        provider=provider
    ).first()
