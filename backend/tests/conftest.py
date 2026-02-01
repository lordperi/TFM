import pytest
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool
from fastapi.testclient import TestClient

# Assume main app is importable
from src.main import app

# Configuration for Ephemeral Test DB
# In a real pipeline, service containers (like in GitHub Actions or GitLab CI) provide the DB.
TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL", 
    "postgresql+psycopg2://postgres:postgres@localhost:5432/diabetics_test_db"
)

@pytest.fixture(scope="session")
def engine():
    """
    Create a single engine for the test session.
    Using NullPool to force a new connection for every request if needed, 
    but mainly here to allow clean tearing down.
    """
    engine = create_engine(TEST_DATABASE_URL, poolclass=NullPool)
    
    # Ideally: Create schemas/tables here if models existed
    # Base.metadata.create_all(bind=engine)
    
    yield engine
    
    # Base.metadata.drop_all(bind=engine)
    engine.dispose()

@pytest.fixture(scope="function")
def db_session(engine):
    """
    Yields a SQLAlchemy session with an automated rollback after each test.
    This ensures test isolation.
    """
    connection = engine.connect()
    transaction = connection.begin()
    
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=connection)
    session = SessionLocal()
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture(scope="module")
def client():
    with TestClient(app) as c:
        yield c
