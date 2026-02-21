from typing import List, Dict
from uuid import UUID
from datetime import datetime
from src.application.repositories.nutrition_repository import NutritionRepository
from src.infrastructure.db.models import MealLogModel, MealItemModel
from src.domain.nutrition import calculate_glycemic_load

def execute_log_meal(
    patient_id: UUID,
    ingredients_input: List[Dict],
    notes: str,
    repo: NutritionRepository
) -> MealLogModel:
    """
    [Backend Ninja] Caso de Uso: Registrar una comida en el historial del paciente.
    """
    total_carbs = 0.0
    total_gl = 0.0
    
    meal_items = []
    
    for item in ingredients_input:
        ing_id = item.get("ingredient_id")
        weight = float(item.get("weight_grams", 0))
        
        ingredient = repo.get_ingredient_by_id(ing_id)
        if ingredient:
            # Calcular carbohidratos reales para el peso ingerido
            carbs = (ingredient.carbs_per_100g / 100.0) * weight
            total_carbs += carbs
            
            # Calcular Carga Glucémica (CG) de este alimento
            gl = calculate_glycemic_load(gi=ingredient.glycemic_index, carbs_grams=carbs)
            total_gl += gl
            
            meal_items.append(
                MealItemModel(
                    ingredient_id=ingredient.id,
                    weight_grams=weight
                )
            )

    # Crear el MealLog (Las notas son texto en memoria; el ORM EncryptedString las cifra antes de BD)
    meal = MealLogModel(
        patient_id=patient_id,
        timestamp=datetime.utcnow(),
        total_carbs_grams=total_carbs,
        total_glycemic_load=total_gl,
        notes=notes,
        items=meal_items
    )
    
    return repo.log_meal(meal)
