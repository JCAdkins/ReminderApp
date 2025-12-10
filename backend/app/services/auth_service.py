from sqlalchemy.orm import Session
from app.models.user import User
from app.oauth.password import hash_password, verify_password
from app.oauth.jwt import create_access_token, create_refresh_token


def register_user(db: Session, email: str, password: str):
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        return None

    new_user = User(
        email=email,
        password_hash=hash_password(password),
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.password_hash):
        return None
    return user


def generate_tokens(user: User):
    payload = {"sub": str(user.id), "email": user.email}
    return {
        "access_token": create_access_token(payload),
        "refresh_token": create_refresh_token(payload)
    }


def refresh_tokens(user_id: str, email: str):
    payload = {"sub": user_id, "email": email}
    return {
        "access_token": create_access_token(payload),
        "refresh_token": create_refresh_token(payload)
    }
