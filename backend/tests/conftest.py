import pytest
import os
import sys
from unittest.mock import patch

# Add project root to sys.path to ensure src module can be found
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient
from src.main import app
from src.infrastructure.db.database import Base, get_db

# Use SQLite in-memory for testing to avoid external dependencies
TEST_DATABASE_URL = "sqlite:///:memory:"

@pytest.fixture(scope="session")
def engine():
    """
    Create a single engine for the test session.
    StaticPool is critical for in-memory SQLite to persist state across connections.
    """
    engine = create_engine(
        TEST_DATABASE_URL, 
        connect_args={"check_same_thread": False},
        poolclass=StaticPool
    )
    
    # Create tables
    Base.metadata.create_all(bind=engine)
    
    yield engine
    
    Base.metadata.drop_all(bind=engine)
    engine.dispose()

@pytest.fixture(scope="function")
def db_session(engine):
    """
    Yields a SQLAlchemy session for each test function.
    Mocks the get_db dependency.
    """
    connection = engine.connect()
    transaction = connection.begin()
    
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=connection)
    session = SessionLocal()
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture(scope="function")
def client(db_session):
    """
    Override the get_db dependency with the test session.
    """
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
            
    # Override lifespan to avoid real DB connection startup
    from contextlib import asynccontextmanager
    
    @asynccontextmanager
    async def mock_lifespan(app):
        print("DEBUG: mock_lifespan ENTERED")
        yield

    # Save original and override
    original_lifespan = app.router.lifespan_context
    app.router.lifespan_context = mock_lifespan
    
    # Patch SessionLocal to ensure get_db always returns the test session
    # Also patch global engine to prevent any accidental production DB connections
    with patch("src.infrastructure.db.database.SessionLocal", return_value=db_session), \
         patch("src.main.engine", engine), \
         patch("src.infrastructure.db.database.engine", engine):
        
        app.dependency_overrides[get_db] = override_get_db
        with TestClient(app) as c:
            yield c
        
    # Restore
    app.router.lifespan_context = original_lifespan
    app.dependency_overrides.clear()
