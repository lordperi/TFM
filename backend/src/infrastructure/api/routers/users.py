from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.domain.user_models import UserCreate, UserPublic
from src.application.services.user_service import create_user
from src.infrastructure.db.database import get_db

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
