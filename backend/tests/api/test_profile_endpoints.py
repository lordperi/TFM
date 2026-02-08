"""
Tests for Profile Management Endpoints

Tests for user profile retrieval, health profile updates, password changes,
XP history, and achievements endpoints. Follows TDD approach.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from uuid import uuid4

from src.infrastructure.db.database import Base, get_db
from src.infrastructure.db.models import UserModel, HealthProfileModel
from src.main import app
from src.application.services.auth import get_password_hash


# Test Database Setup
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test_profile.db"
engine = create_engine(SQLALCHEMY_TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_database():
    """Create tables before each test and drop after"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def test_user_with_profile():
    """Create a test user with health profile"""
    db = TestingSessionLocal()
    user = UserModel(
        id=uuid4(),
        email="testuser@example.com",
        hashed_password=get_password_hash("password123"),
        full_name="Test User",
        is_active=True
    )
    db.add(user)
    db.commit()
    
    health_profile = HealthProfileModel(
        user_id=user.id,
        diabetes_type="type_1",
        insulin_sensitivity="50.0",  # Stored as string in encrypted field
        carb_ratio="10.0",
        target_glucose="100"
    )
    db.add(health_profile)
    db.commit()
    db.close()
    
    return {"email": "testuser@example.com", "password": "password123", "user_id": str(user.id)}


