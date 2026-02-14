from uuid import UUID, uuid4
from pydantic import BaseModel, Field, EmailStr, field_validator, model_validator
# Import from health_models (new location for DiabetesType, TherapyType, BasalInsulinInfo)
from src.domain.health_models import DiabetesType, TherapyType, BasalInsulinInfo

class HealthProfileBase(BaseModel):
    """Base model for health profile with conditional validation"""
    diabetes_type: DiabetesType | None = None
    therapy_type: TherapyType | None = Field(None, description="Tipo de tratamiento")
    
    # Insulin therapy fields (required if therapy uses insulin)
    insulin_sensitivity: float | None = Field(
        None, gt=0, le=500, 
        description="Caída de glucosa (mg/dL) por 1 unidad de insulina"
    )
    carb_ratio: float | None = Field(
        None, gt=0, le=150, 
        description="Gramos de carbohidratos cubiertos por 1 unidad"
    )
    target_glucose: int | None = Field(
        None, ge=70, le=180, 
        description="Objetivo glucémico (mg/dL)"
    )
    
    # Basal insulin info (optional, for long-acting insulin)
    basal_insulin: BasalInsulinInfo | None = None
    
    @model_validator(mode='after')
    def validate_conditional_fields(self) -> 'HealthProfileBase':
        """
        Validación condicional según diabetes_type y therapy_type.
        
        Reglas:
        - diabetes_type=NONE → NO debe tener datos médicos
        - therapy_type=INSULIN o MIXED → ISF/ICR/Target REQUERIDOS
        - therapy_type=ORAL → ISF/ICR/Target OPCIONALES
        """
        if self.diabetes_type == DiabetesType.NONE:
            # Si no tiene diabetes, no debería tener datos médicos
            if any([self.insulin_sensitivity, self.carb_ratio, self.target_glucose]):
                raise ValueError(
                    "diabetes_type=NONE no debe tener datos médicos (ISF/ICR/Target)"
                )
            return self
        
        # Si usa insulina (INSULIN o MIXED), campos son requeridos
        if self.therapy_type in [TherapyType.INSULIN, TherapyType.MIXED]:
            if not all([self.insulin_sensitivity, self.carb_ratio, self.target_glucose]):
                raise ValueError(
                    "Terapia con insulina requiere ISF, ICR y Target Glucose"
                )
        
        return self

class HealthProfileCreate(HealthProfileBase):
    pass

class HealthProfileUpdate(BaseModel):
    """Model for updating health profile (all fields optional)"""
    diabetes_type: DiabetesType | None = None
    therapy_type: TherapyType | None = None
    insulin_sensitivity: float | None = Field(None, gt=0, le=500)
    carb_ratio: float | None = Field(None, gt=0, le=150)
    target_glucose: int | None = Field(None, ge=70, le=180)
    
    # Basal insulin fields (for PATCH updates)
    basal_insulin_type: str | None = None
    basal_insulin_units: float | None = Field(None, ge=0, le=100)
    basal_insulin_time: str | None = None

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
