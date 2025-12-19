import os
import requests
import hashlib
import hmac

FACEBOOK_URL = "https://graph.facebook.com/me"

def verify_facebook_token(fb_token: str):
    appsecret_proof = hmac.new(
        key=os.getenv("FB_APP_SECRET").encode("utf-8"),
        msg=fb_token.encode("utf-8"),
        digestmod=hashlib.sha256
        ).hexdigest()
    params = {
        "fields": "id,first_name,last_name,email,birthday",
        "access_token": fb_token,
        "appsecret_proof": appsecret_proof,

    }
    resp = requests.get(FACEBOOK_URL, params=params)
    
    resp.raise_for_status()
    return resp.json()  # contains id, name, email, picture

# Needed for server-to-server API calls w/ Facebook
def generate_appsecret_proof(access_token: str, app_secret: str) -> str:
    return hmac.new(
        key=app_secret.encode('utf-8'),
        msg=access_token.encode('utf-8'),
        digestmod=hashlib.sha256
    ).hexdigest()
