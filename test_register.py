import requests
import json

url = "http://localhost:8001/api/v1/users/register"
payload = {
    "email": "test_bug_422@example.com",
    "password": "PasswordSeguro123",
    "full_name": "Test User",
    "health_profile": {
        "diabetes_type": "NONE",
        "therapy_type": None,
        "insulin_sensitivity": None,
        "carb_ratio": None,
        "target_glucose": None
    }
}

try:
    response = requests.post(url, json=payload)
    print(f"Status Code: {response.status_code}")
    print("Response Body:")
    print(json.dumps(response.json(), indent=2))
except Exception as e:
    print(f"Error: {e}")
