"""
Tests unitarios para validación condicional de perfiles médicos.
Metodología: TDD Estricto (Red → Green → Refactor)

Estos tests DEBEN FALLAR inicialmente hasta que implementemos:
1. TherapyType enum
2. BasalInsulinInfo class
3. Validación condicional en HealthProfileBase
"""
import pytest
from pydantic import ValidationError


class TestConditionalMedicalProfiles:
    """
    Test Suite para perfiles médicos dinámicos.
    RED PHASE: Estos tests fallarán hasta implementar las clases.
    """
    
    def test_diabetes_none_should_reject_medical_data(self):
        """
        RED TEST: diabetes_type=NONE no debe aceptar datos médicos.
        
        Comportamiento esperado:
        - Si diabetes_type es NONE, los campos ISF/ICR/Target deben ser None
        - Intentar crear con estos campos debe lanzar ValidationError
        """
        from src.domain.user_models import HealthProfileBase, DiabetesType
        
        with pytest.raises(ValidationError, match="diabetes_type=NONE"):
            HealthProfileBase(
                diabetes_type=DiabetesType.NONE,
                insulin_sensitivity=50.0,  # ← No debería permitirse
                carb_ratio=10.0,
                target_glucose=120
            )
    
    def test_diabetes_none_accepts_empty_medical_data(self):
        """
        GREEN TEST (Futuro): diabetes_type=NONE sin datos médicos es válido.
        """
        from src.domain.user_models import HealthProfileBase, DiabetesType
        
        profile = HealthProfileBase(diabetes_type=DiabetesType.NONE)
        
        assert profile.diabetes_type == DiabetesType.NONE
        assert profile.insulin_sensitivity is None
        assert profile.carb_ratio is None
        assert profile.target_glucose is None
    
    def test_insulin_therapy_requires_isf_icr_target(self):
        """
        RED TEST: Terapia con INSULIN requiere ISF, ICR y Target obligatorios.
        """
        from src.domain.user_models import (
            HealthProfileBase, DiabetesType, TherapyType
        )
        
        with pytest.raises(ValidationError, match="requiere ISF, ICR"):
            HealthProfileBase(
                diabetes_type=DiabetesType.T1,
                therapy_type=TherapyType.INSULIN,
                # Falta insulin_sensitivity, carb_ratio, target_glucose
            )
    
    def test_insulin_therapy_with_complete_data_succeeds(self):
        """
        GREEN TEST (Futuro): INSULIN therapy con datos completos debe funcionar.
        """
        from src.domain.user_models import (
            HealthProfileBase, DiabetesType, TherapyType
        )
        
        profile = HealthProfileBase(
            diabetes_type=DiabetesType.T1,
            therapy_type=TherapyType.INSULIN,
            insulin_sensitivity=50.0,
            carb_ratio=10.0,
            target_glucose=120
        )
        
        assert profile.therapy_type == TherapyType.INSULIN
        assert profile.insulin_sensitivity == 50.0
        assert profile.carb_ratio == 10.0
        assert profile.target_glucose == 120
    
    def test_basal_insulin_with_all_fields(self):
        """
        RED TEST: Insulina basal con todos los campos (tipo, unidades, hora).
        """
        from src.domain.user_models import (
            HealthProfileBase, DiabetesType, TherapyType, BasalInsulinInfo
        )
        
        basal = BasalInsulinInfo(
            type="Lantus",
            units=22.0,
            administration_time="22:00"
        )
        
        profile = HealthProfileBase(
            diabetes_type=DiabetesType.T1,
            therapy_type=TherapyType.INSULIN,
            insulin_sensitivity=50.0,
            carb_ratio=10.0,
            target_glucose=120,
            basal_insulin=basal
        )
        
        assert profile.basal_insulin.type == "Lantus"
        assert profile.basal_insulin.units == 22.0
        assert profile.basal_insulin.administration_time == "22:00"
    
    def test_type2_oral_medication_no_insulin_fields_required(self):
        """
        GREEN TEST (Futuro): Type 2 con medicación oral no requiere ISF/ICR.
        """
        from src.domain.user_models import (
            HealthProfileBase, DiabetesType, TherapyType
        )
        
        profile = HealthProfileBase(
            diabetes_type=DiabetesType.T2,
            therapy_type=TherapyType.ORAL
            # NO tiene ISF/ICR porque solo usa medicación oral
        )
        
        assert profile.therapy_type == TherapyType.ORAL
        assert profile.insulin_sensitivity is None
        assert profile.carb_ratio is None
    
    def test_type2_mixed_therapy_requires_insulin_fields(self):
        """
        RED TEST: Type 2 con terapia MIXED (insulina + oral) requiere ISF/ICR.
        """
        from src.domain.user_models import (
            HealthProfileBase, DiabetesType, TherapyType
        )
        
        with pytest.raises(ValidationError, match="requiere ISF, ICR"):
            HealthProfileBase(
                diabetes_type=DiabetesType.T2,
                therapy_type=TherapyType.MIXED,
                # Falta ISF/ICR/Target (requeridos si usa insulina)
            )
    
    def test_basal_insulin_units_validation_range(self):
        """
        RED TEST: Unidades de insulina basal deben estar en rango válido (0-100).
        """
        from src.domain.user_models import BasalInsulinInfo
        
        # Caso válido
        basal_valid = BasalInsulinInfo(type="Lantus", units=22.0)
        assert basal_valid.units == 22.0
        
        # Caso inválido: unidades negativas
        with pytest.raises(ValidationError):
            BasalInsulinInfo(type="Lantus", units=-5.0)
        
        # Caso inválido: unidades excesivas
        with pytest.raises(ValidationError):
            BasalInsulinInfo(type="Lantus", units=150.0)
    
    def test_basal_insulin_time_format_validation(self):
        """
        RED TEST: Hora de administración debe tener formato HH:MM.
        """
        from src.domain.user_models import BasalInsulinInfo
        
        # Formato válido
        basal_valid = BasalInsulinInfo(
            type="Levemir",
            units=18.0,
            administration_time="08:30"
        )
        assert basal_valid.administration_time == "08:30"
        
        # Formato inválido (debe fallar en implementación con validator)
        # Por ahora, Pydantic no valida automáticamente el formato
        # Añadiremos validator en la implementación


class TestTherapyTypeEnum:
    """Tests para el enum TherapyType"""
    
    def test_therapy_type_enum_values(self):
        """RED TEST: Verificar que TherapyType tiene los valores esperados"""
        from src.domain.user_models import TherapyType
        
        assert TherapyType.INSULIN.value == "INSULIN"
        assert TherapyType.ORAL.value == "ORAL_MEDICATION"
        assert TherapyType.MIXED.value == "MIXED"
        assert TherapyType.NONE.value == "NONE"


class TestBasalInsulinInfo:
    """Tests para la clase BasalInsulinInfo"""
    
    def test_basal_insulin_optional_fields(self):
        """GREEN TEST (Futuro): Todos los campos de basal insulin son opcionales"""
        from src.domain.user_models import BasalInsulinInfo
        
        # Sin ningún campo (válido para usuarios que no usan basal)
        basal = BasalInsulinInfo()
        assert basal.type is None
        assert basal.units is None
        assert basal.administration_time is None
    
    def test_basal_insulin_partial_data(self):
        """GREEN TEST (Futuro): Puede tener datos parciales"""
        from src.domain.user_models import BasalInsulinInfo
        
        basal = BasalInsulinInfo(type="Tresiba", units=20.0)
        assert basal.type == "Tresiba"
        assert basal.units == 20.0
        assert basal.administration_time is None  # Opcional
