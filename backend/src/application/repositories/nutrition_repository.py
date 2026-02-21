from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from sqlalchemy import or_

from src.infrastructure.db.models import IngredientModel, MealLogModel, MealItemModel

class NutritionRepository:
    """
    [Lead Architect] Capa de Acceso a Datos (Repository Pattern) 
    para la persistencia y lectura de ingredientes y comidas.
    Se comunica exclusivamente con la abstracción SQLAlchemy.
    """
    def __init__(self, db: Session):
        self.db = db

    def search_ingredients(self, query: str, limit: int = 20) -> List[IngredientModel]:
        """Busca alimentos por coincidencias parciales en el nombre."""
        return self.db.query(IngredientModel).filter(
            IngredientModel.name.ilike(f"%{query}%")
        ).limit(limit).all()

    def get_ingredient_by_id(self, it_id: UUID) -> Optional[IngredientModel]:
        """Obtiene un ingrediente exacto."""
        return self.db.query(IngredientModel).filter(IngredientModel.id == it_id).first()

    def log_meal(self, meal: MealLogModel) -> MealLogModel:
        """Persiste un registro de comida junto con sus items."""
        self.db.add(meal)
        self.db.commit()
        self.db.refresh(meal)
        return meal
