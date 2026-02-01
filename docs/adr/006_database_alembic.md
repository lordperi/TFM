# ADR-006: Base de Datos Relacional y Migraciones

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect |

## Contexto

Los datos médicos son inherentemente relacionales (Usuario -> Perfil -> Métricas -> Tratamientos) y requieren integridad referencial estricta (no perder 'huérfanos'). Se necesita un sistema que garantice consistencia ACID y evolucione el esquema ordenadamente.

## Decisión

1. **Motor**: **PostgreSQL 16**.
2. **Migraciones**: **Alembic**.

### Justificación

* **PostgreSQL**: Base de datos opensource más avanzada, con soporte nativo robusto para JSON para metadatos flexibles y tipos geométricos/temporales potentes.
* **Alembic**: La "fuente de la verdad" del esquema. Permite el versionado del DDL (Data Definition Language) de la base de datos junto con el código fuente.

## Consecuencias

* **Positivas**: Integridad de datos garantizada. Deployments predecibles (no fallan por columnas faltantes).
* **Negativas**: Requiere disciplina de desarrollo: nunca modificar la DB manualmente, siempre crear un script de migración.
