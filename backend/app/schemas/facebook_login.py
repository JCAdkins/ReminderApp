from pydantic import BaseModel


class FacebookMobileLoginRequest(BaseModel):
    id_token: str