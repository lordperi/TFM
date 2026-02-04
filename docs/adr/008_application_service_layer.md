# ADR-008: Capa de Servicios de Aplicación para Lógica de Negocio

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-02 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect |

## Contexto

Inicialmente, los Routers de la API (Capa de Infraestructura) accedían directamente a los Modelos de Base de Datos y ejecutaban lógica de negocio (por ejemplo, Cálculo de Bolus, Registro de Usuario). Esto violaba los principios de **Clean Architecture** y **Responsabilidad Única**, creando un acoplamiento fuerte entre el Framework HTTP (FastAPI) y las Reglas de Dominio.

## Decisión

Se decidió introducir una **Capa de Aplicación** explícitamente definida que contenga **Servicios** (`NutritionService`, `UserService`).

- **Routers** (`src/infrastructure/api/routers`): Solo manejan peticiones HTTP, validación de entrada (Esquemas) y formateo de respuestas. Delegan toda la lógica a los Servicios.
- **Servicios** (`src/application/services`): Orquestan el flujo de datos. Recuperan entidades de Repositorios (o sesiones de DB por ahora), llaman a la lógica de Dominio y manejan la orquestación de cifrado/descifrado.
- **Dominio** (`src/domain`): Lógica de negocio pura y funciones matemáticas, sin dependencias de la base de datos o el framework.

## Consecuencias

### Positivas

- **Testabilidad**: Los servicios se pueden probar de forma aislada sin levantar un servidor HTTP.
- **Flexibilidad**: La base de datos subyacente o el framework de API pueden cambiar sin tocar la lógica de negocio.
- **Claridad**: Es instantáneamente obvio dónde viven las "reglas" de la aplicación.

### Negativas

- **Boilerplate**: Requiere crear una clase/archivo extra para operaciones CRUD simples.
- **Complejidad**: Los nuevos desarrolladores deben entender la estratificación (Router -> Servicio -> Dominio) en lugar de simplemente escribir código en una función.
