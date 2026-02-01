import base64
import os
from cryptography.fernet import Fernet
from functools import lru_cache

class CryptoService:
    def __init__(self, key: str = None):
        # In production, key comes from env vars or KMS
        # Fallback for dev/test if not provided (WARNING: Unsafe for prod)
        self.key = key or os.getenv("ENCRYPTION_KEY")
        if not self.key:
             raise ValueError("ENCRYPTION_KEY environment variable is not set")
        self.fernet = Fernet(self.key)

    def encrypt(self, data: str) -> bytes:
        if data is None:
            return None
        return self.fernet.encrypt(data.encode())

    def decrypt(self, token: bytes) -> str:
        if token is None:
            return None
        return self.fernet.decrypt(token).decode()

@lru_cache()
def get_crypto_service() -> CryptoService:
    # Factory to get singleton instance
    # IMPORTANT: Generate a key in terminal using: 
    # python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
    return CryptoService()
