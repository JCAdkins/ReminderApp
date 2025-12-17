from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from app.models.oauth_token import OAuthTokenDb
from app.models.user import User
from app.schemas.oauth_token import OAuthToken

# ---------- Save or update Google OAuth tokens ----------
def save_google_tokens(db: Session, user: User, tokens: OAuthToken, scopes: list):
    """
    db: SQLAlchemy session
    user: the logged-in User instance
    tokens: dict with 'access_token', 'refresh_token', 'expires_at' (optional)
    scopes: list of scopes granted by the user
    """
    token_row = db.query(OAuthTokenDb).filter_by(user_id=user.id, provider="google").first()

    if token_row:
        # update existing row
        token_row.access_token = tokens.access_token
        token_row.refresh_token = tokens.refresh_token
        token_row.expires_at = tokens.expires_at
        token_row.scopes = scopes
    else:
        # create new row
        token_row = OAuthTokenDb(
            provider="google",
            user_id=user.id,
            access_token=tokens.access_token,
            refresh_token=tokens.refresh_token,
            expires_at= tokens.expires_at,
            scopes=scopes,
        )
        db.add(token_row)

    db.commit()
    db.refresh(token_row)
    return token_row


# ---------- Retrieve Google OAuth tokens ----------
def get_google_tokens(db: Session, user_id: int) -> OAuthTokenDb | None:
    """
    Retrieve the Google OAuth token for a specific user.
    """
    return db.query(OAuthTokenDb).filter_by(user_id=user_id, provider="google").first()