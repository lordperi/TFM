from fastapi.testclient import TestClient
from unittest.mock import MagicMock
from src.main import app
from src.infrastructure.db.database import get_db
from src.infrastructure.api.dependencies import get_current_user_id

client = TestClient(app)

def test_create_family_member():
    # Mock Auth
    app.dependency_overrides[get_current_user_id] = lambda: "123e4567-e89b-12d3-a456-426614174000"
    
    # Mock DB
    mock_db = MagicMock()
    app.dependency_overrides[get_db] = lambda: mock_db
    
    payload = {
        "display_name": "Test Child",
        "theme_preference": "child",
        "diabetes_type": "Type 1",
        "insulin_sensitivity": "1:50",
        "carb_ratio": "1:10",
        "target_glucose": "100"
    }
    
    response = client.post("/api/v1/family/members", json=payload)
    
    assert response.status_code == 201
    assert "id" in response.json()
    assert response.json()["status"] == "created"
