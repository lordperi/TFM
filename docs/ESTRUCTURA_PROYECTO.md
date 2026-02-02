# 📁 Estructura del Proyecto DiaBeaty Mobile

```
TFM/
├── backend/                          # Backend FastAPI (Python)
│   ├── app/
│   │   ├── api/                     # Endpoints REST
│   │   ├── core/                    # Configuración, seguridad
│   │   ├── models/                  # Modelos SQLAlchemy
│   │   └── services/                # Lógica de negocio
│   └── tests/                       # Tests del backend
│
├── frontend/                         # Frontend Flutter (Dart)
│   ├── lib/
│   │   ├── core/                    # ⚙️ CORE - Configuración Central
│   │   │   ├── constants/
│   │   │   │   └── app_constants.dart      # API URLs, Enums, Storage Keys
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart          # 🎨 Dual UX Themes
│   │   │   └── network/
│   │   │       └── dio_client.dart         # 🔐 HTTP Client + JWT Interceptor
│   │   │
│   │   ├── data/                    # 📊 DATA LAYER - API & Storage
│   │   │   ├── models/
│   │   │   │   ├── auth_models.dart        # DTOs: Login, Register, User
│   │   │   │   ├── auth_models.g.dart      # (Generado)
│   │   │   │   ├── bolus_models.dart       # DTOs: Bolus Request/Response
│   │   │   │   └── nutrition_models.dart   # DTOs: Ingredient
│   │   │   ├── datasources/
│   │   │   │   ├── auth_api_client.dart    # Retrofit API (Auth)
│   │   │   │   ├── auth_api_client.g.dart  # (Generado)
│   │   │   │   └── nutrition_api_client.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/                  # 🧠 DOMAIN LAYER - Business Logic
│   │   │   ├── entities/
│   │   │   │   ├── user.dart               # Domain Model: User
│   │   │   │   ├── bolus_calculation.dart  # Domain Model: Bolus
│   │   │   │   └── ingredient.dart         # Domain Model: Ingredient
│   │   │   └── repositories/
│   │   │       ├── auth_repository.dart    # Interface
│   │   │       └── nutrition_repository.dart
│   │   │
│   │   ├── presentation/            # 🎨 PRESENTATION LAYER - UI & State
│   │   │   ├── bloc/
│   │   │   │   ├── auth/
│   │   │   │   │   └── auth_bloc.dart      # 🔐 Auth State Management
│   │   │   │   ├── theme/
│   │   │   │   │   └── theme_bloc.dart     # 🎨 Theme State Management
│   │   │   │   ├── bolus/
│   │   │   │   │   └── bolus_bloc.dart     # (Próximo)
│   │   │   │   └── nutrition/
│   │   │   │       └── nutrition_bloc.dart # (Próximo)
│   │   │   ├── screens/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── login_screen.dart   # ✅ Login (Dual UX)
│   │   │   │   │   └── register_screen.dart # (Próximo)
│   │   │   │   ├── home/
│   │   │   │   │   └── home_screen.dart    # (Próximo)
│   │   │   │   ├── bolus/
│   │   │   │   │   └── bolus_calculator_screen.dart
│   │   │   │   └── profile/
│   │   │   │       └── profile_screen.dart
│   │   │   └── widgets/
│   │   │       ├── dual_ux/               # Componentes Dual UX
│   │   │       │   ├── glucose_card.dart
│   │   │       │   ├── metric_widget.dart
│   │   │       │   └── quest_card.dart
│   │   │       └── common/                # Componentes Comunes
│   │   │           ├── loading_indicator.dart
│   │   │           └── error_widget.dart
│   │   │
│   │   └── main.dart                # 🚀 Entry Point
│   │
│   ├── assets/                      # 🎨 Assets
│   │   ├── images/                  # Logos, iconos
│   │   ├── animations/              # Lottie files
│   │   ├── icons/                   # Iconos personalizados
│   │   └── fonts/                   # Fuentes (Poppins)
│   │
│   ├── test/                        # 🧪 Tests
│   │   ├── bloc/
│   │   │   ├── auth_bloc_test.dart
│   │   │   └── theme_bloc_test.dart
│   │   ├── models/
│   │   │   └── auth_models_test.dart
│   │   └── screens/
│   │       └── login_screen_test.dart
│   │
│   ├── integration_test/            # 🧪 Integration Tests
│   │   └── app_test.dart
│   │
│   ├── pubspec.yaml                 # 📦 Dependencias
│   ├── analysis_options.yaml        # 🔍 Linting
│   └── README.md                    # 📚 Documentación
│
├── docs/                            # 📚 Documentación del Proyecto
│   ├── swagger.json                 # ✅ Contrato de API
│   ├── FLUTTER_ARCHITECTURE.md      # ✅ Arquitectura detallada
│   ├── FLUTTER_SCRIPTS.md           # ✅ Scripts de desarrollo
│   ├── PROYECTO_RESUMEN.md          # ✅ Resumen ejecutivo
│   └── ESTRUCTURA_PROYECTO.md       # ✅ Este archivo
│
├── .github/                         # GitHub Actions (CI/CD)
│   └── workflows/
│       ├── backend_tests.yml
│       └── flutter_tests.yml
│
├── .gitignore                       # ✅ Git ignore (modificado)
├── docker-compose.yml               # Docker setup
└── README.md                        # Documentación principal
```

