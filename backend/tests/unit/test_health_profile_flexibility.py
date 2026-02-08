import pytest
import uuid
from src.infrastructure.db.models import PatientModel, UserModel
from src.infrastructure.api.dependencies import get_current_user_id

def test_create_guardian_without_health_profile(client, db_session):
    """
    Test that we can create a patient (e.g. Guardian/Adult) without providing
    diabetes-specific metrics (diabetes_type, insulin_sensitivity, etc.)
    """
    # 1. Setup Guardian User
    guardian_id = uuid.uuid4()
    guardian = UserModel(
        id=guardian_id,
        email=f"flex_test_{guardian_id}@example.com",
        hashed_password="mock_password",
        full_name="Flex Test Guardian"
    )
    db_session.add(guardian)
    db_session.commit()
    
    # 2. Override Auth
    client.app.dependency_overrides[get_current_user_id] = lambda: str(guardian_id)
    
    try:
        payload = {
            "display_name": "Non-Diabetic Mom",
            "theme_preference": "adult",
            "role": "GUARDIAN",
            "birth_date": "1980-01-01",
            "pin": "1234",
            # Explicitly omitting health connection fields
        }
        
        response = client.post("/api/v1/family/members", json=payload)
        
        assert response.status_code == 200, response.text
        data = response.json()
        assert data["display_name"] == "Non-Diabetic Mom"
        assert data["role"] == "GUARDIAN"
        
        # Verify DB
        patient = db_session.query(PatientModel).filter_by(display_name="Non-Diabetic Mom").first()
        assert patient is not None
        assert patient.health_profile is not None
        
        # Ensure health fields are None/Null
        hp = patient.health_profile
        # API might return defaults if Pydantic model has them, but we removed defaults in previous step.
        # However, DB columns are nullable.
        assert hp.diabetes_type == "NONE" or hp.diabetes_type is None
        assert hp.insulin_sensitivity is None
        
    finally:
        del client.app.dependency_overrides[get_current_user_id]

def test_update_sensitive_fields_requires_pin(client, db_session):
    """
    Test that sensitive fields (role, health data) require a PIN if the patient has one protected.
    Non-sensitive fields (theme, display_name) should be allowed without PIN.
    """
    # 1. Setup Guardian & Patient with PIN
    guardian_id = uuid.uuid4()
    guardian = UserModel(
        id=guardian_id,
        email=f"pin_test_{guardian_id}@example.com",
        hashed_password="mock_password",
        full_name="Pin Test Guardian"
    )
    db_session.add(guardian)
    db_session.commit()
    
    patient_id = uuid.uuid4()
    patient = PatientModel(
        id=patient_id,
        guardian_id=guardian_id,
        display_name="Protected Kid",
        role="DEPENDENT",
        pin_hash="1234", # Protected!
        theme_preference="child"
    )
    db_session.add(patient)
    db_session.commit()
    
    # 2. Override Auth
    client.app.dependency_overrides[get_current_user_id] = lambda: str(guardian_id)
    
    try:
        # A. Update Theme (Non-Sensitive) - Should SUCCEED without PIN
        resp_theme = client.patch(f"/api/v1/family/members/{patient_id}", json={
            "theme_preference": "teen"
        })
        assert resp_theme.status_code == 200
        assert resp_theme.json()["theme_preference"] == "teen"
        
        # B. Update Sensitive (Role) without PIN - Should FAIL
        resp_fail = client.patch(f"/api/v1/family/members/{patient_id}", json={
            "role": "GUARDIAN"
        })
        assert resp_fail.status_code == 401
        
        # C. Update Sensitive (Health) without PIN - Should FAIL
        resp_fail_health = client.patch(f"/api/v1/family/members/{patient_id}", json={
            "diabetes_type": "T2"
        })
        assert resp_fail_health.status_code == 401
        
        # D. Update Sensitive WITH PIN - Should SUCCEED
        # Note: We need to update PatientUpdateRequest to accept 'pin'
        resp_success = client.patch(f"/api/v1/family/members/{patient_id}", json={
            "role": "GUARDIAN",
            "pin": "1234"
        })
        assert resp_success.status_code == 200
        assert resp_success.json()["role"] == "GUARDIAN"
        
    finally:
        if get_current_user_id in client.app.dependency_overrides:
            del client.app.dependency_overrides[get_current_user_id]
