from typing import List
from src.application.repositories.nutrition_repository import NutritionRepository
from src.infrastructure.db.models import IngredientModel

def execute_search(query: str, repo: NutritionRepository, limit: int = 20) -> List[IngredientModel]:
    """
    [Backend Ninja] Caso de Uso: Buscar ingredientes por nombre.
    """
    if not query or len(query.strip()) < 2:
        return []
    
    return repo.search_ingredients(query=query.strip(), limit=limit)
