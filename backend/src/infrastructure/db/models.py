from sqlalchemy import Column, String, Boolean, ForeignKey, Index, Uuid, Integer, Float, DateTime, LargeBinary
from sqlalchemy.orm import relationship
from uuid import uuid4
from datetime import datetime
from src.infrastructure.db.types import EncryptedString
from src.infrastructure.db.database import Base
import datetime as dt

class UserModel(Base):
    __tablename__ = "users"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # 1:N relationship with Patients (Family Members)
    patients = relationship("PatientModel", back_populates="guardian", cascade="all, delete-orphan")
    
    # 1:1 relationship with Health Profile (Self)
    health_profile = relationship("HealthProfileModel", uselist=False, back_populates="user", cascade="all, delete-orphan")
    
    # Security for Quick Switch
    pin_hash = Column(String, nullable=True) # 4-digit PIN for parental control

class PatientModel(Base):
    __tablename__ = "patients"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    guardian_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    display_name = Column(String, nullable=False)
    birth_date = Column(DateTime, nullable=True) # For age logic
    theme_preference = Column(String, default="adult") # 'child', 'teen', 'adult'
    
    # Security & Role
    pin_hash = Column(String, nullable=True) # Encrypted/Hashed PIN for adult access
    role = Column(String, default="DEPENDENT", nullable=False) # 'GUARDIAN', 'DEPENDENT'
    
    # Device Linking (Simple Code)
    login_code = Column(String, unique=True, index=True, nullable=True)
    
    # Relationships
    guardian = relationship("UserModel", back_populates="patients")
    health_profile = relationship("HealthProfileModel", uselist=False, back_populates="patient", cascade="all, delete-orphan")

class HealthProfileModel(Base):
    __tablename__ = "health_profiles"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    # Changed from user_id to patient_id -> Support BOTH 
    # (User can have profile, Patient can have profile)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=True, index=True)
    patient_id = Column(Uuid(as_uuid=True), ForeignKey("patients.id"), unique=True, nullable=True, index=True)
    
    diabetes_type = Column(String, nullable=True)
    therapy_mode = Column(String, nullable=True) # 'PEN', 'PUMP'
    
    # Sensitive Data (Encrypted at rest)
    # Stored as bytes in DB, but types.EncryptedString handles conversion
    # Note: We use EncryptedString so the ORM sees Python string/float, but DB sees garbage.
    insulin_sensitivity = Column(EncryptedString, nullable=True) 
    carb_ratio = Column(EncryptedString, nullable=True)
    target_glucose = Column(EncryptedString, nullable=True) # Often personal preference, but kept private.

    user = relationship("UserModel", back_populates="health_profile")
    patient = relationship("PatientModel", back_populates="health_profile")

# --- NUTRITION DOMAIN ---

class IngredientModel(Base):
    __tablename__ = "ingredients"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    name = Column(String, unique=True, index=True, nullable=False)
    glycemic_index = Column(Integer, nullable=False) # 0-100
    carbs_per_100g = Column(Float, nullable=False)
    fiber_per_100g = Column(Float, nullable=False, default=0.0)
    
    # Metadata for AI/OCR future matching
    barcode = Column(String, index=True, nullable=True) 

class MealLogModel(Base):
    __tablename__ = "meals_log"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    # Linked to Patient (the one eating), not just the User (Guardian)
    patient_id = Column(Uuid(as_uuid=True), ForeignKey("patients.id"), nullable=False, index=True)
    # Optional: Keep user_id as "Recorded By" if needed, but for now assuming Patient context is enough.
    
    timestamp = Column(DateTime, default=dt.datetime.utcnow, index=True)
    
    # Computed metrics snapshot
    total_carbs_grams = Column(Float, nullable=False)
    total_glycemic_load = Column(Float, nullable=False)
    
    # Sensitive data (e.g. "I felt dizzy") -> Encrypted
    notes = Column(EncryptedString, nullable=True) 

    # Relationships
    patient = relationship("PatientModel", backref="meals")
    # user = relationship("UserModel", back_populates="meals") # DEPRECATED linkage
    items = relationship("MealItemModel", back_populates="meal", cascade="all, delete-orphan")

class MealItemModel(Base):
    __tablename__ = "meal_items"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    meal_id = Column(Uuid(as_uuid=True), ForeignKey("meals_log.id"), nullable=False)
    ingredient_id = Column(Uuid(as_uuid=True), ForeignKey("ingredients.id"), nullable=False)
    
    weight_grams = Column(Float, nullable=False)
    
    # Relationships
    meal = relationship("MealLogModel", back_populates="items")
    ingredient = relationship("IngredientModel")
