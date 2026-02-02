from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from uuid import UUID

class BolusRequest(BaseModel):
    total_carbs: float = Field(..., gt=0, description="Total carbohydrates in grams")
    current_glucose: float = Field(..., gt=0, description="Current blood glucose in mg/dL")
    target_glucose: Optional[float] = Field(100.0, gt=70, description="Target glucose (override DB profile default)")
    # Override optionals for quick calculations without fetching profile
    icr: Optional[float] = Field(None, gt=0, description="Insulin-to-Carb Ratio (optional override)")
    isf: Optional[float] = Field(None, gt=0, description="Insulin Sensitivity Factor (optional override)")

class BolusResponse(BaseModel):
    units: float
    breakdown: dict # {"carb_insulin": x, "correction_insulin": y}

class IngredientBase(BaseModel):
    name: str
    glycemic_index: int = Field(..., ge=0, le=100)
    carbs_per_100g: float = Field(..., ge=0)
    fiber_per_100g: float = Field(0.0, ge=0)
    barcode: Optional[str] = None

class IngredientCreate(IngredientBase):
    pass

class IngredientResponse(IngredientBase):
    id: UUID
    model_config = ConfigDict(from_attributes=True)
