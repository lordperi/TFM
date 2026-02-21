from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel

from src.infrastructure.db.database import get_db
from src.infrastructure.api.dependencies import get_current_user_id
from src.application.repositories.nutrition_repository import NutritionRepository
from src.application.use_cases.search_ingredients import execute_search
from src.application.use_cases.calculate_bolus import execute_calculate_bolus
from src.application.use_cases.log_meal import execute_log_meal

router = APIRouter(prefix="/nutrition", tags=["Nutrition Engine"])

def get_nutrition_repo(db: Session = Depends(get_db)) -> NutritionRepository:
    return NutritionRepository(db)

# --- Pydantic Schemas (DTOS) ---
class IngredientResponse(BaseModel):
    id: UUID
    name: str
    glycemic_index: int
    carbs_per_100g: float
    fiber_per_100g: float
    
    model_config = {"from_attributes": True}

class IngredientInput(BaseModel):
    ingredient_id: UUID
    weight_grams: float

class BolusCalcRequest(BaseModel):
    current_glucose: float
    target_glucose: float
    ingredients: List[IngredientInput]
    icr: float = 10.0  
    isf: float = 50.0  

class BolusCalcResponse(BaseModel):
    total_carbs_grams: float
    recommended_bolus_units: float

class LogMealRequest(BaseModel):
    patient_id: UUID
    ingredients: List[IngredientInput]
    notes: Optional[str] = None
    bolus_units_administered: Optional[float] = None

class MealLogResponse(BaseModel):
    id: UUID
    patient_id: UUID
    total_carbs_grams: float
    total_glycemic_load: float
    bolus_units_administered: Optional[float] = None
    timestamp: Optional[datetime] = None

    model_config = {"from_attributes": True}

# --- ENDPOINTS ---

@router.get("/ingredients", response_model=List[IngredientResponse])
def search_ingredients(
    q: str = Query(..., min_length=2, description="Nombre del alimento a buscar"),
    limit: int = 20,
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Búsqueda por nombre de ingredientes."""
    results = execute_search(query=q, repo=repo, limit=limit)
    return results

@router.post("/bolus/calculate", response_model=BolusCalcResponse)
def calculate_bolus(
    payload: BolusCalcRequest,
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Calcula el bolus de insulina basado en carbohidratos, glucemia actual y objetivos."""
    ing_dicts = [{"ingredient_id": i.ingredient_id, "weight_grams": i.weight_grams} for i in payload.ingredients]
    result = execute_calculate_bolus(
        current_glucose=payload.current_glucose,
        target_glucose=payload.target_glucose,
        icr=payload.icr,
        isf=payload.isf,
        ingredients_input=ing_dicts,
        repo=repo
    )
    return result

@router.post("/meals", response_model=MealLogResponse)
def log_meal(
    payload: LogMealRequest,
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Registra una ingesta en el historial del paciente, encriptando notas (PHI)."""
    ing_dicts = [{"ingredient_id": i.ingredient_id, "weight_grams": i.weight_grams} for i in payload.ingredients]
    try:
        meal = execute_log_meal(
            patient_id=payload.patient_id,
            ingredients_input=ing_dicts,
            notes=payload.notes,
            bolus_units_administered=payload.bolus_units_administered,
            repo=repo
        )
        return MealLogResponse(
            id=meal.id,
            patient_id=meal.patient_id,
            total_carbs_grams=meal.total_carbs_grams,
            total_glycemic_load=meal.total_glycemic_load,
            bolus_units_administered=meal.bolus_units_administered,
            timestamp=meal.timestamp,
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/meals/history", response_model=List[MealLogResponse])
def get_meal_history(
    patient_id: UUID = Query(...),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    start_date: Optional[datetime] = Query(None, description="Filtro fecha inicio (ISO 8601)"),
    end_date: Optional[datetime] = Query(None, description="Filtro fecha fin (ISO 8601)"),
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Devuelve el historial de comidas registradas para un paciente, más reciente primero."""
    meals = repo.get_meal_history(
        patient_id=patient_id,
        limit=limit,
        offset=offset,
        start_date=start_date,
        end_date=end_date,
    )
    return [
        MealLogResponse(
            id=m.id,
            patient_id=m.patient_id,
            total_carbs_grams=m.total_carbs_grams,
            total_glycemic_load=m.total_glycemic_load,
            bolus_units_administered=m.bolus_units_administered,
            timestamp=m.timestamp.isoformat() if m.timestamp else None,
        )
        for m in meals
    ]
