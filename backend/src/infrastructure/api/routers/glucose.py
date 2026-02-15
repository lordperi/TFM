
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from uuid import UUID
from typing import List

from src.infrastructure.db.database import get_db
from src.infrastructure.api.dependencies import get_current_user_id
from src.infrastructure.repositories.glucose_repository import GlucoseRepository
from src.domain.glucose_models import GlucoseCreateRequest, GlucoseResponse
from src.infrastructure.db.models import PatientModel, UserModel

router = APIRouter(prefix="/glucose", tags=["glucose"])

@router.post("/", response_model=GlucoseResponse, status_code=status.HTTP_201_CREATED)
def create_glucose_measurement(
    request: GlucoseCreateRequest,
    patient_id: str, # Passed as validation or query param? Actually usually inside request body or separate param
    # Let's use query param for patient_id since request body is pure measurement data
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    """
    Register a new glucose measurement.
    Verifies that the user is the guardian of the patient.
    """
    uid = UUID(user_id)
    pid = UUID(patient_id)
    
    # Verify permission
    # User must be the guardian of the patient OR the patient themselves (if we had patient login)
    # For now, only guardian adds records for family
    patient = db.query(PatientModel).filter(
        PatientModel.id == pid,
        PatientModel.guardian_id == uid
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found or unauthorized")
    
    repo = GlucoseRepository(db)
    measurement = repo.create_measurement(pid, request)
    
    return measurement

@router.get("/history", response_model=List[GlucoseResponse])
def get_glucose_history(
    patient_id: str,
    limit: int = 20,
    offset: int = 0,
    start_date: int = None,  # Timestamp in milliseconds
    end_date: int = None,    # Timestamp in milliseconds
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id)
):
    """
    Get glucose history for a patient.
    """
    uid = UUID(user_id)
    pid = UUID(patient_id)
    
    # Verify permission
    patient = db.query(PatientModel).filter(
        PatientModel.id == pid,
        PatientModel.guardian_id == uid
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found or unauthorized")
    
    repo = GlucoseRepository(db)
    
    # Convert timestamps to datetime if provided
    start_dt = None
    if start_date:
        start_dt = datetime.fromtimestamp(start_date / 1000.0)
        
    end_dt = None
    if end_date:
        end_dt = datetime.fromtimestamp(end_date / 1000.0)

    history = repo.get_history(
        pid, 
        limit=limit, 
        offset=offset,
        start_date=start_dt,
        end_date=end_dt
    )
    
    return history
