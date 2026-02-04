from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List

from src.infrastructure.db.database import get_db
from src.infrastructure.api.schemas.nutrition import BolusRequest, BolusResponse, IngredientCreate, IngredientResponse
from src.infrastructure.api.dependencies import get_current_user_id
from src.application.services.nutrition_service import NutritionService

router = APIRouter(prefix="/nutrition", tags=["Nutrition"])

def get_service(db: Session = Depends(get_db)) -> NutritionService:
    return NutritionService(db)

@router.post("/calculate-bolus", response_model=BolusResponse)
def calculate_bolus(
    req: BolusRequest,
    user_id: str = Depends(get_current_user_id),
    service: NutritionService = Depends(get_service)
):
    """
    Calculates insulin bolus via Application Service.
    """
    result = service.calculate_bolus(
        user_id=str(user_id), # Ensure string for UUID conversion in Service if needed, or pass as is
        patient_id=req.patient_id,
        carbs=req.total_carbs,
        glucose=req.current_glucose,
        icr_override=req.icr,
        isf_override=req.isf,
        target_override=req.target_glucose
    )
    return BolusResponse(**result)

@router.post("/ingredients", response_model=IngredientResponse, status_code=status.HTTP_201_CREATED)
def create_ingredient(
    ingredient: IngredientCreate,
    service: NutritionService = Depends(get_service)
):
    return service.create_ingredient(ingredient.model_dump())

@router.get("/ingredients", response_model=List[IngredientResponse])
def search_ingredients(
    q: str = "",
    skip: int = 0,
    limit: int = 10,
    service: NutritionService = Depends(get_service)
):
    return service.search_ingredients(q, skip, limit)
