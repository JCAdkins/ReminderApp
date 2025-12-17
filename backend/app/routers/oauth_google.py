from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.services.oauth_google_service import fetch_google_userinfo, save_google_tokens, get_google_tokens, find_or_create_google_user, get_names, verify_google_access_token, verify_google_id_token
from app.db import get_db
from app.services.auth_service import generate_tokens
from app.schemas.google_mobile_login import GoogleMobileLogin
from app.schemas.google_web_login import GoogleWebLogin
from app.schemas.auth_response import AuthResponse
from app.schemas.user_response import UserResponse


router = APIRouter(prefix="/auth/google", tags=["Google OAuth"])

@router.post("/mobile")
def google_login(payload: GoogleMobileLogin, db: Session = Depends(get_db)):
    id_token_str = payload.id_token
    google_user = verify_google_id_token(id_token_str)

    if google_user.get("email_verified") is not True:
        raise HTTPException(status_code=401, detail="Email not verified")
    
    first_name, last_name = get_names(google_user)
    google_id = google_user.get("sub")
    email = google_user.get("email")

    user = find_or_create_google_user(db,  google_id= google_id, email=email, first_name=first_name, last_name=last_name) 

    tokens = generate_tokens(user)
    scopes = ["email", "profile", "openid"]
    save_google_tokens(db, user, tokens, scopes)

    user_response = UserResponse.model_validate({
    "id": user.id,
    "email": user.email,
    "first_name": user.first_name,
    "last_name": user.last_name,
    "dob": user.dob,
    })
    return AuthResponse(
        tokens = tokens,
        user = user_response
    )

@router.post("/web")
def google_web_login(payload: GoogleWebLogin, db: Session = Depends(get_db)):
    access_token = payload.access_token

    # Verify access token with Google
    token_info = verify_google_access_token(access_token)

    google_id = token_info.get("sub")
    email = token_info.get("email")

    if not google_id or not email:
        raise HTTPException(status_code=401, detail="Invalid Google token")

    # Optional but recommended
    if token_info.get("email_verified") != "true":
        raise HTTPException(status_code=401, detail="Email not verified")

    # Extract names (same helper as mobile)
    first_name, last_name = get_names(token_info)

    if not first_name and not last_name:
        profile = fetch_google_userinfo(access_token)
        first_name, last_name = get_names(profile)


    # Find or create user
    user = find_or_create_google_user(
        db,
        google_id=google_id,
        email=email,
        first_name=first_name,
        last_name=last_name,
    )

    # Generate backend tokens
    tokens = generate_tokens(user)
    scopes = ["email", "profile", "openid"]
    save_google_tokens(db, user, tokens, scopes)

    user_response = UserResponse.model_validate({
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "dob": user.dob,
    })

    return AuthResponse(tokens=tokens, user=user_response)

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
        "token_type": "Bearer",
        "expires_at": token.expires_at
    }
