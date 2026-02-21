import pytest
from httpx import AsyncClient
class TestNutritionAPI:
    """
    [TDD Enforcer] Pruebas de integración para los Endpoints del Motor Nutricional.
    Fase inicial (RED): Estos tests DEBEN fallar porque los endpoints no existen.
    """

    def test_search_ingredients_endpoint_exists(self, client):
        """Verifica que el endpoint de búsqueda reacciona (incluso si da 401 por Auth)."""
        response = client.get("/api/v1/nutrition/ingredients?q=manzana")
        assert response.status_code != 404, "El endpoint de búsqueda de ingredientes debe existir"

    def test_calculate_bolus_endpoint_exists(self, client):
        """Verifica que el endpoint de cálculo de bolus reacciona."""
        payload = {
            "current_glucose": 150.0,
            "target_glucose": 100.0,
            "ingredients": [{"ingredient_id": "uuid-aqui", "weight_grams": 200}]
        }
        response = client.post("/api/v1/nutrition/bolus/calculate", json=payload)
        assert response.status_code != 404, "El endpoint de cálculo de bolus debe existir"

    def test_log_meal_endpoint_exists(self, client):
        """Verifica que el endpoint de registro de comida reacciona."""
        payload = {
            "patient_id": "uuid-aqui",
            "ingredients": [{"ingredient_id": "uuid-aqui", "weight_grams": 150}],
            "notes": "Me siento mareado"
        }
        response = client.post("/api/v1/nutrition/meals", json=payload)
        assert response.status_code != 404, "El endpoint de registro de comida debe existir"
