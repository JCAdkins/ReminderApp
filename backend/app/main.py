from fastapi import FastAPI
from app.routers import health

app = FastAPI(
    title="My SaaS Backend",
    version="0.1.0",
)

app.include_router(health.router)

@app.get("/")
async def root():
    return {"message": "Backend is running!"}
