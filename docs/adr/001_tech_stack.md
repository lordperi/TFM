# ADR-001: Selección de Stack Tecnológico (Backend)

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect, AI Lead |

## Contexto

El proyecto "Diabetics Platform" requiere un backend capaz de gestionar datos en tiempo real, exponer APIs RESTful seguras y, crucialmente, integrarse nativamente con módulos de Inteligencia Artificial (predicción de glucosa, cálculo de bolus). Se evaluaron opciones como Node.js (NestJS), Go y Python (Django/FastAPI).

## Decisión

Se ha decidido utilizar **Python 3.12** con el framework **FastAPI**.

### Justificación

1. **Ecosistema IA**: Python es el estándar de facto para Data Science y ML. Usar el mismo lenguaje para el backend y los modelos predictivos elimina la fricción de integración (no hace falta microservicios separados por lenguaje).
2. **Rendimiento Asíncrono**: FastAPI se basa en Starlette y Pydantic, ofreciendo un rendimiento comparable a Node.js y Go gracias a `asyncio`.
3. **Tipado Estricto**: Python 3.12 introduce mejoras significativas en el sistema de tipos, lo que junto con Pydantic v2 garantiza una validación de datos robusta en tiempo de ejecución.

## Consecuencias

* **Positivas**: Facilidad para iterar modelos de IA, documentación automática (OpenAPI/Swagger), validación de datos declarativa.
* **Negativas**: Menor rendimiento bruto en tareas puramente de CPU comparado con Go/Rust (mitigable con C-extensions en librerías críticas).
