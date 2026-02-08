from datetime import datetime
from uuid import UUID, uuid4
from pydantic import BaseModel, ConfigDict, Field

# --- DOMAIN ENTITY ---
class HealthMetricMetadata(BaseModel):
    """Value object for metadata"""
    device_id: str | None = None
    units: str # e.g., 'mg/dL', 'mmol/L'
    notes: str | None = None

class HealthMetric(BaseModel):
    """
    Core Domain Entity for a Health Reading (e.g. Glucose).
    Independent of database concerns.
    """
    id: UUID = Field(default_factory=uuid4)
    user_id: UUID
    type: str = "glucose" # Enum candidate
    value: float # The raw numerical value (120.5)
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    metadata: HealthMetricMetadata | None = None

    model_config = ConfigDict(from_attributes=True)


# --- PASSWORD CHANGE MODELS ---

class PasswordChange(BaseModel):
    """Model for password change requests"""
    old_password: str = Field(..., min_length=1, description="Current password")
    new_password: str = Field(..., min_length=8, description="New password (min 8 characters)")
    confirm_password: str = Field(..., min_length=8, description="Confirm new password")
    
    def passwords_match(self) -> bool:
        """Validate that new passwords match"""
        return self.new_password == self.confirm_password


# --- INFRASTRUCTURE MODEL (SQLAlchemy) ---
# Usually this lives in infrastructure/db/models.py, but placing here for context validation
# In real clean arch code, this would be separate.

from sqlalchemy import Column, String, DateTime, Float, Index, Uuid
from src.infrastructure.db.types import EncryptedString
from src.infrastructure.db.database import Base

class HealthMetricModel(Base):
    __tablename__ = "health_metrics"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(Uuid(as_uuid=True), index=True, nullable=False)
    type = Column(String, nullable=False, index=True) # Not encrypted, needed for filtering
    
    # --- SECURITY CRITICAL ---
    # The 'value' is stored as encrypted bytes. 
    # Even if we want to store it as float in python, the DB sees blob.
    # Note: Querying "value > 100" in SQL is now impossible without decryption.
    # For MVP, we fetch by User + Time range, then filter in memory or decrypt application side.
    encrypted_value = Column("value", EncryptedString, nullable=False) 
    
    timestamp = Column(DateTime, default=datetime.utcnow, index=True) # Time is metadata, usually safe to keep plain for sorting
    
    # Metadata blobs can contain sensitive info like "Feeling dizzy after insulin"
    encrypted_notes = Column("notes", EncryptedString, nullable=True)
