import bcrypt
import jwt
from datetime import datetime, timedelta
from typing import Optional
from src.infrastructure.security.crypto import get_crypto_service
import os

# JWT Settings
SECRET_KEY = os.getenv("SECRET_KEY", "dev_secret_key_change_in_prod")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_password_hash(password: str) -> str:
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    pwd_bytes = plain_password.encode('utf-8')
    hash_bytes = hashed_password.encode('utf-8')
    return bcrypt.checkpw(pwd_bytes, hash_bytes)

def encrypt_sensitive_data(data: float | str) -> bytes:
    crypto = get_crypto_service()
    return crypto.encrypt(str(data))

def decrypt_sensitive_data(data: bytes, original_type=float) -> float | str:
    crypto = get_crypto_service()
    decrypted_str = crypto.decrypt(data)
    if original_type == float:
        return float(decrypted_str)
    return decrypted_str
