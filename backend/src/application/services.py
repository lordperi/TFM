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
    db_health = HealthProfileModel(
        diabetes_type=user.health_profile.diabetes_type.value,
        insulin_sensitivity=str(user.health_profile.insulin_sensitivity), # Convert to string for encryption wrapper
        carb_ratio=str(user.health_profile.carb_ratio),
        target_glucose=str(user.health_profile.target_glucose)
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
    hp_domain = HealthProfile(
        diabetes_type=db_health.diabetes_type,
        insulin_sensitivity=float(db_health.insulin_sensitivity),
        carb_ratio=float(db_health.carb_ratio),
        target_glucose=int(db_health.target_glucose),
        user_id=db_user.id
    )
    
    return UserPublic(
        id=db_user.id,
        email=db_user.email,
        full_name=db_user.full_name,
        is_active=db_user.is_active,
        health_profile=hp_domain
    )
