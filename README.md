# DiaBeaty — Plataforma de Nutrición de Precisión para Diabetes

> Trabajo Fin de Máster · Ingeniería y Arquitectura de Software con Inteligencia Artificial · 2024–2026

![Status](https://img.shields.io/badge/Estado-Producción_100%25-success?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.110-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.19-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Coolify_v4-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Backend Tests](https://img.shields.io/badge/Backend_Tests-110_✅-brightgreen?style=for-the-badge&logo=pytest)
![Flutter Tests](https://img.shields.io/badge/Flutter_Tests-36_✅-brightgreen?style=for-the-badge&logo=flutter)
![Security](https://img.shields.io/badge/Seguridad-Fernet_AES·JWT_HS256·Bcrypt-red?style=for-the-badge&logo=letsencrypt)
![License](https://img.shields.io/badge/Licencia-MIT-yellow?style=for-the-badge)

---

## Descripcion ejecutiva

### El problema

La gestión de la **Diabetes Tipo 1 (T1D)** impone una carga cognitiva extraordinaria sobre pacientes y cuidadores. Cada comida exige un cálculo preciso de la dosis de insulina a inyectar (el llamado *bolo*), que depende de múltiples variables: los carbohidratos del plato, la glucemia actual del paciente, su objetivo glucémico personal, su ratio de insulina por carbohidrato (ICR) y su factor de sensibilidad a la insulina (ISF). Un error en cualquiera de estas variables puede provocar una hipoglucemia severa, que puede resultar en pérdida de conciencia o incluso en riesgo vital.

Adicionalmente, cuando el paciente es un niño, la gestión recae casi por completo en los padres o tutores, quienes deben supervisar, calcular y administrar los tratamientos varias veces al día, todos los días del año, sin un soporte digital integrado que adapte la información a cada usuario.

### La solución

**DiaBeaty** actúa como un *Páncreas Digital Auxiliar*. No sustituye al criterio médico, sino que elimina la fricción cognitiva del cálculo rutinario:

1. **Motor de calculo de bolo**: Ingresa los alimentos de la comida, la glucemia actual y la plataforma calcula la dosis de insulina recomendada usando el algoritmo Bolus Wizard estándar. El resultado se muestra con codificación de color (verde/naranja/rojo) para facilitar la interpretación.

2. **Base de datos nutricional**: Mas de 165 alimentos curados con Indice Glucémico (IG) y macronutrientes validados contra tablas internacionales (Foster-Powell, BEDCA, USDA FoodData Central). Búsqueda en tiempo real por nombre.

3. **Dual UX (Modo Adulto / Modo Nino)**: El mismo sistema adapta su interfaz según el perfil activo. El modo adulto es técnico y orientado a métricas; el modo niño convierte el control glucémico en una aventura con puntos de experiencia, niveles y logros desbloqueables.

4. **Gestion familiar**: Un guardian puede crear y gestionar múltiples perfiles de pacientes dependientes, cada uno con sus propios ratios médicos y historial, protegidos por PIN.

5. **Seguridad PHI por diseño**: Los datos médicos sensibles (ISF, ICR, dosis de insulina basal) se cifran con Fernet AES-128-CBC+HMAC antes de persistirse en base de datos. Ni el administrador de la BD puede leer estos valores sin la clave de aplicación.

**Usuarios objetivo**: Pacientes con Diabetes Tipo 1 (especialmente niños y adolescentes), padres/tutores de pacientes diabéticos, educadores en diabetes y profesionales clínicos que deseen monitorizar la adherencia terapéutica de sus pacientes.

---

## Caracteristicas principales

### Motor nutricional y de calculo metabolico
- Busqueda full-text de ingredientes por nombre (`?q=arroz`)
- Bandeja multi-ingrediente: seleccionar varios alimentos y sus gramos de forma simultanea
- Calculo de bolus de insulina usando el algoritmo Bolus Wizard (ICR + ISF)
- Calculo de Carga Glucémica (CG = IG × carbos_netos / 100)
- Historial de comidas con filtros por fecha y paginacion
- Base de datos de 165 alimentos con IG validado, endpoint de seed idempotente

### Seguridad y privacidad
- Autenticacion JWT HS256 con tokens Bearer
- Contrasenas hasheadas con Bcrypt (cost-factor 12)
- Datos PHI cifrados con Fernet AES-128-CBC + HMAC-SHA256 (application-level encryption)
- PIN de control parental para acceso a perfiles de pacientes dependientes
- Codigo de vinculacion de dispositivo (device-link) para acceso desde tablet del paciente
- HTTPS estricto en produccion (Cloudflare + Coolify)

### Gestion de usuarios y familia
- Registro de cuenta con perfil de salud integrado (datos médicos incluidos desde el primer momento)
- Perfiles flexibles: GUARDIAN (sin datos médicos) y DEPENDENT (con ISF/ICR/target cifrados)
- Soporte para Diabetes Tipo 1, Tipo 2 y diferentes regimenes terapéuticos (insulina, medicacion oral, mixto)
- Insulina basal configurable (tipo, dosis, hora de administracion)
- Cambio de contrasena con verificacion de la antigua
- Desvinculacion y reasignacion de perfiles

### Monitorizacion de glucosa
- Registro de mediciones de glucosa (mg/dL)
- Historial de glucosa con filtros de fecha
- Tres tipos de medicion: dedo (FINGER), sensor CGM, manual
- Notas clínicas cifradas asociadas a cada medicion

### Gamificacion XP (modo nino)
- Sistema de puntos de experiencia (XP) por acciones terapéuticas
- Niveles progresivos cada 500 XP: Explorador, Aventurero, Guerrero, Héroe, Campeon, Leyenda
- Logros desbloqueables por categoria: constancia, salud, aprendizaje, hitos
- Historial de transacciones XP y resumen de progreso
- Integrado en el flujo de registro de comidas (10 XP por comida registrada)

### Infraestructura y devops
- Despliegue continuo via webhook a Coolify v4
- Docker multi-stage para backend y frontend
- Migraciones de BD automaticas con Alembic (13 migraciones versionadas)
- Documentacion OpenAPI/Swagger autogenerada disponible en produccion
- Zero-downtime deploy

---

## Stack tecnologico

| Capa | Tecnologia | Version | Motivo de eleccion |
|:-----|:-----------|:--------|:-------------------|
| **Lenguaje backend** | Python | 3.12 | Ecosistema IA, tipado mejorado, rendimiento asincrono |
| **Framework API** | FastAPI | >= 0.110 | OpenAPI autogenerado, Pydantic v2, ASGI nativo |
| **Validacion** | Pydantic | v2 | Validacion declarativa, serializacion eficiente |
| **ORM** | SQLAlchemy | 2.0 | Session 2.0 style, typed queries |
| **Base de datos** | PostgreSQL | 16 | ACID, JSONB, extensible, produccion probada |
| **Migraciones** | Alembic | >= 1.13 | Control de versiones de esquema |
| **Autenticacion** | PyJWT + python-jose | >= 2.8 | JWT HS256 estandar |
| **Hashing** | passlib[bcrypt] | >= 1.7 | Bcrypt industry standard |
| **Cifrado PHI** | cryptography (Fernet) | incluido | AES-128-CBC + HMAC-SHA256 |
| **Servidor** | Uvicorn | >= 0.29 | ASGI, produccion-ready |
| **Framework movil** | Flutter | 3.19 | Multiplataforma (Web/iOS/Android), Dart tipado |
| **Estado (frontend)** | flutter_bloc | ^8.1.3 | BLoC pattern, separacion evento/estado |
| **Inyeccion de dependencias** | get_it + injectable | ^7.6 / ^2.3 | Service locator, code-gen |
| **Cliente HTTP** | Dio + Retrofit | ^5.7 / ^4.4 | Interceptores JWT, code-gen de clientes |
| **Serializacion** | json_serializable | ^6.6 | Code-gen desde anotaciones |
| **Graficas** | fl_chart | ^0.68 | Graficas de glucosa interactivas |
| **Almacenamiento seguro** | flutter_secure_storage | ^9.2 | JWT en keychain/keystore |
| **CI/CD** | Coolify v4 | — | Plataforma self-hosted tipo PaaS |
| **Contenedores** | Docker | Multi-stage | Imagen minima, build reproducible |
| **Proxy** | Nginx Alpine | — | Sirve Flutter Web, compresion gzip |
| **HTTPS** | Cloudflare | — | SSL Full-Strict, CDN |

Referencias a decisiones de diseno: [ADR-001](docs/adr/001_tech_stack.md) | [ADR-003](docs/adr/003_flutter_frontend.md) | [ADR-005](docs/adr/005_data_encryption.md)

---

## Arquitectura del sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLIENTE (Flutter Web)                        │
│  https://diabetics.jljimenez.es  (Nginx Alpine)                 │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  AuthBloc    │  │ NutritionBloc│  │   ThemeBloc          │  │
│  │  ProfileBloc │  │ GlucoseBloc  │  │  (Adulto / Nino)     │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────────────────┘  │
│         │  Retrofit + Dio │                                     │
│         │  JWT Interceptor│                                     │
└─────────┼─────────────────┼───────────────────────────────────┘
          │ HTTPS           │
          ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    API REST (FastAPI)                           │
│  https://diabetics-api.jljimenez.es                             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  INFRASTRUCTURE                                          │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐  │   │
│  │  │  auth.py │ │ users.py │ │family.py │ │nutrition.py│  │   │
│  │  │ glucose.py│ │health.py│ │          │ │            │  │   │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └─────┬──────┘  │   │
│  │       │            │            │              │         │   │
│  │  ┌────▼────────────▼────────────▼──────────────▼──────┐  │   │
│  │  │  APPLICATION (Use Cases)                           │  │   │
│  │  │  calculate_bolus · log_meal · search_ingredients   │  │   │
│  │  └────────────────────┬───────────────────────────────┘  │   │
│  │                       │                                  │   │
│  │  ┌────────────────────▼───────────────────────────────┐  │   │
│  │  │  DOMAIN (Reglas de negocio puras)                  │  │   │
│  │  │  nutrition.py · xp_models.py · user_models.py      │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────▼──────────────────────────────────┐   │
│  │  INFRASTRUCTURE / DB                                     │   │
│  │  EncryptedString (Fernet) · SQLAlchemy 2.0 · Alembic     │   │
│  └───────────────────────┬──────────────────────────────────┘   │
└──────────────────────────┼──────────────────────────────────────┘
                           │
                           ▼
          ┌────────────────────────────────┐
          │    PostgreSQL 16               │
          │    (datos PHI: bytes cifrados) │
          └────────────────────────────────┘
```

---

## Instalacion y puesta en marcha

### Requisitos previos

- Python 3.12 o superior
- Flutter 3.19 o superior (con Dart SDK >= 3.2)
- PostgreSQL 16 (local o via Docker)
- Docker y Docker Compose (opcional, para entorno completo)

### Backend

```bash
# 1. Clonar el repositorio
git clone https://github.com/lordperi/TFM.git
cd TFM/backend

# 2. Crear y activar entorno virtual
python -m venv .venv
source .venv/bin/activate   # Linux/macOS
# .venv\Scripts\activate    # Windows

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Configurar variables de entorno
# Crear un archivo .env en backend/ (nunca subir al repositorio)
cat > .env << 'EOF'
DATABASE_URL=postgresql+psycopg2://usuario:contrasena@localhost:5432/diabeaty
SECRET_KEY=tu_clave_secreta_jwt_minimo_32_caracteres
ENCRYPTION_KEY=tu_clave_fernet_base64url_32_bytes
EOF

# Generar ENCRYPTION_KEY valida:
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# 5. Aplicar migraciones de base de datos
alembic upgrade head

# 6. Poblar la base de datos con alimentos (idempotente)
curl -X POST http://localhost:8000/api/v1/nutrition/ingredients/seed

# 7. Iniciar el servidor de desarrollo
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

La documentacion Swagger estara disponible en `http://localhost:8000/docs`.

### Frontend

```bash
cd TFM/frontend

# 1. Instalar dependencias Dart/Flutter
flutter pub get

# 2. Regenerar codigo (Retrofit, json_serializable, injectable)
dart run build_runner build --delete-conflicting-outputs

# 3. Configurar la URL de la API
# Editar lib/core/constants.dart o la variable de entorno correspondiente

# 4. Ejecutar en modo desarrollo (web)
flutter run -d chrome

# 5. Build para produccion
flutter build web --release
```

### Docker Compose (entorno completo)

```bash
cd TFM
docker-compose up -d
```

---

## Variables de entorno

Todas las variables sensibles se inyectan en produccion a traves del panel de Coolify y nunca se incluyen en el repositorio.

| Variable | Descripcion | Ejemplo |
|:---------|:------------|:--------|
| `DATABASE_URL` | Cadena de conexion PostgreSQL (psycopg2) | `postgresql+psycopg2://user:pass@host:5432/db` |
| `SECRET_KEY` | Clave de firma JWT (minimo 32 caracteres aleatorios) | `openssl rand -hex 32` |
| `ENCRYPTION_KEY` | Clave Fernet para cifrado PHI (base64url, 32 bytes) | `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"` |

> **Advertencia de seguridad**: La pérdida de `ENCRYPTION_KEY` hace irrecuperables todos los datos médicos cifrados almacenados en la base de datos.

---

## Endpoints API

Documentacion interactiva completa: `https://diabetics-api.jljimenez.es/docs`

### Autenticacion (`/api/v1/auth`)

| Metodo | Ruta | Descripcion | Auth |
|:-------|:-----|:------------|:-----|
| `POST` | `/login` | Intercambia credenciales (email+password) por token JWT Bearer | — |

### Usuarios y Salud (`/api/v1/users`)

| Metodo | Ruta | Descripcion | Auth |
|:-------|:-----|:------------|:-----|
| `POST` | `/register` | Registro de cuenta nueva con perfil de salud inicial | — |
| `GET` | `/me` | Perfil del usuario autenticado (PHI descifrado en runtime) | JWT |
| `PATCH` | `/me/health-profile` | Actualiza perfil de salud (campos parciales) | JWT |
| `POST` | `/me/change-password` | Cambio de contrasena con verificacion de la actual | JWT |
| `GET` | `/me/xp-summary` | Resumen XP: nivel actual, progreso, XP total | JWT |
| `GET` | `/me/xp-history` | Historial de transacciones XP con paginacion | JWT |
| `GET` | `/me/achievements` | Logros desbloqueados y bloqueados del usuario | JWT |

### Familia (`/api/v1/family`)

| Metodo | Ruta | Descripcion | Auth |
|:-------|:-----|:------------|:-----|
| `GET` | `/members` | Lista perfiles de pacientes del guardian autenticado | JWT |
| `POST` | `/members` | Crea un nuevo perfil de paciente dependiente | JWT |
| `GET` | `/members/{id}` | Detalle completo del paciente (con PHI descifrado) | JWT |
| `PATCH` | `/members/{id}` | Actualiza datos del paciente (requiere PIN si tiene datos sensibles) | JWT |
| `POST` | `/members/{id}/verify-pin` | Verifica el PIN de control parental de un perfil | JWT |
| `POST` | `/device-link` | Genera codigo de vinculacion de dispositivo para paciente | JWT |

### Glucosa (`/api/v1/glucose`)

| Metodo | Ruta | Descripcion | Auth |
|:-------|:-----|:------------|:-----|
| `POST` | `/` | Registra una lectura de glucosa (mg/dL) para un paciente | JWT |
| `GET` | `/history` | Historial de lecturas con filtros de fecha y paginacion | JWT |

### Motor Nutricional (`/api/v1/nutrition`)

| Metodo | Ruta | Descripcion | Auth |
|:-------|:-----|:------------|:-----|
| `GET` | `/ingredients` | Busqueda full-text de ingredientes por nombre (`?q=`) | — |
| `POST` | `/ingredients` | Crea un nuevo ingrediente en la base de datos | — |
| `POST` | `/ingredients/seed` | Puebla 165 alimentos comunes (idempotente) | — |
| `POST` | `/bolus/calculate` | Calcula bolo de insulina multi-ingrediente | — |
| `POST` | `/meals` | Registra comida + bolo administrado + otorga 10 XP | JWT |
| `GET` | `/meals/history` | Historial de comidas con filtros de fecha | — |

### Sistema (`/api/v1`)

| Metodo | Ruta | Descripcion |
|:-------|:-----|:------------|
| `GET` | `/health` | Heartbeat: estado de la API y conexion a base de datos |

---

## Modelo de datos (diagrama ER)

```
┌──────────────────┐         ┌──────────────────────────┐
│      users       │         │   health_profiles        │
│──────────────────│         │──────────────────────────│
│ id (UUID) PK     │◄───1:1──┤ id (UUID) PK             │
│ email (unique)   │         │ user_id (FK, nullable)   │
│ hashed_password  │         │ patient_id (FK, nullable)│
│ full_name        │         │ diabetes_type            │
│ is_active        │         │ therapy_type             │
│ pin_hash         │         │ insulin_sensitivity [E]  │
└──────┬───────────┘         │ carb_ratio [E]           │
       │ 1:N                 │ target_glucose [E]       │
       ▼                     │ basal_insulin_units [E]  │
┌──────────────────┐         │ target_range_low         │
│     patients     │         │ target_range_high        │
│──────────────────│         └──────────────────────────┘
│ id (UUID) PK     │◄───1:1──(health_profiles.patient_id)
│ guardian_id (FK) │
│ display_name     │         ┌──────────────────────────┐
│ birth_date       │         │      meals_log           │
│ theme_preference │         │──────────────────────────│
│ role             │◄───1:N──┤ id (UUID) PK             │
│ pin_hash         │         │ patient_id (FK)          │
│ login_code       │         │ timestamp                │
└──────────────────┘         │ total_carbs_grams        │
                             │ total_glycemic_load      │
                             │ bolus_units_administered │
                             │ notes [E]                │
                             └──────────┬───────────────┘
                                        │ 1:N
                                        ▼
                             ┌──────────────────────────┐
                             │       meal_items         │
                             │──────────────────────────│
                             │ id (UUID) PK             │
                             │ meal_id (FK)             │
                             │ ingredient_id (FK)       │
                             │ weight_grams             │
                             └──────────┬───────────────┘
                                        │ N:1
                                        ▼
                             ┌──────────────────────────┐
                             │      ingredients         │
                             │──────────────────────────│
                             │ id (UUID) PK             │
                             │ name (unique)            │
                             │ glycemic_index           │
                             │ carbs_per_100g           │
                             │ fiber_per_100g           │
                             │ barcode (nullable)       │
                             └──────────────────────────┘

┌──────────────────────────┐   ┌──────────────────────────┐
│    xp_transactions       │   │    achievements          │
│──────────────────────────│   │──────────────────────────│
│ id (UUID) PK             │   │ id (UUID) PK             │
│ user_id (FK → users)     │   │ name                     │
│ amount                   │   │ description              │
│ reason                   │   │ category                 │
│ description              │   │ icon                     │
│ timestamp                │   │ xp_reward                │
└──────────────────────────┘   └──────────┬───────────────┘
                                           │ N:M via
                               ┌───────────▼───────────────┐
                               │    user_achievements      │
                               │───────────────────────────│
                               │ id (UUID) PK              │
                               │ user_id (FK)              │
                               │ achievement_id (FK)       │
                               │ unlocked_at               │
                               └───────────────────────────┘

┌──────────────────────────┐
│  glucose_measurements    │
│──────────────────────────│
│ id (UUID) PK             │
│ patient_id (FK)          │
│ glucose_value (mg/dL)    │
│ timestamp                │
│ measurement_type         │
│ notes [E]                │
└──────────────────────────┘

[E] = Campo cifrado con Fernet AES-128-CBC en reposo
```

---

## Sistema de seguridad y cifrado PHI

DiaBeaty implementa **Application-Level Encryption (ALE)** como decision de diseno fundamental (ver [ADR-005](docs/adr/005_data_encryption.md)). La filosofia es **Zero-Trust Database**: ni el administrador de base de datos puede leer los datos médicos de los pacientes.

### Capas de seguridad

| Capa | Mecanismo | Implementacion |
|:-----|:----------|:---------------|
| Contrasenas de usuario | Bcrypt (cost-factor 12) | `passlib[bcrypt]` |
| Tokens de sesion | JWT HS256, expiración configurable | `PyJWT` + `python-jose` |
| Datos PHI en BD | Fernet AES-128-CBC + HMAC-SHA256 | `cryptography.fernet` |
| Transporte | HTTPS Full-Strict | Cloudflare + Coolify |
| CORS | Origenes explicitamente permitidos | `FastAPI CORSMiddleware` |
| Headers de seguridad | `X-Frame-Options`, `TrustedHostMiddleware` | FastAPI middleware |

### Campos cifrados en base de datos

| Tabla | Campo | Dato protegido |
|:------|:------|:---------------|
| `health_profiles` | `insulin_sensitivity` | Factor de sensibilidad a la insulina (ISF) |
| `health_profiles` | `carb_ratio` | Ratio insulina/carbohidrato (ICR) |
| `health_profiles` | `target_glucose` | Objetivo glucémico terapéutico |
| `health_profiles` | `basal_insulin_units` | Dosis de insulina de accion lenta |
| `meals_log` | `notes` | Notas clínicas sobre la comida |
| `glucose_measurements` | `notes` | Notas asociadas a la medicion |

### Implementacion del tipo cifrado

El cifrado es transparente para el ORM gracias a `EncryptedString`, un tipo personalizado (`TypeDecorator`) de SQLAlchemy:

```python
# backend/src/infrastructure/db/types.py

class EncryptedString(TypeDecorator):
    impl = LargeBinary  # La BD almacena bytes aleatorios

    def process_bind_param(self, value, dialect):
        # Antes de guardar en BD: cifrar
        if value is not None:
            return get_crypto_service().encrypt(str(value))
        return None

    def process_result_value(self, value, dialect):
        # Al leer de BD: descifrar
        if value is not None:
            return get_crypto_service().decrypt(value)
        return None
```

El servicio de cifrado carga la `ENCRYPTION_KEY` desde variables de entorno y nunca la expone en logs ni respuestas:

```python
# backend/src/infrastructure/security/crypto.py

class CryptoService:
    def __init__(self, key: str = None):
        self.key = key or os.getenv("ENCRYPTION_KEY")
        self.fernet = Fernet(self.key)

    def encrypt(self, data: str) -> bytes:
        return self.fernet.encrypt(data.encode())

    def decrypt(self, token: bytes) -> str:
        return self.fernet.decrypt(token).decode()
```

---

## Logica medica core

### Algoritmo de bolo de insulina (Bolus Wizard)

El algoritmo implementado es el estandar clinico **Bolus Wizard**, utilizado en bombas de insulina comerciales (Medtronic, Omnipod) y en el criterio clinico internacional:

```
Bolo_Comida    = Carbohidratos_Netos / ICR
Bolo_Correccion = (Glucosa_Actual - Glucosa_Objetivo) / ISF

Bolo_Total = max(0, Bolo_Comida + Bolo_Correccion)
```

**Parametros del algoritmo:**

| Parametro | Descripcion | Rango tipico |
|:----------|:------------|:-------------|
| **ICR** (Insulin-to-Carb Ratio) | Gramos de carbohidratos cubiertos por 1 unidad de insulina | 5–20 g/U |
| **ISF** (Insulin Sensitivity Factor) | Cuanto baja la glucosa (mg/dL) 1 unidad de insulina | 20–100 mg/dL por U |
| **Glucosa_Objetivo** | Objetivo glucémico personalizado | 70–180 mg/dL |

La condicion `max(0, ...)` garantiza que **el bolo nunca es negativo**: si el paciente tiene hipoglucemia (glucosa actual menor que el objetivo), el sistema no sugiere inyectar insulina.

**Implementacion en Python:**

```python
# backend/src/domain/nutrition.py

def calculate_daily_bolus(
    total_carbs: float,
    icr: float,
    current_glucose: float,
    target_glucose: float,
    isf: float
) -> float:
    carb_insulin = total_carbs / icr
    correction_insulin = (current_glucose - target_glucose) / isf
    total = carb_insulin + correction_insulin
    return max(0.0, total)
```

**Ejemplo practico:**

```
Comida: 60g arroz blanco (carbs = 28.2g/100g × 60g = 16.92g carbos)
Glucosa actual: 160 mg/dL
Glucosa objetivo: 100 mg/dL
ICR: 10 (1U por cada 10g de carbos)
ISF: 50 (1U baja 50 mg/dL)

Bolo_Comida     = 16.92 / 10  = 1.69 U
Bolo_Correccion = (160 - 100) / 50 = 1.20 U
Bolo_Total      = 1.69 + 1.20  = 2.89 U  →  Color NARANJA
```

### Carga glucemica

```
CG = (Indice_Glucémico × Carbohidratos_Netos) / 100
```

La Carga Glucémica es mas informativa que el IG solo porque tiene en cuenta la cantidad real consumida. Un alimento con IG alto pero consumido en poca cantidad puede tener CG baja.

| CG | Clasificacion |
|:---|:-------------|
| < 10 | Baja (impacto glucémico reducido) |
| 10–20 | Media |
| > 20 | Alta (precaucion) |

### Codificacion de color del bolo

| Bolo calculado | Color | Interpretacion clinica |
|:--------------|:------|:----------------------|
| ≤ 2 unidades | Verde | Dosis segura, bajo riesgo |
| 2 – 5 unidades | Naranja | Dosis moderada, precaucion |
| > 5 unidades | Rojo | Dosis elevada, revisar con medico |

---

## Sistema de gamificacion XP

El sistema de gamificacion esta disenado especificamente para ninos y adolescentes con diabetes, convirtiendo las tareas terapéuticas diarias en una experiencia de juego de rol.

### Fuentes de XP

| Accion | XP otorgado |
|:-------|:-----------|
| Registrar una comida | +10 XP |
| Calcular bolo de insulina | +5 XP |
| Login diario | +5 XP |
| Glucosa en rango perfecto | +20 XP |
| Racha semanal completa | +50 XP |
| Logro desbloqueado | Variable |

### Niveles y nomenclatura

```
Nivel 1 (   0 –  499 XP): Explorador
Nivel 2 ( 500 –  999 XP): Aventurero
Nivel 3 (1000 – 1499 XP): Guerrero
Nivel 4 (1500 – 1999 XP): Heroe
Nivel 5 (2000 – 2499 XP): Campeon
Nivel 6 (2500+        XP): Leyenda
```

**Formula de nivel:**
```python
nivel = (xp_total // 500) + 1          # nivel minimo: 1
xp_para_siguiente = nivel * 500 - xp_total
porcentaje_progreso = (xp_total % 500) / 500.0
```

### Categorias de logros

| Categoria | Ejemplo de logro |
|:----------|:----------------|
| `CONSISTENCY` | "Registra 7 comidas en una semana" |
| `HEALTH` | "Mantén glucosa en rango 3 días seguidos" |
| `LEARNING` | "Calcula tu primer bolo de insulina" |
| `MILESTONE` | "Alcanza el nivel Aventurero" |
| `SOCIAL` | "Primer perfil familiar creado" |

---

## Testing

### Resumen de cobertura

| Suite | Tests | Estado | Descripcion |
|:------|:------|:-------|:------------|
| **Backend (pytest)** | 110 | Todos pasan | TDD estricto, SQLite in-memory |
| **Frontend (flutter test)** | 36 | Todos pasan | BLoC unit tests, widget tests |

### Estrategia TDD

El proyecto sigue el ciclo **Red → Green → Refactor** sin excepciones:

1. **Red**: Se escribe el test antes que el codigo de produccion. El test debe fallar.
2. **Green**: Se implementa el minimo codigo necesario para que el test pase.
3. **Refactor**: Se limpia el codigo sin romper los tests.

Ver [ADR-004](docs/adr/004_testing_strategy.md) para la estrategia completa.

### Configuracion de tests (backend)

```python
# tests/conftest.py — Configuracion de base de datos de test

engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool  # Misma conexion para toda la sesion
)

@pytest.fixture(scope="function")
def db_session():
    """Sesion con rollback automatico tras cada test."""
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)
    yield session
    session.close()
    transaction.rollback()
    connection.close()
```

### Ejecucion de tests

```bash
# Backend — todos los tests
cd backend
pytest tests/ -v

# Backend — por categoria
pytest tests/api/ -v       # Tests de endpoints HTTP
pytest tests/unit/ -v      # Tests unitarios de logica de negocio

# Con reporte de cobertura
pytest tests/ -v --cov=src --cov-report=html

# Frontend
cd frontend
flutter test
flutter test --coverage
```

### Tests clave por modulo

| Archivo de test | Cobertura |
|:----------------|:----------|
| `test_nutrition_logic.py` | Algoritmo bolus, carga glucémica, casos borde |
| `test_nutrition_security.py` | Cifrado/descifrado de notas PHI en comidas |
| `test_conditional_medical_profiles.py` | 11 combinaciones validas/invalidas de terapia medica |
| `test_health_profile_flexibility.py` | Perfiles GUARDIAN vs DEPENDENT |
| `test_xp_models.py` | Calculo de niveles XP, progreso, transacciones |
| `test_glucose_tracking.py` | Registro y consulta de mediciones de glucosa |
| `test_meal_history.py` | Historial de comidas con filtros de fecha |
| `test_family_router.py` | CRUD de perfiles familiares |
| `test_family_basal_insulin.py` | Cifrado de insulina basal (PHI) |

---

## Despliegue en produccion

### URLs de produccion

| Servicio | URL |
|:---------|:----|
| Frontend Web | `https://diabetics.jljimenez.es` |
| Backend API | `https://diabetics-api.jljimenez.es` |
| Swagger/OpenAPI | `https://diabetics-api.jljimenez.es/docs` |
| Health check | `https://diabetics-api.jljimenez.es/api/v1/health` |

### Flujo CI/CD

```
git push origin main
       │
       ▼ Webhook
┌─────────────────┐
│   Coolify v4    │
│  (self-hosted)  │
└────────┬────────┘
         │
         ▼ Docker Build
┌────────────────────────────────────────────────┐
│  Backend (Multi-stage Dockerfile)              │
│  Stage 1: python:3.12-slim (install deps)      │
│  Stage 2: python:3.12-slim (runtime only)      │
│  Entrypoint: alembic upgrade head && uvicorn   │
└────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────┐
│  Frontend (Multi-stage Dockerfile)             │
│  Stage 1: flutter:latest (flutter build web)   │
│  Stage 2: nginx:alpine (serve build/web/)      │
└────────────────────────────────────────────────┘
         │
         ▼ Zero-downtime deploy
    Produccion activa
```

### Seed inicial de datos

La base de datos de produccion se puebla con 165 alimentos usando el endpoint idempotente:

```bash
curl -X POST https://diabetics-api.jljimenez.es/api/v1/nutrition/ingredients/seed
# {"inserted": 165, "total_available": 165}
```

El endpoint es idempotente: si los alimentos ya existen (por nombre), no se duplican.

---

## Estado del proyecto y hitos

`[██████████] 100% Completado`

| Hito | Estado | Completitud | Detalles |
|:-----|:-------|:------------|:---------|
| **I. Infraestructura** | Completado | 100% | VPS propio, Coolify v4, Docker Registry privado, HTTPS Full-Strict |
| **II. Base de datos** | Completado | 100% | PostgreSQL 16, 13 migraciones Alembic versionadas, 10 modelos ORM |
| **III. Seguridad** | Completado | 100% | JWT HS256, Bcrypt cost-12, Fernet AES-128-CBC PHI, PIN parental |
| **IV. Motor nutricional** | Completado | 100% | 165 alimentos, CRUD ingredientes, calculo bolus multi-ingrediente, CG |
| **V. Aplicacion movil** | Completado | 100% | Dual UX, Hub Nutricional, bandeja multi-ingrediente, graficas glucosa |
| **VI. Gestion de usuarios** | Completado | 100% | Guardianes, dependientes, PIN granular, cambio de contrasena |
| **VII. Sistema XP** | Completado | 100% | Niveles, transacciones, logros, progreso |
| **VIII. Monitoring glucosa** | Completado | 100% | Registro, historial, graficas, tipos de medicion |

### Tests

| Fecha | Backend | Frontend |
|:------|:--------|:---------|
| Sprint 1 (Feb 2026) | 108 tests | 36 tests |
| Estado actual | **110 tests** | **36 tests** |

---

## Roadmap post-TFM

### Fase 2: Vision IA

- **OCR de menus**: Extraccion automatica de platos desde fotos de cartas de restaurante
- **Estimacion visual**: Deep Learning para estimar gramos de carbohidratos por foto del plato
- **Prediccion glucemica**: Modelo predictivo (LSTM) basado en historial de glucosa

### Fase 3: Contenido y social

- **Video-to-Recipe**: Pipeline que transforma videos de cocina en recetas calculadas para diabéticos
- **Comunidad**: Compartir recetas validadas entre usuarios

### Fase 4: Ecosistema IoT

- **CGM Direct Link**: Conexion en tiempo real con sensores Dexcom G6/G7 y Abbott FreeStyle Libre
- **Insulina conectada**: Integracion con bombas de insulina Omnipod/Medtronic

---

## Documentacion tecnica

| Documento | Descripcion |
|:----------|:------------|
| [Manual Tecnico](docs/manual_tecnico.md) | Documento exhaustivo para tribunal TFM |
| [Arquitectura Backend](docs/backend/architecture.md) | Capas, patrones, flujos, seguridad |
| [Arquitectura Frontend](docs/frontend/architecture.md) | BLoC pattern, Dual UX, pantallas |
| [ADR-001: Stack tecnologico](docs/adr/001_tech_stack.md) | Python + FastAPI |
| [ADR-002: Clean Architecture](docs/adr/002_clean_architecture.md) | Arquitectura hexagonal |
| [ADR-003: Flutter](docs/adr/003_flutter_frontend.md) | Eleccion de framework movil |
| [ADR-004: Testing](docs/adr/004_testing_strategy.md) | Estrategia TDD |
| [ADR-005: Cifrado PHI](docs/adr/005_data_encryption.md) | Fernet, ALE, Zero-Trust DB |
| [ADR-006: BD y Alembic](docs/adr/006_database_alembic.md) | PostgreSQL, migraciones |
| [ADR-007: Infraestructura](docs/adr/007_infrastructure_coolify.md) | Coolify, Docker, CI/CD |
| [Swagger JSON](docs/backend/swagger.json) | Especificacion OpenAPI exportada |
| [Sprint 1 Report](docs/reports/sprint_1.md) | Retrospectiva Sprint 1 |
| [Sprint 2 Report](docs/reports/sprint_2.md) | Retrospectiva Sprint 2 |

---

## Glosario medico

| Termino | Definicion |
|:--------|:-----------|
| **T1D** | Diabetes Tipo 1 (autoinmune, insulinodependiente desde el diagnostico) |
| **ICR** (Insulin-to-Carb Ratio) | Gramos de carbohidratos cubiertos por 1 unidad de insulina rapida |
| **ISF** (Insulin Sensitivity Factor) | Cuanto baja la glucosa (mg/dL) una sola unidad de insulina |
| **IG** (Indice Glucémico) | Velocidad a la que un alimento eleva la glucosa en sangre (escala 0–100) |
| **CG** (Carga Glucémica) | Impacto glucémico real = `(IG × carbos_netos) / 100` |
| **PHI** (Protected Health Information) | Datos médicos sensibles protegidos por GDPR/normativa medica |
| **Bolo** | Dosis de insulina de accion rapida administrada para cubrir una comida |
| **Basal** | Dosis de insulina de accion prolongada administrada una vez al dia |
| **CGM** | Continuous Glucose Monitor: sensor de glucosa en tiempo real (Dexcom, Libre) |
| **Hipoglucemia** | Glucosa en sangre menor de 70 mg/dL (emergencia medica) |
| **Hiperglucemia** | Glucosa en sangre mayor de 180 mg/dL (danino a largo plazo) |

---

## Contribucion

Este proyecto es un Trabajo Fin de Master. El codigo es publico con fines academicos y de referencia.

Si encuentras un error de seguridad relacionado con datos de salud (PHI), por favor reportalo de forma responsable al email del autor antes de publicarlo.

## Licencia

MIT License — Ver archivo `LICENSE` para detalles completos.

---

*DiaBeaty TFM — Ingenieria y Arquitectura de Software con Inteligencia Artificial · Jose Luis Jimenez · 2024–2026*
