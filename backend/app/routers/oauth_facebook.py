from fastapi import APIRouter, Depends, HTTPException
from requests import Session

from app.schemas.auth_response import AuthResponse
from app.schemas.user_response import UserResponse
from app.schemas.facebook_login import FacebookMobileLoginRequest
from app.services.auth_service import generate_tokens
from app.services.oauth_service import find_or_create_oauth_user, upsert_oauth_tokens
from app.services.oauth_facebook_service import verify_facebook_token
from app.db import get_db


router = APIRouter(prefix="/auth/facebook", tags=["Facebook OAuth"])
FACEBOOK_URL = "https://graph.facebook.com/me"

# ============================
# Mobile login
# ============================
@router.post("/mobile")
def facebook_mobile_login(
    payload: FacebookMobileLoginRequest,
    db: Session = Depends(get_db),
):
    if not payload.id_token:
        raise HTTPException(
            status_code=400,
            detail="Facebook ID token required",
        )

    # Verify token with Facebook
    fb_data = verify_facebook_token(payload.id_token)

    provider = "facebook"
    provider_user_id = fb_data.get("facebook_user_id")
    email = fb_data.get("email")

    if not provider_user_id:
        raise HTTPException(
            status_code=401,
            detail="Facebook user ID missing",
        )

    # Facebook email may be missing if user denied it
    if not email:
        raise HTTPException(
            status_code=400,
            detail="Facebook account has no email",
        )

    first_name = fb_data.get("first_name")
    last_name = fb_data.get("last_name")
    dob_str = fb_data.get("birthday")
    dob = None
    if dob_str:
        from datetime import datetime
        try:
            dob = datetime.strptime(dob_str, "%m/%d/%Y").date()
        except ValueError:
            pass  # invalid or missing format

    # Find or create user (GENERIC)
    user = find_or_create_oauth_user(
        db,
        provider=provider,
        provider_user_id=provider_user_id,
        email=email,
        first_name=first_name,
        last_name=last_name,
        dob=dob
    )

    # Generate YOUR backend tokens
    tokens = generate_tokens(user)

    # Store Facebook OAuth token
    upsert_oauth_tokens(
        db,
        user=user,
        provider=provider,
        access_token= tokens.access_token,
        scopes=["email", "public_profile"],
    )

    # Response
    user_response = UserResponse.model_validate({
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "dob": user.dob,
    })

    return AuthResponse(
        tokens=tokens,
        user=user_response,
    )



# *** WEB NOT IMPLEMENTED YET ***
#
# ============================
# Web login
# ============================
# @router.post("/web")
# def facebook_web_login(
#     payload: FacebookLoginRequest,
#     db: Session = Depends(get_db),
# ):
#     if not payload.access_token:
#         raise HTTPException(
#             status_code=400,
#             detail="Facebook access token required",
#         )

#     # Verify access token with Facebook
#     fb_resp = httpx.get(
#         FACEBOOK_URL,
#         params={
#             "fields": "id,first_name,last_name,email",
#             "access_token": payload.access_token,
#         },
#         timeout=10,
#     )

#     if fb_resp.status_code != 200:
#         raise HTTPException(
#             status_code=401,
#             detail="Invalid Facebook token",
#         )

#     fb_data = fb_resp.json()

#     provider = "facebook"
#     provider_user_id = fb_data.get("id")
#     email = fb_data.get("email")

#     if not provider_user_id:
#         raise HTTPException(
#             status_code=401,
#             detail="Facebook user ID missing",
#         )

#     if not email:
#         raise HTTPException(
#             status_code=400,
#             detail="Facebook account has no email",
#         )

#     first_name = fb_data.get("first_name")
#     last_name = fb_data.get("last_name")

#     # Find or create user (GENERIC)
#     user = find_or_create_oauth_user(
#         db,
#         provider=provider,
#         provider_user_id=provider_user_id,
#         email=email,
#         first_name=first_name,
#         last_name=last_name,
#     )

#     # Generate backend tokens
#     tokens = generate_tokens(user)

#     # Save Facebook OAuth token
#     upsert_oauth_tokens(
#         db,
#         user=user,
#         provider=provider,
#         access_token=payload.access_token,
#         scopes=["email", "public_profile"],
#     )

#     # Response
#     user_response = UserResponse.model_validate({
#         "id": user.id,
#         "email": user.email,
#         "first_name": user.first_name,
#         "last_name": user.last_name,
#         "dob": user.dob,
#     })

#     return AuthResponse(
#         tokens=tokens,
#         user=user_response,
#     )
