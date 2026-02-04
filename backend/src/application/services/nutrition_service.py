from sqlalchemy.orm import Session
from fastapi import HTTPException
from uuid import UUID

# Domain
from src.domain.nutrition import calculate_daily_bolus
# Infra (Repository would be cleaner, but we'll use DB models here carefully for MVP speed, 
# ideally we should have a UserRepository interface)
from src.infrastructure.db.models import PatientModel, IngredientModel

class NutritionService:
    def __init__(self, db: Session):
        self.db = db

    def calculate_bolus(self, user_id: str, patient_id: str, carbs: float, glucose: float, 
                       icr_override: float = None, isf_override: float = None, target_override: float = None):
        """
        Orchestrates the Bolus Calculation Use Case.
        1. Fetches Patient Profile & Verifies Guardian Ownership
        2. Decrypts Data
        3. Applies Domain Logic
        """
        try:
            pid = UUID(patient_id)
            uid = UUID(user_id)
        except ValueError:
             raise HTTPException(status_code=400, detail="Invalid ID format")

        # Security: Allow access ONLY if User is the Guardian
        patient = self.db.query(PatientModel).filter(
            PatientModel.id == pid,
            PatientModel.guardian_id == uid
        ).first()
        
        if not patient:
            # 404 is safer than 403 to avoid leaking patient existence
            raise HTTPException(status_code=404, detail="Patient not found or access denied")
        
        if not patient.health_profile:
            raise HTTPException(status_code=400, detail="Health profile missing for this patient")

        # Decryption Logic (Application Layer handles sensitive data orchestration)
        try:
            print(f"DEBUG: Health Profile Raw: ICR={type(patient.health_profile.carb_ratio)}/{patient.health_profile.carb_ratio}")
            
            profile_icr = float(patient.health_profile.carb_ratio)
            profile_isf = float(patient.health_profile.insulin_sensitivity)
            profile_target = float(patient.health_profile.target_glucose)
        except Exception as e:
            print(f"CRITICAL ERROR loading profile: {e}")
            raise HTTPException(status_code=500, detail="Data corruption in health profile")

        # Priority: Override > Profile
        final_icr = icr_override if icr_override else profile_icr
        final_isf = isf_override if isf_override else profile_isf
        final_target = target_override if target_override else profile_target

        # Call Pure Domain
        units = calculate_daily_bolus(
            total_carbs=carbs,
            icr=final_icr,
            current_glucose=glucose,
            target_glucose=final_target,
            isf=final_isf
        )

        # Breakdowns
        carb_insulin = carbs / final_icr
        correction_insulin = (glucose - final_target) / final_isf

        return {
            "units": round(units, 2),
            "breakdown": {
                "carb_insulin": round(carb_insulin, 2),
                "correction_insulin": round(max(0, correction_insulin), 2)
            }
        }

    def search_ingredients(self, query: str, skip: int, limit: int):
        q = self.db.query(IngredientModel)
        if query:
            q = q.filter(IngredientModel.name.ilike(f"%{query}%"))
        return q.offset(skip).limit(limit).all()

    def create_ingredient(self, data: dict):
        # En Clean Arch puro, 'data' sería un DTO de entrada, no un dict
        item = IngredientModel(**data)
        self.db.add(item)
        self.db.commit()
        self.db.refresh(item)
        return item
