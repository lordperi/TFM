from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager

# Import absolute assuming src is in pythonpath or running as module
from src.infrastructure.api.routers import health

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup event: Connect to DB, etc.
    yield
    # Shutdown event: Close connections

app = FastAPI(
    title="Diabetics Platform API",
    version="0.1.0",
    lifespan=lifespan
)

# --- DevSecOps Requirement: Security Middlewares ---

# Prevent Host Header Injection
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["localhost", "127.0.0.1", "0.0.0.0", "api"] 
)

# CORS Configuration
# Ideally restricted to specific frontend domains in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Routes ---
app.include_router(health.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
