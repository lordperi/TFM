from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import date, datetime

from src.infrastructure.db.database import get_db
from src.infrastructure.api.dependencies import get_current_user_id
from src.infrastructure.db.models import PatientModel, UserModel, HealthProfileModel
import uuid

router = APIRouter(prefix="/family", tags=["family"])

# --- DTOs ---

from src.domain.health_models import TherapyType, DiabetesType
from src.infrastructure.db.types import EncryptedString

# --- DTOs ---

class PinVerificationRequest(BaseModel):
    pin: str

class BasalInsulinData(BaseModel):
    type: str # Lantus, etc
    units: float
    administration_time: Optional[str] = None # HH:MM

class PatientCreateRequest(BaseModel):
    display_name: str
    theme_preference: str = "adult" # 'child', 'adult'
    role: str = "DEPENDENT" # 'GUARDIAN', 'DEPENDENT'
    birth_date: Optional[date] = None
    pin: Optional[str] = None # Only for GUARDIAN
    # Health Profile Initial Data
    diabetes_type: Optional[DiabetesType] = None
    therapy_type: Optional[TherapyType] = None
    insulin_sensitivity: Optional[float] = None
    carb_ratio: Optional[float] = None
    target_glucose: Optional[float] = None # cambiado de target_range a target_glucose para consistencia
    # Basal Insulin (Flattened or object? Let's use flattened for simplicity regarding DB mapping manually here, or nested if we want cleaner API.
    # User API uses nested HealthProfile. Let's keep it flat here for minimal refactor of existing calls structure, but adding new fields.)
    basal_insulin_type: Optional[str] = None
    basal_insulin_units: Optional[float] = None
    basal_insulin_time: Optional[str] = None  # HH:MM:SS


class PatientUpdateRequest(BaseModel):
    display_name: Optional[str] = None
    theme_preference: Optional[str] = None
    role: Optional[str] = None
    birth_date: Optional[date] = None
    pin: Optional[str] = None 
    diabetes_type: Optional[DiabetesType] = None
    therapy_type: Optional[TherapyType] = None
    insulin_sensitivity: Optional[float] = None
    carb_ratio: Optional[float] = None
    target_glucose: Optional[float] = None
    basal_insulin_type: Optional[str] = None
    basal_insulin_units: Optional[float] = None
    basal_insulin_time: Optional[str] = None

class PatientResponse(BaseModel):
    id: str
    display_name: str
    theme_preference: str
    login_code: str | None = None
    role: str
    is_protected: bool # True if has PIN

    model_config = ConfigDict(from_attributes=True)

# --- Endpoints ---

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
            login_code=p.login_code,
            role=p.role,
            is_protected=bool(p.pin_hash)
        ) for p in patients
    ]

