# Manual Técnico — DiaBeaty

> **Plataforma de Nutrición de Precisión para Diabetes Tipo 1**
> Trabajo Fin de Máster · Ingeniería y Arquitectura de Software con Inteligencia Artificial · 2024–2026
>
> **Autores**: José Luis Jiménez
> **Versión**: 1.0 · Febrero 2026
> **Repositorios**: Backend (`backend/`) · Frontend (`frontend/`)
> **Producción**: API `https://diabetics-api.jljimenez.es` · App `https://diabetics.jljimenez.es`

---

## Índice

1. [Introducción y Objetivos del Sistema](#1-introducción-y-objetivos-del-sistema)
2. [Visión General de la Arquitectura](#2-visión-general-de-la-arquitectura)
3. [Backend: FastAPI + PostgreSQL](#3-backend-fastapi--postgresql)
4. [Frontend: Flutter](#4-frontend-flutter)
5. [Modelo de Dominio y Base de Datos](#5-modelo-de-dominio-y-base-de-datos)
6. [API REST: Contratos y Esquemas](#6-api-rest-contratos-y-esquemas)
7. [Seguridad y Protección de Datos PHI](#7-seguridad-y-protección-de-datos-phi)
8. [Motor Nutricional y Algoritmo de Bolus](#8-motor-nutricional-y-algoritmo-de-bolus)
9. [Sistema de Gamificación: XP y Logros](#9-sistema-de-gamificación-xp-y-logros)
10. [Estrategia de Testing (TDD)](#10-estrategia-de-testing-tdd)
11. [Infraestructura y Despliegue](#11-infraestructura-y-despliegue)
12. [Migraciones de Base de Datos](#12-migraciones-de-base-de-datos)
13. [Guía de Desarrollo Local](#13-guía-de-desarrollo-local)
14. [Decisiones de Arquitectura (ADRs)](#14-decisiones-de-arquitectura-adrs)
15. [Glosario](#15-glosario)

---

## 1. Introducción y Objetivos del Sistema

### 1.1 Problema a Resolver

La **Diabetes Tipo 1 (T1D)** es una enfermedad autoinmune crónica en la que el páncreas no produce insulina. Los pacientes deben administrarse insulina de forma exógena varias veces al día, calculando manualmente la dosis (llamada *bolo de insulina*) en función de los carbohidratos de cada comida y de su glucemia actual.

Este cálculo depende de cuatro variables clínicas personales:

- **ICR** (*Insulin-to-Carb Ratio*): unidades de insulina por gramo de carbohidrato.
- **ISF** (*Insulin Sensitivity Factor*): cuánto baja la glucemia (mg/dL) cada unidad de insulina.
- **Glucemia actual**: medida en el momento previo a la comida.
- **Glucemia objetivo**: el valor de glucemia que el paciente debe mantener.

Una dosificación incorrecta puede causar **hipoglucemia severa** (glucemia < 70 mg/dL), que en casos extremos provoca pérdida de conciencia, convulsiones y riesgo vital. En pacientes pediátricos, la gestión recae en los padres, quienes deben realizar estos cálculos varias veces al día, todos los días del año.

DiaBeaty nació para eliminar la fricción cognitiva de este proceso rutinario, actuando como un *Páncreas Digital Auxiliar*.

### 1.2 Objetivos del Sistema

| Objetivo | Descripción |
| :--- | :--- |
| **Precisión clínica** | Implementar el algoritmo Bolus Wizard estándar con fidelidad matemática a las guías de la ADA/EASD |
| **Seguridad de datos PHI** | Cifrar todos los datos médicos sensibles (ISF, ICR, notas) con Fernet AES-128-CBC antes de persistirlos |
| **Gestión familiar** | Soportar un guardián con múltiples perfiles de pacientes dependientes, cada uno con ratios médicos independientes |
| **Doble UX** | Adaptar la interfaz según el perfil activo: modo técnico para adultos, modo gamificado para niños |
| **Calidad de código** | Mantener cobertura de tests superior al 90% mediante metodología TDD estricta |
| **Operabilidad** | Despliegue continuo automatizado con validación de salud post-deploy en Coolify v4 |

### 1.3 Alcance de la Versión 1.0

El MVP cubre los siguientes módulos funcionales:

1. Autenticación y gestión de sesión (JWT)
2. Gestión de perfiles familiares (guardián + dependientes)
3. Perfiles de salud configurables (ICR, ISF, glucemia objetivo)
4. Monitorización de glucosa (registro manual + historial)
5. Motor nutricional completo (ingredientes, bandeja, cálculo de bolus, registro de comidas)
6. Sistema de gamificación (XP, niveles, logros)
7. Interfaz dual adulto/niño

---

## 2. Visión General de la Arquitectura

### 2.1 Diagrama de Componentes

```
┌──────────────────────────────────────────────────────────────────────┐
│                         CLIENTE FLUTTER                              │
│  ┌────────────┐  ┌────────────────┐  ┌────────────────────────────┐ │
│  │ Presentation│  │  BLoC Layer    │  │      Data Layer            │ │
│  │  Screens   │◄─│  (BLoC/Cubits) │◄─│  Repositories + Models    │ │
│  │  Widgets   │  │  State Mgmt    │  │  Retrofit HTTP Client      │ │
│  └────────────┘  └────────────────┘  └────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                              │ HTTPS/REST
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         BACKEND FASTAPI                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────────┐  │
│  │    Routers     │  │   Use Cases    │  │    Repositories      │  │
│  │  (HTTP Layer)  │─►│ (Domain Logic) │─►│  (Data Access Layer) │  │
│  └────────────────┘  └────────────────┘  └──────────────────────┘  │
│                                                    │                 │
│                              SQLAlchemy ORM        │                 │
└───────────────────────────────────────────────────┼─────────────────┘
                                                     │
                              ┌──────────────────────▼──────────┐
                              │        PostgreSQL 16             │
                              │  (Datos + PHI cifrado con Fernet)│
                              └──────────────────────────────────┘
```

### 2.2 Principios de Diseño

**Clean Architecture** es el principio rector de ambas capas. La regla fundamental es que **las dependencias solo apuntan hacia el centro** (hacia el dominio). Nunca un componente de dominio importa de la infraestructura.

- **Backend**: `Infraestructura HTTP (routers)` → `Casos de Uso (use_cases/)` → `Dominio (models, interfaces)`.
- **Frontend**: `Presentación (screens, blocs)` → `Datos (repositories, datasources)` → `Modelos de dominio`.

**SOLID** se aplica en ambas capas. El Principio de Responsabilidad Única (SRP) es especialmente relevante: cada `BLoC` de Flutter gestiona un único área de estado; cada `UseCase` de FastAPI realiza una única operación de dominio.

**TDD (Test-Driven Development)** es un requisito de proceso: ninguna funcionalidad se implementa sin un test en fase RED previo. El ciclo RED → GREEN → REFACTOR se documenta en los commits de cada rama `feature/`.

---

## 3. Backend: FastAPI + PostgreSQL

### 3.1 Estructura de Directorios

```
backend/
├── src/
│   ├── main.py                        # Punto de entrada ASGI, registro de routers
│   ├── infrastructure/
│   │   ├── api/
│   │   │   ├── routers/               # Controladores HTTP (auth, users, family, glucose, nutrition)
│   │   │   └── dependencies.py        # Inyección de dependencias FastAPI (get_db, get_current_user)
│   │   ├── db/
│   │   │   ├── models.py              # Modelos SQLAlchemy ORM
│   │   │   ├── base.py                # DeclarativeBase + engine
│   │   │   └── session.py             # SessionLocal factory
│   │   ├── security/
│   │   │   ├── auth.py                # JWT encode/decode, bcrypt
│   │   │   └── encryption.py          # EncryptedString (Fernet custom type)
│   │   └── repositories/              # Implementaciones concretas de acceso a datos
│   ├── domain/
│   │   ├── models/                    # Pydantic schemas de entrada/salida (request/response)
│   │   └── interfaces/                # Interfaces abstractas de repositorios
│   └── application/
│       └── use_cases/                 # Lógica de dominio pura (BolusCalculator, NutritionCalculator)
├── alembic/
│   ├── env.py
│   └── versions/                      # 13 archivos de migración numerados
├── tests/
│   ├── conftest.py                    # Fixtures: client, db_session (SQLite in-memory)
│   ├── api/                           # Tests de integración HTTP (usa TestClient)
│   └── unit/                          # Tests unitarios de modelos y lógica de dominio
├── requirements.txt
└── entrypoint.sh                      # Script de arranque: alembic upgrade head + uvicorn
```

### 3.2 Módulos Principales

#### `src/main.py`

Instancia la aplicación FastAPI con los siguientes middlewares:
- `CORSMiddleware`: permite peticiones desde el dominio del frontend.
- Registro de todos los routers bajo el prefijo `/api/v1`.

```python
app = FastAPI(title="DiaBeaty API", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], ...)
app.include_router(auth_router, prefix="/api/v1/auth")
app.include_router(users_router, prefix="/api/v1/users")
# ... resto de routers
```

#### `src/infrastructure/db/models.py`

Define todos los modelos ORM. Cada modelo hereda de `Base` (SQLAlchemy `DeclarativeBase`). Los campos que contienen PHI (Protected Health Information) usan el tipo personalizado `EncryptedString` que aplica cifrado/descifrado transparente en lectura/escritura.

| Modelo ORM | Tabla | Descripción |
| :--- | :--- | :--- |
| `UserModel` | `users` | Cuenta de usuario (email, bcrypt hash, nombre) |
| `PatientModel` | `patients` | Perfil de paciente (nombre, rol, PIN hash) |
| `HealthProfileModel` | `health_profiles` | Parámetros clínicos cifrados (ISF, ICR, glucemia objetivo) |
| `GlucoseReadingModel` | `glucose_readings` | Registro de mediciones de glucosa |
| `IngredientModel` | `ingredients` | Alimentos con IG, carbohidratos, fibra |
| `MealLogModel` | `meal_logs` | Registro de comidas (timestamp, CHO total, CG total, bolus administrado) |
| `MealLogIngredientModel` | `meal_log_ingredients` | Ingredientes y gramaje de cada comida registrada |
| `XPTransactionModel` | `xp_transactions` | Historial de transacciones de puntos de experiencia |
| `AchievementModel` | `achievements` | Logros desbloqueados por paciente |

#### `src/infrastructure/security/encryption.py`

`EncryptedString` es un tipo personalizado de SQLAlchemy que extiende `TypeDecorator`. Intercepta las operaciones de escritura (`process_bind_param`) y lectura (`process_result_value`) para aplicar cifrado Fernet de forma transparente:

```python
class EncryptedString(TypeDecorator):
    impl = Text
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is None:
            return None
        return fernet.encrypt(value.encode()).decode()

    def process_result_value(self, value, dialect):
        if value is None:
            return None
        return fernet.decrypt(value.encode()).decode()
```

La clave Fernet se carga desde la variable de entorno `FERNET_KEY`. Si no está configurada, se genera una clave aleatoria (solo para desarrollo local).

### 3.3 Inyección de Dependencias

FastAPI utiliza el sistema `Depends()` para inyectar dependencias en los endpoints. Las principales dependencias son:

- **`get_db()`**: Gestiona el ciclo de vida de la sesión SQLAlchemy. Abre sesión, la entrega al endpoint y hace rollback/cierre en caso de excepción.
- **`get_current_user_id()`**: Decodifica el token JWT del header `Authorization: Bearer <token>` y devuelve el `user_id`. Devuelve HTTP 401 si el token es inválido o expirado.
- **`get_current_user()`**: Como la anterior, pero devuelve el objeto `UserModel` completo (hace query a BD).

---

## 4. Frontend: Flutter

### 4.1 Estructura de Directorios

```
frontend/lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # AppConstants, UiMode enum
│   ├── network/
│   │   └── api_client.dart            # Retrofit client (code-generated)
│   └── utils/
├── data/
│   ├── models/                        # DTOs Dart (generados con json_serializable)
│   │   ├── auth_models.dart
│   │   ├── nutrition_models.dart
│   │   └── profile_models.dart
│   ├── datasources/                   # Fuentes de datos remotas (llamadas HTTP directas)
│   └── repositories/                  # Implementaciones de repositorios
│       ├── auth_repository.dart
│       ├── nutrition_repository.dart
│       └── profile_repository.dart
└── presentation/
    ├── bloc/                          # BLoCs y Cubits
    │   ├── auth/auth_bloc.dart
    │   ├── nutrition/nutrition_bloc.dart
    │   ├── profile/profile_bloc.dart
    │   └── theme/theme_bloc.dart
    └── screens/                       # Pantallas organizadas por dominio
        ├── auth/
        ├── dashboard/
        ├── glucose/
        ├── nutrition/
        └── profile/
            ├── profile_screen.dart
            ├── adult_profile_screen.dart
            └── child_profile_screen.dart
```

### 4.2 Gestión de Estado con BLoC

La aplicación utiliza el patrón **BLoC (Business Logic Component)** de `flutter_bloc`. Cada BLoC gestiona un dominio de estado independiente:

| BLoC | Estado Principal | Responsabilidad |
| :--- | :--- | :--- |
| `AuthBloc` | `AuthAuthenticated / AuthUnauthenticated` | Token JWT, `selectedProfile`, PIN de sesión |
| `NutritionBloc` | `NutritionLoaded` | Búsqueda de ingredientes, bandeja, resultado de bolus |
| `ProfileBloc` | `ProfileLoaded` | Datos de perfil, XP, logros |
| `ThemeBloc` | `ThemeState(uiMode)` | Modo adulto/niño, colores del tema |

#### Convención de propagación de BLoC

Cuando una pantalla hija necesita acceder al mismo BLoC que su padre, se utiliza `BlocProvider.value(value: context.read<XBloc>())` en lugar de crear una nueva instancia. Esto evita duplicar peticiones HTTP y garantiza que el estado es compartido.

#### Race condition en ProfileBloc (y su solución)

Un problema crítico identificado durante el desarrollo fue una **race condition** con el transformer `concurrent` de `flutter_bloc`. Los eventos `LoadXPSummary` y `LoadAchievements` se disparaban simultáneamente con `LoadProfile`. Dado que el transformer `concurrent` procesa eventos en paralelo, estos dos eventos ejecutaban su handler cuando el estado aún era `ProfileLoading` (no `ProfileLoaded`), encontrando el guard `if (state is! ProfileLoaded) return` y abandonando la ejecución sin llamar a la API.

**Solución implementada**: Los handlers de XP y logros se eliminaron como eventos independientes. La carga de XP y logros se integró dentro del propio handler de `_onLoadProfile` usando `Future.wait` para garantizar el orden de ejecución:

```dart
Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
  emit(ProfileLoading());
  try {
    // 1. Cargar perfil base
    final user = await repository.getProfile(event.token);
    emit(ProfileLoaded(user: user));  // UI ya tiene datos básicos

    // 2. Cargar XP y logros en paralelo (no bloquean entre sí)
    final results = await Future.wait([
      repository.getXPSummary(event.token)
          .then<UserXPSummary?>((v) => v).catchError((_) => null),
      repository.getAchievements(event.token)
          .then<AchievementsResponse?>((v) => v).catchError((_) => null),
    ]);

    // 3. Emitir estado completo
    emit(ProfileLoaded(
      user: user,
      xpSummary: results[0] as UserXPSummary?,
      achievements: results[1] as AchievementsResponse?,
    ));
  } catch (e) {
    emit(ProfileError(e.toString()));
  }
}
```

Este diseño también mejora la latencia: las dos peticiones HTTP (XP y logros) se ejecutan en paralelo, no secuencialmente.

### 4.3 Generación de Código

Los modelos de datos y el cliente HTTP utilizan generación de código con `build_runner`:

- **`json_serializable`**: Genera métodos `fromJson/toJson` para todos los DTOs. Los archivos generados tienen el sufijo `.g.dart`.
- **`retrofit_generator`**: Genera la implementación del cliente HTTP a partir de las anotaciones `@GET`, `@POST`, etc. en el archivo `api_client.dart`.

Comando para regenerar:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4.4 Sistema de Temas: Modo Adulto / Modo Niño

`ThemeBloc` controla el `UiMode` actual (enum `UiMode.adult` / `UiMode.child`). Cuando el usuario selecciona un perfil de tipo `DEPENDENT` (menor de edad), el `ThemeBloc` emite un nuevo estado con `UiMode.child`, lo que desencadena el renderizado de las variantes de interfaz pediátrica en todas las pantallas que usan `BlocBuilder<ThemeBloc, ThemeState>`.

Las pantallas que tienen variantes dual son:
- `DashboardScreen`: adulto (indicadores técnicos) / niño (panel RPG con XP y misiones)
- `ProfileScreen`: adulto (datos clínicos + cambio de contraseña) / niño ("Héroe de la Salud" con medallas)
- `LogMealScreen`: adulto (resultado técnico con unidades decimales) / niño ("¡Tu poción está lista!")

---

## 5. Modelo de Dominio y Base de Datos

### 5.1 Diagrama Entidad-Relación

```
USERS (1) ──────────── (N) PATIENTS
  │                          │
  │                          ├── (1) HEALTH_PROFILES
  │                          │         (ICR_enc, ISF_enc, target_bg)
  │                          │
  │                          ├── (N) GLUCOSE_READINGS
  │                          │         (value, timestamp)
  │                          │
  │                          ├── (N) MEAL_LOGS
  │                          │         (total_carbs, total_gl, bolus_administered)
  │                          │              │
  │                          │              └── (N) MEAL_LOG_INGREDIENTS
  │                          │                        (ingredient_id, weight_g)
  │                          │
  │                          └── (N) ACHIEVEMENTS
  │
USERS (1) ──────────── (N) XP_TRANSACTIONS
                               (amount, reason, description, timestamp)

INGREDIENTS (standalone)
  (name, glycemic_index, carbs_per_100g, fiber_per_100g, category)
```

### 5.2 Relaciones Clave

**`USERS` → `PATIENTS`**: Un usuario guardián puede tener múltiples pacientes dependientes. La relación es `guardian_id` (FK en `patients`). El guardián también tiene su propio registro implícito como paciente principal (el primer paciente creado automáticamente en el registro).

**`PATIENTS` → `HEALTH_PROFILES`**: Relación uno a uno. Cada paciente tiene exactamente un perfil de salud que almacena sus parámetros clínicos cifrados.

**`MEAL_LOGS` → `MEAL_LOG_INGREDIENTS`**: Relación uno a muchos. Un `MealLog` puede tener varios ingredientes. La tabla intermedia almacena el gramaje de cada ingrediente en esa comida específica.

**`USERS` → `XP_TRANSACTIONS`**: Las transacciones de XP se asocian al usuario (no al paciente), porque el usuario es quien interactúa con la app. Cada transacción registra la razón (`reason`) y una descripción legible, formando un historial auditable.

### 5.3 Campos PHI Cifrados

Los siguientes campos utilizan `EncryptedString` y se almacenan cifrados en la base de datos:

| Tabla | Campo | Tipo de dato original |
| :--- | :--- | :--- |
| `health_profiles` | `icr` | Float (ratio insulina/carbohidrato) |
| `health_profiles` | `isf` | Float (factor de sensibilidad) |
| `health_profiles` | `target_glucose` | Float (glucemia objetivo en mg/dL) |
| `meal_logs` | `notes` | String (notas libres del usuario sobre la comida) |

El valor almacenado en PostgreSQL es el resultado de `Fernet.encrypt(valor.encode())`, una cadena Base64 URL-safe prefijada por metadatos Fernet (versión, timestamp, IV, HMAC). El descifrado es transparente en la lectura ORM.

---

## 6. API REST: Contratos y Esquemas

La API expone 15 endpoints bajo el prefijo `/api/v1`. La documentación interactiva Swagger está disponible en `https://diabetics-api.jljimenez.es/docs`.

### 6.1 Resumen de Endpoints

| Método | Ruta | Auth | Descripción |
| :---: | :--- | :---: | :--- |
| `POST` | `/auth/login` | No | Obtiene JWT a partir de credenciales |
| `POST` | `/users/register` | No | Registro de nuevo usuario |
| `GET` | `/users/me` | Sí | Datos del usuario autenticado |
| `PUT` | `/users/profile` | Sí | Actualiza perfil de salud |
| `GET` | `/users/xp-summary` | Sí | Resumen XP y nivel del usuario |
| `GET` | `/users/achievements` | Sí | Lista de logros desbloqueados |
| `GET` | `/profiles` | Sí | Lista perfiles del guardián |
| `POST` | `/profiles` | Sí | Crea perfil de dependiente |
| `PUT` | `/profiles/{id}` | Sí | Actualiza perfil de dependiente |
| `GET` | `/profiles/{id}` | Sí | Detalle completo de un perfil |
| `POST` | `/glucose/add` | Sí | Registra medición de glucosa |
| `GET` | `/glucose/history` | Sí | Historial de mediciones |
| `GET` | `/nutrition/ingredients` | No | Búsqueda de ingredientes |
| `POST` | `/nutrition/ingredients` | Sí | Crea nuevo ingrediente |
| `POST` | `/nutrition/ingredients/seed` | No | Carga seed de 165+ alimentos |
| `POST` | `/nutrition/bolus/calculate` | No | Calcula dosis de insulina |
| `POST` | `/nutrition/meals` | Sí | Registra comida completa |
| `GET` | `/nutrition/meals/history` | No | Historial de comidas |
| `GET` | `/health` | No | Health check del sistema |

### 6.2 Esquema de Autenticación

Todos los endpoints marcados con "Auth: Sí" requieren la cabecera:

```
Authorization: Bearer <jwt_token>
```

El token se obtiene en `POST /auth/login` y tiene una vigencia configurable (por defecto 24 horas). El payload del JWT incluye el `sub` (user_id como UUID string) y el `exp` (timestamp de expiración).

### 6.3 Paginación y Filtros de Historial

Los endpoints de historial (`GET /glucose/history`, `GET /nutrition/meals/history`) aceptan los siguientes query params:

| Parámetro | Tipo | Descripción |
| :--- | :--- | :--- |
| `patient_id` | UUID (string) | **Requerido**. ID del paciente a consultar |
| `limit` | int | Número máximo de resultados (defecto: 20, máx: 100) |
| `offset` | int | Número de resultados a saltar (paginación) |
| `start_date` | ISO 8601 datetime | Filtra registros posteriores a esta fecha |
| `end_date` | ISO 8601 datetime | Filtra registros anteriores a esta fecha |

Los resultados se devuelven ordenados de **más reciente a más antiguo** (ORDER BY timestamp DESC).

---

## 7. Seguridad y Protección de Datos PHI

### 7.1 Capas de Seguridad

DiaBeaty implementa seguridad en profundidad con múltiples capas independientes:

```
┌─────────────────────────────────────────────────┐
│  CAPA 1: Transporte — HTTPS/TLS 1.3             │
│  (Caddy reverse proxy con certificado Let's     │
│   Encrypt gestionado por Coolify)               │
├─────────────────────────────────────────────────┤
│  CAPA 2: Autenticación — JWT HS256              │
│  (Tokens con expiración, verificados en cada    │
│   request por get_current_user_id)              │
├─────────────────────────────────────────────────┤
│  CAPA 3: Contraseñas — Bcrypt (work factor 12) │
│  (passlib[bcrypt], nunca se almacena la         │
│   contraseña en claro)                          │
├─────────────────────────────────────────────────┤
│  CAPA 4: PHI — Fernet AES-128-CBC + HMAC-SHA256│
│  (Cifrado simétrico con autenticación de        │
│   mensaje, aplicado transparentemente por ORM)  │
└─────────────────────────────────────────────────┘
```

### 7.2 Fernet AES-128-CBC

**Fernet** es una especificación de cifrado simétrico autenticado que garantiza:
- **Confidencialidad**: AES-128 en modo CBC con IV aleatorio por mensaje.
- **Integridad y autenticidad**: HMAC-SHA256 sobre el ciphertext (cifrado autenticado).
- **No reutilización de IV**: Cada cifrado genera un IV aleatorio de 16 bytes.

El formato de un token Fernet cifrado es (en Base64 URL-safe):
```
Version (1 byte) | Timestamp (8 bytes) | IV (16 bytes) | Ciphertext | HMAC (32 bytes)
```

La clave Fernet es una clave de 32 bytes (256 bits) codificada en Base64, almacenada en la variable de entorno `FERNET_KEY`. Esta variable se inyecta en el contenedor Docker por Coolify y nunca se incluye en el repositorio.

### 7.3 Consideraciones OWASP Top 10

| Riesgo OWASP | Mitigación en DiaBeaty |
| :--- | :--- |
| A01: Broken Access Control | Todos los endpoints sensibles verifican JWT. Los datos de un paciente solo son accesibles al guardián propietario. |
| A02: Cryptographic Failures | Fernet para PHI, bcrypt para contraseñas, TLS 1.3 en tránsito. |
| A03: Injection | SQLAlchemy ORM previene SQL injection mediante parámetros enlazados. Ninguna query SQL se construye por concatenación de strings. |
| A05: Security Misconfiguration | Variables de entorno para secretos, sin valores hardcodeados en el código. |
| A07: Identification Failures | JWT con expiración, bcrypt para contraseñas, PIN de protección para perfiles de menores. |

---

## 8. Motor Nutricional y Algoritmo de Bolus

### 8.1 Algoritmo Bolus Wizard

El algoritmo implementa el **Bolus Wizard** estándar, que calcula la dosis de insulina necesaria para una comida como la suma de:

1. **Bolo de comida**: unidades necesarias para cubrir los carbohidratos de la comida.
2. **Bolo de corrección**: unidades necesarias para corregir la glucemia actual si está por encima del objetivo.

La fórmula completa es:

```
Bolus (U) = max(0, (Carbohidratos_netos / ICR) + ((Glucemia_actual - Glucemia_objetivo) / ISF))
```

Donde:
- `Carbohidratos_netos` = total de carbohidratos en gramos de todos los ingredientes de la comida.
- `ICR` = Insulin-to-Carb Ratio del paciente (unidades de insulina por gramo de CHO).
- `ISF` = Insulin Sensitivity Factor del paciente (mg/dL de descenso por unidad de insulina).
- `Glucemia_actual` = medición de glucosa del paciente en el momento de la comida.
- `Glucemia_objetivo` = target glucémico personal del paciente.
- `max(0, ...)` = garantiza que el bolo nunca sea negativo (si la glucemia está por debajo del objetivo, no se reduce el bolo de comida).

**Ejemplo clínico**: Paciente con ICR=10 e ISF=50. Comida con 60g CHO. Glucemia actual: 180 mg/dL. Glucemia objetivo: 100 mg/dL.
```
Bolo = (60/10) + ((180-100)/50) = 6 + 1.6 = 7.6 unidades
```

### 8.2 Cálculo de Carga Glucémica

La **Carga Glucémica (CG)** es una métrica más precisa que el Índice Glucémico (IG), porque tiene en cuenta tanto la calidad (IG) como la cantidad de carbohidratos ingeridos:

```
CG = (IG × Carbohidratos_netos) / 100
```

Una CG < 10 se considera baja, entre 10 y 19 media, y ≥ 20 alta.

Para una comida completa con múltiples ingredientes, la CG total es la suma de las CGs individuales de cada ingrediente.

### 8.3 Codificación de Color del Bolus

El resultado del bolus se presenta con una codificación de color para facilitar la interpretación clínica rápida:

| Dosis calculada | Color | Significado clínico |
| :---: | :---: | :--- |
| ≤ 2 unidades | Verde | Dosis baja, comida ligera |
| 2 – 5 unidades | Naranja | Dosis moderada, atención recomendada |
| > 5 unidades | Rojo | Dosis alta, verificar antes de administrar |

### 8.4 Base de Datos de Ingredientes

El sistema incluye una base de datos de **165+ alimentos** curados con:
- Nombre del alimento
- Índice Glucémico (validado contra tablas de Foster-Powell, BEDCA y USDA FoodData Central)
- Carbohidratos por 100g
- Fibra por 100g (para cálculo de carbohidratos netos)
- Categoría (cereales, frutas, lácteos, proteínas, verduras, legumbres, bebidas, snacks)

El seed se carga mediante `POST /api/v1/nutrition/ingredients/seed`, que es idempotente: no duplica alimentos si se ejecuta múltiples veces.

---

## 9. Sistema de Gamificación: XP y Logros

### 9.1 Arquitectura del Sistema de XP

El sistema de XP está implementado en el backend como un módulo independiente:

- **`XPTransactionModel`**: Tabla `xp_transactions` que registra cada transacción de XP con timestamp, amount, reason y descripción.
- **`XPRepository`**: Repositorio que expone `add_xp()` (escritura) y `get_xp_summary()` (lectura con cálculo de nivel).
- **Integración no bloqueante**: Los módulos que otorgan XP (nutrition, glucose) lo hacen en bloques try/except que registran errores pero no propagan excepciones. Un fallo en XP nunca bloquea el flujo clínico.

### 9.2 Tabla de Niveles

Los umbrales de XP siguen una progresión diseñada para que el primer nivel se alcance en las primeras dos semanas de uso con adherencia moderada:

| Nivel | Título | XP Acumulado |
| :---: | :--- | :---: |
| 1 | Explorador | 0 |
| 2 | Explorador II | 50 |
| 3 | Aventurero | 100 |
| 4 | Aventurero II | 175 |
| 5 | Guerrero | 250 |
| 6 | Guerrero II | 375 |
| 7 | Héroe | 500 |
| 8 | Héroe II | 750 |
| 9 | Campeón | 1.000 |
| 10 | Campeón II | 1.500 |
| 11+ | Leyenda | 2.000+ |

La fórmula de cálculo de nivel a partir del XP total es:

```
nivel = floor(sqrt(xp_total / 25)) + 1
```

Esta fórmula produce una curva de progresión creciente donde cada nivel sucesivo requiere más XP que el anterior.

### 9.3 Acciones Recompensadas con XP

| Acción | XP | Razón almacenada |
| :--- | :---: | :--- |
| Registrar una comida | +10 | `meal_logged` |
| Registrar glucosa | +5 | `glucose_logged` |
| Completar misiones del día | +25 | `daily_quest_completed` |

### 9.4 Sistema de Logros (Achievements)

Los logros se almacenan como registros individuales en la tabla `achievements`. Cada logro tiene:
- `achievement_type`: identificador único del logro.
- `unlocked_at`: timestamp de desbloqueo.
- `patient_id`: paciente que lo desbloqueó.

Los logros se evalúan en el backend tras cada acción relevante. El frontend los muestra en la pantalla de perfil del niño con una galería 3x3 de medallas desbloqueadas y una cuadrícula 4x4 de medallas bloqueadas en escala de grises.

---

## 10. Estrategia de Testing (TDD)

### 10.1 Filosofía TDD

El proyecto sigue **Test-Driven Development** estricto. El flujo es invariable:

1. **RED**: Escribir un test que falle (la funcionalidad no existe aún).
2. **GREEN**: Implementar el código mínimo para que el test pase.
3. **REFACTOR**: Mejorar el código sin romper los tests.

Ningún código de producción se escribe sin un test previo. Los commits de las ramas `feature/` incluyen primero el commit del test en RED, luego el commit de la implementación en GREEN.

### 10.2 Infraestructura de Tests Backend

Los tests de backend utilizan:
- **pytest**: Framework de testing principal.
- **SQLite in-memory con StaticPool**: Cada test recibe una base de datos SQLite en memoria, creada con el schema completo de Alembic y destruida al finalizar el test. Esto garantiza aislamiento total entre tests.
- **TestClient de FastAPI**: Cliente HTTP síncrono que permite hacer peticiones HTTP reales contra la aplicación sin levantar un servidor real.
- **Fixtures en `conftest.py`**: `client` (TestClient), `db_session` (SQLite in-memory con rollback).

```python
# conftest.py — fixture db_session
@pytest.fixture
def db_session():
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()
    yield session
    session.rollback()
    session.close()
```

### 10.3 Cobertura de Tests

| Módulo | Tests | Tipo |
| :--- | :---: | :--- |
| Autenticación (JWT, login, registro) | 18 | Integración |
| Gestión de usuarios y perfil de salud | 14 | Integración |
| Gestión familiar (perfiles dependientes) | 16 | Integración |
| Monitorización de glucosa | 12 | Integración |
| Motor nutricional (ingredientes, bolus) | 22 | Integración + Unitario |
| Registro de comidas e historial | 16 | Integración |
| Sistema de XP (transacciones, niveles) | 12 | Integración + Unitario |
| **Total Backend** | **110** | |

| Módulo Flutter | Tests |
| :--- | :---: |
| BLoC: AuthBloc | 8 |
| BLoC: NutritionBloc | 10 |
| BLoC: ProfileBloc | 8 |
| Widgets: Pantallas principales | 10 |
| **Total Flutter** | **36** |

### 10.4 Comandos de Testing

```bash
# Backend (desde backend/)
pytest tests/ -v                          # Todos los tests con salida detallada
pytest tests/api/ -v                      # Solo tests de integración API
pytest tests/unit/ -v                     # Solo tests unitarios
pytest tests/ -v -k "bolus"               # Tests que contengan "bolus" en el nombre

# Flutter (desde frontend/)
flutter test                              # Todos los tests
flutter test test/bloc/                   # Solo tests de BLoC
flutter test --coverage                   # Con cobertura (genera lcov.info)
```

---

## 11. Infraestructura y Despliegue

### 11.1 Stack de Infraestructura

```
Internet
    │
    ▼
Caddy (reverse proxy + TLS)   ← Coolify gestiona certificados Let's Encrypt
    │
    ├── → diabetics.jljimenez.es   → Contenedor Flutter Web (Nginx)
    │
    └── → diabetics-api.jljimenez.es → Contenedor FastAPI (Uvicorn)
                                              │
                                              ▼
                                     PostgreSQL 16 (contenedor)
                                     (volumen persistente)
```

### 11.2 Coolify v4

**Coolify** es una plataforma PaaS self-hosted que gestiona el ciclo de vida completo de los contenedores. La configuración incluye:

- **Despliegue continuo**: Coolify escucha el webhook de GitHub. Cada push a `main` desencadena automáticamente un nuevo build y despliegue.
- **Variables de entorno**: `DATABASE_URL`, `JWT_SECRET_KEY`, `FERNET_KEY` se configuran en el panel de Coolify y se inyectan en el contenedor en tiempo de ejecución. Nunca están en el repositorio.
- **Health check**: Coolify verifica el endpoint `GET /health` cada 30 segundos para determinar si el contenedor está operativo.

### 11.3 Proceso de Despliegue

El despliegue del backend sigue este flujo al arrancar el contenedor:

```bash
# entrypoint.sh
#!/bin/bash
set -e

echo "Ejecutando migraciones de Alembic..."
alembic upgrade head

echo "Iniciando servidor Uvicorn..."
uvicorn src.main:app --host 0.0.0.0 --port 8000 --workers 2
```

El comando `alembic upgrade head` aplica automáticamente todas las migraciones pendientes antes de arrancar el servidor, garantizando que el schema de la BD siempre esté sincronizado con el código.

### 11.4 Dockerfile Backend

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chmod +x entrypoint.sh

EXPOSE 8000
CMD ["./entrypoint.sh"]
```

### 11.5 Dockerfile Frontend (Flutter Web)

```dockerfile
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS builder
WORKDIR /app
COPY pubspec.* .
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

El frontend se construye en un contenedor de build y el artefacto resultante (directorio `build/web/`) se copia a una imagen Nginx mínima para servir los ficheros estáticos.

---

## 12. Migraciones de Base de Datos

### 12.1 Estrategia con Alembic

Alembic gestiona el versionado incremental del schema de PostgreSQL. Cada migración es un archivo Python con dos funciones: `upgrade()` (aplica el cambio) y `downgrade()` (lo revierte).

Las migraciones se aplican automáticamente en el arranque del contenedor. En desarrollo local, se aplican manualmente con `alembic upgrade head`.

### 12.2 Historial de Migraciones

| # | Descripción | Cambio Principal |
| :---: | :--- | :--- |
| 001 | Tablas base: users, patients | Estructura inicial del sistema de usuarios |
| 002 | Tabla health_profiles | Perfiles de salud con campos PHI cifrados |
| 003 | Tabla glucose_readings | Registro de mediciones de glucosa |
| 004 | Tabla ingredients | Catálogo de alimentos con IG y macronutrientes |
| 005 | Tabla meal_logs | Registro de comidas |
| 006 | Tabla meal_log_ingredients | Desglose de ingredientes por comida |
| 007 | Campo category en ingredients | Categorización de alimentos |
| 008 | Campo role en patients | Roles SELF/DEPENDENT para perfiles familiares |
| 009 | Tabla xp_transactions | Sistema de puntos de experiencia |
| 010 | Tabla achievements | Logros desbloqueables |
| 011 | Campo bolus_units_administered | Campo opcional en meal_logs para registrar la dosis administrada |
| 012 | Índices de rendimiento | Índices en patient_id y timestamp de meal_logs y glucose_readings |
| 013 | Campo pin_hash en patients | PIN de acceso para perfiles de menores |

### 12.3 Crear una Nueva Migración

```bash
# 1. Modificar el modelo en src/infrastructure/db/models.py
# 2. Generar la migración automáticamente
alembic revision --autogenerate -m "descripcion_breve"

# 3. Revisar el archivo generado en alembic/versions/ y eliminar ruido
#    (Alembic a veces genera cambios espurios para columnas cifradas)

# 4. Aplicar la migración
alembic upgrade head
```

---

## 13. Guía de Desarrollo Local

### 13.1 Requisitos Previos

- Python 3.12+
- Flutter SDK 3.19+
- PostgreSQL 16 (o Docker para ejecutarlo en contenedor)
- `git`, `pip`, `dart`

### 13.2 Configuración del Backend

```bash
# 1. Clonar repositorio y entrar al backend
git clone <url-repositorio>
cd backend

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar variables de entorno (.env)
cp .env.example .env
# Editar .env con los valores locales:
# DATABASE_URL=postgresql://user:pass@localhost:5432/diabeaty
# JWT_SECRET_KEY=dev-secret-key-cambiar-en-produccion
# FERNET_KEY=<generar con: python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())">

# 4. Aplicar migraciones
alembic upgrade head

# 5. Cargar seed de ingredientes (opcional)
curl -X POST http://localhost:8000/api/v1/nutrition/ingredients/seed

# 6. Ejecutar servidor de desarrollo
uvicorn src.main:app --reload

# 7. Ejecutar tests
pytest tests/ -v
```

### 13.3 Configuración del Frontend

```bash
# 1. Entrar al directorio frontend
cd frontend

# 2. Instalar dependencias Dart
flutter pub get

# 3. Regenerar código generado (si es necesario)
dart run build_runner build --delete-conflicting-outputs

# 4. Ejecutar en emulador/dispositivo
flutter run

# 5. Ejecutar tests
flutter test

# 6. Build web (para despliegue)
flutter build web --release
```

### 13.4 Variables de Entorno

| Variable | Descripción | Obligatorio |
| :--- | :--- | :---: |
| `DATABASE_URL` | URL de conexión PostgreSQL | Sí |
| `JWT_SECRET_KEY` | Clave secreta para firmar tokens JWT | Sí |
| `FERNET_KEY` | Clave de cifrado simétrico para PHI | Sí |
| `ALGORITHM` | Algoritmo JWT (defecto: HS256) | No |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Expiración del token (defecto: 1440) | No |

---

## 14. Decisiones de Arquitectura (ADRs)

El proyecto mantiene un registro de todas las decisiones de arquitectura significativas en `docs/adr/`. Cada ADR sigue la plantilla estándar: Contexto → Decisión → Consecuencias → Alternativas Consideradas.

| ADR | Título | Estado |
| :--- | :--- | :--- |
| ADR-001 | Selección del stack tecnológico (FastAPI + Flutter + PostgreSQL) | Aceptado |
| ADR-002 | Clean Architecture en backend y frontend | Aceptado |
| ADR-003 | Flutter como framework frontend multiplataforma | Aceptado |
| ADR-004 | Estrategia de testing con TDD y pytest | Aceptado |
| ADR-005 | Cifrado de datos PHI con Fernet AES | Aceptado |
| ADR-006 | Migraciones de BD con Alembic | Aceptado |
| ADR-007 | Infraestructura con Coolify v4 y Docker | Aceptado |
| ADR-008 | Capa de servicios/casos de uso | Aceptado |
| ADR-009 | Arquitectura de sistema familiar (guardián + dependientes) | Aceptado |
| ADR-010 | Perfiles de salud flexibles con condición médica | Aceptado |
| ADR-011 | Perfiles médicos condicionales según tipo de diabetes | Aceptado |
| ADR-012 | Motor nutricional y protección PHI de notas de comidas | Aceptado |
| ADR-013 | Hub nutricional y bandeja multi-ingrediente | Aceptado |
| ADR-014 | Modo niño gamificado — Interfaz RPG "Héroe de la Salud" | Aceptado |
| ADR-015 | Integración del sistema de XP en el registro de comidas | Aceptado |

---

## 15. Glosario

| Término | Definición |
| :--- | :--- |
| **T1D** | Diabetes Tipo 1. Enfermedad autoinmune donde el páncreas no produce insulina. |
| **Bolo de insulina** | Dosis de insulina de acción rápida que se administra antes de una comida para cubrir los carbohidratos y corregir la glucemia. |
| **ICR** | *Insulin-to-Carb Ratio*. Cuántos gramos de carbohidrato cubre una unidad de insulina. Típicamente entre 8 y 20 g/U según el paciente. |
| **ISF** | *Insulin Sensitivity Factor*. Cuántos mg/dL reduce la glucemia una unidad de insulina. Típicamente entre 30 y 100 mg/dL/U. |
| **IG** | Índice Glucémico. Escala 0-100 que mide la velocidad a la que un alimento eleva la glucemia respecto a la glucosa pura. |
| **CG** | Carga Glucémica. Métrica que combina IG y cantidad de carbohidratos. CG = (IG × CHO) / 100. |
| **PHI** | *Protected Health Information*. Información de salud protegida. En DiaBeaty: ISF, ICR, glucemia objetivo, notas de comidas. |
| **JWT** | *JSON Web Token*. Estándar para tokens de autenticación firmados digitalmente. |
| **Fernet** | Esquema de cifrado simétrico autenticado (AES-128-CBC + HMAC-SHA256) de la librería `cryptography` de Python. |
| **BLoC** | *Business Logic Component*. Patrón de gestión de estado en Flutter que separa la lógica de negocio de la UI mediante streams de eventos y estados. |
| **Bolus Wizard** | Algoritmo estándar de cálculo de dosis de insulina pre-prandial, implementado en bombas de insulina y apps de gestión de diabetes. |
| **Alembic** | Herramienta de migraciones de base de datos para SQLAlchemy. Gestiona el versionado incremental del schema. |
| **Coolify** | Plataforma PaaS self-hosted que gestiona contenedores Docker, despliegue continuo y certificados TLS. |
| **TDD** | *Test-Driven Development*. Metodología de desarrollo donde los tests se escriben antes del código de producción (RED → GREEN → REFACTOR). |
| **Guardián** | Usuario adulto que gestiona uno o más perfiles de pacientes dependientes (generalmente padres de niños con T1D). |
| **Dependiente** | Perfil de paciente gestionado por un guardián (PatientModel con `role="DEPENDENT"`). |
| **XP** | Puntos de Experiencia del sistema de gamificación. Se acumulan al realizar acciones de autocuidado (registrar comidas, medir glucosa). |
| **Seed** | Carga inicial de datos de referencia. En DiaBeaty: endpoint idempotente que carga 165+ ingredientes en la base de datos. |
