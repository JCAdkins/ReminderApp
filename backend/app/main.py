import asyncio
from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, health, oauth, oauth_google, oauth_facebook, reminders, preview
from app.db import Base, engine
from app.services.notifications.worker import notification_worker


# Create tables
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    worker_task = asyncio.create_task(notification_worker())

    try:
        yield
    finally:
        # Shutdown
        worker_task.cancel()
        try:
            await worker_task
        except asyncio.CancelledError:
            pass

app = FastAPI(
    title="iRemind",
    version="0.1.1",
    lifespan=lifespan,
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
app.include_router(preview.router)

@app.get("/home")
async def root():
    return {"message": "Backend is running!"}
