"""
[TDD Enforcer] RED PHASE
Tests para el endpoint CRUD de ingredientes.
Estos tests deben FALLAR antes de implementar el código.
"""
import pytest


class TestCreateIngredient:
    def test_create_ingredient_returns_201(self, client):
        """POST /ingredients crea un ingrediente y devuelve 201."""
        payload = {
            "name": "Manzana",
            "glycemic_index": 36,
            "carbs_per_100g": 13.8,
            "fiber_per_100g": 2.4,
        }
        response = client.post("/api/v1/nutrition/ingredients", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Manzana"
        assert data["glycemic_index"] == 36
        assert data["carbs"] == 13.8
        assert "id" in data

    def test_create_ingredient_duplicate_name_returns_409(self, client):
        """Crear dos ingredientes con el mismo nombre devuelve 409."""
        payload = {
            "name": "Plátano",
            "glycemic_index": 51,
            "carbs_per_100g": 22.8,
            "fiber_per_100g": 2.6,
        }
        client.post("/api/v1/nutrition/ingredients", json=payload)
        response = client.post("/api/v1/nutrition/ingredients", json=payload)
        assert response.status_code == 409

    def test_create_ingredient_missing_field_returns_422(self, client):
        """Payload incompleto devuelve error de validación 422."""
        response = client.post("/api/v1/nutrition/ingredients", json={"name": "Fresa"})
        assert response.status_code == 422

    def test_search_returns_created_ingredient(self, client):
        """Ingrediente creado es encontrado por búsqueda posterior."""
        client.post("/api/v1/nutrition/ingredients", json={
            "name": "Arroz blanco",
            "glycemic_index": 73,
            "carbs_per_100g": 28.0,
            "fiber_per_100g": 0.4,
        })
        response = client.get("/api/v1/nutrition/ingredients?q=arroz")
        assert response.status_code == 200
        results = response.json()
        assert any(r["name"] == "Arroz blanco" for r in results)

    def test_created_ingredient_id_is_string_uuid(self, client):
        """El id devuelto es un string UUID (compatible con frontend)."""
        response = client.post("/api/v1/nutrition/ingredients", json={
            "name": "Lentejas",
            "glycemic_index": 32,
            "carbs_per_100g": 20.1,
            "fiber_per_100g": 7.9,
        })
        assert response.status_code == 201
        data = response.json()
        import uuid
        uuid.UUID(data["id"])  # debe ser un UUID válido

    def test_search_response_contains_carbs_field(self, client):
        """La búsqueda devuelve campo 'carbs' (no 'carbs_per_100g') para el frontend."""
        client.post("/api/v1/nutrition/ingredients", json={
            "name": "Pan integral",
            "glycemic_index": 51,
            "carbs_per_100g": 47.5,
            "fiber_per_100g": 6.0,
        })
        response = client.get("/api/v1/nutrition/ingredients?q=pan")
        assert response.status_code == 200
        results = response.json()
        assert len(results) > 0
        assert "carbs" in results[0]
        assert "carbs_per_100g" not in results[0]


class TestSeedIngredients:
    def test_seed_populates_database(self, client):
        """POST /ingredients/seed inserta alimentos base y devuelve cuántos se añadieron."""
        response = client.post("/api/v1/nutrition/ingredients/seed")
        assert response.status_code == 200
        data = response.json()
        assert "inserted" in data
        assert data["inserted"] > 0

    def test_seed_is_idempotent(self, client):
        """Llamar seed dos veces no duplica ingredientes."""
        client.post("/api/v1/nutrition/ingredients/seed")
        response = client.post("/api/v1/nutrition/ingredients/seed")
        assert response.status_code == 200
        data = response.json()
        assert data["inserted"] == 0  # 0 nuevos en la segunda llamada
