from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.services.oauth_google_service import save_google_tokens, get_google_tokens
from app.db import get_db
from app.schemas.oauth_token import OAuthTokenCreate   # ✅ Use Pydantic schema
from app.oauth.require_access_token import require_access_token
from app.models.user import User
from app.services.auth_service import generate_tokens
from app.utils.google_helpers import verify_google_access_token, verify_google_id_token
from app.schemas.google_mobile_login import GoogleMobileLogin
from app.schemas.google_web_login import GoogleWebLogin


router = APIRouter(prefix="/auth/google", tags=["Google OAuth"])

@router.post("/mobile")
def google_login(payload: GoogleMobileLogin, db: Session = Depends(get_db)):
    id_token_str = payload.id_token

    google_user = verify_google_id_token(id_token_str)

    email = google_user.get("email")
    google_id = google_user.get("sub")

    print("google_user: ", google_user)

    user = db.query(User).filter(
        (User.email == email) | (User.google_id == google_id)
    ).first()

    print("user: ", user)

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not registered"
        )
    
        # update google_id in user if not set
    if not user.google_id:
        user.google_id = google_id
        db.commit()
        db.refresh(user)

    tokens = generate_tokens(user)
    scopes = ["email", "profile", "openid"]
    print("tokens: ", tokens)
    save_google_tokens(db, user, tokens, scopes)

    return {
        "access_token": tokens["access_token"],
        "refresh_token": tokens["refresh_token"],
        "token_type": "bearer"
    }

@router.post("/web")
def google_web_login(payload: GoogleWebLogin, db: Session = Depends(get_db)):
    email = payload.email
    google_id = payload.google_id
    access_token = payload.access_token

    # Verify token with Google
    token_info = verify_google_access_token(access_token)

    # Validate token contents
    if token_info.get("email") != email:
        raise HTTPException(status_code=401, detail="Email mismatch")

    if token_info.get("sub") != google_id:
        raise HTTPException(status_code=401, detail="Google ID mismatch")

    # Optional but recommended
    if token_info.get("email_verified") != "true":
        raise HTTPException(status_code=401, detail="Email not verified")

    # Find user
    user = db.query(User).filter(
        (User.email == email) | (User.google_id == google_id)
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not registered"
        )
        
    # Link Google ID if missing
    if not user.google_id:
        user.google_id = google_id
        db.commit()

    # 4Issue backend tokens
    tokens = generate_tokens(user)

    return {
        "access_token": tokens["access_token"],
        "refresh_token": tokens["refresh_token"],
        "token_type": "bearer",
    }


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
