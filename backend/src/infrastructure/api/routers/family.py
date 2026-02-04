from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from uuid import UUID

from src.infrastructure.db.database import get_db
from src.infrastructure.api.dependencies import get_current_user_id
from src.infrastructure.db.models import PatientModel, UserModel, HealthProfileModel
import uuid

router = APIRouter(prefix="/family", tags=["Family"])

# Schemas (Simplified inline for MVP speed, ideally in schemas/family.py)
class PatientCreate(BaseModel):
    display_name: str
    birth_date: str = None
    theme_preference: str = "child"
    # Initial medical data
    diabetes_type: str
    insulin_sensitivity: str # Encrypted string simulation (in real app, pass raw and encrypt in service)
    carb_ratio: str
    target_glucose: str

class PatientResponse(BaseModel):
    id: str
    display_name: str
    theme_preference: str
    login_code: str = None

@router.get("/members", response_model=List[PatientResponse])
def get_family_members(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    uid = UUID(user_id)
    patients = db.query(PatientModel).filter(PatientModel.guardian_id == uid).all()
    return [
        PatientResponse(
            id=str(p.id),
            display_name=p.display_name, 
            theme_preference=p.theme_preference,
            login_code=p.login_code
        ) for p in patients
    ]

@router.post("/members", status_code=status.HTTP_201_CREATED)
def create_family_member(
    req: PatientCreate,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    uid = UUID(user_id)
    
    # 1. Create Patient
    new_patient = PatientModel(
        id=uuid.uuid4(),
        guardian_id=uid,
        display_name=req.display_name,
        theme_preference=req.theme_preference,
        # TODO: Parse birth_date
    )
    db.add(new_patient)
    db.flush() # Get ID
    
    # 2. Create Health Profile
    health_profile = HealthProfileModel(
        patient_id=new_patient.id,
        diabetes_type=req.diabetes_type,
        insulin_sensitivity=req.insulin_sensitivity,
        carb_ratio=req.carb_ratio,
        target_glucose=req.target_glucose
    )
    db.add(health_profile)
    
    db.commit()
    return {"status": "created", "id": str(new_patient.id)}

@router.post("/link-device")
def generate_link_code(
    patient_id: str,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    # Security: Verify ownership
    uid = UUID(user_id)
    pid = UUID(patient_id)
    patient = db.query(PatientModel).filter(PatientModel.id == pid, PatientModel.guardian_id == uid).first()
    if not patient:
         raise HTTPException(status_code=404, detail="Patient not found")
         
    # Generate simple code (e.g. 6 digits)
    # For MVP, using a short UUID segment
    code = str(uuid.uuid4())[:6].upper()
    patient.login_code = code
    db.commit()
    
    return {"code": code, "expires_in": "15m (Mocked)"}
