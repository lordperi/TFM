# 🧬 DiaBeaty: Inteligencia Nutricional para el Siglo XXI

> **Plataforma de Salud de Precisión.**
> Redefiniendo la interacción entre el paciente diabético y la comida mediante IA, Arquitectura Hexagonal y Diseño Dual-UX.

![Status](https://img.shields.io/badge/Status-MVP_Core_Ready-success?style=for-the-badge)
![AI-Ready](https://img.shields.io/badge/AI-Metabolic_Wizard_Active-purple?style=for-the-badge)
![Infrastructure](https://img.shields.io/badge/Deploy-Coolify_v4-blue?style=for-the-badge&logo=docker)

---

## 🚀 La Visión: Empoderamiento mediante Datos

**DiaBeaty** no es un simple diario de glucosa. Es un ecosistema diseñado para cerrar la brecha entre la ingesta y la dosis de insulina, ofreciendo dos experiencias radicalmente distintas:

- **Modo Adulto**: Análisis técnico, ratios de sensibilidad y gestión de bolus de precisión.
- **Modo Niño**: El "Hero's Path", donde el cuidado de la salud se traduce en mecánicas de RPG y gamificación terapéutica.

---

## 🗺️ Roadmap de Innovación y Milestones

### 🏗️ Fase 1: The Metabolic Foundation (MVP) - `[███████████░░░] 70%`

*Enfoque: Estabilidad, Seguridad e Infraestructura.*

- ✅ **Infrastructure 1.0**: Despliegue atómico en **Coolify v4 (Beta)** con Registro Docker Privado (`registry.jljimenez.es`).
- ✅ **Security Core**: Cifrado simétrico AES-256 de PHI (Personal Health Information) y Auth JWT (HS256).
- ✅ **Metabolic Logic (TDD)**: Implementación del **Bolus Wizard**, cálculo de Carga Glucémica (CG) y Tests de Integración.
- 🔄 **Data Population**: Semillado de base de datos con índices glucémicos estándar.
- ⏳ **Mobile Bridge**: Inicialización del esqueleto Flutter (Dual UX).

### 🤖 Fase 2: AI Vision & Perception (Milestone)

- **OCR Menu Scanner**: Extracción de platos desde cartas de restaurantes con filtrado de seguridad glucémica.
- **Food Lens**: Estimación de macros y porciones mediante reconocimiento visual de imágenes.

### 🎬 Fase 3: AI Video Integration (Milestone)

- **Recipe-to-Data**: Pipeline de IA para transformar vídeos de cocina (Reels/TikTok) en recetas estructuradas con cálculo de CG automático.

---

## 🏗️ Arquitectura y Metodología de Desarrollo

El proyecto sigue una **Arquitectura Hexagonal (Clean Architecture)**, asegurando que la lógica nutricional sea independiente de la base de datos o el framework web.

### 🔄 Flujo de Trabajo Senior (GitFlow)

Cada funcionalidad se desarrolla en aislamiento:

1. `feature/XXX` -> 2. Atomic Commits -> 3. PR Review -> 4. Automated Tests -> 5. Merge -> 6. Auto-Deploy.

### 🔌 Catálogo de Endpoints (v1.0)

| Método | Ruta | Descripción | Estado |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/login` | Intercambio de credenciales por Token JWT | ✅ |
| `POST` | `/users/register` | Registro de usuario y perfil médico cifrado | ✅ |
| `POST` | `/nutrition/calc` | Cálculo de Bolus e Insulina (Wizard) | ✅ |
| `GET` | `/health` | Heartbeat del sistema y la base de datos | ✅ |

---

## 🛡️ Stack Tecnológico de Élite

- **Backend**: Python 3.12 + FastAPI (Asíncrono y optimizado para IA).
- **Data**: PostgreSQL 16 + Alembic (Gestión de migraciones de grado de producción).
- **Seguridad**: Fernet (Cifrado de datos de salud) + Bcrypt (Hashing).
- **Infra**: Docker + Coolify v4 + Cloudflare (Proxy SSL Full Strict).

---

## 📖 Glosario Metabólico (Reference)

- **IG (Índice Glucémico)**: Velocidad con la que un alimento aumenta la glucosa.
- **CG (Carga Glucémica)**: Impacto real basado en el IG y la cantidad de carbohidratos netos.
- **ICR (Carb Ratio)**: Gramos de carbohidratos cubiertos por 1 unidad de insulina.
- **ISF (Sensitivity Factor)**: Cuánto baja la glucosa 1 unidad de insulina.

---
*DiaBeaty TFM - Ingeniería y Arquitectura de Software con IA*
