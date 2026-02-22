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
    id: str   # UUID como string para compatibilidad Flutter
    name: str
    glycemic_index: int
    carbs: float         # alias de carbs_per_100g — nombre esperado por el frontend
    fiber_per_100g: float

    @classmethod
    def from_model(cls, m) -> "IngredientResponse":
        return cls(
            id=str(m.id),
            name=m.name,
            glycemic_index=m.glycemic_index,
            carbs=m.carbs_per_100g,
            fiber_per_100g=m.fiber_per_100g,
        )

class IngredientCreateRequest(BaseModel):
    name: str
    glycemic_index: int
    carbs_per_100g: float
    fiber_per_100g: float = 0.0

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
    return [IngredientResponse.from_model(r) for r in results]


@router.post("/ingredients", response_model=IngredientResponse, status_code=status.HTTP_201_CREATED)
def create_ingredient(
    payload: IngredientCreateRequest,
    repo: NutritionRepository = Depends(get_nutrition_repo),
):
    """Crea un nuevo ingrediente en la base de datos."""
    try:
        ingredient = repo.create_ingredient(
            name=payload.name,
            glycemic_index=payload.glycemic_index,
            carbs_per_100g=payload.carbs_per_100g,
            fiber_per_100g=payload.fiber_per_100g,
        )
        return IngredientResponse.from_model(ingredient)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))


# Lista curada de alimentos comunes para el seed inicial
_SEED_INGREDIENTS = [
    {"name": "Arroz blanco cocido",   "glycemic_index": 73, "carbs_per_100g": 28.2, "fiber_per_100g": 0.4},
    {"name": "Arroz integral cocido", "glycemic_index": 50, "carbs_per_100g": 23.0, "fiber_per_100g": 1.8},
    {"name": "Pan blanco",            "glycemic_index": 75, "carbs_per_100g": 49.0, "fiber_per_100g": 2.7},
    {"name": "Pan integral",          "glycemic_index": 51, "carbs_per_100g": 41.0, "fiber_per_100g": 6.0},
    {"name": "Pasta cocida",          "glycemic_index": 55, "carbs_per_100g": 25.0, "fiber_per_100g": 1.8},
    {"name": "Patata cocida",         "glycemic_index": 78, "carbs_per_100g": 17.0, "fiber_per_100g": 1.3},
    {"name": "Patata frita",          "glycemic_index": 63, "carbs_per_100g": 35.0, "fiber_per_100g": 3.4},
    {"name": "Manzana",               "glycemic_index": 36, "carbs_per_100g": 13.8, "fiber_per_100g": 2.4},
    {"name": "Plátano",               "glycemic_index": 51, "carbs_per_100g": 22.8, "fiber_per_100g": 2.6},
    {"name": "Naranja",               "glycemic_index": 43, "carbs_per_100g": 11.8, "fiber_per_100g": 2.4},
    {"name": "Uvas",                  "glycemic_index": 59, "carbs_per_100g": 17.2, "fiber_per_100g": 0.9},
    {"name": "Sandía",                "glycemic_index": 72, "carbs_per_100g": 7.6,  "fiber_per_100g": 0.4},
    {"name": "Fresas",                "glycemic_index": 40, "carbs_per_100g": 7.7,  "fiber_per_100g": 2.0},
    {"name": "Lentejas cocidas",      "glycemic_index": 32, "carbs_per_100g": 20.1, "fiber_per_100g": 7.9},
    {"name": "Garbanzos cocidos",     "glycemic_index": 28, "carbs_per_100g": 27.4, "fiber_per_100g": 7.6},
    {"name": "Leche entera",          "glycemic_index": 31, "carbs_per_100g": 4.8,  "fiber_per_100g": 0.0},
    {"name": "Yogur natural",         "glycemic_index": 35, "carbs_per_100g": 6.0,  "fiber_per_100g": 0.0},
    {"name": "Zumo de naranja",       "glycemic_index": 50, "carbs_per_100g": 10.4, "fiber_per_100g": 0.2},
    {"name": "Coca-Cola 33cl",        "glycemic_index": 63, "carbs_per_100g": 10.6, "fiber_per_100g": 0.0},
    {"name": "Chocolate negro 70%",   "glycemic_index": 23, "carbs_per_100g": 44.0, "fiber_per_100g": 10.9},
    {"name": "Galletas tipo María",   "glycemic_index": 70, "carbs_per_100g": 74.4, "fiber_per_100g": 2.0},
    {"name": "Copos de avena",        "glycemic_index": 55, "carbs_per_100g": 58.7, "fiber_per_100g": 10.1},
    {"name": "Maíz dulce",            "glycemic_index": 52, "carbs_per_100g": 18.7, "fiber_per_100g": 2.7},
    {"name": "Zanahoria cruda",       "glycemic_index": 16, "carbs_per_100g": 9.6,  "fiber_per_100g": 2.8},
    {"name": "Tomate",                "glycemic_index": 15, "carbs_per_100g": 3.9,  "fiber_per_100g": 1.2},
]


@router.post("/ingredients/seed", response_model=dict)
def seed_ingredients(
    repo: NutritionRepository = Depends(get_nutrition_repo),
):
    """Puebla la base de datos con ingredientes comunes si aún no existen."""
    inserted = repo.bulk_create_ingredients(_SEED_INGREDIENTS)
    return {"inserted": inserted, "total_available": len(_SEED_INGREDIENTS)}

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
