from pydantic import BaseModel


class GoogleWebLogin(BaseModel):
    email: str
    google_id: str
    access_token: str
    
