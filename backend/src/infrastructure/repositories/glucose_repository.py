
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional
from datetime import datetime

from src.infrastructure.db.models import GlucoseMeasurementModel
from src.domain.glucose_models import GlucoseCreateRequest

class GlucoseRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_measurement(self, patient_id: UUID, data: GlucoseCreateRequest) -> GlucoseMeasurementModel:
        """Create a new glucose measurement record"""
        measurement = GlucoseMeasurementModel(
            patient_id=patient_id,
            glucose_value=data.value,
            timestamp=data.timestamp,
            measurement_type=data.measurement_type.value,
            notes=data.notes
        )
        self.db.add(measurement)
        self.db.commit()
        self.db.refresh(measurement)
        return measurement

    def get_history(self, patient_id: UUID, limit: int = 20, offset: int = 0) -> List[GlucoseMeasurementModel]:
        """Get glucose history for a patient, ordered by timestamp desc"""
        return self.db.query(GlucoseMeasurementModel)\
            .filter(GlucoseMeasurementModel.patient_id == patient_id)\
            .order_by(GlucoseMeasurementModel.timestamp.desc())\
            .limit(limit)\
            .offset(offset)\
            .all()

    def get_latest(self, patient_id: UUID) -> Optional[GlucoseMeasurementModel]:
        """Get the most recent glucose measurement"""
        return self.db.query(GlucoseMeasurementModel)\
            .filter(GlucoseMeasurementModel.patient_id == patient_id)\
            .order_by(GlucoseMeasurementModel.timestamp.desc())\
            .first()
