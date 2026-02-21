from fastapi.testclient import TestClient
from src.main import app

def test_login_successful_returns_token(client):
    # 1. Register a user first
    register_payload = {
        "email": "login_test@example.com",
        "password": "SecurePassword123!",
        "full_name": "Login User",
        "health_profile": {
            "diabetes_type": "T1",
            "insulin_sensitivity": 30.0,
            "carb_ratio": 15.0,
            "target_glucose": 100
        }
    }
    client.post("/api/v1/users/register", json=register_payload)

    # 2. Attempt Login
    login_payload = {
        "username": "login_test@example.com", # OAuth2 spec uses 'username' field for email usually
        "password": "SecurePassword123!"
    }
    
    # Using OAuth2PasswordRequestForm usually expects form data, but let's see implementation.
    # Standard FastAPI OAuth2 uses form-data not json.
    response = client.post("/api/v1/auth/login", data=login_payload)
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_failed_wrong_password(client):
    register_payload = {
        "email": "fail_test@example.com",
        "password": "SecurePassword123!",
        "health_profile": {
            "diabetes_type": "T1",
            "insulin_sensitivity": 30.0,
            "carb_ratio": 15.0
        }
    }
    client.post("/api/v1/users/register", json=register_payload)

    login_payload = {
        "username": "fail_test@example.com",
        "password": "WrongPassword"
    }
    response = client.post("/api/v1/auth/login", data=login_payload)
    
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json().get("detail", "")