@pytest.fixture
def authenticated_headers(test_user_with_profile):
    """Get authentication headers for test user"""
    response = client.post(
        "/api/v1/auth/login",
        data={
            "username": test_user_with_profile["email"],
            "password": test_user_with_profile["password"]
        }
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


class TestGetUserProfile:
    """Test GET /api/v1/users/me endpoint"""
    
    def test_get_profile_success(self, test_user_with_profile, authenticated_headers):
        """Test successful profile retrieval"""
        response = client.get("/api/v1/users/me", headers=authenticated_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "testuser@example.com"
        assert data["full_name"] == "Test User"
        assert "health_profile" in data
        assert data["health_profile"]["diabetes_type"] == "type_1"
    
    def test_get_profile_unauthorized(self):
        """Test profile retrieval without authentication"""
        response = client.get("/api/v1/users/me")
        assert response.status_code == 401


class TestUpdateHealthProfile:
    """Test PATCH /api/v1/users/me/health-profile endpoint"""
    
    def test_update_health_profile_success(self, test_user_with_profile, authenticated_headers):
        """Test successful health profile update"""
        update_data = {
            "insulin_sensitivity": 60.0,
            "carb_ratio": 12.0,
            "target_glucose": 110
        }
        
        response = client.patch(
            "/api/v1/users/me/health-profile",
            json=update_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["insulin_sensitivity"] == 60.0
        assert data["carb_ratio"] == 12.0
        assert data["target_glucose"] == 110
    
    def test_update_health_profile_partial(self, test_user_with_profile, authenticated_headers):
        """Test partial update of health profile"""
        update_data = {"target_glucose": 95}
        
        response = client.patch(
            "/api/v1/users/me/health-profile",
            json=update_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["target_glucose"] == 95
        # Other fields should remain unchanged
        assert data["diabetes_type"] == "type_1"
    
    def test_update_health_profile_invalid_data(self, test_user_with_profile, authenticated_headers):
        """Test update with invalid data"""
        update_data = {"insulin_sensitivity": -10}  # Invalid: must be > 0
        
        response = client.patch(
            "/api/v1/users/me/health-profile",
            json=update_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 422  # Validation error
    
    def test_update_health_profile_unauthorized(self):
        """Test update without authentication"""
        update_data = {"target_glucose": 100}
        response = client.patch("/api/v1/users/me/health-profile", json=update_data)
        assert response.status_code == 401


class TestChangePassword:
    """Test POST /api/v1/users/me/change-password endpoint"""
    
    def test_change_password_success(self, test_user_with_profile, authenticated_headers):
        """Test successful password change"""
        password_data = {
            "old_password": "password123",
            "new_password": "newpassword456",
            "confirm_password": "newpassword456"
        }
        
        response = client.post(
            "/api/v1/users/me/change-password",
            json=password_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 200
        assert response.json()["message"] == "Password changed successfully"
        
        # Verify new password works
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "testuser@example.com", "password": "newpassword456"}
        )
        assert login_response.status_code == 200
    
    def test_change_password_wrong_old_password(self, test_user_with_profile, authenticated_headers):
        """Test password change with incorrect old password"""
        password_data = {
            "old_password": "wrongpassword",
            "new_password": "newpassword456",
            "confirm_password": "newpassword456"
        }
        
        response = client.post(
            "/api/v1/users/me/change-password",
            json=password_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 400
        assert "incorrect" in response.json()["detail"].lower()
    
    def test_change_password_mismatch(self, test_user_with_profile, authenticated_headers):
        """Test password change with mismatched new passwords"""
        password_data = {
            "old_password": "password123",
            "new_password": "newpassword456",
            "confirm_password": "differentpassword789"
        }
        
        response = client.post(
            "/api/v1/users/me/change-password",
            json=password_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 400
        assert "match" in response.json()["detail"].lower()
    
    def test_change_password_too_short(self, test_user_with_profile, authenticated_headers):
        """Test password change with password that's too short"""
        password_data = {
            "old_password": "password123",
            "new_password": "short",
            "confirm password": "short"
        }
        
        response = client.post(
            "/api/v1/users/me/change-password",
            json=password_data,
            headers=authenticated_headers
        )
        
        assert response.status_code == 422  # Validation error
    
    def test_change_password_unauthorized(self):
        """Test password change without authentication"""
        password_data = {
            "old_password": "password123",
            "new_password": "newpassword456",
            "confirm_password": "newpassword456"
        }
        response = client.post("/api/v1/users/me/change-password", json=password_data)
        assert response.status_code == 401


class TestXPHistory:
    """Test GET /api/v1/users/me/xp-history endpoint"""
    
    def test_get_xp_history_empty(self, test_user_with_profile, authenticated_headers):
        """Test XP history retrieval with no transactions"""
        response = client.get("/api/v1/users/me/xp-history", headers=authenticated_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0
    
    def test_get_xp_history_with_transactions(self, test_user_with_profile, authenticated_headers):
        """Test XP history retrieval with transactions (requires XP repository setup)"""
        # This test would require creating XP transactions first
        # For now, testing the endpoint exists and returns 200
        response = client.get("/api/v1/users/me/xp-history", headers=authenticated_headers)
        assert response.status_code == 200
    
    def test_get_xp_history_unauthorized(self):
        """Test XP history retrieval without authentication"""
        response = client.get("/api/v1/users/me/xp-history")
        assert response.status_code == 401


class TestUserAchievements:
    """Test GET /api/v1/users/me/achievements endpoint"""
    
    def test_get_achievements_empty(self, test_user_with_profile, authenticated_headers):
        """Test achievements retrieval with no unlocked achievements"""
        response = client.get("/api/v1/users/me/achievements", headers=authenticated_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "unlocked" in data
        assert "locked" in data
        assert isinstance(data["unlocked"], list)
        assert isinstance(data["locked"], list)
    
    def test_get_achievements_unauthorized(self):
        """Test achievements retrieval without authentication"""
        response = client.get("/api/v1/users/me/achievements")
        assert response.status_code == 401


class TestXPSummary:
    """Test GET /api/v1/users/me/xp-summary endpoint"""
    
    def test_get_xp_summary(self, test_user_with_profile, authenticated_headers):
        """Test XP summary retrieval"""
        response = client.get("/api/v1/users/me/xp-summary", headers=authenticated_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "total_xp" in data
        assert "current_level" in data
        assert "xp_to_next_level" in data
        assert "progress_percentage" in data
        assert data["current_level"] >= 1
