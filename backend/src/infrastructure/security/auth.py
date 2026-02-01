import bcrypt
from src.infrastructure.security.crypto import get_crypto_service

def get_password_hash(password: str) -> str:
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    # Return as string to store in DB
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    pwd_bytes = plain_password.encode('utf-8')
    hash_bytes = hashed_password.encode('utf-8')
    return bcrypt.checkpw(pwd_bytes, hash_bytes)

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
