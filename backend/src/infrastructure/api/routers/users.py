from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.domain.user_models import UserCreate, UserPublic, HealthProfileUpdate
from src.domain.health_models import PasswordChange
from src.domain.xp_models import XPTransaction, UserAchievement, Achievement, UserXPSummary
from src.application.services.user_service import create_user
from src.infrastructure.db.database import get_db
from src.infrastructure.db.models import UserModel, HealthProfileModel
from src.infrastructure.api.dependencies import get_current_user
from src.infrastructure.security.auth import get_password_hash, verify_password
from src.infrastructure.db.xp_repository import XPRepository

router = APIRouter(prefix="/users", tags=["Users"])

@router.post("/register", response_model=UserPublic, status_code=201)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    Register a new user with their medical profile.
    Passwords are hashed (Bcrypt).
    Sensitive Health Data is encrypted (Fernet).
    """
    created_user = create_user(db, user)
    return created_user

@router.get("/me", response_model=UserPublic)
def get_current_user_profile(current_user: UserModel = Depends(get_current_user)):
    """
    Get current authenticated user's profile including health data.
    """
    return current_user


@router.patch("/me/health-profile")
def update_health_profile(
    profile_update: HealthProfileUpdate,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update current user's health profile.
    All fields are optional - only provided fields will be updated.
    """
    # Get user's health profile
    health_profile = db.query(HealthProfileModel).filter(
        HealthProfileModel.user_id == current_user.id
    ).first()
    
    if not health_profile:
        raise HTTPException(status_code=404, detail="Health profile not found")
    
    # Update only provided fields
    update_data = profile_update.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        # Convert to string for encrypted fields
        if field in ["insulin_sensitivity", "carb_ratio", "target_glucose"]:
            setattr(health_profile, field, str(value) if value is not None else None)
        else:
            setattr(health_profile, field, value)
    
    db.commit()
    db.refresh(health_profile)
    
    # Convert back to domain model for response
    return {
        "user_id": str(health_profile.user_id),
        "diabetes_type": health_profile.diabetes_type,
        "insulin_sensitivity": float(health_profile.insulin_sensitivity) if health_profile.insulin_sensitivity else None,
        "carb_ratio": float(health_profile.carb_ratio) if health_profile.carb_ratio else None,
        "target_glucose": int(health_profile.target_glucose) if health_profile.target_glucose else None,
    }


@router.post("/me/change-password")
def change_password(
    password_change: PasswordChange,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Change current user's password.
    Requires old password for verification.
    """
    # Verify passwords match
    if not password_change.passwords_match():
        raise HTTPException(status_code=400, detail="New passwords do not match")
    
    # Verify old password
    if not verify_password(password_change.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Old password is incorrect")
    
    # Update password
    current_user.hashed_password = get_password_hash(password_change.new_password)
    db.commit()
    
    return {"message": "Password changed successfully"}


@router.get("/me/xp-history", response_model=list[XPTransaction])
def get_xp_history(
    limit: int = 50,
    skip: int = 0,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get current user's XP transaction history.
    Returns recent XP gains/losses with descriptions.
    """
    xp_repo = XPRepository(db)
    transactions = xp_repo.get_user_xp_history(current_user.id, limit=limit, skip=skip)
    return transactions


@router.get("/me/xp-summary", response_model=UserXPSummary)
def get_xp_summary(
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get current user's XP summary including:
    - Total XP
    - Current level
    - XP needed for next level
    - Progress percentage
    - Recent transactions
    """
    xp_repo = XPRepository(db)
    summary = xp_repo.get_user_xp_summary(current_user.id)
    return summary


@router.get("/me/achievements")
def get_user_achievements(
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get user's achievements status.
    Returns both unlocked and locked achievements.
    """
    xp_repo = XPRepository(db)
    
    unlocked = xp_repo.get_user_achievements(current_user.id)
    locked = xp_repo.get_user_locked_achievements(current_user.id)
    
    return {
        "unlocked": unlocked,
        "locked": locked
    }
