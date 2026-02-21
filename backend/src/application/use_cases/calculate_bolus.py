from typing import List, Dict
from src.domain.nutrition import calculate_daily_bolus
from src.application.repositories.nutrition_repository import NutritionRepository

def execute_calculate_bolus(
    current_glucose: float, 
    target_glucose: float, 
    icr: float, 
    isf: float, 
    ingredients_input: List[Dict], 
    repo: NutritionRepository
) -> dict:
    """
    [Backend Ninja] Caso de Uso: Calcula el Bolus total (Corrección + Comida).
    """
    total_carbs = 0.0
    for item in ingredients_input:
        ing_id = item.get("ingredient_id")
        weight = item.get("weight_grams", 0)
        
        ingredient = repo.get_ingredient_by_id(ing_id)
        if ingredient:
            carbs_for_weight = (ingredient.carbs_per_100g / 100.0) * weight
            total_carbs += carbs_for_weight

    recommended_bolus = calculate_daily_bolus(
        total_carbs=total_carbs, 
        icr=icr, 
        current_glucose=current_glucose, 
        target_glucose=target_glucose, 
        isf=isf
    )

    return {
        "total_carbs_grams": round(total_carbs, 2),
        "recommended_bolus_units": round(recommended_bolus, 2)
    }
