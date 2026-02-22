# Arquitectura Backend — DiaBeaty

> Última actualización: 2026-02-22 · Python 3.12 · FastAPI · 108 tests ✅

## Patrón Arquitectónico

El backend sigue **Clean Architecture** (Hexagonal / Puertos y Adaptadores). La regla central: las dependencias solo apuntan hacia adentro.

```
Domain (sin dependencias)
  ↑
Application (depende solo de Domain)
  ↑
Infrastructure (depende de Application + Domain)
```

### Estructura de Capas (`backend/src/`)

#### Domain (`/domain`)
- **Responsabilidad**: Reglas de negocio puras, sin frameworks.
- **Contenido**: Entidades, enums, modelos de dominio.
- **Ficheros clave**:
  - `health_models.py` — `TherapyType`, `DiabetesType`
  - `xp_models.py` — lógica de gamificación (XP, niveles, logros)
  - `glucose_models.py` — entidad `GlucoseReading`
  - `nutrition.py` — enums y constantes del motor nutricional

#### Application (`/application`)
- **Responsabilidad**: Orquestación de casos de uso.
- **Contenido**: Casos de uso, interfaces de repositorios.
- **Casos de uso implementados**:

| Caso de Uso | Descripción |
|-------------|-------------|
| `calculate_bolus.py` | `Bolus = (Carbs/ICR) + (ΔGlucosa/ISF)`, nunca negativo |
| `log_meal.py` | Registra comida, calcula totales, cifra notas PHI |
| `search_ingredients.py` | Búsqueda full-text por nombre |

- **Repositorios**:
  - `nutrition_repository.py` — CRUD ingredientes + historial de comidas

#### Infrastructure (`/infrastructure`)
- **Responsabilidad**: Detalles técnicos (DB, HTTP, seguridad).

```
infrastructure/
├── api/
│   ├── routers/         # Endpoints FastAPI
│   │   ├── auth.py       # POST /login
│   │   ├── users.py      # POST /register, GET /me, PUT /profile
│   │   ├── family.py     # CRUD /profiles (perfiles de pacientes)
│   │   ├── glucose.py    # POST /add, GET /history
│   │   ├── nutrition.py  # GET/POST /ingredients, POST /seed, /bolus/calculate, /meals
│   │   └── health.py     # GET /health
│   └── dependencies.py   # get_current_user_id (validación JWT)
├── db/
│   ├── database.py       # Engine, SessionLocal, Base
│   ├── models.py         # ORM: User, Patient, HealthProfile, Ingredient, MealLog, MealItem
│   └── types.py          # EncryptedString (Fernet AES-128-CBC custom type)
└── security/
    ├── auth.py           # Bcrypt hashing/verification
    ├── jwt_handler.py    # JWT create_access_token, verify_token
    └── crypto.py         # Fernet encrypt/decrypt para PHI
```

---

## Modelo de Datos

### Relaciones principales

```
UserModel (1) ──────── (N) PatientModel
    │                          │
    │ (1:1)                     │ (1:1)
    ▼                          ▼
HealthProfileModel        HealthProfileModel
                               │
                               │ (1:N)
                               ▼
                          MealLogModel (1) ──── (N) MealItemModel
                                                         │ (N:1)
                                                         ▼
                                                    IngredientModel
```

### Campos cifrados (PHI — Fernet AES-128-CBC)

| Modelo | Campo | Motivo |
|--------|-------|--------|
| `HealthProfileModel` | `insulin_sensitivity` | Ratio médico personal |
| `HealthProfileModel` | `carb_ratio` | Ratio médico personal |
| `HealthProfileModel` | `target_glucose` | Objetivo terapéutico |
| `HealthProfileModel` | `basal_insulin_units` | Dosis de medicamento |
| `MealLogModel` | `notes` | Notas clínicas (PHI) |

El tipo `EncryptedString` es un custom SQLAlchemy `TypeDecorator` que cifra en `process_bind_param` y descifra en `process_result_value`. Transparente para el ORM.

---

## Seguridad

| Capa | Mecanismo |
|------|-----------|
| Contraseñas | Bcrypt (factor de coste 12) |
| Tokens de sesión | JWT HS256, expiración configurable |
| Datos PHI en DB | Fernet (AES-128-CBC + HMAC-SHA256) |
| Transport | HTTPS Full-Strict via Cloudflare |
| CORS | Orígenes permitidos explícitos |
| Headers | `TrustedHostMiddleware`, `X-Frame-Options: DENY` |

---

## Testing

### Estrategia

**TDD estricto**: Se escribe el test primero (RED), se implementa el mínimo para que pase (GREEN), se refactoriza (REFACTOR).

### Configuración (`tests/conftest.py`)

- SQLite `:memory:` con `StaticPool` — sin dependencias externas
- `scope="function"` con rollback de transacción — aislamiento total
- Override de `get_db` dependency — la app usa la session de test
- Mock del lifespan — evita conexión a PostgreSQL en tests

### Suite de tests (108 en total)

```
tests/
├── api/
│   ├── test_auth_login.py          # Login + tokens
│   ├── test_auth_jwt.py            # JWT validation
│   ├── test_nutrition_api.py       # Endpoints nutrición básicos
│   ├── test_ingredients_crud.py    # POST /ingredients + seed (8 tests)
│   ├── test_profile_endpoints.py   # CRUD perfiles
│   ├── test_user_profile.py        # PUT /profile
│   ├── test_family_basal_insulin.py # Insulina basal cifrada
│   └── test_health.py              # Heartbeat
└── unit/
    ├── test_nutrition_logic.py          # Algoritmo bolus
    ├── test_nutrition_security.py       # Cifrado notas PHI
    ├── test_health_profile_flexibility.py # Perfiles flexibles
    ├── test_conditional_medical_profiles.py # 11 combinaciones terapia
    ├── test_glucose_tracking.py          # Registro glucosa
    ├── test_meal_history.py              # Historial con filtros
    ├── test_user_router.py
    ├── test_family_router.py
    └── test_xp_models.py                # Gamificación XP/niveles
```

```bash
cd backend
pytest tests/ -v          # todos los tests
pytest tests/api/ -v      # solo API
pytest tests/unit/ -v     # solo unitarios
```

---

## Despliegue

### Docker Multi-Stage

```dockerfile
# Stage 1: Build (Python deps)
FROM python:3.12-slim AS builder
...

# Stage 2: Runtime (imagen mínima)
FROM python:3.12-slim
COPY --from=builder ...
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0"]
```

### Variables de entorno (inyectadas por Coolify)

```
DATABASE_URL      # postgresql+psycopg2://...
SECRET_KEY        # JWT signing key (≥ 32 chars random)
ENCRYPTION_KEY    # Fernet key (base64url, 32 bytes)
```

### Migraciones automáticas

Alembic ejecuta `alembic upgrade head` en el entrypoint del contenedor antes de iniciar Uvicorn. Historial de migraciones versionado junto al código.
