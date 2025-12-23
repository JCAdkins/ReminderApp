from pydantic import BaseModel
from app.schemas.user_response import UserResponse
from app.schemas.oauth_token import OAuthToken


class AuthResponse(BaseModel):
    tokens: OAuthToken
    user: UserResponse

    class Config:
        model_config = {
        "from_attributes": True  # <-- allows conversion from ORM objects
    }
