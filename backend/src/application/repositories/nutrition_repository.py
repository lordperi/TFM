from typing import List, Optional
from uuid import UUID
from datetime import datetime
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

    def create_ingredient(self, name: str, glycemic_index: int, carbs_per_100g: float, fiber_per_100g: float = 0.0) -> IngredientModel:
        """Crea un nuevo ingrediente. Lanza ValueError si el nombre ya existe."""
        existing = self.db.query(IngredientModel).filter(
            IngredientModel.name.ilike(name)
        ).first()
        if existing:
            raise ValueError(f"El ingrediente '{name}' ya existe")
        ingredient = IngredientModel(
            name=name,
            glycemic_index=glycemic_index,
            carbs_per_100g=carbs_per_100g,
            fiber_per_100g=fiber_per_100g,
        )
        self.db.add(ingredient)
        self.db.commit()
        self.db.refresh(ingredient)
        return ingredient

    def bulk_create_ingredients(self, items: list[dict]) -> int:
        """Inserta ingredientes que no existan aún. Devuelve el número insertado."""
        inserted = 0
        for item in items:
            exists = self.db.query(IngredientModel).filter(
                IngredientModel.name.ilike(item["name"])
            ).first()
            if not exists:
                self.db.add(IngredientModel(**item))
                inserted += 1
        self.db.commit()
        return inserted

    def get_meal_history(
        self,
        patient_id: UUID,
        limit: int = 20,
        offset: int = 0,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> List[MealLogModel]:
        """Devuelve el historial de comidas de un paciente, más reciente primero."""
        q = (
            self.db.query(MealLogModel)
            .filter(MealLogModel.patient_id == patient_id)
        )
        if start_date is not None:
            q = q.filter(MealLogModel.timestamp >= start_date)
        if end_date is not None:
            q = q.filter(MealLogModel.timestamp <= end_date)
        return q.order_by(MealLogModel.timestamp.desc()).offset(offset).limit(limit).all()
