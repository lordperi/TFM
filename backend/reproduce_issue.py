from src.infrastructure.api.routers.family import PatientResponse
try:
    p = PatientResponse(id="123", display_name="Test", theme_preference="adult", role="DEPENDENT", is_protected=False)
    print("Instantiation successful:", p.model_dump())
except Exception as e:
    print(f"Instantiation failed: {e}")
    exit(1)
