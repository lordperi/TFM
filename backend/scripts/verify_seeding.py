import requests
import sys

BASE_URL = "https://diabetics-api.jljimenez.es/api/v1"
INGREDIENTS_ENDPOINT = f"{BASE_URL}/nutrition/ingredients"

def verify_seeding():
    print(f"🔍 [VERIFY] Checking ingredients at {INGREDIENTS_ENDPOINT}...")
    
    try:
        # 1. Search for a common item that SHOULD exist after seeding (e.g., 'Arroz')
        response = requests.get(INGREDIENTS_ENDPOINT, params={"q": "Arroz"})
        
        if response.status_code != 200:
            print(f"❌ API Error: {response.status_code} - {response.text}")
            sys.exit(1)
            
        data = response.json()
        
        if not isinstance(data, list):
            print("❌ Invalid response format (expected list)")
            sys.exit(1)
            
        count = len(data)
        print(f"ℹ️ Found {count} items matching 'Arroz'.")
        
        # 2. Assert Expectations
        # For Phase Red (Before Seeding), we expect this to likely be empty or low count.
        # But specifically, we want to verify specific SEED items exist.
        
        # Let's check for a specific "Seed Signature" item or just 15 items total?
        # A simple check: If empty, it's 'Unseeded'. If populated, 'Seeded'.
        
        if count == 0:
            print("⚠️ [RED PHASE] Database seems empty or missing target data.")
            # In Red Phase, getting 0 is technically "Success" of the check "Is it empty?" 
            # but for the test pipeline, we want to know if seeding IS DONE.
            # So, return 0 (Fail) if we expect seeded data.
            # But the Orchestrator wants to confirm it FAILS first.
            sys.exit(1) # Return Error to indicate "Not Seeded Yet"
            
        print("✅ [GREEN PHASE] Data found. Seeding verification passed.")
        sys.exit(0)

    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    verify_seeding()
