import os
from cachetools import TTLCache
from fastapi import HTTPException
from jose import JWTError, jwt
import requests
import hashlib
import hmac

from dotenv import load_dotenv

FB_APP_ID = os.getenv("FB_APP_ID")
JWKS_URL = "https://www.facebook.com/.well-known/oauth/openid/jwks/"
jwks_cache = TTLCache(maxsize=1, ttl=86400) # Cache keys for 24 hours
nonce_cache = TTLCache(maxsize=10_000, ttl=300)# Optional: nonce replay cache (5 minutes)

load_dotenv()  # loads .env into environment variables

FB_APP_ID = os.environ.get("FB_APP_ID")
FB_APP_SECRET = os.environ.get("FB_APP_SECRET")

def verify_facebook_token(fb_token: str):
    try:
        jwks = get_facebook_jwks()

        claims = jwt.decode(
            fb_token,
            jwks,
            algorithms=["RS256"],
            audience=FB_APP_ID,
            issuer="https://www.facebook.com",
        )

        # 🔐 Nonce replay protection
        nonce = claims.get("nonce")
        if nonce:
            if nonce in nonce_cache:
                raise HTTPException(
                    status_code=401,
                    detail="Replay attack detected"
                )
            nonce_cache[nonce] = True

        return {
            "facebook_user_id": claims["sub"],   # 🔑 PRIMARY ID
            "email": claims.get("email"),
            "name": claims.get("name"),
            "first_name": claims.get("given_name"),
            "last_name": claims.get("family_name"),
            "expires_at": claims.get("exp"),
            "birthday": claims.get("user_birthday")
        }

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Facebook token expired")

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid Facebook token")

# Needed for server-to-server API calls w/ Facebook
def generate_appsecret_proof(access_token: str, app_secret: str) -> str:
    return hmac.new(
        key=app_secret.encode('utf-8'),
        msg=access_token.encode('utf-8'),
        digestmod=hashlib.sha256
    ).hexdigest()

def get_facebook_jwks():
    if "jwks" not in jwks_cache:
        jwks_cache["jwks"] = requests.get(JWKS_URL).json()
    return jwks_cache["jwks"]
