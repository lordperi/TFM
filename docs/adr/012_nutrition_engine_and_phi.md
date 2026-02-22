# ADR-012: Diseño e Integración del Motor Nutricional y Protección PHI

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-21 |
| **Última revisión** | 2026-02-22 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect, Doc-AutoBot |

## Contexto

El cálculo del Bolus de insulina es el núcleo crítico de cualquier aplicación de gestión de Diabetes. DiaBeaty requiere un módulo de Nutrición capaz de:

1. Gestionar una base de datos de ingredientes con Índice Glucémico (IG) y carbohidratos.
2. Permitir búsqueda full-text de alimentos.
3. Soportar una "bandeja" multi-ingrediente para calcular el bolus de una comida completa.
4. Registrar ingestas asociadas a cargas glucémicas (CG) y sugerir dosis (Bolus) usando los parámetros del paciente (ICR, ISF, glucosa actual).
5. Proteger notas clínicas (PHI) mediante cifrado en reposo.

## Decisiones

### 1. Clean Architecture Strict

`NutritionRepository` aísla el acceso a datos de los casos de uso. Los routers FastAPI solo orquestan; la lógica vive en `application/use_cases/`.

### 2. Cifrado Transparente (PHI)

Las notas de comidas (posibles PHI: "hipoglucemia postprandial", "mareo tras ingesta") usan el Custom Type `EncryptedString` de SQLAlchemy (Fernet AES-128-CBC + HMAC). El ORM cifra/descifra de forma transparente; la BD nunca ve texto plano.

### 3. Casos de Uso Aislados

```
execute_calculate_bolus(current_glucose, target_glucose, icr, isf, ingredients_input, repo)
execute_log_meal(patient_id, ingredients_input, notes, bolus_units_administered, repo)
execute_search(query, repo, limit)
```

Los algoritmos son agnósticos al framework web, haciéndolos extensibles para IoT (CGM auto-log).

### 4. Modelo de Ingrediente con UUID

```python
class IngredientModel(Base):
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    name = Column(String, unique=True, index=True)
    glycemic_index = Column(Integer)
    carbs_per_100g = Column(Float)
    fiber_per_100g = Column(Float)
```

El `id` es UUID en base de datos. La API serializa el `id` como **string** en el JSON de respuesta para compatibilidad con Flutter (que usa `String` para UUIDs).

### 5. Campo `carbs` en IngredientResponse (Flutter Contract)

La columna de BD es `carbs_per_100g`, pero el DTO de respuesta expone el campo como `carbs` (nombre corto que usa el frontend):

```python
class IngredientResponse(BaseModel):
    id: str           # UUID como string
    carbs: float      # alias de carbs_per_100g
```

Esto evita romper el contrato con el frontend sin renombrar la columna de BD.

### 6. Seed Idempotente de Ingredientes

Endpoint `POST /api/v1/nutrition/ingredients/seed` que inserta 25 alimentos comunes (arroz, pasta, frutas, legumbres…) solo si no existen, usando `ilike` para case-insensitive matching. Devuelve `{"inserted": N}`.

### 7. Bandeja Multi-Ingrediente (MealTrayUpdated)

En el frontend, el `NutritionBloc` mantiene el estado `MealTrayUpdated` que contiene simultáneamente:
- `List<TrayItem> tray` — ingredientes añadidos con sus gramos
- `List<Ingredient> searchResults` — resultados de búsqueda activos

Cuando el usuario busca mientras tiene ingredientes en la bandeja, el bloc emite `copyWith(searchResults: results)` preservando la bandeja. Esto evita el anti-patrón de resetear estado por una búsqueda.

### 8. Bolus Multi-Ingrediente

```dart
CalculateBolusForTray(
  currentGlucose: glucosaActual,
  icr: perfil.carbRatio,
  isf: perfil.insulinSensitivity,
  targetGlucose: perfil.targetGlucose,
)
```

Los parámetros ICR/ISF/targetGlucose provienen del perfil activo en `AuthBloc`, no de valores hardcodeados. El caso de uso en backend los acepta como parámetros explícitos del request body.

### 9. TDD Core API

Todas las rutas fueron construidas pasando la fase Red-Green-Refactor con `TestClient` sobre SQLite in-memory. Los 8 nuevos tests del CRUD de ingredientes siguieron el mismo protocolo.

## Algoritmo de Bolus

```
CarbsNetos = Σ (ingredient.carbs_per_100g × weight_grams / 100)
CargaGlucemica = Σ (ingredient.glycemic_index × carbs_netos_item / 100)
Bolus = max(0, CarbsNetos/ICR + (GlucosaActual - GlucosaObjetivo)/ISF)
```

## Consecuencias

**Positivas:**
- Seguridad por defecto en notas de pacientes.
- El algoritmo es totalmente agnóstico al framework web.
- Seed idempotente permite repoblar producción sin riesgo de duplicados.
- La bandeja multi-ingrediente permite cálculos complejos sin múltiples API calls.

**Resueltos:**
- ✅ ICR/ISF derivados del perfil activo (resuelto en PR #20 `feature/fix-bolus-profile-params`).
- ✅ `id` de ingrediente como string UUID (resuelto en `feature/ingredient-crud-endpoint`).
- ✅ Nombre de campo `carbs` en respuesta API (resuelto en `feature/ingredient-crud-endpoint`).

**Limitaciones activas:**
- Los endpoints de ingredientes no requieren auth — apropiado para demo pero en producción deberían requerir rol de administrador.
- No hay paginación en búsqueda de ingredientes (máximo 20 resultados hardcodeado).
