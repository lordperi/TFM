# ADR-004: Estrategia de Testing (TDD)

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Aceptado |
| **Decisores** | QA Engineer, DevSecOps |

## Contexto

En software médico, un error en el cálculo de una dosis de insulina o en el registro de un nivel de glucosa puede tener consecuencias fatales. La metodología de "probar al final" (Waterfall) es inaceptable.

## Decisión

Adoptar **Test-Driven Development (TDD)** estricto y un pipeline de CI que bloquee cualquier commit sin tests.

* Framework: **Pytest**.
* Base de Datos de Test: **SQLite In-Memory** (emulando PostgreSQL con configuraciones de `StaticPool`).

### Justificación

1. **Fiabilidad**: TDD obliga a pensar en los casos borde antes de escribir el código.
2. **Velocidad**: Usar SQLite en memoria permite ejecutar cientos de tests de integración en segundos, fomentando la ejecución local continua.

## Consecuencias

* **Positivas**: Reducción de bugs regresivos, documentación viva del comportamiento del sistema.
* **Negativas**: Velocidad de desarrollo inicial más lenta (escribir el doble de código). Posibles discrepancias sutiles entre SQLite (Tests) y Postgres (Prod), aunque mitigadas usando ORM estándar.
