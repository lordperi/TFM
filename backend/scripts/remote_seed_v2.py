import requests
import json
import sys

# CONFIG
BASE_URL = "https://diabetics-api.jljimenez.es/api/v1"
INGREDIENTS_ENDPOINT = f"{BASE_URL}/nutrition/ingredients"

# DATA SEED (15 Items - Real Data)
# Data source: USDA/Bedca simplified for global usage
SEED_DATA = [
    {"name": "Arroz Blanco Cocido", "glycemic_index": 73, "carbs_per_100g": 28.0, "calories": 130.0, "protein": 2.7, "fat": 0.3},
    {"name": "Arroz Integral Cocido", "glycemic_index": 68, "carbs_per_100g": 23.0, "calories": 111.0, "protein": 2.6, "fat": 0.9},
    {"name": "Pan Blanco (Barra)", "glycemic_index": 75, "carbs_per_100g": 50.0, "calories": 265.0, "protein": 9.0, "fat": 3.0},
    {"name": "Pan Integral", "glycemic_index": 50, "carbs_per_100g": 40.0, "calories": 250.0, "protein": 13.0, "fat": 4.0},
    {"name": "Manzana (con piel)", "glycemic_index": 36, "carbs_per_100g": 14.0, "calories": 52.0, "protein": 0.3, "fat": 0.2},
    {"name": "Plátano (Maduro)", "glycemic_index": 51, "carbs_per_100g": 23.0, "calories": 89.0, "protein": 1.1, "fat": 0.3},
    {"name": "Leche Entera", "glycemic_index": 39, "carbs_per_100g": 4.8, "calories": 61.0, "protein": 3.2, "fat": 3.7},
    {"name": "Yogur Natural (Sin Azúcar)", "glycemic_index": 35, "carbs_per_100g": 4.5, "calories": 60.0, "protein": 3.8, "fat": 3.0},
    {"name": "Pasta (Espaguetis cocidos)", "glycemic_index": 49, "carbs_per_100g": 31.0, "calories": 158.0, "protein": 5.8, "fat": 0.9},
    {"name": "Patata Cocida", "glycemic_index": 78, "carbs_per_100g": 17.0, "calories": 77.0, "protein": 2.0, "fat": 0.1},
    {"name": "Pizza (Porción estándar)", "glycemic_index": 60, "carbs_per_100g": 30.0, "calories": 266.0, "protein": 11.0, "fat": 10.0},
    {"name": "Coca-Cola (Vaso 250ml)", "glycemic_index": 60, "carbs_per_100g": 10.6, "calories": 42.0, "protein": 0.0, "fat": 0.0},
    {"name": "Pollo (Pechuga plancha)", "glycemic_index": 0, "carbs_per_100g": 0.0, "calories": 165.0, "protein": 31.0, "fat": 3.6},
    {"name": "Huevo (Cocido)", "glycemic_index": 0, "carbs_per_100g": 1.1, "calories": 155.0, "protein": 13.0, "fat": 11.0},
    {"name": "Chocolate Negro (70%)", "glycemic_index": 23, "carbs_per_100g": 34.0, "calories": 600.0, "protein": 7.8, "fat": 42.0},
]

def seed_database():
    print(f"🚀 [SEED] Starting remote seeding to {BASE_URL}...")
    success_count = 0
    
    # 1. (Optional) Login Step if API requires it. 
    # Analysing 'nutrition.py', the POST endpoint depends on 'Depends(get_service)'.
    # It does NOT seem to look for 'get_current_user_id' in the signature of 'create_ingredient' in 'nutrition.py'
    # Line 34: @router.post("/ingredients", ...)
    # Line 35: def create_ingredient(ingredient: IngredientCreate, service: NutritionService = Depends(get_service)):
    # Unlike 'calculate_bolus' which has 'user_id=Depends(...)', 'create_ingredient' seems PUBLIC or un-guarded in the router definition provided!
    # If so, we can skip login. Let's try direct POST.
    
    for item in SEED_DATA:
        try:
            print(f"   > Seeding '{item['name']}'...", end=" ")
            resp = requests.post(INGREDIENTS_ENDPOINT, json=item)
            
            if resp.status_code in [200, 201]:
                print("✅ OK")
                success_count += 1
            else:
                print(f"❌ Failed ({resp.status_code}): {resp.text}")
                
        except Exception as e:
            print(f"❌ Error: {e}")

    print(f"\n✨ Seeding Complete. Created {success_count}/{len(SEED_DATA)} items.")

if __name__ == "__main__":
    seed_database()
