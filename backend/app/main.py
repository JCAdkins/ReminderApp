from fastapi import FastAPI
from app.routers import auth, health, oauth, oauth_google
from app.db import Base, engine

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Reminder App",
    version="0.1.1",
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(oauth.router)
app.include_router(oauth_google.router)

@app.get("/home")
async def root():
    return {"message": "Backend is running!"}
