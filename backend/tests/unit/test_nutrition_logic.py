import pytest
from src.domain.nutrition import calculate_glycemic_load, calculate_daily_bolus

def test_calculate_glycemic_load_low():
    # Manzana (IG ~38, 15g carbs)
    gl = calculate_glycemic_load(38, 15)
    # CG = (38 * 15) / 100 = 5.7
    assert gl == 5.7

def test_calculate_glycemic_load_high():
    # Arroz blanco (IG ~70, 50g carbs)
    gl = calculate_glycemic_load(70, 50)
    # CG = (70 * 50) / 100 = 35.0
    assert gl == 35.0

def test_bolus_calculation_standard():
    # Carbs: 60g
    # ICR: 10 (1u per 10g) => 6u
    # Glucose: 200, Target: 100, ISF: 50 (1u drops 50)
    # Correction: (200-100)/50 = 2u
    # Total: 8u
    units = calculate_daily_bolus(
        total_carbs=60,
        icr=10,
        current_glucose=200,
        target_glucose=100,
        isf=50
    )
    assert units == 8.0

def test_bolus_calculation_hypo_protection():
    # Caso Hipoglucemia: Glucosa 70 (Target 100) -> Correction -0.6u
    # Comida: 5g Carbs (ICR 10) -> 0.5u
    # Total: -0.1u -> Debería ser 0
    units = calculate_daily_bolus(5, 10, 70, 100, 50)
    assert units == 0.0