---

## 📊 Leyenda de Estados

- ✅ **Completado** - Archivo/carpeta implementado
- 🔜 **Próximo** - Planificado para próximo sprint
- ⚙️ **Core** - Configuración central
- 📊 **Data** - Capa de datos
- 🧠 **Domain** - Capa de dominio
- 🎨 **Presentation** - Capa de presentación
- 🔐 **Security** - Relacionado con seguridad
- 🧪 **Testing** - Tests

---

## 🎯 Archivos Clave

### Configuración

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `pubspec.yaml` | Dependencias y assets | ✅ |
| `analysis_options.yaml` | Reglas de linting | ✅ |
| `.gitignore` | Exclusiones de Git | ✅ |

### Core

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `app_constants.dart` | URLs, Keys, Enums | ✅ |
| `app_theme.dart` | Temas Dual UX | ✅ |
| `dio_client.dart` | HTTP Client + JWT | ✅ |

### Data Layer

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `auth_models.dart` | DTOs de autenticación | ✅ |
| `auth_api_client.dart` | Retrofit API Client | ✅ |

### Presentation Layer

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `auth_bloc.dart` | BLoC de autenticación | ✅ |
| `theme_bloc.dart` | BLoC de temas | ✅ |
| `login_screen.dart` | Pantalla de Login | ✅ |
| `main.dart` | Entry point | ✅ |

---

## 🔄 Flujo de Datos

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │ LoginScreen  │────────▶│  AuthBloc    │                  │
│  └──────────────┘         └──────┬───────┘                  │
│                                   │                          │
└───────────────────────────────────┼──────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────┼──────────────────────────┐
│                      DOMAIN LAYER │                          │
│                                   │                          │
│                          ┌────────▼────────┐                 │
│                          │ AuthRepository  │                 │
│                          └────────┬────────┘                 │
│                                   │                          │
└───────────────────────────────────┼──────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────┼──────────────────────────┐
│                      DATA LAYER   │                          │
│                                   │                          │
│  ┌────────────────┐      ┌────────▼────────┐                │
│  │ AuthApiClient  │◀─────│  DioClient      │                │
│  └────────┬───────┘      └─────────────────┘                │
│           │                                                  │
└───────────┼──────────────────────────────────────────────────┘
            │
            ▼
┌───────────┼──────────────────────────────────────────────────┐
│           │              EXTERNAL API                        │
│           │                                                  │
│  ┌────────▼────────────────────────────────────────┐         │
│  │  https://diabetics-api.jljimenez.es            │         │
│  │  - POST /api/v1/auth/login                     │         │
│  │  - POST /api/v1/users/register                 │         │
│  │  - POST /api/v1/nutrition/calculate-bolus      │         │
│  │  - GET  /api/v1/nutrition/ingredients          │         │
│  └─────────────────────────────────────────────────┘         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎨 Sistema de Dual UX

