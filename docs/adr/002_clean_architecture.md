# ADR-002: Implementación de Clean Architecture

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect |

## Contexto

Las aplicaciones construidas con frameworks como Django o FastAPI a menudo acoplan la lógica de negocio a los controladores HTTP o al ORM DB, dificultando el mantenimiento y las pruebas unitarias a largo plazo. Necesitamos una arquitectura que permita cambiar la base de datos o el framework web sin reescribir las reglas de negocio (ej. cálculos de insulina).

## Decisión

Implementar **Clean Architecture** (también conocida como Hexagonal/Ports & Adapters), dividiendo el código en capas concéntricas:

1. **Domain**: Entidades y reglas de negocio puras (sin dependencias).
2. **Application**: Casos de uso y orquestación.
3. **Infrastructure**: Implementaciones técnicas (DB, API, Auth).

## Consecuencias

* **Positivas**:
  * **Testabilidad Total**: La lógica de negocio se puede probar sin levantar la base de datos ni el servidor web.
  * **Independencia**: El dominio no "conoce" a FastAPI ni a SQLALchemy.
* **Negativas**:
  * **Boilerplate**: Requiere duplicar modelos (DTOs vs ORM vs Domain Entities) y escribir mapeadores.
  * **Curva de Aprendizaje**: Mayor complejidad inicial para desarrolladores junior.
