"""
Test: Registrar una comida otorga XP al usuario autenticado.

TDD — RED phase: este test debe fallar hasta que log_meal llame a XPRepository.
"""
import pytest
from uuid import uuid4
from src.infrastructure.db.models import UserModel, PatientModel, IngredientModel
from src.infrastructure.security.auth import get_password_hash


@pytest.fixture
def user_with_patient_and_ingredient(db_session):
    """Crea un usuario, su perfil de paciente y un ingrediente de prueba."""
    user = UserModel(
        id=uuid4(),
        email="xptest@example.com",
        hashed_password=get_password_hash("pass1234"),
        full_name="XP Test User",
        is_active=True,
    )
    db_session.add(user)
    db_session.flush()

    patient = PatientModel(
        id=uuid4(),
        guardian_id=user.id,
        display_name="Niño XP",
        theme_preference="child",
        role="DEPENDENT",
        login_code="XPT001",
    )
    db_session.add(patient)
    db_session.flush()

    ingredient = IngredientModel(
        id=uuid4(),
        name="Manzana test",
        glycemic_index=36,
        carbs_per_100g=13.8,
        fiber_per_100g=2.4,
    )
    db_session.add(ingredient)
    db_session.commit()

    return {
        "user_id": str(user.id),
        "email": "xptest@example.com",
        "password": "pass1234",
        "patient_id": str(patient.id),
        "ingredient_id": str(ingredient.id),
    }


@pytest.fixture
def auth_headers(client, user_with_patient_and_ingredient):
    data = user_with_patient_and_ingredient
    resp = client.post(
        "/api/v1/auth/login",
        data={"username": data["email"], "password": data["password"]},
    )
    assert resp.status_code == 200
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


class TestMealLoggingAwardsXP:
    """Registrar una comida debe añadir XP al usuario autenticado."""

    def test_log_meal_awards_xp(
        self, client, user_with_patient_and_ingredient, auth_headers
    ):
        data = user_with_patient_and_ingredient

        # Obtener XP antes
        xp_before = client.get(
            "/api/v1/users/me/xp-summary", headers=auth_headers
        ).json()["total_xp"]

        # Registrar comida
        payload = {
            "patient_id": data["patient_id"],
            "ingredients": [
                {"ingredient_id": data["ingredient_id"], "weight_grams": 150}
            ],
            "bolus_units_administered": 1.0,
        }
        resp = client.post(
            "/api/v1/nutrition/meals", json=payload, headers=auth_headers
        )
        assert resp.status_code == 200, f"log_meal falló: {resp.text}"

        # Obtener XP después
        xp_after = client.get(
            "/api/v1/users/me/xp-summary", headers=auth_headers
        ).json()["total_xp"]

        assert xp_after > xp_before, (
            f"Se esperaba que registrar una comida otorgara XP. "
            f"XP antes: {xp_before}, XP después: {xp_after}"
        )

    def test_log_meal_xp_reason_is_meal_logged(
        self, client, user_with_patient_and_ingredient, auth_headers
    ):
        """La transacción de XP debe tener reason='meal_logged'."""
        data = user_with_patient_and_ingredient

        payload = {
            "patient_id": data["patient_id"],
            "ingredients": [
                {"ingredient_id": data["ingredient_id"], "weight_grams": 100}
            ],
        }
        client.post("/api/v1/nutrition/meals", json=payload, headers=auth_headers)

        history = client.get(
            "/api/v1/users/me/xp-history", headers=auth_headers
        ).json()

        reasons = [t["reason"] for t in history]
        assert "meal_logged" in reasons, (
            f"Se esperaba una transacción con reason='meal_logged'. Historial: {reasons}"
        )
