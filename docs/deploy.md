# Deploying to Coolify

This guide explains how to deploy the **Diabetics Platform** using Coolify, leveraging a private Docker Registry (or building directly from source).

## Prerequisites

1. **VPS** with Coolify installed.
2. **Private Registry** credentials configured in Coolify (Settings -> Registries).
3. **Domain** configured in Cloudflare (DNS pointing to VPS).

## Deployment Steps

### 1. Repository Setup

Connect this repository to your Coolify instance.

### 2. Configuration (Environment Variables)

In the Coolify project settings, copy the contents of `.env.example` into the **"Secrets"** or **"Environment Variables"** section.

* **Generate Strong Secrets**: Use `openssl rand -hex 32` for `SECRET_KEY`.
* **Database Config**: Ensure `POSTGRES_USER` and `POSTGRES_PASSWORD` match your desired production credentials.

### 3. Service Configuration (Docker Compose)

We use the `docker-compose.yml` located in `/infra`.

1. **Build Pack**: Select **Docker Compose**.
2. **Base Directory**: Set to `/` (Root).
3. **Docker Compose Location**: Set to `/infra/docker-compose.yml`.
4. **Domains**: Set the domain for the `api` service (e.g., `https://api.diabetics-platform.com`).

### 4. Health Checks

The Compose file includes built-in `healthcheck` definitions.

* **API**: Checks `GET /health` to ensure FastAPI is accepting requests.
* **DB**: Checks `pg_isready` to ensure the database is accepting connections.
* **Result**: Coolify will only route traffic to the container once these checks pass ("Healthy").

### 5. Private Docker Registry (Optional Strategy)

If you prefer building the image externally (e.g., GitHub Actions) and just pulling it in Coolify:

1. Build and push the image:

    ```bash
    docker build -t ghcr.io/user/backend:latext ./backend
    docker push ghcr.io/user/backend:latest
    ```

2. In Coolify Service, set the variable `DOCKER_REGISTRY` to `ghcr.io/user` and `IMAGE_TAG` to `latest`.
3. Coolify will pull this image instead of building from source if specifically configured to strictly follow the compose file's `image` directive.

## Troubleshooting

* **"Container Unhealthy"**: Check the Application Logs. Usually means `DATABASE_URL` is incorrect or the DB is taking too long to start.
* **CORS Errors**: Verify `ALLOWED_HOSTS` and `CORS_ORIGINS` include your frontend domain.
