import sys
import os

# Add project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

print("Starting imports...")
try:
    from src.main import app
    print("Imported app")
    from src.infrastructure.db.models import PatientModel, HealthProfileModel
    print("Imported models")
    from src.infrastructure.api.dependencies import get_db
    print("Imported dependencies")
except Exception as e:
    print(f"IMPORT ERROR: {e}")
    import traceback
    traceback.print_exc()

print("Imports successful")
