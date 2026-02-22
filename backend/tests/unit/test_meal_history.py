"""
[TDD Enforcer] RED Phase - Meal History & Bolus Persistence Tests.

Tests:
1. bolus_units_administered is stored when logging a meal.
2. GET /nutrition/meals/history returns the meal list with bolus units.
"""
import pytest
from uuid import uuid4
from sqlalchemy import inspect as sa_inspect

from src.infrastructure.db.models import (
    UserModel, PatientModel, HealthProfileModel, IngredientModel, MealLogModel
)
from src.infrastructure.security.auth import get_password_hash


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _create_user_and_patient(db_session, password="pass1234"):
    """Create a user + patient and return (user, patient_id)."""
    user = UserModel(
        email=f"test_{uuid4().hex[:6]}@example.com",
        hashed_password=get_password_hash(password),
        full_name="Test User",
        is_active=True,
    )
    db_session.add(user)
    db_session.flush()

    patient = PatientModel(
        guardian_id=user.id,
        display_name="Test Patient",
        role="DEPENDENT",
    )
    db_session.add(patient)
    db_session.flush()
    return user, patient.id


def _create_patient(db_session):
    """Create a minimal user + patient and return the patient id."""
    _, patient_id = _create_user_and_patient(db_session)
    return patient_id


def _get_auth_headers(client, user, password="pass1234"):
    """Login and return Authorization headers."""
    resp = client.post(
        "/api/v1/auth/login",
        data={"username": user.email, "password": password},
    )
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def _create_ingredient(db_session, name="Arroz"):
    """Create and return an IngredientModel."""
    ingredient = IngredientModel(
        name=f"{name}_{uuid4().hex[:4]}",
        glycemic_index=70,
        carbs_per_100g=28.0,
        fiber_per_100g=0.4,
    )
    db_session.add(ingredient)
    db_session.flush()
    return ingredient


# ---------------------------------------------------------------------------
# Unit Tests: Model Layer
# ---------------------------------------------------------------------------

class TestMealLogBolusColumn:
    """Verify that MealLogModel exposes bolus_units_administered."""

    def test_column_exists_on_model(self):
        """bolus_units_administered must be a mapped column in MealLogModel."""
        columns = {c.key for c in MealLogModel.__mapper__.columns}
        assert "bolus_units_administered" in columns, (
            "MealLogModel is missing the 'bolus_units_administered' column. "
            "Add it as a Float nullable column."
        )

    def test_column_is_nullable(self):
        """The column must allow NULL (for backwards-compatible meals without bolus data)."""
        col = MealLogModel.__mapper__.columns["bolus_units_administered"]
        assert col.nullable is True

    def test_column_stored_and_retrieved(self, db_session):
        """Round-trip: write bolus_units_administered, read it back."""
        patient_id = _create_patient(db_session)

        meal = MealLogModel(
            patient_id=patient_id,
            total_carbs_grams=60.0,
            total_glycemic_load=25.0,
            bolus_units_administered=3.5,
        )
        db_session.add(meal)
        db_session.commit()

        fetched = db_session.query(MealLogModel).filter_by(id=meal.id).first()
        assert fetched is not None
        assert fetched.bolus_units_administered == pytest.approx(3.5)

    def test_column_nullable_in_db(self, db_session):
        """A meal logged without bolus data should persist without error."""
        patient_id = _create_patient(db_session)

        meal = MealLogModel(
            patient_id=patient_id,
            total_carbs_grams=30.0,
            total_glycemic_load=10.0,
        )
        db_session.add(meal)
        db_session.commit()

        fetched = db_session.query(MealLogModel).filter_by(id=meal.id).first()
        assert fetched.bolus_units_administered is None


# ---------------------------------------------------------------------------
# Integration Tests: API Layer
# ---------------------------------------------------------------------------

class TestLogMealWithBolus:
    """POST /nutrition/meals should accept and persist bolus_units_administered."""

    def test_log_meal_stores_bolus_units(self, client, db_session):
        """Logging a meal with bolus_units_administered stores the value."""
        user, patient_id = _create_user_and_patient(db_session)
        ingredient = _create_ingredient(db_session, "Pollo")
        headers = _get_auth_headers(client, user)

        payload = {
            "patient_id": str(patient_id),
            "ingredients": [
                {"ingredient_id": str(ingredient.id), "weight_grams": 200}
            ],
            "bolus_units_administered": 2.5,
        }

        response = client.post("/api/v1/nutrition/meals", json=payload, headers=headers)
        assert response.status_code == 200, response.text

        data = response.json()
        assert "bolus_units_administered" in data
        assert data["bolus_units_administered"] == pytest.approx(2.5)

    def test_log_meal_without_bolus_units_defaults_null(self, client, db_session):
        """Logging a meal without bolus_units_administered should return None/null."""
        user, patient_id = _create_user_and_patient(db_session)
        ingredient = _create_ingredient(db_session, "Manzana")
        headers = _get_auth_headers(client, user)

        payload = {
            "patient_id": str(patient_id),
            "ingredients": [
                {"ingredient_id": str(ingredient.id), "weight_grams": 150}
            ],
        }

        response = client.post("/api/v1/nutrition/meals", json=payload, headers=headers)
        assert response.status_code == 200, response.text

        data = response.json()
        # bolus_units_administered can be absent or null
        assert data.get("bolus_units_administered") is None


