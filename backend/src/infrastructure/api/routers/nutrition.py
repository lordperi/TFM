import logging
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel

logger = logging.getLogger(__name__)

from src.infrastructure.db.database import get_db
from src.infrastructure.api.dependencies import get_current_user_id
from src.infrastructure.db.xp_repository import XPRepository
from src.application.repositories.nutrition_repository import NutritionRepository
from src.application.use_cases.search_ingredients import execute_search
from src.application.use_cases.calculate_bolus import execute_calculate_bolus
from src.application.use_cases.log_meal import execute_log_meal

router = APIRouter(prefix="/nutrition", tags=["Nutrition Engine"])

def get_nutrition_repo(db: Session = Depends(get_db)) -> NutritionRepository:
    return NutritionRepository(db)

# --- Pydantic Schemas (DTOS) ---
class IngredientResponse(BaseModel):
    id: str   # UUID como string para compatibilidad Flutter
    name: str
    glycemic_index: int
    carbs: float         # alias de carbs_per_100g — nombre esperado por el frontend
    fiber_per_100g: float

    @classmethod
    def from_model(cls, m) -> "IngredientResponse":
        return cls(
            id=str(m.id),
            name=m.name,
            glycemic_index=m.glycemic_index,
            carbs=m.carbs_per_100g,
            fiber_per_100g=m.fiber_per_100g,
        )

class IngredientCreateRequest(BaseModel):
    name: str
    glycemic_index: int
    carbs_per_100g: float
    fiber_per_100g: float = 0.0

class IngredientInput(BaseModel):
    ingredient_id: UUID
    weight_grams: float

class BolusCalcRequest(BaseModel):
    current_glucose: float
    target_glucose: float
    ingredients: List[IngredientInput]
    icr: float = 10.0  
    isf: float = 50.0  

class BolusCalcResponse(BaseModel):
    total_carbs_grams: float
    recommended_bolus_units: float

class LogMealRequest(BaseModel):
    patient_id: UUID
    ingredients: List[IngredientInput]
    notes: Optional[str] = None
    bolus_units_administered: Optional[float] = None

class MealLogResponse(BaseModel):
    id: UUID
    patient_id: UUID
    total_carbs_grams: float
    total_glycemic_load: float
    bolus_units_administered: Optional[float] = None
    timestamp: Optional[datetime] = None

    model_config = {"from_attributes": True}

# --- ENDPOINTS ---

