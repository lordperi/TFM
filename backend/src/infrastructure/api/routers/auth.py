from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta

# Core Deps
from src.infrastructure.db.database import get_db
from src.infrastructure.db.models import UserModel
from src.infrastructure.security.auth import verify_password
from src.infrastructure.security.jwt_handler import create_access_token, Token, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """
    Autentica un usuario y devuelve un token JWT (Bearer).
    - **username**: Debe ser el email registrado.
    - **password**: Contraseña en texto plano.
    """
    # 1. Buscar usuario
    # NOTA: En Clean Arch estricto, esto iría en un AuthUseCase en la capa de Aplicación.
    # Dado el MVP, accedemos al repository/modelo directamente aquí por pragmatismo.
    user = db.query(UserModel).filter(UserModel.email == form_data.username).first()
    
    # 2. Verificar credenciales
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 3. Generar Access Token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}
