from fastapi import FastAPI
from app.routers import auth, health, oauth, oauth_google, oauth_facebook, reminders
from app.db import Base, engine
from fastapi.middleware.cors import CORSMiddleware

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="iRemind",
    version="0.1.1",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(oauth.router)
app.include_router(oauth_google.router)
app.include_router(oauth_facebook.router)
app.include_router(reminders.router)


@app.get("/home")
async def root():
    return {"message": "Backend is running!"}
