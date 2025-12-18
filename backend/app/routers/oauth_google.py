from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.services.oauth_google_service import fetch_google_userinfo, get_google_tokens, get_names, verify_google_access_token, verify_google_id_token
from app.db import get_db
from app.services.auth_service import generate_tokens
from app.schemas.google_mobile_login import GoogleMobileLogin
from app.schemas.google_web_login import GoogleWebLogin
from app.schemas.auth_response import AuthResponse
from app.schemas.user_response import UserResponse
from app.services.oauth_service import find_or_create_oauth_user, upsert_oauth_tokens


router = APIRouter(prefix="/auth/google", tags=["Google OAuth"])

@router.post("/mobile")
def google_login(payload: GoogleMobileLogin, db: Session = Depends(get_db)):
    # Verify Google ID token
    google_user = verify_google_id_token(payload.id_token)

    if google_user.get("email_verified") is not True:
        raise HTTPException(status_code=401, detail="Email not verified")

    # Extract normalized user info
    provider = "google"
    provider_user_id = google_user.get("sub")  # Google user ID
    email = google_user.get("email")
    first_name, last_name = get_names(google_user)

    # Find or create user (GENERIC)
    user = find_or_create_oauth_user(
        db,
        provider=provider,
        provider_user_id=provider_user_id,
        email=email,
        first_name=first_name,
        last_name=last_name,
    )

    # Generate YOUR app tokens (JWT access/refresh)
    tokens = generate_tokens(user)

    # Store OAuth provider tokens (optional but recommended)
    upsert_oauth_tokens(
        db,
        user=user,
        provider=provider,
        access_token=payload.id_token,
        scopes=["email", "profile", "openid"],
    )

    # Return auth response
    user_response = UserResponse.model_validate({
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "dob": user.dob,
    })

    return AuthResponse(
        tokens=tokens,
        user=user_response
    )


@router.post("/web")
def google_web_login(payload: GoogleWebLogin, db: Session = Depends(get_db)):
    access_token = payload.access_token

    # Verify Google access token
    token_info = verify_google_access_token(access_token)

    provider = "google"
    provider_user_id = token_info.get("sub")
    email = token_info.get("email")

    if not provider_user_id or not email:
        raise HTTPException(status_code=401, detail="Invalid Google token")

    # Optional but recommended
    if token_info.get("email_verified") not in (True, "true"):
        raise HTTPException(status_code=401, detail="Email not verified")

    # Extract names
    first_name, last_name = get_names(token_info)

    if not first_name and not last_name:
        profile = fetch_google_userinfo(access_token)
        first_name, last_name = get_names(profile)

    # Find or create user (GENERIC)
    user = find_or_create_oauth_user(
        db,
        provider=provider,
        provider_user_id=provider_user_id,
        email=email,
        first_name=first_name,
        last_name=last_name,
    )

    # Generate YOUR backend tokens
    tokens = generate_tokens(user)

    # Store provider tokens
    upsert_oauth_tokens(
        db,
        user=user,
        provider=provider,
        access_token=access_token,
        scopes=["email", "profile", "openid"],
    )

    # Return response
    user_response = UserResponse.model_validate({
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "dob": user.dob,
    })

    return AuthResponse(tokens=tokens, user=user_response)
