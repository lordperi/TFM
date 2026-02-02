# 8. Application Service Layer for Business Logic

Date: 2026-02-02

## Status

Accepted

## Context

Initially, the API Routers (Infrastructure Layer) were directly accessing the Database Models and performing business logic (e.g., Bolus Calculation, User Registration). This violated the **Clean Architecture** and **Single Responsibility** principles, creating tight coupling between the HTTP Framework (FastAPI) and the Domain Rules.

## Decision

We decided to introduce an explicitly defined **Application Layer** containing **Services** (`NutritionService`, `UserService`).

- **Routers** (`src/infrastructure/api/routers`): Only handle HTTP requests, input validation (Schemas), and response formatting. They delegate all logic to Services.
- **Services** (`src/application/services`): Orchestrate the flow of data. They retrieve entities from Repositories (or DB sessions for now), call Domain logic, and handle encryption/decryption orchestration.
- **Domain** (`src/domain`): Pure business logic and mathematical functions, with zero dependencies on the database or framework.

## Consequences

### Positive

- **Testability**: Services can be tested in isolation without spinning up an HTTP server.
- **Flexibility**: The underlying database or API framework can change without touching the business logic.
- **Clarity**: It is instantly obvious where the "rules" of the application live.

### Negative

- **Boilerplate**: Requires creating an extra class/file for simple CRUD operations.
- **Complexity**: New developers must understand the layering (Router -> Service -> Domain) instead of just writing code in one function.
