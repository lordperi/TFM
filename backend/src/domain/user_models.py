from enum import Enum
from uuid import UUID, uuid4
from pydantic import BaseModel, Field, EmailStr, field_validator

class DiabetesType(str, Enum):
    TYPE_1 = "type_1"
    TYPE_2 = "type_2"
    GESTATIONAL = "gestational"
    LADA = "lada"
    MODY = "mody"

class HealthProfileBase(BaseModel):
    diabetes_type: DiabetesType | None = None
    
    # Insulin Sensitivity Factor (ISF): How much 1 unit drops glucose (mg/dL)
    # Range validation: 1 to 500 is clinically reasonable.
    # Insulin Sensitivity Factor (ISF): How much 1 unit drops glucose (mg/dL)
    # Range validation: 1 to 500 is clinically reasonable.
    insulin_sensitivity: float | None = Field(None, gt=0, le=500, description="Caída de glucosa (mg/dL) por 1 unidad de insulina")
    
    # Insulin-to-Carb Ratio (ICR): Grams of carbs covered by 1 unit
    # Range validation: 1 to 150
    carb_ratio: float | None = Field(None, gt=0, le=150, description="Gramos de carbohidratos cubiertos por 1 unidad")
    
    target_glucose: int | None = Field(100, ge=70, le=180, description="Objetivo glucémico (mg/dL)")

class HealthProfileCreate(HealthProfileBase):
    pass

class HealthProfile(HealthProfileBase):
    user_id: UUID

class UserBase(BaseModel):
    email: EmailStr
    full_name: str | None = None

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Plain password to be hashed")
    health_profile: HealthProfileCreate

class UserPublic(UserBase):
    id: UUID
    is_active: bool
    health_profile: HealthProfile | None = None
