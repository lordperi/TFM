from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
from src.infrastructure.db.database import engine, Base

# Import Routers
from src.infrastructure.api.routers import health, users

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

# --- DevSecOps Requirement: Security Middlewares ---

# Prevent Host Header Injection
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["localhost", "127.0.0.1", "0.0.0.0", "api", "diabetics-api.jljimenez.es", "api.diabetics-platform.com"] 
)

# CORS Configuration
# Ideally restricted to specific frontend domains in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080", "https://app.jljimenez.es"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Routes ---
app.include_router(health.router)
app.include_router(users.router, prefix="/api/v1")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
