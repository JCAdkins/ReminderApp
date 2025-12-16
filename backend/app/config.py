# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRES_DAYS: int = 7
    GOOGLE_CID_iOS: str
    GOOGLE_CID_ANDROID: str
    GOOGLE_CID_WEB: str

    class Config: 
        env_file = ".env",
        extra = "allow"

settings = Settings()
