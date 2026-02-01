from sqlalchemy import Column, String, Boolean, ForeignKey, Index
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from uuid import uuid4
from datetime import datetime
from src.infrastructure.db.types import EncryptedString
from src.domain.health_models import Base

class UserModel(Base):
    __tablename__ = "users"

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # 1:1 relationship with HealthProfile
    health_profile = relationship("HealthProfileModel", uselist=False, back_populates="user", cascade="all, delete-orphan")

class HealthProfileModel(Base):
    __tablename__ = "health_profiles"

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PG_UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False, index=True)
    diabetes_type = Column(String, nullable=False)
    
    # Sensitive Data (Encrypted at rest)
    # Stored as bytes in DB, but types.EncryptedString handles conversion
    # Note: We use EncryptedString so the ORM sees Python string/float, but DB sees garbage.
    insulin_sensitivity = Column(EncryptedString, nullable=False) 
    carb_ratio = Column(EncryptedString, nullable=False)
    target_glucose = Column(EncryptedString, nullable=False) # Often personal preference, but kept private.

    user = relationship("UserModel", back_populates="health_profile")
