
import pytest
from datetime import datetime
from pydantic import ValidationError

class TestGlucoseTrackingModels:
    """
    Test Suite for Glucose Tracking Logic (DTOs & Domain).
    RED PHASE: Fails until implementation.
    """

    def test_glucose_measurement_dto_validation(self):
        """
        RED TEST: Verify GlucoseCreateRequest validation logic.
        """
        # Intentional import error until implemented
        from src.domain.glucose_models import GlucoseCreateRequest, GlucoseType
        
        # Valid creation
        dto = GlucoseCreateRequest(
            value=120,
            timestamp=datetime.now(),
            measurement_type=GlucoseType.FINGER
        )
        assert dto.value == 120
        assert dto.measurement_type == GlucoseType.FINGER

        # Invalid value (too low)
        with pytest.raises(ValidationError):
            GlucoseCreateRequest(value=10, timestamp=datetime.now(), measurement_type=GlucoseType.FINGER)

        # Invalid value (too high)
        with pytest.raises(ValidationError):
            GlucoseCreateRequest(value=1000, timestamp=datetime.now(), measurement_type=GlucoseType.FINGER)

    def test_health_profile_target_ranges(self):
        """
        RED TEST: Verify target ranges in HealthProfile.
        """
        from src.domain.user_models import HealthProfileBase
        
        # Valid ranges
        profile = HealthProfileBase(
            target_range_low=70,
            target_range_high=180
        )
        assert profile.target_range_low == 70
        assert profile.target_range_high == 180

        # Invalid: Low >= High
        with pytest.raises(ValidationError):
            HealthProfileBase(
                target_range_low=100,
                target_range_high=90 # Error: Low > High
            )

    def test_glucose_measurement_sqlalchemy_model(self, db_session):
        """
        RED TEST: Verify SQLAlchemy model creation and relationships.
        """
        from src.infrastructure.db.models import GlucoseMeasurementModel, PatientModel
        from uuid import uuid4

        # Create dummy patient
        patient = PatientModel(
            id=uuid4(), 
            display_name="Test Kid", 
            guardian_id=uuid4()
        )
        db_session.add(patient)
        db_session.commit()

        # Create measurement
        measurement = GlucoseMeasurementModel(
            patient_id=patient.id,
            glucose_value=150,
            timestamp=datetime.utcnow(),
            measurement_type="FINGER"
        )
        db_session.add(measurement)
        db_session.commit()

        assert measurement.id is not None
        assert measurement.patient_id == patient.id
