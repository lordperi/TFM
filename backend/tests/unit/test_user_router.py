
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from src.main import app
from src.infrastructure.db.database import Base, get_db
from src.infrastructure.api.dependencies import get_current_user
from src.infrastructure.db.models import UserModel, PatientModel
import uuid
from src.infrastructure.security.auth import get_password_hash

# Local fixtures removed to use conftest.py fixtures which handle engine patching and lifespan correctly.


# Fixture para un usuario autenticado
@pytest.fixture(scope="function")
def authenticated_user(db_session, client):
    # Crear usuario en DB
    user_id = uuid.uuid4()
    user = UserModel(
        id=user_id,
        email=f"test_user_{user_id}@example.com",
        hashed_password=get_password_hash("password123"),
        is_active=True
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)

    # Override get_current_user para simular autenticación
    app.dependency_overrides[get_current_user] = lambda: user
    
    return user

def test_get_current_user_me(client, authenticated_user):
    """
    Test que verifica el endpoint GET /users/me
    """
    response = client.get("/api/v1/users/me")
    
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == authenticated_user.email
    assert data["id"] == str(authenticated_user.id)
    assert "hashed_password" not in data

def test_get_current_user_me_unauthorized(client):
    """
    Test que verifica el endpoint GET /users/me sin autenticación
    """
    # Asegurarse de que no haya override de autenticación
    if get_current_user in app.dependency_overrides:
        del app.dependency_overrides[get_current_user]
        
    response = client.get("/api/v1/users/me")
    assert response.status_code == 401
