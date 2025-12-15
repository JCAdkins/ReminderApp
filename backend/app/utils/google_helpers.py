import os
from google.oauth2 import id_token
from google.auth.transport import requests
from fastapi import HTTPException, status



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
            raise ValueError("Invalid audience")

        return idinfo

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Google token: {str(e)}"
        )


