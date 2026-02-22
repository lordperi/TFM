# 📁 Estructura del Proyecto DiaBeaty Mobile

> Última actualización: 2026-02-22 · 36 tests ✅ · 93% completado

```
TFM/
├── backend/                              # Backend FastAPI (Python 3.12)
│   ├── src/
│   │   ├── domain/                      # 🧠 DOMAIN — Entidades y reglas de negocio
│   │   │   ├── nutrition.py             # IngredientModel, MealLogModel (dominio)
│   │   │   ├── user_models.py           # UserModel, PatientModel (dominio)
│   │   │   ├── health_models.py         # TherapyType, DiabetesType
│   │   │   ├── glucose_models.py        # GlucoseReading
│   │   │   └── xp_models.py             # Gamification XP/Level logic
│   │   │
│   │   ├── application/                 # ⚙️ APPLICATION — Casos de uso e interfaces
│   │   │   ├── use_cases/
│   │   │   │   ├── calculate_bolus.py   # Algoritmo: (Carbs/ICR) + (ΔGlucosa/ISF)
│   │   │   │   ├── log_meal.py          # Registrar comida + calcular totales
│   │   │   │   └── search_ingredients.py
│   │   │   ├── repositories/
│   │   │   │   └── nutrition_repository.py  # CRUD ingredientes + historial comidas
│   │   │   └── services/
│   │   │       ├── nutrition_service.py
│   │   │       └── user_service.py
│   │   │
│   │   └── infrastructure/              # 🔌 INFRASTRUCTURE — FastAPI, SQLAlchemy, Security
│   │       ├── api/
│   │       │   ├── routers/
│   │       │   │   ├── auth.py          # ✅ POST /login
│   │       │   │   ├── users.py         # ✅ POST /register, GET /me, PUT /profile
│   │       │   │   ├── family.py        # ✅ CRUD perfiles de pacientes
│   │       │   │   ├── glucose.py       # ✅ POST /add, GET /history
│   │       │   │   ├── nutrition.py     # ✅ Ingredientes CRUD, bolus, meals, seed
│   │       │   │   └── health.py        # ✅ GET /health (heartbeat)
│   │       │   ├── dependencies.py      # get_current_user_id (JWT validation)
│   │       │   └── schemas/             # Pydantic DTOs adicionales
│   │       ├── db/
│   │       │   ├── database.py          # Engine, SessionLocal, Base
│   │       │   ├── models.py            # ORM: User, Patient, HealthProfile, Ingredient, MealLog
│   │       │   └── types.py             # EncryptedString (Fernet custom type)
│   │       └── security/
│   │           ├── auth.py              # Bcrypt password hashing
│   │           ├── jwt_handler.py       # JWT create/verify
│   │           └── crypto.py            # Fernet encryption/decryption
│   │
│   ├── tests/                           # 🧪 108 tests pasando
│   │   ├── conftest.py                  # SQLite in-memory + rollback per function
│   │   ├── api/
│   │   │   ├── test_auth_login.py
│   │   │   ├── test_auth_jwt.py
│   │   │   ├── test_nutrition_api.py
│   │   │   ├── test_ingredients_crud.py # ✅ NUEVO: POST /ingredients + seed
│   │   │   ├── test_profile_endpoints.py
│   │   │   ├── test_user_profile.py
│   │   │   ├── test_family_basal_insulin.py
│   │   │   └── test_health.py
│   │   └── unit/
│   │       ├── test_nutrition_logic.py
│   │       ├── test_nutrition_security.py
│   │       ├── test_health_profile_flexibility.py
│   │       ├── test_conditional_medical_profiles.py
│   │       ├── test_glucose_tracking.py
│   │       ├── test_meal_history.py
│   │       ├── test_user_router.py
│   │       ├── test_family_router.py
│   │       └── test_xp_models.py
│   │
│   ├── alembic/                         # Migraciones de BD versionadas
│   └── requirements.txt
│
├── frontend/                            # Frontend Flutter (Dart)
│   ├── lib/
│   │   ├── core/                        # ⚙️ CORE — Configuración Central
│   │   │   ├── constants/
│   │   │   │   └── app_constants.dart   # API URLs, Enums, Storage Keys
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart       # 🎨 Dual UX Themes (Adulto/Niño)
│   │   │   └── network/
│   │   │       └── dio_client.dart      # 🔐 HTTP Client + JWT Interceptor
│   │   │
│   │   ├── data/                        # 📊 DATA LAYER — API & Models
│   │   │   ├── models/
│   │   │   │   ├── auth_models.dart     # ✅ DTOs: Login, Register, User, PatientProfile
│   │   │   │   ├── auth_models.g.dart   # (Generado por json_serializable)
│   │   │   │   ├── nutrition_models.dart # ✅ Ingredient(id:String), TrayItem, MealLogEntry
│   │   │   │   └── nutrition_models.g.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_api_client.dart    # ✅ Retrofit: Auth + Family endpoints
│   │   │   │   ├── auth_api_client.g.dart
│   │   │   │   ├── nutrition_api_client.dart # ✅ Retrofit: Nutrition endpoints
│   │   │   │   └── nutrition_api_client.g.dart
│   │   │   └── repositories/
│   │   │       └── family_repository.dart  # ✅ getProfiles, getProfileDetails, updateProfile
│   │   │
│   │   ├── presentation/                # 🎨 PRESENTATION LAYER — UI & State
│   │   │   ├── bloc/
│   │   │   │   ├── auth/
│   │   │   │   │   └── auth_bloc.dart   # ✅ Login, Register, SwitchProfile, RefreshSelectedProfile
│   │   │   │   ├── theme/
│   │   │   │   │   └── theme_bloc.dart  # ✅ SwitchTheme (Adult↔Child automático)
│   │   │   │   ├── profile/
│   │   │   │   │   └── profile_bloc.dart # ✅ XP, achievements
│   │   │   │   └── nutrition/
│   │   │   │       └── nutrition_bloc.dart # ✅ Tray, Bolus, History, Seed
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── auth/
│   │   │   │   │   └── login_screen.dart        # ✅ Login Dual UX
│   │   │   │   ├── dashboard/
│   │   │   │   │   └── dashboard_screen.dart    # ✅ Dashboard Adulto + Niño, nav botttom bar
│   │   │   │   ├── glucose/
│   │   │   │   │   ├── add_glucose_screen.dart  # ✅ Registrar lectura
│   │   │   │   │   └── glucose_history_screen.dart # ✅ Gráfica + lista + filtros fecha
│   │   │   │   ├── nutrition/
│   │   │   │   │   ├── nutrition_hub_screen.dart  # ✅ Hub con 5 secciones
│   │   │   │   │   ├── log_meal_screen.dart       # ✅ Bandeja multi-ingrediente + bolus
│   │   │   │   │   └── meal_history_screen.dart   # ✅ Historial comidas + marcadores insulina
│   │   │   │   └── profile/
│   │   │   │       ├── profile_screen.dart        # ✅ Router Adult/Child según perfil activo
│   │   │   │       ├── adult_profile_screen.dart  # ✅ Campos médicos completos + guardar
│   │   │   │       ├── child_profile_screen.dart  # ✅ Vista gamificada del niño
│   │   │   │       ├── edit_patient_screen.dart   # ✅ Editar datos del paciente (guardián)
│   │   │   │       └── profile_selection_screen.dart # ✅ Selector tipo Netflix
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── glucose_chart.dart             # ✅ Gráfica glucosa + marcadores insulina ▲
│   │   │       ├── conditional_medical_fields.dart # ✅ ISF/ICR según tipo terapia
│   │   │       └── basal_insulin_fields.dart       # ✅ Insulina basal (tipo, unidades, hora)
│   │   │
│   │   └── main.dart                    # 🚀 Entry Point + DI
│   │
│   ├── test/                            # 🧪 36 tests pasando
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc_test.dart
│   │   │   │   ├── nutrition_bloc_test.dart
│   │   │   │   └── nutrition_tray_bloc_test.dart   # ✅ Bandeja multi-ingrediente
│   │   │   └── screens/
│   │   │       └── profile/
│   │   │           └── member_profile_view_test.dart # ✅ Vista perfil miembro
│   │   └── widgets/
│   │       └── conditional_medical_fields_test.dart
│   │
│   └── pubspec.yaml
│
├── docs/                                # 📚 Documentación completa
│   ├── adr/                             # 12 Architecture Decision Records
│   │   ├── 001_tech_stack.md
│   │   ├── 002_clean_architecture.md
│   │   ├── 003_flutter_frontend.md
│   │   ├── 004_testing_strategy.md
│   │   ├── 005_data_encryption.md
│   │   ├── 006_database_alembic.md
│   │   ├── 007_infrastructure_coolify.md
│   │   ├── 008_application_service_layer.md
│   │   ├── 009_family_architecture.md
│   │   ├── 010_flexible_health_profiles_and_security.md
│   │   ├── 011_conditional_medical_profiles.md
│   │   └── 012_nutrition_engine_and_phi.md
│   ├── backend/
│   │   ├── architecture.md
│   │   ├── patients_schema.txt
│   │   └── swagger.json                 # OpenAPI spec exportada
│   ├── frontend/
│   │   ├── architecture.md              # BLoC pattern + Dual UX
│   │   ├── project_structure.md         # Este archivo
│   │   ├── quickstart.md
│   │   ├── scripts.md
│   │   └── README.md
│   ├── infrastructure/
│   │   ├── architecture.md
│   │   ├── coolify_deploy.md
│   │   └── deploy.md
│   └── reports/
│       └── sprint_1.md
│
├── CLAUDE.md                            # Instrucciones para Claude Code CLI
└── README.md                            # Documentación principal del proyecto
```

