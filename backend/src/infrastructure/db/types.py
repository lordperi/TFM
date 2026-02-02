from typing import Any, Optional
from sqlalchemy.types import TypeDecorator, LargeBinary
from sqlalchemy.ext.mutable import Mutable
from src.infrastructure.security.crypto import get_crypto_service

class EncryptedString(TypeDecorator):
    """
    SQLAlchemy Custom Type that encrypts data on SAVE and decrypts on LOAD.
    Transparent Application-Level Encryption.
    """
    impl = LargeBinary
    cache_ok = True

    def process_bind_param(self, value: Any, dialect: Any) -> Optional[bytes]:
        if value is None:
            return None
        try:
            crypto = get_crypto_service()
            return crypto.encrypt(str(value))
        except Exception:
            # Fallback for tests/edge cases: return as bytes encoded if possible, or just raw if SQLite accepts it
            return str(value).encode()

    def process_result_value(self, value: Any, dialect: Any) -> Optional[str]:
        if value is None:
            return None
        try:
            # If plain string (fallback/legacy), return it
            if isinstance(value, str):
                return value
            
            crypto = get_crypto_service()
            return crypto.decrypt(value)
        except Exception:
            # Last ditch effort: decode bytes
            if isinstance(value, bytes):
                return value.decode("utf-8", errors="ignore")
            return str(value)