@router.get("/ingredients", response_model=List[IngredientResponse])
def search_ingredients(
    q: str = Query(..., min_length=2, description="Nombre del alimento a buscar"),
    limit: int = 20,
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Búsqueda por nombre de ingredientes."""
    results = execute_search(query=q, repo=repo, limit=limit)
    return [IngredientResponse.from_model(r) for r in results]


@router.post("/ingredients", response_model=IngredientResponse, status_code=status.HTTP_201_CREATED)
def create_ingredient(
    payload: IngredientCreateRequest,
    repo: NutritionRepository = Depends(get_nutrition_repo),
):
    """Crea un nuevo ingrediente en la base de datos."""
    try:
        ingredient = repo.create_ingredient(
            name=payload.name,
            glycemic_index=payload.glycemic_index,
            carbs_per_100g=payload.carbs_per_100g,
            fiber_per_100g=payload.fiber_per_100g,
        )
        return IngredientResponse.from_model(ingredient)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))


# Lista curada de 165 alimentos con IG y macros validados
# Fuentes: tablas internacionales de IG (Foster-Powell et al.), BEDCA, USDA FoodData Central
_SEED_INGREDIENTS = [
    # ── CEREALES Y ARROCES ───────────────────────────────────────────────────
    {"name": "Arroz blanco cocido",        "glycemic_index": 73, "carbs_per_100g": 28.2, "fiber_per_100g": 0.4},
    {"name": "Arroz integral cocido",      "glycemic_index": 50, "carbs_per_100g": 23.0, "fiber_per_100g": 1.8},
    {"name": "Arroz basmati cocido",       "glycemic_index": 57, "carbs_per_100g": 25.2, "fiber_per_100g": 0.6},
    {"name": "Arroz jazmín cocido",        "glycemic_index": 68, "carbs_per_100g": 28.7, "fiber_per_100g": 0.4},
    {"name": "Arroz inflado",              "glycemic_index": 87, "carbs_per_100g": 87.7, "fiber_per_100g": 1.0},
    {"name": "Copos de avena",             "glycemic_index": 55, "carbs_per_100g": 58.7, "fiber_per_100g": 10.1},
    {"name": "Avena cocida (porridge)",    "glycemic_index": 55, "carbs_per_100g": 12.0, "fiber_per_100g": 1.7},
    {"name": "Muesli sin azúcar",          "glycemic_index": 57, "carbs_per_100g": 59.0, "fiber_per_100g": 7.0},
    {"name": "Corn flakes",                "glycemic_index": 81, "carbs_per_100g": 84.0, "fiber_per_100g": 1.2},
    {"name": "Trigo bulgur cocido",        "glycemic_index": 46, "carbs_per_100g": 18.6, "fiber_per_100g": 4.5},
    {"name": "Quinoa cocida",              "glycemic_index": 53, "carbs_per_100g": 21.3, "fiber_per_100g": 2.8},
    {"name": "Cuscús cocido",              "glycemic_index": 65, "carbs_per_100g": 23.2, "fiber_per_100g": 1.4},
    {"name": "Maíz dulce",                 "glycemic_index": 52, "carbs_per_100g": 18.7, "fiber_per_100g": 2.7},
    {"name": "Palomitas de maíz",          "glycemic_index": 65, "carbs_per_100g": 55.0, "fiber_per_100g": 10.0},

    # ── PANES Y PANIFICACIÓN ─────────────────────────────────────────────────
    {"name": "Pan blanco",                 "glycemic_index": 75, "carbs_per_100g": 49.0, "fiber_per_100g": 2.7},
    {"name": "Pan integral",               "glycemic_index": 51, "carbs_per_100g": 41.0, "fiber_per_100g": 6.0},
    {"name": "Pan de centeno",             "glycemic_index": 41, "carbs_per_100g": 45.8, "fiber_per_100g": 5.8},
    {"name": "Pan de pita",                "glycemic_index": 68, "carbs_per_100g": 55.7, "fiber_per_100g": 2.2},
    {"name": "Pan de hamburguesa",         "glycemic_index": 72, "carbs_per_100g": 47.0, "fiber_per_100g": 1.5},
    {"name": "Baguette",                   "glycemic_index": 95, "carbs_per_100g": 55.0, "fiber_per_100g": 2.7},
    {"name": "Tostadas integrales",        "glycemic_index": 74, "carbs_per_100g": 65.0, "fiber_per_100g": 7.5},
    {"name": "Cracker de arroz",           "glycemic_index": 82, "carbs_per_100g": 80.8, "fiber_per_100g": 1.0},
    {"name": "Tortilla de trigo (wrap)",   "glycemic_index": 62, "carbs_per_100g": 52.0, "fiber_per_100g": 2.4},
    {"name": "Croissant",                  "glycemic_index": 67, "carbs_per_100g": 45.8, "fiber_per_100g": 1.5},

    # ── PASTAS ───────────────────────────────────────────────────────────────
    {"name": "Espaguetis cocidos",         "glycemic_index": 49, "carbs_per_100g": 25.0, "fiber_per_100g": 1.8},
    {"name": "Macarrones cocidos",         "glycemic_index": 50, "carbs_per_100g": 24.7, "fiber_per_100g": 1.6},
    {"name": "Pasta integral cocida",      "glycemic_index": 42, "carbs_per_100g": 23.2, "fiber_per_100g": 4.5},
    {"name": "Fideos de arroz cocidos",    "glycemic_index": 61, "carbs_per_100g": 24.0, "fiber_per_100g": 0.4},
    {"name": "Lasaña cocida",              "glycemic_index": 47, "carbs_per_100g": 22.6, "fiber_per_100g": 1.5},

    # ── PATATAS Y TUBÉRCULOS ─────────────────────────────────────────────────
    {"name": "Patata cocida",              "glycemic_index": 78, "carbs_per_100g": 17.0, "fiber_per_100g": 1.3},
    {"name": "Patata al horno",            "glycemic_index": 85, "carbs_per_100g": 19.0, "fiber_per_100g": 1.8},
    {"name": "Patata frita",               "glycemic_index": 63, "carbs_per_100g": 35.0, "fiber_per_100g": 3.4},
    {"name": "Puré de patata",             "glycemic_index": 83, "carbs_per_100g": 14.0, "fiber_per_100g": 1.5},
    {"name": "Boniato cocido",             "glycemic_index": 63, "carbs_per_100g": 20.1, "fiber_per_100g": 3.0},
    {"name": "Yuca cocida",                "glycemic_index": 46, "carbs_per_100g": 27.0, "fiber_per_100g": 1.8},

    # ── FRUTAS ───────────────────────────────────────────────────────────────
    {"name": "Manzana",                    "glycemic_index": 36, "carbs_per_100g": 13.8, "fiber_per_100g": 2.4},
    {"name": "Pera",                       "glycemic_index": 38, "carbs_per_100g": 15.5, "fiber_per_100g": 3.1},
    {"name": "Plátano maduro",             "glycemic_index": 62, "carbs_per_100g": 22.8, "fiber_per_100g": 2.6},
    {"name": "Plátano verde",              "glycemic_index": 30, "carbs_per_100g": 18.5, "fiber_per_100g": 3.4},
    {"name": "Naranja",                    "glycemic_index": 43, "carbs_per_100g": 11.8, "fiber_per_100g": 2.4},
    {"name": "Mandarina",                  "glycemic_index": 42, "carbs_per_100g": 13.3, "fiber_per_100g": 1.8},
    {"name": "Uvas blancas",               "glycemic_index": 59, "carbs_per_100g": 17.2, "fiber_per_100g": 0.9},
    {"name": "Uvas negras",                "glycemic_index": 53, "carbs_per_100g": 16.0, "fiber_per_100g": 0.9},
    {"name": "Sandía",                     "glycemic_index": 72, "carbs_per_100g": 7.6,  "fiber_per_100g": 0.4},
    {"name": "Melón",                      "glycemic_index": 65, "carbs_per_100g": 7.9,  "fiber_per_100g": 0.9},
    {"name": "Fresas",                     "glycemic_index": 40, "carbs_per_100g": 7.7,  "fiber_per_100g": 2.0},
    {"name": "Arándanos",                  "glycemic_index": 53, "carbs_per_100g": 14.5, "fiber_per_100g": 2.4},
    {"name": "Frambuesas",                 "glycemic_index": 25, "carbs_per_100g": 11.9, "fiber_per_100g": 6.5},
    {"name": "Moras",                      "glycemic_index": 25, "carbs_per_100g": 9.6,  "fiber_per_100g": 5.3},
    {"name": "Kiwi",                       "glycemic_index": 50, "carbs_per_100g": 14.7, "fiber_per_100g": 3.0},
    {"name": "Mango",                      "glycemic_index": 51, "carbs_per_100g": 17.0, "fiber_per_100g": 1.8},
    {"name": "Piña",                       "glycemic_index": 59, "carbs_per_100g": 13.1, "fiber_per_100g": 1.4},
    {"name": "Papaya",                     "glycemic_index": 60, "carbs_per_100g": 10.8, "fiber_per_100g": 1.7},
    {"name": "Melocotón",                  "glycemic_index": 42, "carbs_per_100g": 9.5,  "fiber_per_100g": 1.5},
    {"name": "Ciruela",                    "glycemic_index": 39, "carbs_per_100g": 11.4, "fiber_per_100g": 1.4},
    {"name": "Cereza",                     "glycemic_index": 22, "carbs_per_100g": 16.0, "fiber_per_100g": 2.1},
    {"name": "Higos frescos",              "glycemic_index": 61, "carbs_per_100g": 19.2, "fiber_per_100g": 2.9},
    {"name": "Dátiles",                    "glycemic_index": 42, "carbs_per_100g": 74.0, "fiber_per_100g": 6.7},
    {"name": "Pasas",                      "glycemic_index": 64, "carbs_per_100g": 79.2, "fiber_per_100g": 3.7},
    {"name": "Pomelo",                     "glycemic_index": 25, "carbs_per_100g": 10.7, "fiber_per_100g": 1.6},
    {"name": "Granada",                    "glycemic_index": 35, "carbs_per_100g": 18.7, "fiber_per_100g": 4.0},
    {"name": "Coco rallado",               "glycemic_index": 45, "carbs_per_100g": 23.7, "fiber_per_100g": 16.3},

    # ── VERDURAS Y HORTALIZAS ────────────────────────────────────────────────
    {"name": "Tomate",                     "glycemic_index": 15, "carbs_per_100g": 3.9,  "fiber_per_100g": 1.2},
    {"name": "Tomate cherry",              "glycemic_index": 15, "carbs_per_100g": 5.8,  "fiber_per_100g": 1.2},
    {"name": "Zanahoria cruda",            "glycemic_index": 16, "carbs_per_100g": 9.6,  "fiber_per_100g": 2.8},
    {"name": "Zanahoria cocida",           "glycemic_index": 47, "carbs_per_100g": 8.2,  "fiber_per_100g": 3.0},
    {"name": "Lechuga",                    "glycemic_index": 10, "carbs_per_100g": 2.9,  "fiber_per_100g": 1.3},
    {"name": "Espinacas",                  "glycemic_index": 15, "carbs_per_100g": 3.6,  "fiber_per_100g": 2.2},
    {"name": "Brócoli",                    "glycemic_index": 10, "carbs_per_100g": 6.6,  "fiber_per_100g": 2.6},
    {"name": "Coliflor",                   "glycemic_index": 15, "carbs_per_100g": 5.0,  "fiber_per_100g": 2.0},
    {"name": "Coles de Bruselas",          "glycemic_index": 15, "carbs_per_100g": 9.0,  "fiber_per_100g": 3.8},
    {"name": "Calabacín",                  "glycemic_index": 15, "carbs_per_100g": 3.1,  "fiber_per_100g": 1.0},
    {"name": "Pepino",                     "glycemic_index": 15, "carbs_per_100g": 3.6,  "fiber_per_100g": 0.5},
    {"name": "Pimiento verde",             "glycemic_index": 10, "carbs_per_100g": 6.4,  "fiber_per_100g": 2.1},
    {"name": "Pimiento rojo",              "glycemic_index": 10, "carbs_per_100g": 6.0,  "fiber_per_100g": 2.1},
    {"name": "Berenjena",                  "glycemic_index": 15, "carbs_per_100g": 5.9,  "fiber_per_100g": 3.0},
    {"name": "Cebolla",                    "glycemic_index": 10, "carbs_per_100g": 9.3,  "fiber_per_100g": 1.7},
    {"name": "Cebolla caramelizada",       "glycemic_index": 30, "carbs_per_100g": 18.0, "fiber_per_100g": 1.5},
    {"name": "Ajo",                        "glycemic_index": 10, "carbs_per_100g": 33.1, "fiber_per_100g": 2.1},
    {"name": "Espárragos",                 "glycemic_index": 15, "carbs_per_100g": 3.9,  "fiber_per_100g": 2.1},
    {"name": "Alcachofa cocida",           "glycemic_index": 15, "carbs_per_100g": 10.5, "fiber_per_100g": 5.4},
    {"name": "Guisantes cocidos",          "glycemic_index": 51, "carbs_per_100g": 14.5, "fiber_per_100g": 5.5},
    {"name": "Habas cocidas",              "glycemic_index": 40, "carbs_per_100g": 18.0, "fiber_per_100g": 7.6},
    {"name": "Judías verdes cocidas",      "glycemic_index": 15, "carbs_per_100g": 7.1,  "fiber_per_100g": 3.4},
    {"name": "Remolacha cocida",           "glycemic_index": 64, "carbs_per_100g": 9.6,  "fiber_per_100g": 2.0},
    {"name": "Apio",                       "glycemic_index": 15, "carbs_per_100g": 3.0,  "fiber_per_100g": 1.6},
    {"name": "Champiñones",                "glycemic_index": 15, "carbs_per_100g": 3.3,  "fiber_per_100g": 1.0},
    {"name": "Setas shiitake",             "glycemic_index": 10, "carbs_per_100g": 6.8,  "fiber_per_100g": 2.5},
    {"name": "Aguacate",                   "glycemic_index": 10, "carbs_per_100g": 8.5,  "fiber_per_100g": 6.7},
    {"name": "Aceitunas",                  "glycemic_index": 15, "carbs_per_100g": 3.8,  "fiber_per_100g": 3.2},

    # ── LEGUMBRES ────────────────────────────────────────────────────────────
    {"name": "Lentejas cocidas",           "glycemic_index": 32, "carbs_per_100g": 20.1, "fiber_per_100g": 7.9},
    {"name": "Garbanzos cocidos",          "glycemic_index": 28, "carbs_per_100g": 27.4, "fiber_per_100g": 7.6},
    {"name": "Alubias negras cocidas",     "glycemic_index": 30, "carbs_per_100g": 23.7, "fiber_per_100g": 8.7},
    {"name": "Alubias blancas cocidas",    "glycemic_index": 31, "carbs_per_100g": 26.0, "fiber_per_100g": 11.0},
    {"name": "Alubias rojas cocidas",      "glycemic_index": 29, "carbs_per_100g": 22.8, "fiber_per_100g": 7.4},
    {"name": "Edamame cocido",             "glycemic_index": 18, "carbs_per_100g": 8.9,  "fiber_per_100g": 5.2},
    {"name": "Tofu",                       "glycemic_index": 15, "carbs_per_100g": 1.9,  "fiber_per_100g": 0.3},
    {"name": "Hummus",                     "glycemic_index": 25, "carbs_per_100g": 14.3, "fiber_per_100g": 6.0},

    # ── LÁCTEOS ──────────────────────────────────────────────────────────────
    {"name": "Leche entera",               "glycemic_index": 31, "carbs_per_100g": 4.8,  "fiber_per_100g": 0.0},
    {"name": "Leche semidesnatada",        "glycemic_index": 30, "carbs_per_100g": 5.0,  "fiber_per_100g": 0.0},
    {"name": "Leche desnatada",            "glycemic_index": 32, "carbs_per_100g": 5.1,  "fiber_per_100g": 0.0},
    {"name": "Leche de avena",             "glycemic_index": 69, "carbs_per_100g": 9.0,  "fiber_per_100g": 0.5},
    {"name": "Leche de almendras",         "glycemic_index": 25, "carbs_per_100g": 3.0,  "fiber_per_100g": 0.4},
    {"name": "Leche de soja",              "glycemic_index": 34, "carbs_per_100g": 6.3,  "fiber_per_100g": 0.4},
    {"name": "Yogur natural",              "glycemic_index": 35, "carbs_per_100g": 6.0,  "fiber_per_100g": 0.0},
    {"name": "Yogur griego natural",       "glycemic_index": 11, "carbs_per_100g": 3.6,  "fiber_per_100g": 0.0},
    {"name": "Yogur de frutas",            "glycemic_index": 33, "carbs_per_100g": 17.9, "fiber_per_100g": 0.0},
    {"name": "Queso fresco",               "glycemic_index": 10, "carbs_per_100g": 2.7,  "fiber_per_100g": 0.0},
    {"name": "Queso curado (manchego)",    "glycemic_index": 10, "carbs_per_100g": 0.5,  "fiber_per_100g": 0.0},
    {"name": "Queso mozzarella",           "glycemic_index": 10, "carbs_per_100g": 2.2,  "fiber_per_100g": 0.0},
    {"name": "Requesón",                   "glycemic_index": 10, "carbs_per_100g": 3.4,  "fiber_per_100g": 0.0},
    {"name": "Helado de vainilla",         "glycemic_index": 57, "carbs_per_100g": 23.0, "fiber_per_100g": 0.0},
    {"name": "Helado de chocolate",        "glycemic_index": 62, "carbs_per_100g": 26.0, "fiber_per_100g": 0.7},

    # ── CARNES Y PROTEÍNAS (0 carbs o mínimas) ──────────────────────────────
    {"name": "Pechuga de pollo",           "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Muslo de pollo",             "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Lomo de cerdo",              "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Solomillo de ternera",       "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Hamburguesa de ternera",     "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Pavo filete",                "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Huevo entero",               "glycemic_index":  0, "carbs_per_100g": 0.6,  "fiber_per_100g": 0.0},
    {"name": "Jamón cocido",               "glycemic_index":  0, "carbs_per_100g": 1.5,  "fiber_per_100g": 0.0},
    {"name": "Jamón serrano",              "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},

    # ── PESCADOS Y MARISCOS (0 carbs) ────────────────────────────────────────
    {"name": "Salmón",                     "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Atún fresco",                "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Atún en lata (al natural)",  "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Merluza",                    "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Bacalao",                    "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Gambas",                     "glycemic_index":  0, "carbs_per_100g": 0.9,  "fiber_per_100g": 0.0},
    {"name": "Sardinas",                   "glycemic_index":  0, "carbs_per_100g": 0.0,  "fiber_per_100g": 0.0},

    # ── BEBIDAS ──────────────────────────────────────────────────────────────
    {"name": "Zumo de naranja",            "glycemic_index": 50, "carbs_per_100g": 10.4, "fiber_per_100g": 0.2},
    {"name": "Zumo de manzana",            "glycemic_index": 44, "carbs_per_100g": 11.7, "fiber_per_100g": 0.1},
    {"name": "Zumo de tomate",             "glycemic_index": 38, "carbs_per_100g": 4.2,  "fiber_per_100g": 0.4},
    {"name": "Zumo de zanahoria",          "glycemic_index": 43, "carbs_per_100g": 9.3,  "fiber_per_100g": 0.4},
    {"name": "Coca-Cola",                  "glycemic_index": 63, "carbs_per_100g": 10.6, "fiber_per_100g": 0.0},
    {"name": "Fanta naranja",              "glycemic_index": 68, "carbs_per_100g": 11.8, "fiber_per_100g": 0.0},
    {"name": "Batido de chocolate",        "glycemic_index": 37, "carbs_per_100g": 13.0, "fiber_per_100g": 0.0},
    {"name": "Bebida isotónica (Aquarius)","glycemic_index": 78, "carbs_per_100g": 6.5,  "fiber_per_100g": 0.0},

    # ── DULCES Y REPOSTERÍA ──────────────────────────────────────────────────
    {"name": "Chocolate negro 70%",        "glycemic_index": 23, "carbs_per_100g": 44.0, "fiber_per_100g": 10.9},
    {"name": "Chocolate con leche",        "glycemic_index": 43, "carbs_per_100g": 59.5, "fiber_per_100g": 1.5},
    {"name": "Chocolate blanco",           "glycemic_index": 44, "carbs_per_100g": 59.2, "fiber_per_100g": 0.0},
    {"name": "Galletas tipo María",        "glycemic_index": 70, "carbs_per_100g": 74.4, "fiber_per_100g": 2.0},
    {"name": "Galletas de avena",          "glycemic_index": 55, "carbs_per_100g": 64.0, "fiber_per_100g": 4.5},
    {"name": "Galletas Oreo",              "glycemic_index": 71, "carbs_per_100g": 71.0, "fiber_per_100g": 2.4},
    {"name": "Tarta de manzana",           "glycemic_index": 44, "carbs_per_100g": 36.0, "fiber_per_100g": 1.2},
    {"name": "Tarta de chocolate",         "glycemic_index": 38, "carbs_per_100g": 48.0, "fiber_per_100g": 1.5},
    {"name": "Bizcocho",                   "glycemic_index": 54, "carbs_per_100g": 53.0, "fiber_per_100g": 0.8},
    {"name": "Donuts",                     "glycemic_index": 76, "carbs_per_100g": 47.5, "fiber_per_100g": 1.1},
    {"name": "Bollería industrial",        "glycemic_index": 65, "carbs_per_100g": 52.0, "fiber_per_100g": 1.0},
    {"name": "Miel",                       "glycemic_index": 61, "carbs_per_100g": 82.4, "fiber_per_100g": 0.2},
    {"name": "Mermelada de fresa",         "glycemic_index": 51, "carbs_per_100g": 69.0, "fiber_per_100g": 0.6},
    {"name": "Azúcar blanca",              "glycemic_index": 65, "carbs_per_100g": 99.8, "fiber_per_100g": 0.0},
    {"name": "Azúcar moreno",              "glycemic_index": 64, "carbs_per_100g": 98.1, "fiber_per_100g": 0.0},
    {"name": "Sirope de agave",            "glycemic_index": 19, "carbs_per_100g": 76.0, "fiber_per_100g": 0.0},
    {"name": "Chuches (gominolas)",        "glycemic_index": 78, "carbs_per_100g": 77.0, "fiber_per_100g": 0.0},

    # ── SNACKS Y APERITIVOS ──────────────────────────────────────────────────
    {"name": "Patatas fritas de bolsa",    "glycemic_index": 57, "carbs_per_100g": 52.9, "fiber_per_100g": 4.3},
    {"name": "Nachos",                     "glycemic_index": 74, "carbs_per_100g": 63.0, "fiber_per_100g": 5.0},
    {"name": "Palomitas con mantequilla",  "glycemic_index": 72, "carbs_per_100g": 60.0, "fiber_per_100g": 10.0},
    {"name": "Pretzels",                   "glycemic_index": 83, "carbs_per_100g": 76.0, "fiber_per_100g": 2.5},

    # ── FRUTOS SECOS Y SEMILLAS ──────────────────────────────────────────────
    {"name": "Almendras",                  "glycemic_index": 15, "carbs_per_100g": 21.7, "fiber_per_100g": 12.5},
    {"name": "Nueces",                     "glycemic_index": 15, "carbs_per_100g": 13.7, "fiber_per_100g": 6.7},
    {"name": "Cacahuetes",                 "glycemic_index": 14, "carbs_per_100g": 16.1, "fiber_per_100g": 8.5},
    {"name": "Anacardos",                  "glycemic_index": 22, "carbs_per_100g": 30.2, "fiber_per_100g": 3.3},
    {"name": "Pistachos",                  "glycemic_index": 15, "carbs_per_100g": 27.5, "fiber_per_100g": 10.3},
    {"name": "Avellanas",                  "glycemic_index": 15, "carbs_per_100g": 16.7, "fiber_per_100g": 9.7},
    {"name": "Semillas de chía",           "glycemic_index": 10, "carbs_per_100g": 42.1, "fiber_per_100g": 34.4},
    {"name": "Semillas de lino",           "glycemic_index": 10, "carbs_per_100g": 28.9, "fiber_per_100g": 27.3},
    {"name": "Mantequilla de cacahuete",   "glycemic_index": 14, "carbs_per_100g": 20.0, "fiber_per_100g": 6.0},

    # ── PLATOS PREPARADOS Y COMIDA RÁPIDA ────────────────────────────────────
    {"name": "Pizza margarita",            "glycemic_index": 60, "carbs_per_100g": 33.0, "fiber_per_100g": 2.3},
    {"name": "Pizza pepperoni",            "glycemic_index": 60, "carbs_per_100g": 31.5, "fiber_per_100g": 2.0},
    {"name": "Hamburguesa con pan",        "glycemic_index": 66, "carbs_per_100g": 24.0, "fiber_per_100g": 1.2},
    {"name": "Sándwich de jamón y queso",  "glycemic_index": 60, "carbs_per_100g": 26.0, "fiber_per_100g": 1.5},
    {"name": "Burrito de pollo",           "glycemic_index": 58, "carbs_per_100g": 30.0, "fiber_per_100g": 3.0},
    {"name": "Sopa de verduras",           "glycemic_index": 48, "carbs_per_100g": 8.5,  "fiber_per_100g": 2.0},
    {"name": "Paella",                     "glycemic_index": 56, "carbs_per_100g": 22.5, "fiber_per_100g": 0.8},
    {"name": "Tortilla española",          "glycemic_index": 54, "carbs_per_100g": 12.5, "fiber_per_100g": 0.8},

    # ── SALSAS Y CONDIMENTOS ─────────────────────────────────────────────────
    {"name": "Ketchup",                    "glycemic_index": 55, "carbs_per_100g": 26.1, "fiber_per_100g": 0.8},
    {"name": "Salsa de tomate (frito)",    "glycemic_index": 45, "carbs_per_100g": 15.5, "fiber_per_100g": 1.5},
    {"name": "Mayonesa",                   "glycemic_index": 10, "carbs_per_100g": 2.0,  "fiber_per_100g": 0.0},
    {"name": "Mostaza",                    "glycemic_index": 10, "carbs_per_100g": 8.0,  "fiber_per_100g": 3.0},
    {"name": "Salsa de soja",              "glycemic_index": 10, "carbs_per_100g": 8.1,  "fiber_per_100g": 0.8},
    {"name": "Vinagreta",                  "glycemic_index": 10, "carbs_per_100g": 3.2,  "fiber_per_100g": 0.0},
]


@router.post("/ingredients/seed", response_model=dict)
def seed_ingredients(
    repo: NutritionRepository = Depends(get_nutrition_repo),
):
    """Puebla la base de datos con ingredientes comunes si aún no existen."""
    inserted = repo.bulk_create_ingredients(_SEED_INGREDIENTS)
    return {"inserted": inserted, "total_available": len(_SEED_INGREDIENTS)}

@router.post("/bolus/calculate", response_model=BolusCalcResponse)
def calculate_bolus(
    payload: BolusCalcRequest,
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Calcula el bolus de insulina basado en carbohidratos, glucemia actual y objetivos."""
    ing_dicts = [{"ingredient_id": i.ingredient_id, "weight_grams": i.weight_grams} for i in payload.ingredients]
    result = execute_calculate_bolus(
        current_glucose=payload.current_glucose,
        target_glucose=payload.target_glucose,
        icr=payload.icr,
        isf=payload.isf,
        ingredients_input=ing_dicts,
        repo=repo
    )
    return result

@router.post("/meals", response_model=MealLogResponse)
def log_meal(
    payload: LogMealRequest,
    repo: NutritionRepository = Depends(get_nutrition_repo),
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Registra una ingesta en el historial del paciente, encriptando notas (PHI).

    Otorga 10 XP al usuario autenticado por cada comida registrada.
    """
    ing_dicts = [{"ingredient_id": i.ingredient_id, "weight_grams": i.weight_grams} for i in payload.ingredients]
    try:
        meal = execute_log_meal(
            patient_id=payload.patient_id,
            ingredients_input=ing_dicts,
            notes=payload.notes,
            bolus_units_administered=payload.bolus_units_administered,
            repo=repo
        )

        # Otorgar XP al usuario que registra la comida
        try:
            xp_repo = XPRepository(db)
            xp_repo.add_xp(
                user_id=UUID(current_user_id),
                amount=10,
                reason="meal_logged",
                description="Comida registrada",
            )
        except Exception as xp_err:
            logger.error("Error awarding XP for meal_logged [user=%s]: %s", current_user_id, xp_err)

        return MealLogResponse(
            id=meal.id,
            patient_id=meal.patient_id,
            total_carbs_grams=meal.total_carbs_grams,
            total_glycemic_load=meal.total_glycemic_load,
            bolus_units_administered=meal.bolus_units_administered,
            timestamp=meal.timestamp,
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/meals/history", response_model=List[MealLogResponse])
def get_meal_history(
    patient_id: UUID = Query(...),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    start_date: Optional[datetime] = Query(None, description="Filtro fecha inicio (ISO 8601)"),
    end_date: Optional[datetime] = Query(None, description="Filtro fecha fin (ISO 8601)"),
    repo: NutritionRepository = Depends(get_nutrition_repo)
):
    """Devuelve el historial de comidas registradas para un paciente, más reciente primero."""
    meals = repo.get_meal_history(
        patient_id=patient_id,
        limit=limit,
        offset=offset,
        start_date=start_date,
        end_date=end_date,
    )
    return [
        MealLogResponse(
            id=m.id,
            patient_id=m.patient_id,
            total_carbs_grams=m.total_carbs_grams,
            total_glycemic_load=m.total_glycemic_load,
            bolus_units_administered=m.bolus_units_administered,
            timestamp=m.timestamp.isoformat() if m.timestamp else None,
        )
        for m in meals
    ]
