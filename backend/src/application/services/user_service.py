from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException, status
from src.domain.user_models import UserCreate, UserPublic, HealthProfile
from src.infrastructure.db.models import UserModel, HealthProfileModel
from src.infrastructure.security.auth import get_password_hash

def create_user(db: Session, user: UserCreate) -> UserPublic:
    """
    Creates a new user and their associated health profile atomically.
    Passwords are hashed. Health metrics are encrypted via TypeDecorator.
    """
    # 1. Start atomic transaction check
    existing_user = db.query(UserModel).filter(UserModel.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered"
        )
    
    # 2. Hash Password
    hashed_pwd = get_password_hash(user.password)
    
    # 3. Create User Model
    db_user = UserModel(
        email=user.email,
        hashed_password=hashed_pwd,
        full_name=user.full_name,
        is_active=True
    )
    
    # 4. Create Health Profile Model
    # The EncryptedString type decorator will handle encryption automatically on commit
    hp = user.health_profile
    db_health = HealthProfileModel(
        diabetes_type=hp.diabetes_type.value if hp.diabetes_type else None,
        therapy_type=hp.therapy_type if hp.therapy_type else None,
        
        # Campos cifrados (convertir a string)
        insulin_sensitivity=str(hp.insulin_sensitivity) if hp.insulin_sensitivity else None,
        carb_ratio=str(hp.carb_ratio) if hp.carb_ratio else None,
        target_glucose=str(hp.target_glucose) if hp.target_glucose else None,
        
        # Insulina basal (nuevos campos)
        basal_insulin_type=hp.basal_insulin.type if hp.basal_insulin else None,
        basal_insulin_units=str(hp.basal_insulin.units) if (hp.basal_insulin and hp.basal_insulin.units) else None,
        basal_insulin_time=hp.basal_insulin.administration_time if hp.basal_insulin else None,
    )
    
    # Link manually or via Relationship
    db_user.health_profile = db_health
    
    db.add(db_user)
    try:
        db.commit()
        db.refresh(db_user)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    
    # 5. Map back to Domain (Public)
    # When reading back, EncryptedString decrypts to string. We cast to float/int for response.
    from src.domain.health_models import BasalInsulinInfo
    
    basal_info = None
    if db_health.basal_insulin_type or db_health.basal_insulin_units:
        basal_info = BasalInsulinInfo(
            type=db_health.basal_insulin_type,
            units=float(db_health.basal_insulin_units) if db_health.basal_insulin_units else None,
            administration_time=str(db_health.basal_insulin_time) if db_health.basal_insulin_time else None
        )
    
    hp_domain = HealthProfile(
        diabetes_type=db_health.diabetes_type,
        therapy_type=db_health.therapy_type,
        insulin_sensitivity=float(db_health.insulin_sensitivity) if db_health.insulin_sensitivity else None,
        carb_ratio=float(db_health.carb_ratio) if db_health.carb_ratio else None,
        target_glucose=int(db_health.target_glucose) if db_health.target_glucose else None,
        basal_insulin=basal_info,
        user_id=db_user.id
    )
    
    return UserPublic(
        id=db_user.id,
        email=db_user.email,
        full_name=db_user.full_name,
        is_active=db_user.is_active,
        health_profile=hp_domain
    )
