# � DiaBeaty (TFM - Advanced Agentic Project)

> **Plataforma de Nutrición de Precisión y Monitorización de Salud** para Pacientes Diabéticos.
> *Empoderando familias con cálculos nutricionales asistidos por IA y una interfaz Dual-UX (Adulto/Niño).*

![Status](https://img.shields.io/badge/Status-Access_Early_Access-success?style=for-the-badge&logo=statuspage)
![Backend](https://img.shields.io/badge/Backend-Python_3.12_%7C_FastAPI-blue?style=for-the-badge&logo=python)
![Frontend](https://img.shields.io/badge/Frontend-Flutter_3.19-02569B?style=for-the-badge&logo=flutter)
![Infra](https://img.shields.io/badge/Infra-Coolify_v4_%7C_Docker-336791?style=for-the-badge&logo=docker)
![Coverage](https://img.shields.io/badge/Testing-Pytest_%7C_Coverage_High-green?style=for-the-badge&logo=pytest)
![Security](https://img.shields.io/badge/Security-AES_256_%7C_OWASP-red?style=for-the-badge&logo=lock)

---

## 📖 Resumen Ejecutivo

**El Problema**: La gestión de la Diabetes Tipo 1 (T1D) es una carga cognitiva inmensa. Pacientes y cuidadores deben realizar cálculos complejos (ratios de insulina, carga glucémica) múltiples veces al día. Un error de cálculo puede resultar en hipoglucemia severa.

**Nuestra Solución**: *DiaBeaty* actúa como un **Páncreas Digital Auxiliar**. No solo registra datos; procesa información nutricional para sugerir dosis precisas, adaptando la interfaz al usuario:

1. **Modo Tutor (Adulto)**: Dashboard técnico, gestión de ratios y métricas avanzadas.
2. **Modo Héroe (Niño)**: Gamificación terapéutica donde el control glucémico se traduce en la salud de un avatar virtual.

---

## 📶 Milestone Tracking (MVP Status)

`[████████░░] 78% Completado`

| Hito | Estado | Detalles Técnicos |
| :--- | :--- | :--- |
| **I. Infraestructura** | ✅ 100% | VPS propio, Coolify v4, Registro Privado, HTTPS Strict. |
| **II. Database Core** | ✅ 100% | PostgreSQL 16, Migraciones Alembic, Modelado Relacional. |
| **III. Seguridad** | ✅ 100% | Auth JWT (HS256), Hash Bcrypt, Cifrado AES-256 (PHI). |
| **IV. Motor Metabólico** | 🔄 40% | Modelado de Alimentos, Algoritmo de Carga Glucémica, Registro de Insulina (bolus_units_administered), Historial de Comidas con GET /meals/history. |
| **V. Mobile App** | 🔄 65% | **Dual UX** (Adulto/Niño), Gestión de Estado BLoC, MealHistoryScreen con indicadores de color, marcadores de insulina en GlucoseChart (triángulos naranja ▲), botones "Historial Insulina" y "Mis Dosis" en Dashboard. |
| **VI. Gestión de Usuarios** | ✅ 100% | Perfiles Flexibles (Guardián/Niño), Protección PIN granular, UI Bloqueada. [Ref ADR 010](docs/adr/010_flexible_health_profiles_and_security.md) |

---

## �️ Roadmap Estratégico

### 🏛️ Fase 1: The Foundation (Semanas 1-3) - *En Desarrollo*

El objetivo es establecer un núcleo seguro y operativo.

- [x] **Arquitectura Hexagonal**: Desacoplamiento total de lógica de negocio y frameworks.
- [x] **Zero-Trust Security**: Cifrado de datos sensibles (Ratios, Notas médicas) en reposo.
- [x] **Perfiles Flexibles**: Soporte para Guardianes (sin datos médicos) y Niños (UI Protegida).
- [ ] **Motor Nutricional**: Base de datos de ingredientes con IG (Índice Glucémico) y Fibra.

### 👁️ Fase 2: AI Vision (Milestone Post-TFM)

Eliminar la fricción de la entrada manual de datos.

- [ ] **OCR de Menús**: Extracción de platos y precios desde fotos de cartas de restaurantes.
- [ ] **Estimación Visual**: Deep Learning para estimar gramos de carbohidratos por foto del plato.

### 🎥 Fase 3: Social & Video AI

- [ ] **Video-to-Recipe**: Pipeline que transforma TikToks de cocina en recetas estructuradas y calculadas para diabéticos.

### 🌐 Fase 4: Ecosistema IoT

- [ ] **CGM Direct Link**: Conexión con sensores Dexcom/Libre en tiempo real.

El proyecto sigue una **Arquitectura Hexagonal (Clean Architecture)**, asegurando que la lógica nutricional sea independiente de la base de datos o el framework web.

## 🛠️ Stack Tecnológico

| Area | Tenologías | Justificación Arquitectónica (ADR) |
| :--- | :--- | :--- |
| **Lenguaje Core** | **Python 3.12** | Tipado fuerte, rendimiento asíncrono y ecosistema nativo de IA. |
| **API Framework** | **FastAPI** | Validación automática Pydantic v2 y documentación OpenAPI. |
| **Datos** | **PostgreSQL 16** | Integridad ACID robusta y soporte JSONB para flexibilidad. |
| **ORM / Migraciones** | **SQLAlchemy 2.0 / Alembic** | Abstracción de DB y control de versiones del esquema. |
| **Mobile** | **Flutter 3.19** | Código único (Dart) para iOS/Android y motor gráfico Skia para gamificación. |
| **CD / Orquestación** | **Coolify v4** | Deployments automáticos (Push-to-Deploy) y soberanía de datos. [Ver detalles](docs/infrastructure/coolify.md) |

---

## 🔌 Catálogo de Endpoints (API V1)

Actualmente documentados en `/docs` (Swagger UI) al desplegar.

### Authentication (`/api/v1/auth`)

- `POST /login`: Intercambia credenciales por **Access Token** (JWT Bearer).

- `POST /refresh`: (Planeado) Rotación de tokens de sesión.

### Users & Health (`/api/v1/users`)

- `POST /register`: Creación de cuenta y **Perfil de Salud Inicial** (Ratios, Tipo Diabetes).

- `GET /me`: Obtiene datos del usuario descifrados en tiempo real (requiere Auth).

### Nutrition (`/api/v1/nutrition`) - *Coming Soon*

- `GET /ingredients/search`: Búsqueda full-text de alimentos.

- `POST /bolus/calculate`: Algoritmo complejo: $Bolus = \frac{Carbs}{ICR} + \frac{Gluc_{actual} - Gluc_{target}}{ISF}$.

1. `feature/XXX` -> 2. Atomic Commits -> 3. PR Review -> 4. Automated Tests -> 5. Merge -> 6. Auto-Deploy.

### 🔌 Catálogo de Endpoints (v1.0)

| Método | Ruta | Descripción | Estado |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/login` | Intercambio de credenciales por Token JWT | ✅ |
| `POST` | `/users/register` | Registro de usuario y perfil médico cifrado | ✅ |
| `POST` | `/nutrition/calc` | Cálculo de Bolus e Insulina (Wizard) | ✅ |
| `POST` | `/nutrition/meals` | Registrar comida con bolus administrado | ✅ |
| `GET` | `/nutrition/meals/history` | Historial de comidas/insulina por paciente | ✅ |
| `GET` | `/health` | Heartbeat del sistema y la base de datos | ✅ |

---

## 🛡️ Stack Tecnológico de Élite

- **Backend**: Python 3.12 + FastAPI (Asíncrono y optimizado para IA).
- **Frontend**: Flutter Web (WASM/JS) + Nginx Alpine (SPA Routing & Security Hardening).
- **Data**: PostgreSQL 16 + Alembic (Gestión de migraciones de grado de producción).
- **Seguridad**: Fernet (Cifrado de datos de salud) + Bcrypt (Hashing) + CSP Headers.
- **Infra**: Docker + Coolify v4 + Cloudflare (Proxy SSL Full Strict).

## 🚀 Despliegue Frontend (Flutter Web)

El frontend utiliza una estrategia híbrida para optimizar recursos en el servidor:

1. **Compilación Automatizada**: Docker utiliza un *Multi-stage Build* para descargar Flutter y compilar el código.
2. **Containerización Optimizada**: La imagen final solo contiene Nginx y los estáticos (Alpine Linux), descartando el SDK de Flutter.
3. **Despliegue Continuo**: Coolify detecta cambios en `main`, construye la imagen Docker y despliega sin intervención manual.

- **Documentación Completa**: [Ver Guía de Despliegue](docs/infrastructure/deploy.md)
- **URL Producción**: `https://diabetics.jljimenez.es`
- **Seguridad**: Nginx con CSP estricto y bloqueo de iframes (`X-Frame-Options: DENY`).

---

## 📖 Glosario Metabólico (Reference)

- **IG (Índice Glucémico)**: Velocidad con la que un alimento aumenta la glucosa.
- **CG (Carga Glucémica)**: Impacto real basado en el IG y la cantidad de carbohidratos netos.
- **ICR (Carb Ratio)**: Gramos de carbohidratos cubiertos por 1 unidad de insulina.
- **ISF (Sensitivity Factor)**: Cuánto baja la glucosa 1 unidad de insulina.

## ⚙️ Metodología de Desarrollo & CI/CD

El equipo sigue un flujo estricto de **Trunk-Based Development** adaptado.

1. **Feature Branches**: Todo desarrollo ocurre en `feature/nombre-tarea`.
2. **Pull Requests**: Revisión de código obligatoria.
3. **Pipeline Gates (Manual/Automated)**:
    - Linting (Ruff/Black).
    - **Testing Coverage > 80%** (Pytest).
    - Validación de Seguridad (OWASP).
4. **Despliegue Automático**: Al hacer merge a `main`, el webhook de Coolify:
    - Construye la imagen Docker.
    - Ejecuta Migraciones de DB (`alembic upgrade head`).
    - Despliega en Producción sin downtime.

## 📦 Data Seeding (Operación Semilla)

Para poblar la base de datos de producción con alimentos validados (15 items iniciales):

```bash
# Requiere Python 3.10+ y requests
python backend/scripts/remote_seed_v2.py
```

Esto inyectará alimentos como Arroz, Pollo, Manzana, etc., necesarios para el funcionamiento del Frontend.

**Verificación:**

```bash
python backend/scripts/verify_seeding.py
```

**Gestión de Secretos**: Las variables (`ENCRYPTION_KEY`, `SECRET_KEY`, `DB_URL`) se inyectan exclusivamente a través de la UI de Coolify, nunca en el repositorio.

---

## � Glosario Médico (TFM Context)

- **IG (Índice Glucémico)**: Velocidad a la que un alimento eleva la glucosa (0-100).
- **CG (Carga Glucémica)**: Impacto real en sangre. $CG = (IG \times Carbos_{netos}) / 100$.
- **ICR (Insulin-to-Carb Ratio)**: Cuántos gramos de carbohidratos cubre 1 unidad de insulina.
- **ISF (Insulin Sensitivity Factor)**: Cuánto baja la glucosa 1 unidad de insulina.
- **PHI (Protected Health Information)**: Datos médicos sensibles que deben ser cifrados por ley (GDPR/HIPAA).

---
*DiaBeaty TFM - Ingeniería y Arquitectura de Software con IA*
