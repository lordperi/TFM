# ADR 011: Diseño e Integración del Motor Nutricional y Protección PHI

## Contexto

El cálculo del Bolus de insulina es el núcleo crítico de cualquier aplicación de gestión de Diabetes. DiaBeaty requiere un módulo de Nutrición capaz de buscar alimentos, registrar ingestas asociadas a cargas glucémicas (CG) y sugerir dosis (Bolus) usando las consideraciones del paciente (ICR, ISF). Estas ingestas pueden venir acompañadas de notas clínicas de los pacientes.

## Decisión

1. **Clean Architecture Strict:** Implementado el `NutritionRepository` para aislar el acceso a la base de datos de los casos de uso principales.
2. **Cifrado Transparente en DB:** Las notas asociadas a las comidas (posibles sentencias PHI como "hipoglucemia postprandial") siguen el protocolo de seguridad establecido usando el Custom Type `EncryptedString` de SQLAlchemy, que emplea AES-256 simétrico de forma transparente en la capa ORM.
3. **Casos de Uso Aislados:** Todo el proceso algorítmico se encapsula en funciones de Application layer (`execute_calculate_bolus`, `execute_log_meal`). El Router de FastAPI solo tramita peticiones y llama los Casos de Uso.
4. **TDD Core API:** Todas las rutas fueron construidas pasando la fase Red-Green-Refactor mediante *httpx* test client asíncrono sobre la instancia de prueba en SQLite in-memory.

## Consecuencias

- **Positivas:** Seguridad por defecto en notas de pacientes. El algoritmo es totalmente agnóstico al framework web, haciéndolo extensible para futuros triggers IoT (por ejemplo, CGM auto-log).
- **Limitaciones Activas:** El cálculo de Bolus actual requiere que el ICR y el ISF se pasen en el Request Body (API V1) para simplificar pruebas. En producción (V2), deberán derivarse desde la sesión JWT -> vinculada al Perfil de Salud. Este "debt" está documentado para resolver en la integración del Frontend.
