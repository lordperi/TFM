# 🧬 DiaBeaty: Intelligent Nutrition for the 21st Century

> **The Digital Pancreas.**
> *Precision health platform redefining how Diabetics interact with food through Artificial Intelligence and Dual-UX Design.*

![Status](https://img.shields.io/badge/Status-MVP_Production_Ready-success?style=for-the-badge)
![AI-Ready](https://img.shields.io/badge/AI-Vision_Ready-purple?style=for-the-badge)
![Privacy](https://img.shields.io/badge/Privacy-AES_256_Encrypted-red?style=for-the-badge&logo=lock)

---

## 🚀 Concepto: Más allá del registro de glucosa

**DiaBeaty** no es otra app de registro. Es un asistente inteligente que empodera al paciente.

- **Para el Adulto**: Un nutricionista de bolsillo que calcula ratios de insulina (ICR) y sensibilidad (ISF) con precisión matemática.
- **Para el Niño**: Un videojuego donde "alimentar al avatar" significa cuidarse a uno mismo. (Gamificación Terapéutica).

---

## 🗺️ Roadmap de Innovación (TFM & Beyond)

Diseñado modularmente para evolucionar desde una base sólida hasta un ecosistema de IA completo.

### 🏛️ Fase 1: The Foundation (Semanas 1-3) - *Current Status*
>
> **"Construir el búnker antes del rascacielos."**
En esta fase nos centramos en la infraestructura crítica, seguridad y modelado de datos metabólicos.

- ✅ **Clean Architecture (Hexagonal)**: Núcleo desacoplado de frameworks.
- ✅ **Zero-Trust Security**: Cifrado de datos médicos (Application-Level Encryption).
- ✅ **Auth & Profiles**: Gestión de usuarios y perfiles de salud complejos (Pydantic v2).
- 🔄 **Motor Nutricional**: Cálculo de Carga Glucémica y sugerencia de Bolus (En progreso).

### 👁️ Fase 2: AI Vision (Milestone Post-MVP)
>
> **"La cámara es el nuevo teclado."**

- 🤖 **Menu OCR**: Escanea la carta de un restaurante y DiaBeaty te dirá qué plato es seguro y cuánta insulina necesitas.
- 📸 **Food Lens**: Análisis de macro-nutrientes mediante reconocimiento de imágenes de platos reales.

### 🎥 Fase 3: AI Video (Milestone)
>
> **"De TikTok a tu Mesa."**

- 🎬 **Recipe Extraction**: Un pipeline de IA que procesa vídeos cortos de cocina (RRSS) y extrae: Ingredientes, Pasos Estructurados y, lo más importante, **Información Nutricional para Diabéticos**.

### 🌐 Fase 4: Smart Ecosystem (Milestone)
>
> **"Internet of Healthy Things."**

- 📶 **IoT Integration**: Conexión directa con sensores CGM (Dexcom/Abbott).
- 🛒 **Smart Shopping**: Integración con APIs de supermercados para autocompletar la compra semanal.

---

## 🛠️ Stack Tecnológico de Élite

| Área | Tecnología | Justificación (ADR) |
| :--- | :--- | :--- |
| **Backend** | **Python 3.12 + FastAPI** | Ecosistema nativo para IA y rendimiento asíncrono. |
| **Frontend** | **Flutter 3.19** | Código único para iOS/Android y capacidad gráfica para gamificación (Skia). |
| **Data** | **PostgreSQL 16 + Alembic** | Integridad relacional y migraciones robustas. |
| **Infra** | **Coolify v4 + Docker** | Soberanía de datos y orquestación privada. |
| **Security** | **Fernet Encryption** | Protección de PHI contra accesos administrativos. |

---

## ⚙️ Despliegue (Coolify v4)

Esta infraestructura está optimizada para **Zero-Config Deployment** en Coolify.

1. **Configurar Servicio**: Crear un recurso `Docker Compose`.
2. **Repo Link**: Vincular este repositorio.
3. **Variables**: Inyectar `POSTGRES_USER`, `POSTGRES_PASSWORD`, `SECRET_KEY`, `ENCRYPTION_KEY`, y `DOCKER_IMAGE` (ej: `registry.jljimenez.es/user/backend:v1`).
4. **Registro Privado**:
    - Activar "Push to Registry" en Coolify.
    - El orquestador construirá la imagen usando el contexto raíz y la subirá a tu registro privado automáticamente antes de desplegar.

---

## 🛡️ Quality Gates & Compliance

- **Testing**: Cobertura > 80% requerida. Tests de integración corren sobre SQLite in-memory.
- **GDPR**: Cumplimiento por diseño (Privacy by Design). Servidores en territorio UE (si el VPS lo está).

---
*Máster de Desarrollo con Inteligencia Artificial - 2026*