### Archivos Relacionados

```
lib/
├── core/theme/
│   └── app_theme.dart              # Definición de temas
├── presentation/bloc/theme/
│   └── theme_bloc.dart             # Gestión de estado del tema
└── presentation/screens/
    └── auth/login_screen.dart      # Implementación Dual UX
```

### Flujo de Cambio de Tema

```
Usuario presiona "Cambiar Modo"
        ↓
ThemeBloc.add(ToggleUiMode())
        ↓
ThemeBloc.emit(ThemeState(uiMode: UiMode.child))
        ↓
SharedPreferences.setString('ui_mode', 'child')
        ↓
MaterialApp reconstruye con childTheme
        ↓
Toda la UI se actualiza automáticamente
```

---

## 🔐 Flujo de Autenticación

### Archivos Relacionados

```
lib/
├── core/network/
│   └── dio_client.dart             # JWT Interceptor
├── data/
│   ├── models/auth_models.dart     # DTOs
│   └── datasources/auth_api_client.dart
├── presentation/bloc/auth/
│   └── auth_bloc.dart              # State Management
└── presentation/screens/auth/
    └── login_screen.dart           # UI
```

### Flujo de Login

```
1. Usuario ingresa email/password
        ↓
2. LoginScreen valida formulario
        ↓
3. AuthBloc.add(LoginRequested(email, password))
        ↓
4. AuthApiClient.login(email, password)
        ↓
5. POST /api/v1/auth/login (form-urlencoded)
        ↓
6. Response: { access_token, token_type }
        ↓
7. FlutterSecureStorage.write('access_token', token)
        ↓
8. AuthBloc.emit(AuthAuthenticated(token))
        ↓
9. Navigate to HomeScreen
```

---

## 📦 Dependencias por Capa

### Core

- `dio` - HTTP Client
- `flutter_secure_storage` - Token storage
- `shared_preferences` - Theme persistence

### Data

- `retrofit` - API Client generator
- `json_annotation` - JSON serialization

### Presentation

- `flutter_bloc` - State Management
- `equatable` - Value equality
- `google_fonts` - Typography
- `lottie` - Animations

### Dev Dependencies

- `build_runner` - Code generation
- `retrofit_generator` - API Client generation
- `json_serializable` - JSON serialization
- `mockito` - Mocking
- `bloc_test` - BLoC testing

---

## 🚀 Próximas Adiciones

### Sprint 2

```
lib/presentation/
├── screens/home/
│   ├── home_screen.dart            # Dashboard principal
│   └── widgets/
│       ├── glucose_chart.dart      # Gráfico de glucosa
│       └── metrics_summary.dart    # Resumen de métricas
└── widgets/dual_ux/
    ├── glucose_card.dart           # Card de glucosa (Dual UX)
    └── metric_widget.dart          # Widget de métrica (Dual UX)
```

### Sprint 3

```
lib/
├── data/
│   ├── models/bolus_models.dart    # DTOs de Bolus
│   └── datasources/nutrition_api_client.dart
├── presentation/
│   ├── bloc/bolus/
│   │   └── bolus_bloc.dart
│   └── screens/bolus/
│       └── bolus_calculator_screen.dart
```

---

## 📚 Documentación Relacionada

- `frontend/README.md` - Documentación del proyecto Flutter
- `docs/FLUTTER_ARCHITECTURE.md` - Arquitectura detallada
- `docs/FLUTTER_SCRIPTS.md` - Scripts de desarrollo
- `docs/PROYECTO_RESUMEN.md` - Resumen ejecutivo
- `docs/swagger.json` - Contrato de API

---

**Última actualización**: 2026-02-02  
**Versión**: 0.1.0  
**Estado**: Sprint 1 Completado ✅
