from time import timezone
from sqlalchemy import Date
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from app.models.user import User
from app.config import settings
from app.oauth.password import hash_password, verify_password
from app.oauth.jwt import create_access_token, create_refresh_token, ACCESS_TOKEN_EXPIRE_MINUTES, REFRESH_TOKEN_EXPIRE_DAYS
from app.oauth.exceptions import OAuthOnlyAccount
from app.schemas.oauth_token import OAuthToken

def register_user(db: Session, email: str, password: str, first_name: str, last_name: str, dob: Date):
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        return None

    new_user = User(
        email=email,
        password_hash=hash_password(password),
        first_name=first_name,
        last_name=last_name,
        dob=dob
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        return None

    if not user.password_hash:
        provider = (
            user.oauth_providers[0].provider
            if user.oauth_providers else None
        )
        raise OAuthOnlyAccount(provider)

    if not verify_password(password, user.password_hash):
        return None

    return user

def get_user(db: Session, email: str):
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return None
    return user


def generate_tokens(user: User):
    # expiration for access token
    access_expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token({"sub": str(user.id), "email": user.email})

    # expiration for refresh token
    refresh_expire = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    refresh_token = create_refresh_token({"sub": str(user.id), "email": user.email})

    # expires_in for frontend (seconds until access token expires)
    expires_in = int((access_expire - datetime.now(timezone.utc)).total_seconds())

    return OAuthToken(
        access_token = access_token,
        refresh_token = refresh_token,
        expires_in = expires_in,
        token_type = "Bearer"
    )
    


def refresh_tokens(user_id: str, email: str):
    payload = {"sub": user_id, "email": email}
        # Calculate the expiration datetime for the access token
    expires_at = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return OAuthToken(
        access_token=create_access_token(payload),
        refresh_token=create_refresh_token(payload),
        token_type="Bearer",
        expires_at=expires_at
    )
