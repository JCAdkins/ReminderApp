from pydantic import BaseModel


class GoogleMobileLogin(BaseModel):
    id_token: str
