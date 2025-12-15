import os
import requests
from google.oauth2 import id_token
from fastapi import HTTPException, status

GOOGLE_TOKENINFO_URL = "https://www.googleapis.com/oauth2/v3/tokeninfo"

GOOGLE_CLIENT_IDS = {
    os.getenv("GOOGLE_CID_WEB"),
    os.getenv("GOOGLE_CID_iOS"),
    os.getenv("GOOGLE_CID_ANDROID"),
}

# Remove None values in case one isn't set
GOOGLE_CLIENT_IDS = {cid for cid in GOOGLE_CLIENT_IDS if cid}

def verify_google_id_token(token: str) -> dict:
    try:
        idinfo = id_token.verify_oauth2_token(
            token,
            requests.Request(),
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

