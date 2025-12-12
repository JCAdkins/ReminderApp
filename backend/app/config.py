# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRES_DAYS: int = 7
    GOOGLE_CLIENT_ID: str 

    class Config: 
        env_file = ".env",
        extra = "allow"

settings = Settings()
