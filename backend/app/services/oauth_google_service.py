from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from app.models.oauth_token import OAuthToken
from app.models.user import User
from app.schemas.oauth_token import OAuthTokenCreate

# ---------- Save or update Google OAuth tokens ----------
def save_google_tokens(db: Session, user: User, tokens: OAuthTokenCreate, scopes: list):
    """
    db: SQLAlchemy session
    user: the logged-in User instance
    tokens: dict with 'access_token', 'refresh_token', 'expires_at' (optional)
    scopes: list of scopes granted by the user
    """
    token_row = db.query(OAuthToken).filter_by(user_id=user.id, provider="google").first()

    expires_at = None
    if "expires_in" in tokens:
        expires_at = datetime.now(timezone.utc) + timedelta(seconds=tokens["expires_in"])
    elif "expires_at" in tokens:
        expires_at = tokens["expires_at"]  # already datetime

    if token_row:
        # update existing row
        token_row.access_token = tokens.access_token
        token_row.refresh_token = tokens.refresh_token
        token_row.expires_at = expires_at
        token_row.scopes = scopes
    else:
        # create new row
        token_row = OAuthToken(
            provider="google",
            user_id=user.id,
            access_token=tokens.get("access_token"),
            refresh_token=tokens.get("refresh_token"),
            expires_at=expires_at,
            scopes=scopes,
        )
        db.add(token_row)

    db.commit()
    db.refresh(token_row)
    return token_row


# ---------- Retrieve Google OAuth tokens ----------
def get_google_tokens(db: Session, user_id: int) -> OAuthToken | None:
    """
    Retrieve the Google OAuth token for a specific user.
    """
    return db.query(OAuthToken).filter_by(user_id=user_id, provider="google").first()
