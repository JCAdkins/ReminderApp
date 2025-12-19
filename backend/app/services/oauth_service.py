from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.models.user import User
from app.models.user_oauth_provider import UserOAuthProvider
from app.models.oauth_token import OAuthTokenDb


def find_or_create_oauth_user(
    db: Session,
    *,
    provider: str,
    provider_user_id: str,
    email: str,
    first_name: str | None = None,
    last_name: str | None = None,
    dob: datetime | None = None
) -> User:
    # Primary lookup: provider + provider_user_id
    provider_entry = (
        db.query(UserOAuthProvider)
        .filter_by(provider=provider, provider_user_id=provider_user_id)
        .first()
    )

    if provider_entry:
        user = provider_entry.user
        if user.email != email:
            user.email = email
            db.commit()
        return user

    # Secondary lookup: email (account linking)
    user = db.query(User).filter(User.email == email).first()
    if user:
        new_provider = UserOAuthProvider(
            user_id=user.id,
            provider=provider,
            provider_user_id=provider_user_id,
        )
        db.add(new_provider)
        db.commit()
        return user

    # Create new user and link provider
    user = User(
        email=email,
        first_name=first_name,
        last_name=last_name,
        dob=dob.date()
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    new_provider = UserOAuthProvider(
        user_id=user.id,
        provider=provider,
        provider_user_id=provider_user_id,
    )
    db.add(new_provider)
    db.commit()

    return user


def upsert_oauth_tokens(
    db: Session,
    *,
    user: User,
    provider: str,
    access_token: str,
    refresh_token: str | None = None,
    expires_in: int | None = None,
    scopes: list | None = None
) -> OAuthTokenDb:
    """
    Insert or update the OAuthTokenDb row for this user/provider.
    """
    token = (
        db.query(OAuthTokenDb)
        .filter_by(user_id=user.id, provider=provider)
        .first()
    )
    if not token:
        token = OAuthTokenDb(user_id=user.id, provider=provider)
        db.add(token)

    token.access_token = access_token
    token.refresh_token = refresh_token
    token.expires_at = datetime.utcnow() + timedelta(seconds=expires_in) if expires_in else None
    token.scopes = scopes or []

    db.commit()
    db.refresh(token)

    return token



def save_oauth_tokens(
    db: Session,
    user_id: int,
    provider: str,
    access_token: str,
    refresh_token: str | None,
    expires_at: datetime | None
):
    # Upsert: if existing token for provider, update it
    existing = db.query(OAuthTokenDb).filter_by(
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

    token = OAuthTokenDb(
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
    return db.query(OAuthTokenDb).filter_by(
        user_id=user_id,
        provider=provider
    ).first()
