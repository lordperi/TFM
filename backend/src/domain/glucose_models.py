
from enum import Enum
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

class GlucoseType(str, Enum):
    FINGER = "FINGER"
    CGM = "CGM"
    MANUAL = "MANUAL"

class GlucoseCreateRequest(BaseModel):
    value: int = Field(..., ge=20, le=600, description="Glucose value in mg/dL")
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    measurement_type: GlucoseType = Field(default=GlucoseType.FINGER)
    notes: Optional[str] = None

class GlucoseResponse(BaseModel):
    id: str
    patient_id: str
    value: int
    timestamp: datetime
    measurement_type: GlucoseType
    notes: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)
