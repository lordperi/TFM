# Guía de Configuración: Despliegue en Coolify con Docker Compose

Esta documentación explica paso a paso cómo desplegar la plataforma **Diabetics** en Coolify usando el archivo de orquestación situado en `/infra`.

## 1. Configuración del Servicio

1. En tu panel de Coolify, crea un nuevo **Service** -> **Docker Compose**.
2. Vincula tu repositorio privado de GitHub/GitLab.
3. Configura los siguientes campos:
   - **Base Directory**: `/`
   - **Docker Compose Location**: `/infra/docker-compose.yml`

## 2. Variables de Entorno (Secrets)

En la sección **"Environment Variables"** de Coolify, añade las siguientes claves. **NO** subas el archivo `.env` al repositorio.

| Clave | Valor Recomendado | Descripción |
| :--- | :--- | :--- |
| `POSTGRES_USER` | `diabetics_admin` | Usuario maestro de la DB |
| `POSTGRES_PASSWORD` | *(Generar contraseña fuerte)* | Contraseña maestra de la DB |
| `POSTGRES_DB` | `diabeticsplatform` | Nombre de la base de datos |
| `SECRET_KEY` | `openssl rand -hex 32` | Llave para cifrar tokens JWT |
| `ALLOWED_HOSTS` | `api.tudominio.com` | Hostname donde se servirá la API |
| `CORS_ORIGINS` | `https://app.tudominio.com` | URL del frontend (para evitar bloqueos CORS) |
| `DOCKER_IMAGE_BACKEND`| `ghcr.io/usuario/repo` | (Opcional) Si usas registro privado |

## 3. Configuración de Dominios (Cloudflare)

1. En Cloudflare, crea un registro `A` apuntando al **IP de tu VPS** (con la nube naranja activada para proxy).
2. En Coolify, dentro de la configuración del servicio `api`:
   - **FQDN**: `https://api.tudominio.com`
   - Coolify gestionará automáticamente el certificado SSL y el proxy inverso (Traefik).

## 4. Configuración del Registro Privado (Opcional - Zero Downtime)

Si tienes el registro configurado en Coolify (Settings -> Registries):

1. En la configuración del Servicio (Compose):
   - Activa la opción **"Push to Registry"**.
   - Selecciona tu registro (ej. GitHub CR o DockerHub).
2. Esto hará que Coolify construya la imagen, la suba a tu registro, y luego descargue la nueva versión para desplegar.
   - **Beneficio**: Si el despliegue falla, puedes hacer "Rollback" a la imagen anterior instantáneamente.

## 5. Verificación

Una vez desplegado (`Deploy`), verifica:

- Logs del contenedor `api`: "Application startup complete".
- Endpoint de salud: `https://api.tudominio.com/health` $\rightarrow$ `{"status": "healthy"}`.
