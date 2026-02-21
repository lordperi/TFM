"""
Regression test: GET /api/v1/family/members/{id} con basal_insulin_units cifrado.

Bug: La columna basal_insulin_units fue creada como VARCHAR (sa.String) en la migración 010,
pero EncryptedString usa impl=LargeBinary (BYTEA). Al leer la columna en PostgreSQL,
SQLAlchemy intentaba bytes(str_value) sin encoding → TypeError → 500.

Fix: Migración que convierte la columna a BYTEA.
"""
import pytest
from uuid import uuid4
from datetime import time

from src.infrastructure.db.models import UserModel, PatientModel, HealthProfileModel
from src.infrastructure.security.auth import get_password_hash


@pytest.fixture
def guardian_with_patient(db_session):
    """Crea un guardián con un paciente que tiene basal_insulin_units configurado."""
    guardian = UserModel(
        id=uuid4(),
        email="guardian_basal@example.com",
        hashed_password=get_password_hash("pass1234"),
        full_name="Guardian Basal Test",
        is_active=True,
    )
    db_session.add(guardian)
    db_session.flush()

    patient = PatientModel(
        id=uuid4(),
        guardian_id=guardian.id,
        display_name="Paciente Basal",
        theme_preference="child",
        role="DEPENDENT",
        login_code="BASAL01",
    )
    db_session.add(patient)
    db_session.flush()

    # Health profile WITH basal_insulin_units — columna problemática
    health_profile = HealthProfileModel(
        patient_id=patient.id,
        diabetes_type="T1",
        insulin_sensitivity="50.0",
        carb_ratio="10.0",
        target_glucose="100",
        basal_insulin_type="Lantus",
        basal_insulin_units="14.5",  # Este valor causaba el 500 en producción
        basal_insulin_time=time(22, 0),
    )
    db_session.add(health_profile)
    db_session.commit()

    return {
        "guardian_email": "guardian_basal@example.com",
        "guardian_password": "pass1234",
        "patient_id": str(patient.id),
    }


@pytest.fixture
def guardian_auth_headers(client, guardian_with_patient):
    response = client.post(
        "/api/v1/auth/login",
        data={
            "username": guardian_with_patient["guardian_email"],
            "password": guardian_with_patient["guardian_password"],
        },
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


class TestGetPatientDetailsWithBasalInsulin:
    """
    Regresión: GET /api/v1/family/members/{patient_id} no debe lanzar 500
    cuando el paciente tiene basal_insulin_units configurado.
    """

    def test_get_patient_details_with_basal_insulin_returns_200(
        self, client, guardian_with_patient, guardian_auth_headers
    ):
        """El endpoint debe devolver 200 y los datos del paciente incluyendo basal_insulin_units."""
        patient_id = guardian_with_patient["patient_id"]

        response = client.get(
            f"/api/v1/family/members/{patient_id}",
            headers=guardian_auth_headers,
        )

        assert response.status_code == 200, (
            f"Se esperaba 200 pero se obtuvo {response.status_code}. "
            f"Body: {response.text}"
        )
        data = response.json()
        assert data["id"] == patient_id
        assert data["diabetes_type"] == "T1"

    def test_get_patient_details_basal_insulin_fields_present(
        self, client, guardian_with_patient, guardian_auth_headers
    ):
        """Los campos de insulina basal deben estar presentes en la respuesta."""
        patient_id = guardian_with_patient["patient_id"]

        response = client.get(
            f"/api/v1/family/members/{patient_id}",
            headers=guardian_auth_headers,
        )

        assert response.status_code == 200
        data = response.json()
        assert data.get("basal_insulin_type") == "Lantus"
        assert data.get("basal_insulin_units") is not None

    def test_get_patient_details_null_basal_insulin_returns_200(
        self, client, db_session, guardian_with_patient, guardian_auth_headers
    ):
        """Paciente sin basal_insulin_units (NULL) también debe devolver 200."""
        # Crear otro paciente sin insulina basal
        guardian_id_str = guardian_with_patient["patient_id"]
        guardian = db_session.query(UserModel).filter_by(
            email="guardian_basal@example.com"
        ).first()

        patient_no_basal = PatientModel(
            id=uuid4(),
            guardian_id=guardian.id,
            display_name="Paciente Sin Basal",
            theme_preference="adult",
            role="DEPENDENT",
            login_code="NOBASAL01",
        )
        db_session.add(patient_no_basal)
        db_session.flush()

        hp = HealthProfileModel(
            patient_id=patient_no_basal.id,
            diabetes_type="T1",
            insulin_sensitivity="40.0",
            carb_ratio="8.0",
            target_glucose="90",
            basal_insulin_units=None,  # NULL explícito
        )
        db_session.add(hp)
        db_session.commit()

        response = client.get(
            f"/api/v1/family/members/{patient_no_basal.id}",
            headers=guardian_auth_headers,
        )

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == str(patient_no_basal.id)
