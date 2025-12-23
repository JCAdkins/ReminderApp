from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db import get_db
from app.services.auth_service import (
    get_user, register_user, authenticate_user, generate_tokens, refresh_tokens
)
from app.oauth.jwt import verify_token
from app.dependencies import get_current_user
from app.schemas.user_response import UserResponse
from app.schemas.auth_response import AuthResponse
from app.oauth.exceptions import OAuthOnlyAccount


router = APIRouter(prefix="/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    email: str
    password: str
    first_name: str
    last_name: str
    dob: date


class LoginRequest(BaseModel):
    email: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


@router.post("/register")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    user = register_user(db, data.email, data.password, data.first_name, data.last_name, data.dob)
    if not user:
        raise HTTPException(400, "Email already registered")
    user_response = UserResponse.model_validate({
    "id": user.id,
    "email": user.email,
    "first_name": user.first_name,
    "last_name": user.last_name,
    "dob": user.dob,
    })
    return AuthResponse(
        tokens = generate_tokens(user),
        user = user_response
    )


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    try:
        user = authenticate_user(db, data.email, data.password)
    except OAuthOnlyAccount as e:
        raise HTTPException(
            status_code=409,
            detail={
                "error": "OAUTH_ONLY_ACCOUNT",
                "provider": e.provider.capitalize()
            }
        )

    if not user:
        raise HTTPException(
            status_code=400,
            detail="Invalid credentials"
        )

    user_response = UserResponse.model_validate({
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "dob": user.dob,
    })

    return AuthResponse(
        tokens=generate_tokens(user),
        user=user_response
    )



@router.post("/refresh")
def refresh(data: RefreshRequest, db: Session = Depends(get_db)):
    payload = verify_token(data.refresh_token, expected_type="refresh")
    if not payload:
        raise HTTPException(401, "Invalid refresh token")

    tokens = refresh_tokens(payload["sub"], payload["email"])
    user = get_user(db, payload["email"])
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


@router.get("/me", response_model=AuthResponse)
async def me(current_user: AuthResponse = Depends(get_current_user)):

    return current_user
