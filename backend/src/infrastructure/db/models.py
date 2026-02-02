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
    
    # 1:1 relationship with HealthProfile
    health_profile = relationship("HealthProfileModel", uselist=False, back_populates="user", cascade="all, delete-orphan")
    # 1:N relationship with MealLogs
    meals = relationship("MealLogModel", back_populates="user", cascade="all, delete-orphan")

class HealthProfileModel(Base):
    __tablename__ = "health_profiles"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False, index=True)
    diabetes_type = Column(String, nullable=False)
    
    # Sensitive Data (Encrypted at rest)
    # Stored as bytes in DB, but types.EncryptedString handles conversion
    # Note: We use EncryptedString so the ORM sees Python string/float, but DB sees garbage.
    insulin_sensitivity = Column(EncryptedString, nullable=False) 
    carb_ratio = Column(EncryptedString, nullable=False)
    target_glucose = Column(EncryptedString, nullable=False) # Often personal preference, but kept private.

    user = relationship("UserModel", back_populates="health_profile")

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
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    timestamp = Column(DateTime, default=dt.datetime.utcnow, index=True)
    
    # Computed metrics snapshot
    total_carbs_grams = Column(Float, nullable=False)
    total_glycemic_load = Column(Float, nullable=False)
    
    # Sensitive data (e.g. "I felt dizzy") -> Encrypted
    notes = Column(EncryptedString, nullable=True) 

    # Relationships
    user = relationship("UserModel", back_populates="meals")
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
