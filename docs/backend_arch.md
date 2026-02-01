# Backend Architecture & Developer Guide

## Architectural Pattern

The **Diabetics Platform** backend follows a **Clean Architecture** (also known as Hexagonal or Ports & Adapters) design. This ensures that the business logic is independent of frameworks, databases, and external agencies.

### Layer Structure (`backend/src`)

1. **Domain (`/domain`)**:
    * **Responsibility**: The core logic and rules of the business.
    * **Content**: Entities, Value Objects, Domain Services.
    * **Dependencies**: Zero. This layer depends on nothing.

2. **Application (`/application`)**:
    * **Responsibility**: Orchestration of domain objects to fulfill user cases.
    * **Content**: Use Cases, DTOs (Data Transfer Objects), Interfaces (Ports) for repositories.
    * **Dependencies**: Depends only on Domain.

3. **Infrastructure (`/infrastructure`)**:
    * **Responsibility**: Implementation of technical details.
    * **Content**: Database Repositories (SQLAlchemy), Web Framework (FastAPI Routers), External API Adapters.
    * **Dependencies**: Depends on Application and Domain.

## Security (DevSecOps)

* The application is containerized using a multi-stage **Dockerfile** running as a non-root user.
* **FastAPI** includes `TrustedHostMiddleware` and strict `CORSMiddleware`.
* Database runs in an isolated network in `docker-compose`.

## Testing (QA)

### Prerequisites

* Python 3.12+
* PostgreSQL (or Docker for the test DB)

### Running Tests

We use **pytest** for testing.

1. **Set up environment**:

    ```bash
    cd backend
    pip install -r requirements.txt
    ```

2. **Run Tests**:

    ```bash
    # Run all tests
    pytest tests/

    # Run with verbose output
    pytest -v tests/
    ```

### Test Configuration

The testing configuration is located in `backend/tests/conftest.py`. It is set up to use an **ephemeral database session** for integration tests, ensuring that each test runs with a clean state (transaction rollback pattern).
