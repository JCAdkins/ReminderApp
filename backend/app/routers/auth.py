from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db import get_db
from app.services.auth_service import (
    register_user, authenticate_user, generate_tokens, refresh_tokens
)
from app.oauth.jwt import verify_token


router = APIRouter(prefix="/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    email: str
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


@router.post("/register")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    user = register_user(db, data.email, data.password)
    if not user:
        raise HTTPException(400, "Email already registered")
    return generate_tokens(user)


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    print("data: ", data)
    user = authenticate_user(db, data.email, data.password)
    if not user:
        raise HTTPException(400, "Invalid credentials")
    return generate_tokens(user)


@router.post("/refresh")
def refresh(data: RefreshRequest):
    payload = verify_token(data.refresh_token, expected_type="refresh")
    if not payload:
        raise HTTPException(401, "Invalid refresh token")

    return refresh_tokens(payload["sub"], payload["email"])