class TestGetMealHistory:
    """GET /nutrition/meals/history must return chronological meal list."""

    def test_returns_empty_list_for_new_patient(self, client, db_session):
        """A patient with no meals should receive an empty list."""
        patient_id = _create_patient(db_session)
        response = client.get(f"/api/v1/nutrition/meals/history?patient_id={patient_id}&limit=20&offset=0")
        assert response.status_code == 200, response.text
        assert response.json() == []

    def test_returns_logged_meals_in_order(self, client, db_session):
        """Meals are returned most-recent first with bolus_units_administered included."""
        user, patient_id = _create_user_and_patient(db_session)
        ingredient = _create_ingredient(db_session, "Pan")
        headers = _get_auth_headers(client, user)

        payload_1 = {
            "patient_id": str(patient_id),
            "ingredients": [{"ingredient_id": str(ingredient.id), "weight_grams": 50}],
            "bolus_units_administered": 1.0,
        }
        payload_2 = {
            "patient_id": str(patient_id),
            "ingredients": [{"ingredient_id": str(ingredient.id), "weight_grams": 100}],
            "bolus_units_administered": 2.0,
        }

        client.post("/api/v1/nutrition/meals", json=payload_1, headers=headers)
        client.post("/api/v1/nutrition/meals", json=payload_2, headers=headers)

        response = client.get(
            f"/api/v1/nutrition/meals/history?patient_id={patient_id}&limit=20&offset=0"
        )
        assert response.status_code == 200, response.text

        meals = response.json()
        assert len(meals) == 2

        # Each entry must contain bolus_units_administered and timestamp
        for meal in meals:
            assert "bolus_units_administered" in meal
            assert "timestamp" in meal
            assert "total_carbs_grams" in meal

    def test_history_respects_limit(self, client, db_session):
        """The limit query parameter caps the number of results."""
        user, patient_id = _create_user_and_patient(db_session)
        ingredient = _create_ingredient(db_session, "Pasta")
        headers = _get_auth_headers(client, user)

        for _ in range(5):
            client.post("/api/v1/nutrition/meals", json={
                "patient_id": str(patient_id),
                "ingredients": [{"ingredient_id": str(ingredient.id), "weight_grams": 80}],
            }, headers=headers)

        response = client.get(
            f"/api/v1/nutrition/meals/history?patient_id={patient_id}&limit=3&offset=0"
        )
        assert response.status_code == 200
        assert len(response.json()) == 3

    def test_history_filters_by_start_date(self, client, db_session):
        """Meals before start_date must be excluded."""
        from datetime import datetime, timezone
        patient_id = _create_patient(db_session)

        # Create meal directly in DB with a specific timestamp
        old_meal = MealLogModel(
            patient_id=patient_id,
            total_carbs_grams=10.0,
            total_glycemic_load=5.0,
            bolus_units_administered=1.0,
            timestamp=datetime(2024, 1, 1, 12, 0, 0, tzinfo=timezone.utc),
        )
        recent_meal = MealLogModel(
            patient_id=patient_id,
            total_carbs_grams=20.0,
            total_glycemic_load=10.0,
            bolus_units_administered=2.0,
            timestamp=datetime(2026, 1, 15, 12, 0, 0, tzinfo=timezone.utc),
        )
        db_session.add_all([old_meal, recent_meal])
        db_session.commit()

        response = client.get(
            f"/api/v1/nutrition/meals/history?patient_id={patient_id}"
            f"&start_date=2026-01-01T00:00:00Z"
        )
        assert response.status_code == 200
        meals = response.json()
        assert len(meals) == 1
        assert meals[0]["bolus_units_administered"] == pytest.approx(2.0)

    def test_history_filters_by_end_date(self, client, db_session):
        """Meals after end_date must be excluded."""
        from datetime import datetime, timezone
        patient_id = _create_patient(db_session)

        old_meal = MealLogModel(
            patient_id=patient_id,
            total_carbs_grams=10.0,
            total_glycemic_load=5.0,
            bolus_units_administered=1.0,
            timestamp=datetime(2024, 6, 1, 12, 0, 0, tzinfo=timezone.utc),
        )
        future_meal = MealLogModel(
            patient_id=patient_id,
            total_carbs_grams=30.0,
            total_glycemic_load=15.0,
            bolus_units_administered=3.0,
            timestamp=datetime(2027, 1, 1, 12, 0, 0, tzinfo=timezone.utc),
        )
        db_session.add_all([old_meal, future_meal])
        db_session.commit()

        response = client.get(
            f"/api/v1/nutrition/meals/history?patient_id={patient_id}"
            f"&end_date=2025-12-31T23:59:59Z"
        )
        assert response.status_code == 200
        meals = response.json()
        assert len(meals) == 1
        assert meals[0]["bolus_units_administered"] == pytest.approx(1.0)
