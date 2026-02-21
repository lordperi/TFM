from fastapi.testclient import TestClient
import jwt
from src.infrastructure.security.jwt_handler import SECRET_KEY, ALGORITHM

def test_login_successful_flow(client):
    """Verifica que el usuario puede obtener un token válido"""
    # 1. Register
    reg_data = {
        "email": "jwt_user@example.com",
        "password": "SecurePass123!",
        "full_name": "JWT Test",
        "health_profile": {
            "diabetes_type": "T1",
            "insulin_sensitivity": 30.0,
            "carb_ratio": 15.0,
            "target_glucose": 100
        }
    }
    client.post("/api/v1/users/register", json=reg_data)

    # 2. Login (Form Data, not JSON)
    login_data = {
        "username": "jwt_user@example.com",
        "password": "SecurePass123!"
    }
    response = client.post("/api/v1/auth/login", data=login_data)
    
    # Debug si falla
    if response.status_code != 200:
        print(response.json())

    assert response.status_code == 200
    token_resp = response.json()
    assert "access_token" in token_resp
    assert token_resp["token_type"] == "bearer"
    
    # 3. Verify Token contents locally
    decoded = jwt.decode(token_resp["access_token"], SECRET_KEY, algorithms=[ALGORITHM])
    assert decoded["sub"] is not None # Debe contener el ID del user

def test_login_invalid_credentials_returns_401(client):
    """Verifica rechazo de password incorrecto"""
    # 1. Register
    reg_data = {
        "email": "hacker@example.com",
        "password": "RealPassword",
        "health_profile": {
            "diabetes_type": "T1",
            "insulin_sensitivity": 30.0,
            "carb_ratio": 15.0,
            "target_glucose": 100
        }
    }
    client.post("/api/v1/users/register", json=reg_data)

    # 2. Bad Login
    login_data = {"username": "hacker@example.com", "password": "WrongPassword"}
    response = client.post("/api/v1/auth/login", data=login_data)
    
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]
