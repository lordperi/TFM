from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
from src.infrastructure.db.database import engine, Base

# Import Routers
from src.infrastructure.api.routers import health, users, auth, nutrition, family

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Establish DB tables on startup (Dev Only - use Alembic for prod)
    Base.metadata.create_all(bind=engine)
    yield
    # Shutdown logic if needed

app = FastAPI(
    title="Diabetics Platform API",
    version="0.1.0",
    lifespan=lifespan
)

# CORS Middleware configuration
# WARNING: In production, restrict allow_origins to specific domains
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "https://diabetics.jljimenez.es",
        "http://localhost", # Allow generic localhost for Flutter random ports
    ],
    allow_origin_regex=r"http://localhost:\d+", # Allow any port on localhost
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Routes ---
app.include_router(health.router)
app.include_router(users.router, prefix="/api/v1")
app.include_router(auth.router, prefix="/api/v1")
app.include_router(nutrition.router, prefix="/api/v1")
app.include_router(family.router, prefix="/api/v1")
from src.infrastructure.api.routers import glucose
app.include_router(glucose.router, prefix="/api/v1")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
