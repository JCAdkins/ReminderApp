import os
import requests
from google.auth.transport.requests import Request
from google.oauth2 import id_token
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.models.oauth_token import OAuthTokenDb
from app.models.user import User
from app.schemas.oauth_token import OAuthToken
from app.models.user_oauth_provider import UserOAuthProvider

GOOGLE_TOKENINFO_URL = "https://www.googleapis.com/oauth2/v3/tokeninfo"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo"

GOOGLE_CLIENT_IDS = {
    os.getenv("GOOGLE_CID_WEB"),
    os.getenv("GOOGLE_CID_iOS"),
    os.getenv("GOOGLE_CID_ANDROID"),
}

# Remove None values in case one isn't set
GOOGLE_CLIENT_IDS = {cid for cid in GOOGLE_CLIENT_IDS if cid}

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

def verify_google_id_token(token: str) -> dict:
    try:
        request = Request()
        idinfo = id_token.verify_oauth2_token(
            token,
            request,
            audience=None  # we will validate manually
        )

        if idinfo["iss"] not in (
            "accounts.google.com",
            "https://accounts.google.com",
        ):
            raise ValueError("Invalid issuer")

        if idinfo["aud"] not in GOOGLE_CLIENT_IDS:
            raise HTTPException(
            status_code=401,
            detail="Token audience mismatch",
        )

        return idinfo

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Google token: {str(e)}"
        )

def verify_google_access_token(access_token: str) -> dict:
    response = requests.get(
        GOOGLE_TOKENINFO_URL,
        params={"access_token": access_token},
        timeout=5,
    )

    if response.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid Google access token")

    token_info = response.json()

    aud = token_info.get("aud")
    if aud not in GOOGLE_CLIENT_IDS:
        raise HTTPException(
            status_code=401,
            detail="Token audience mismatch",
        )

    return token_info


def get_names(google_user: dict) -> tuple[str, str]:
    """
    Returns (first_name, last_name) from Google token.
    Falls back to splitting full name if given/family names are missing.
    Ignores middle names.
    """
    first_name = google_user.get("given_name")
    last_name = google_user.get("family_name")
    full_name = google_user.get("name")

    if first_name and last_name:
        return first_name, last_name

    if full_name:
        parts = full_name.strip().split()
        if len(parts) == 1:
            # Only one word -> first name, no last name
            return parts[0], ""
        else:
            # First word = first name, last word = last name, middle names ignored
            return parts[0], parts[-1]

    # Nothing provided
    return "", ""

def fetch_google_userinfo(access_token: str) -> dict:
    resp = requests.get(GOOGLE_USERINFO_URL,
        headers={
            "Authorization": f"Bearer {access_token}"
        }
    )
    if resp.status_code != 200:
        raise HTTPException(
            status_code=401,
            detail="Failed to fetch Google user profile",
        )

    return resp.json()



# ---------- Retrieve Google OAuth tokens ----------
def get_google_tokens(db: Session, user_id: int) -> OAuthTokenDb | None:
    """
    Retrieve the Google OAuth token for a specific user.
    """
    return db.query(OAuthTokenDb).filter_by(user_id=user_id, provider="google").first()