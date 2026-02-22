# 🩺 DiaBeaty (TFM — Arquitectura de Software con IA)

> **Plataforma de Nutrición de Precisión y Monitorización de Salud** para Pacientes Diabéticos.
> *Empoderando familias con cálculos nutricionales asistidos por IA y una interfaz Dual-UX (Adulto/Niño).*

![Status](https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge&logo=statuspage)
![Backend](https://img.shields.io/badge/Backend-Python_3.12_%7C_FastAPI-blue?style=for-the-badge&logo=python)
![Frontend](https://img.shields.io/badge/Frontend-Flutter_3.19-02569B?style=for-the-badge&logo=flutter)
![Infra](https://img.shields.io/badge/Infra-Coolify_v4_%7C_Docker-336791?style=for-the-badge&logo=docker)
![Backend Tests](https://img.shields.io/badge/Backend_Tests-108_✅-brightgreen?style=for-the-badge&logo=pytest)
![Flutter Tests](https://img.shields.io/badge/Flutter_Tests-36_✅-brightgreen?style=for-the-badge&logo=flutter)
![Security](https://img.shields.io/badge/Security-AES_256_%7C_OWASP-red?style=for-the-badge&logo=lock)

---

## 📖 Resumen Ejecutivo

**El Problema**: La gestión de la Diabetes Tipo 1 (T1D) es una carga cognitiva inmensa. Pacientes y cuidadores deben realizar cálculos complejos (ratios de insulina, carga glucémica) múltiples veces al día. Un error de cálculo puede resultar en hipoglucemia severa.

**Nuestra Solución**: *DiaBeaty* actúa como un **Páncreas Digital Auxiliar**. No solo registra datos; procesa información nutricional para sugerir dosis precisas, adaptando la interfaz al usuario:

1. **Modo Tutor (Adulto)**: Dashboard técnico, gestión de ratios y métricas avanzadas.
2. **Modo Héroe (Niño)**: Gamificación terapéutica donde el control glucémico se convierte en una aventura.

---

## 📶 Milestone Tracking (Estado MVP)

`[█████████░] 93% Completado`

| Hito | Estado | Detalles Técnicos |
| :--- | :--- | :--- |
| **I. Infraestructura** | ✅ 100% | VPS propio, Coolify v4, Registro Docker Privado, HTTPS Full-Strict. |
| **II. Database Core** | ✅ 100% | PostgreSQL 16, Migraciones Alembic versionadas, Modelado Relacional completo. |
| **III. Seguridad** | ✅ 100% | Auth JWT (HS256), Hash Bcrypt, Cifrado AES-256 Fernet (PHI), PIN de control parental. |
| **IV. Motor Metabólico** | ✅ 90% | BD de ingredientes CRUD + seed 25 alimentos, Bolus multi-ingrediente, Historial con filtros de fecha, Carga Glucémica. |
| **V. Mobile App** | ✅ 90% | Dual UX completa, Hub Nutricional, Bandeja multi-ingrediente, Perfiles de familia, Gráfica de glucosa con marcadores de insulina. |
| **VI. Gestión de Usuarios** | ✅ 100% | Perfiles Flexibles (Guardián/Dependiente), PIN granular, Vista de perfil por miembro. |

---

## 🗺️ Roadmap Estratégico

### 🏛️ Fase 1: The Foundation — *Completada*

- [x] **Arquitectura Hexagonal**: Desacoplamiento total de lógica de negocio y frameworks.
- [x] **Zero-Trust Security**: Cifrado de datos sensibles (Ratios, Notas médicas) en reposo con Fernet.
- [x] **Perfiles Flexibles**: Soporte para Guardianes (sin datos médicos) y Pacientes (UI Protegida).
- [x] **Motor Nutricional**: BD de ingredientes con IG, endpoint CRUD y seed de 25 alimentos base.
- [x] **Dual UX**: Dashboard adulto (técnico) y niño (gamificado) con tema dinámico.

### 👁️ Fase 2: AI Vision (Post-TFM)

- [ ] **OCR de Menús**: Extracción de platos desde fotos de cartas de restaurantes.
- [ ] **Estimación Visual**: Deep Learning para estimar gramos de carbohidratos por foto del plato.

### 🎥 Fase 3: Social & Video AI

- [ ] **Video-to-Recipe**: Pipeline que transforma vídeos de cocina en recetas calculadas para diabéticos.

### 🌐 Fase 4: Ecosistema IoT

- [ ] **CGM Direct Link**: Conexión con sensores Dexcom/Libre en tiempo real.

---

## 🛠️ Stack Tecnológico

| Área | Tecnologías | ADR |
| :--- | :--- | :--- |
| **Lenguaje Core** | Python 3.12 | [ADR-001](docs/adr/001_tech_stack.md) |
| **API Framework** | FastAPI + Pydantic v2 | [ADR-001](docs/adr/001_tech_stack.md) |
| **Datos** | PostgreSQL 16 + SQLAlchemy 2.0 | [ADR-006](docs/adr/006_database_alembic.md) |
| **Migraciones** | Alembic | [ADR-006](docs/adr/006_database_alembic.md) |
| **Mobile** | Flutter 3.19 + Dart | [ADR-003](docs/adr/003_flutter_frontend.md) |
| **Estado (Frontend)** | flutter_bloc + BLoC Pattern | [ADR-002](docs/adr/002_clean_architecture.md) |
| **API Client** | Retrofit + Dio + JWT Interceptor | — |
| **CD / Orquestación** | Coolify v4 + Docker | [ADR-007](docs/adr/007_infrastructure_coolify.md) |
| **Seguridad** | Fernet (AES-128-CBC + HMAC) + Bcrypt | [ADR-005](docs/adr/005_data_encryption.md) |

---

## 🔌 Catálogo de Endpoints (API v1)

La documentación interactiva completa está disponible en `https://diabetics-api.jljimenez.es/docs`.

### Authentication (`/api/v1/auth`)

| Método | Ruta | Descripción | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/login` | Intercambia credenciales por JWT Bearer Token | — |

### Users & Health (`/api/v1/users`)

| Método | Ruta | Descripción | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/register` | Registro de cuenta + perfil médico cifrado | — |
| `GET` | `/me` | Perfil del usuario autenticado (descifrado en runtime) | 🔒 |
| `PUT` | `/profile` | Actualiza perfil de salud del usuario | 🔒 |

### Family (`/api/v1/family`)

| Método | Ruta | Descripción | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/profiles` | Lista perfiles de pacientes del guardián | 🔒 |
| `GET` | `/profiles/{id}` | Detalle completo del perfil (campos médicos cifrados) | 🔒 |
| `POST` | `/profiles` | Crea un nuevo perfil de paciente | 🔒 |
| `PUT` | `/profiles/{id}` | Actualiza datos médicos del paciente | 🔒 |

### Glucose (`/api/v1/glucose`)

| Método | Ruta | Descripción | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/add` | Registra una lectura de glucosa | 🔒 |
| `GET` | `/history` | Historial de lecturas por paciente con filtros | 🔒 |

### Nutrition Engine (`/api/v1/nutrition`)

| Método | Ruta | Descripción | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/ingredients` | Búsqueda full-text de ingredientes (`?q=`) | — |
| `POST` | `/ingredients` | Crea un nuevo ingrediente en la BD | — |
| `POST` | `/ingredients/seed` | Puebla 25 alimentos comunes (idempotente) | — |
| `POST` | `/bolus/calculate` | Calcula bolus multi-ingrediente con ICR/ISF | — |
| `POST` | `/meals` | Registra comida con dosis de insulina administrada | — |
| `GET` | `/meals/history` | Historial de comidas con filtros de fecha | — |

### System (`/api/v1`)

| Método | Ruta | Descripción |
| :--- | :--- | :--- |
| `GET` | `/health` | Heartbeat + estado de la BD |

---

## 🧮 Lógica de Negocio Core

### Algoritmo de Bolus de Insulina

```
Bolus = (CarbosNetos / ICR) + ((GlucosaActual - GlucosaObjetivo) / ISF)
Bolus = max(0, Bolus)  # nunca negativo
```

Donde:
- **ICR** (Insulin-to-Carb Ratio): gramos de carbohidratos cubiertos por 1 unidad.
- **ISF** (Insulin Sensitivity Factor): cuánto baja la glucosa 1 unidad de insulina.

### Carga Glucémica

```
CG = (IG × CarbosNetos) / 100
```

### Rangos de Color (UI)

| Bolus | Color | Lectura glucosa |
| :--- | :--- | :--- |
| ≤ 2 U | 🟢 Verde | Dentro de rango objetivo |
| 2–5 U | 🟠 Naranja | Límite superior / alerta |
| > 5 U | 🔴 Rojo | Hipoglucemia / urgencia |

---

## 🏗️ Arquitectura Clean (Backend)

```
src/
├── domain/          # Entidades puras + reglas de negocio (sin dependencias)
├── application/
│   ├── use_cases/   # Casos de uso: calculate_bolus, log_meal, search_ingredients
│   └── repositories/# Interfaces de repositorios
└── infrastructure/
    ├── api/         # Routers FastAPI + Pydantic DTOs
    ├── db/          # Modelos SQLAlchemy + tipos cifrados
    └── security/    # JWT, Bcrypt, Fernet
```

**Flujo**: Router → Use Case → Repository → ORM. Los casos de uso no conocen FastAPI ni SQLAlchemy.

---

## 📱 Arquitectura Frontend (Flutter)

```
lib/
├── core/            # Constants, themes, DI, HTTP client
├── data/
│   ├── models/      # DTOs con json_serializable
│   └── datasources/ # Retrofit API clients (code-gen)
├── domain/          # Entities, Repository interfaces
└── presentation/
    ├── bloc/        # AuthBloc, ThemeBloc, NutritionBloc, ProfileBloc
    └── screens/     # Login, Dashboard, Glucose, Nutrition Hub, Profile
```

**Dual UX**: El `ThemeBloc` cambia automáticamente entre tema Adulto (azules, técnico) y Niño (rosas, gamificado) según el perfil activo. Ver [ADR-003](docs/adr/003_flutter_frontend.md).

---

## 🧪 Testing

| Suite | Nº Tests | Estado |
| :--- | :--- | :--- |
| **Backend (pytest)** | 108 | ✅ All passing |
| **Frontend (flutter test)** | 36 | ✅ All passing |

**Estrategia TDD**: Red → Green → Refactor en cada feature. Ver [ADR-004](docs/adr/004_testing_strategy.md).

**Backend**: SQLite in-memory con StaticPool y rollback por función para aislamiento total.

```bash
# Backend
cd backend && pytest tests/ -v

# Frontend
cd frontend && flutter test
```

---

## 🚀 Despliegue

### Stack de Producción

- **Backend API**: `https://diabetics-api.jljimenez.es` (FastAPI + PostgreSQL)
- **Frontend Web**: `https://diabetics.jljimenez.es` (Flutter Web + Nginx Alpine)

### CI/CD

1. `git push origin main` → Webhook → Coolify detecta cambio
2. Docker Multi-stage Build (compile Flutter, copy to Nginx)
3. `alembic upgrade head` automático en cada deploy
4. Zero-downtime deploy

### Variables de entorno (nunca en repo, solo en Coolify UI)

```
ENCRYPTION_KEY  # Fernet key para PHI
SECRET_KEY      # JWT signing key
DATABASE_URL    # PostgreSQL connection string
```

---

## 🌱 Seed de Base de Datos

La BD de producción se puebla con el endpoint idempotente:

```bash
curl -X POST https://diabetics-api.jljimenez.es/api/v1/nutrition/ingredients/seed
# → {"inserted": 25, "total_available": 25}
```

Incluye: arroz, pasta, patatas, frutas (manzana, plátano, naranja, uvas, sandía, fresas), legumbres (lentejas, garbanzos), lácteos, bebidas, chocolate, avena, pan, maíz, verduras.

---

## 📚 Documentación

| Documento | Descripción |
| :--- | :--- |
| [Backend Architecture](docs/backend/architecture.md) | Clean Architecture layers, patrones, decisiones |
| [Frontend Architecture](docs/frontend/architecture.md) | BLoC pattern, Dual UX, estructura de pantallas |
| [Project Structure](docs/frontend/project_structure.md) | Árbol completo de ficheros con estados |
| [ADR Index](docs/adr/) | 12 Architecture Decision Records |
| [Deploy Guide](docs/infrastructure/deploy.md) | Docker, Coolify, Nginx config |
| [Sprint 1 Report](docs/reports/sprint_1.md) | Retrospectiva Sprint 1 |
| [Swagger JSON](docs/backend/swagger.json) | OpenAPI spec exportada |

---

## 📖 Glosario Médico

- **IG (Índice Glucémico)**: Velocidad a la que un alimento eleva la glucosa (0–100).
- **CG (Carga Glucémica)**: Impacto real en sangre. `CG = (IG × Carbos_netos) / 100`.
- **ICR (Insulin-to-Carb Ratio)**: Gramos de carbohidratos cubiertos por 1 unidad de insulina.
- **ISF (Insulin Sensitivity Factor)**: Cuánto baja la glucosa (mg/dL) 1 unidad de insulina.
- **PHI (Protected Health Information)**: Datos médicos sensibles cifrados por GDPR/HIPAA.
- **T1D**: Diabetes Tipo 1 (autoinmune, insulinodependiente).
- **Bolus**: Dosis rápida de insulina para cubrir una comida.
- **Basal**: Dosis de insulina de acción lenta (una vez al día).

---

*DiaBeaty TFM — Ingeniería y Arquitectura de Software con IA · 2024–2025*
