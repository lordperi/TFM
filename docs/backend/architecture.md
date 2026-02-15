# Arquitectura Backend y Guía de Desarrollo

## Patrón Arquitectónico

El backend de la **Plataforma DiaBeaty** sigue un diseño de **Clean Architecture** (también conocida como Hexagonal o Puertos y Adaptadores). Esto asegura que la lógica de negocio sea independiente de frameworks, bases de datos y agencias externas.

### Estructura de Capas (`backend/src`)

1. **Domain (`/domain`)**:
    * **Responsabilidad**: La lógica central y las reglas de negocio.
    * **Contenido**: Entidades, Objetos de Valor, Servicios de Dominio.
    * **Dependencias**: Cero. Esta capa no depende de nada.

2. **Application (`/application`)**:
    * **Responsabilidad**: Orquestación de objetos de dominio para cumplir los casos de uso.
    * **Contenido**: Casos de Uso, DTOs (Data Transfer Objects), Interfaces (Puertos) para repositorios.
    * **Dependencias**: Depende solo del Dominio.

3. **Infrastructure (`/infrastructure`)**:
    * **Responsabilidad**: Implementación de detalles técnicos.
    * **Contenido**: Repositorios de Base de Datos (SQLAlchemy), Framework Web (Routers FastAPI), Adaptadores de API Externas.
    * **Dependencias**: Depende de Application y Domain.

## Seguridad (DevSecOps)

* La aplicación está contenedorizada usando un **Dockerfile** multi-etapa que se ejecuta como usuario no root.
* **FastAPI** incluye `TrustedHostMiddleware` y `CORSMiddleware` estricto.
* La base de datos se ejecuta en una red aislada en `docker-compose`.

## Testing (QA)

### Prerrequisitos

* Python 3.12+
* PostgreSQL (o Docker para la DB de pruebas)

### Ejecutar Tests

Usamos **pytest** para las pruebas.

1. **Configurar el entorno**:

    ```bash
    cd backend
    pip install -r requirements.txt
    ```

2. **Ejecutar Pruebas**:

    ```bash
    # Ejecutar todos los tests
    pytest tests/

    # Ejecutar con salida detallada
    pytest -v tests/
    ```

### Configuración de Tests

La configuración de pruebas se encuentra en `backend/tests/conftest.py`. Está configurada para usar una **sesión de base de datos efímera** para las pruebas de integración, asegurando que cada prueba se ejecute con un estado limpio (patrón de reversión de transacciones).
