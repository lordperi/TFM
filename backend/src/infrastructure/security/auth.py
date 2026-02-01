from passlib.context import CryptContext
from src.infrastructure.security.crypto import get_crypto_service

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def encrypt_sensitive_data(data: float | str) -> bytes:
    """Encrypts numerical or string data for DB storage."""
    crypto = get_crypto_service()
    return crypto.encrypt(str(data))

def decrypt_sensitive_data(data: bytes, original_type=float) -> float | str:
    """Decrypts bytes to original type."""
    crypto = get_crypto_service()
    decrypted_str = crypto.decrypt(data)
    if original_type == float:
        return float(decrypted_str)
    return decrypted_str
