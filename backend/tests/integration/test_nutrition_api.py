from fastapi.testclient import TestClient

def test_full_bolus_calculation_flow(client):
    """
    Integration Test (End-to-End Flow):
    1. Register User & Set Health Profile
    2. Login to get Token
    3. Create Ingredient (Apple)
    4. Calculate Bolus for 200g of Apple
    """
    
    # 1. Register
    email = "integration_test@example.com"
    password = "SecurePass123!"
    reg_resp = client.post("/api/v1/users/register", json={
        "email": email,
        "password": password,
        "full_name": "Integration Tester",
        "health_profile": {
            "diabetes_type": "type_1",
            "insulin_sensitivity": 50.0,
            "carb_ratio": 10.0,
            "target_glucose": 100
        }
    })
    # Fail fast if register fails
    assert reg_resp.status_code == 201, f"Register failed: {reg_resp.text}"
    user_id = reg_resp.json()["id"]

    # 2. Login
    login_resp = client.post("/api/v1/auth/login", data={"username": email, "password": password})
    assert login_resp.status_code == 200
    token = login_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 3. Create Ingredient 'Manzana Golden'
    ing_resp = client.post("/api/v1/nutrition/ingredients", json={
        "name": "Manzana Golden Integration",
        "glycemic_index": 38,
        "carbs_per_100g": 15.0,
        "fiber_per_100g": 2.4
    }, headers=headers)
    assert ing_resp.status_code == 201

    # 4. Search Ingredient (Verify create)
    search_resp = client.get("/api/v1/nutrition/ingredients?q=Manzana", headers=headers)
    assert search_resp.status_code == 200
    results = search_resp.json()
    assert any(r["name"] == "Manzana Golden Integration" for r in results)

    # 5. Calculate Bolus
    # Scenario: Eating 200g of Apple (30g Carbs)
    # Glucose: 250 (Needs correction)
    # Target: 100 (Default)
    # Expected:
    # - Meal: 30g / 10 ICR = 3.0u
    # - Correction: (250 - 100) / 50 ISF = 3.0u
    # - Total: 6.0u
    
    bolus_resp = client.post("/api/v1/nutrition/calculate-bolus", json={
        "patient_id": user_id,
        "total_carbs": 30.0,
        "current_glucose": 250.0
    }, headers=headers)

    assert bolus_resp.status_code == 200
    data = bolus_resp.json()
    
    assert data["units"] == 6.0
    assert data["breakdown"]["carb_insulin"] == 3.0
    assert data["breakdown"]["correction_insulin"] == 3.0