@router.post("/members", response_model=PatientResponse)
def create_patient_profile(
    request: PatientCreateRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    uid = UUID(user_id)
    
    # 1. Create Patient
    new_patient = PatientModel(
        guardian_id=uid,
        display_name=request.display_name,
        theme_preference=request.theme_preference,
        role=request.role,
        birth_date=request.birth_date,
        pin_hash=request.pin # Storing plain for MVP, SHOULD HASH in prod
    )
    db.add(new_patient)
    db.flush() # Generate ID

    # 2. Create Health Profile
    # Parse time if present
    b_time = None
    if request.basal_insulin_time:
        try:
            b_time = datetime.strptime(request.basal_insulin_time, "%H:%M:%S").time()
        except ValueError:
            try:
                b_time = datetime.strptime(request.basal_insulin_time, "%H:%M").time()
            except:
                pass

    health_profile = HealthProfileModel(
        patient_id=new_patient.id,
        diabetes_type=request.diabetes_type.value if request.diabetes_type else None,
        therapy_type=request.therapy_type, # Enum
        insulin_sensitivity=request.insulin_sensitivity,
        carb_ratio=request.carb_ratio,
        target_glucose=request.target_glucose,
        basal_insulin_type=request.basal_insulin_type,
        basal_insulin_units=request.basal_insulin_units, # EncryptedString handles float conversion? No, model expects string/float depending on definition. 
        # EncryptedString in models.py handles encryption. We pass raw value.
        basal_insulin_time=b_time
    )
    db.add(health_profile)
    
    db.commit()
    db.refresh(new_patient)
    
    return PatientResponse(
        id=str(new_patient.id),
        display_name=new_patient.display_name,
        theme_preference=new_patient.theme_preference,
        login_code=new_patient.login_code,
        role=new_patient.role,
        is_protected=bool(new_patient.pin_hash)
    )

@router.post("/members/{patient_id}/verify-pin")
def verify_patient_pin(
    patient_id: str,
    request: PinVerificationRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    pid = UUID(patient_id)
    uid = UUID(user_id)
    
    patient = db.query(PatientModel).filter(
        PatientModel.id == pid,
        PatientModel.guardian_id == uid
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    if not patient.pin_hash:
        return {"valid": True} # No PIN = Open access
        
    if patient.pin_hash == request.pin:
        return {"valid": True}
    else:
        raise HTTPException(status_code=401, detail="Invalid PIN")

class PatientDetailResponse(PatientResponse):
    birth_date: Optional[date] = None
    diabetes_type: Optional[str] = None
    therapy_type: Optional[str] = None
    insulin_sensitivity: Optional[float] = None
    carb_ratio: Optional[float] = None
    target_glucose: Optional[float] = None
    basal_insulin_type: Optional[str] = None
    basal_insulin_units: Optional[float] = None
    basal_insulin_time: Optional[str] = None

@router.get("/members/{patient_id}", response_model=PatientDetailResponse)
def get_patient_details(
    patient_id: str,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    pid = UUID(patient_id)
    uid = UUID(user_id)
    
    patient = db.query(PatientModel).filter(
        PatientModel.id == pid, 
        PatientModel.guardian_id == uid
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    hp = patient.health_profile
    
    return PatientDetailResponse(
        id=str(patient.id),
        display_name=patient.display_name,
        theme_preference=patient.theme_preference,
        login_code=patient.login_code,
        role=patient.role,
        is_protected=bool(patient.pin_hash),
        birth_date=patient.birth_date,
        diabetes_type=hp.diabetes_type if hp else None,
        therapy_type=hp.therapy_type.value if hp and hp.therapy_type else None, # Enum to str
        insulin_sensitivity=hp.insulin_sensitivity if hp else None,
        carb_ratio=hp.carb_ratio if hp else None,
        target_glucose=hp.target_glucose if hp else None,
        basal_insulin_type=hp.basal_insulin_type if hp else None,
        basal_insulin_units=hp.basal_insulin_units if hp else None,
        basal_insulin_time=str(hp.basal_insulin_time) if hp and hp.basal_insulin_time else None
    )

@router.patch("/members/{patient_id}", response_model=PatientResponse)
def update_patient_profile(
    patient_id: str,
    request: PatientUpdateRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    pid = UUID(patient_id)
    uid = UUID(user_id)
    
    patient = db.query(PatientModel).filter(
        PatientModel.id == pid,
        PatientModel.guardian_id == uid
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    # Security: PIN Verification for Sensitive Updates
    sensitive_fields_present = any([
        request.role is not None,
        request.diabetes_type is not None,
        request.therapy_type is not None,
        request.insulin_sensitivity is not None,
        request.carb_ratio is not None,
        request.target_glucose is not None,
        request.basal_insulin_type is not None
    ])
    
    if sensitive_fields_present and patient.pin_hash:
        # Check if PIN is provided and matches
        if not request.pin or request.pin != patient.pin_hash:
            raise HTTPException(status_code=401, detail="PIN required for sensitive updates")

    # Update Basic Info
    if request.display_name: patient.display_name = request.display_name
    if request.theme_preference: patient.theme_preference = request.theme_preference
    if request.role: patient.role = request.role
    if request.birth_date: patient.birth_date = request.birth_date
    
    if request.pin and not sensitive_fields_present: 
         pass
    
    # Update Health Profile
    if patient.health_profile:
        hp = patient.health_profile
        if request.diabetes_type: hp.diabetes_type = request.diabetes_type.value
        if request.therapy_type: hp.therapy_type = request.therapy_type
        if request.insulin_sensitivity: hp.insulin_sensitivity = request.insulin_sensitivity
        if request.carb_ratio: hp.carb_ratio = request.carb_ratio
        if request.target_glucose: hp.target_glucose = request.target_glucose
        if request.basal_insulin_type: hp.basal_insulin_type = request.basal_insulin_type
        if request.basal_insulin_units: hp.basal_insulin_units = request.basal_insulin_units
        if request.basal_insulin_time:
             try:
                hp.basal_insulin_time = datetime.strptime(request.basal_insulin_time, "%H:%M").time()
             except:
                pass # Ignore malformed time update

    db.commit()
    db.refresh(patient)
    
    return PatientResponse(
        id=str(patient.id),
        display_name=patient.display_name,
        theme_preference=patient.theme_preference,
        login_code=patient.login_code,
        role=patient.role,
        is_protected=bool(patient.pin_hash)
    )

# --- Legacy/Helper Endpoints ---
@router.post("/device-link")
def generate_device_link_code(
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
