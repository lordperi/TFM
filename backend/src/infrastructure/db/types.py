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

    def process_bind_param(self, value: Optional[str], dialect: Any) -> Optional[bytes]:
        """Encrypt the value before sending to the DB."""
        if value is None:
            return None
        crypto = get_crypto_service()
        return crypto.encrypt(str(value))

    def process_result_value(self, value: Optional[bytes], dialect: Any) -> Optional[str]:
        """Decrypt the value after receiving from the DB."""
        if value is None:
            return None
        crypto = get_crypto_service()
        return crypto.decrypt(value)
