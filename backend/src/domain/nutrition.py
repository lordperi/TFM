from dataclasses import dataclass
from typing import List

@dataclass
class NutritionalInfo:
    carbs: float
    protein: float
    fat: float
    fiber: float
    glycemic_index: int

def calculate_glycemic_load(gi: int, carbs_grams: float) -> float:
    """
    Calcula la Carga Glucémica (CG).
    CG = (IG * Carbohidratos_Netos) / 100
    """
    return (gi * carbs_grams) / 100.0

def calculate_daily_bolus(
    total_carbs: float, 
    icr: float, 
    current_glucose: float, 
    target_glucose: float, 
    isf: float
) -> float:
    """
    Algoritmo estándar de Bolus Wizard.
    Bolus = (Carbs / ICR) + ((Current - Target) / ISF)
    """
    carb_insulin = total_carbs / icr
    correction_insulin = (current_glucose - target_glucose) / isf
    
    # El bolus no puede ser negativo (si tienes hipoglucemia, no te pones insulina)
    total = carb_insulin + correction_insulin
    return max(0.0, total)
