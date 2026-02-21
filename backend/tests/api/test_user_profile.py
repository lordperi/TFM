from fastapi.testclient import TestClient
import pytest
from src.main import app

# Como estamos en fase TDD y el router aún no está montado en main,
# este test fallará (Red). Es el comportamiento esperado.

# client = TestClient(app) # REMOVED: Use fixture instead

def test_create_user_with_valid_health_profile(client):
    payload = {
        "email": "test_patient@example.com",
        "password": "StrongPassword123!",
        "full_name": "Test Patient",
        "health_profile": {
            "diabetes_type": "T1",
            "insulin_sensitivity": 40.5, # 1 unidad baja 40.5 mg/dL
            "carb_ratio": 10.0,          # 1 unidad cubre 10g carbohidratos
            "target_glucose": 110
        }
    }
    
    # Simular POST
    response = client.post("/api/v1/users/register", json=payload)
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == payload["email"]
    assert data["health_profile"]["diabetes_type"] == "T1"
    assert "id" in data

def test_create_user_invlalid_sensitivity_rejects(client):
    """Valida reglas de negocio críticas de salud"""
    payload = {
        "email": "unsafe@example.com",
        "password": "123",
        "health_profile": {
            "diabetes_type": "T1",
            "insulin_sensitivity": -5, # IMPOSIBLE BIOLÓGICAMENTE
            "carb_ratio": 10
        }
    }
    response = client.post("/api/v1/users/register", json=payload)
    assert response.status_code == 422