---

## 📊 Leyenda de Estados

- ✅ **Completado** — Implementado y testeado
- 🔜 **Próximo** — Planificado
- ⚙️ **Core** — Configuración central
- 🔐 **Security** — Relacionado con seguridad
- 🧪 **Testing** — Suite de tests

---

## 🎯 Archivos Clave

### Configuración

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `pubspec.yaml` | Dependencias y assets del frontend | ✅ |
| `backend/requirements.txt` | Dependencias Python | ✅ |
| `CLAUDE.md` | Instrucciones del AI orchestrator | ✅ |

### Backend — Archivos Críticos

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `src/infrastructure/db/models.py` | ORM completo (User, Patient, HealthProfile, Ingredient, MealLog) | ✅ |
| `src/infrastructure/db/types.py` | EncryptedString (Fernet custom SQLAlchemy type) | ✅ |
| `src/application/use_cases/calculate_bolus.py` | Algoritmo bolus + carga glucémica | ✅ |
| `src/application/repositories/nutrition_repository.py` | CRUD ingredientes + historial | ✅ |
| `src/infrastructure/api/routers/nutrition.py` | Endpoints nutrición (CRUD + seed) | ✅ |

### Frontend — Archivos Críticos

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `lib/presentation/bloc/auth/auth_bloc.dart` | Autenticación + perfil seleccionado | ✅ |
| `lib/presentation/bloc/nutrition/nutrition_bloc.dart` | Bandeja multi-ingrediente + historial | ✅ |
| `lib/data/models/nutrition_models.dart` | TrayItem, Ingredient(id:String), MealLogEntry | ✅ |
| `lib/presentation/screens/nutrition/nutrition_hub_screen.dart` | Hub con 5 secciones | ✅ |
| `lib/presentation/screens/nutrition/log_meal_screen.dart` | Flujo multi-ingrediente completo | ✅ |
| `lib/presentation/screens/dashboard/dashboard_screen.dart` | Dual UX + navegación | ✅ |

---

## 📈 Estado del Proyecto

| Métrica | Valor |
|---------|-------|
| Backend tests | 108 ✅ |
| Flutter tests | 36 ✅ |
| Endpoints API | 15 |
| Pantallas Flutter | 12 |
| ADRs documentados | 12 |
| Completitud MVP | 93% |
