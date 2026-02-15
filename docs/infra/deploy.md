# 🚀 Despliegue en Coolify

Este documento detalla el proceso de despliegue continuo (CI/CD) de la plataforma **DiaBeaty**, utilizando Coolify v4 y Docker Compose.

## 🔄 Flujo de Trabajo (Workflow)

El despliegue está **automatizado** mediante un webhook de GitHub -> Coolify. Sin embargo, debido a la arquitectura híbrida (Python + Flutter Web), el proceso requiere un paso de construcción local para el Frontend.

1. **Frontend Build (Local):** El desarrollador compila la aplicación Flutter Web localmente.
2. **Commit & Push:** Los artefactos compilados (`build/web`) se suben al repositorio.
3. **Coolify Trigger:** Coolify detecta el push en la rama `main`.
4. **Backend Build (Cloud):** Coolify construye el contenedor de Python/FastAPI.
5. **Frontend Build (Cloud):** Coolify construye el contenedor Nginx y copia los artefactos estáticos pre-subidos.
6. **Deploy:** Se levantan ambos servicios y se ejecutan las migraciones de base de datos.

## 🛠️ Guía Paso a Paso

### 1. Preparar una Nueva Versión (Frontend)

Gracias a Docker Multi-stage, **ya no necesitas compilar manualmente**. El servidor lo hará por ti.

1. Asegúrate de que `frontend/pubspec.yaml` tiene la versión correcta.
2. Verifica que tu código funciona localmente con `docker-compose up`.

### 2. Subir Cambios (Git)

Simplemente haz push a `main`.

```bash
git add .
git commit -m "feat: Nueva funcionalidad"
git push origin main
```

**Nota Importante:** La carpeta `build/` debe estar en `.gitignore`. Ya no subimos binarios al repositorio.

### 3. Orquestación (Docker Compose)

El archivo `docker-compose.yml` en la raíz define la infraestructura:

* **`api`**: Construye desde `./backend/Dockerfile`. Ejecuta migraciones al inicio.
* **`frontend`**: Construye desde `./frontend/Dockerfile` (Multi-stage).
  * *Stage 1:* Descarga Flutter y compila el proyecto.
  * *Stage 2:* Genera una imagen limpia con Nginx Alpine y los estáticos.
* **`db`**: PostgreSQL 16.

### 4. Variables de Entorno (Coolify)

En el proyecto de Coolify, asegúrate de tener definidos los secretos:

* `DATABASE_URL`: `postgresql+psycopg2://...`
* `SECRET_KEY`: Clave AES-256 para cifrado.
* `POSTGRES_USER` / `POSTGRES_PASSWORD`: Credenciales DB.
* `API_BASE_URL`: Url pública del backend (ej: `https://diabetics-api.jljimenez.es`).

## 🛡️ Seguridad en el Despliegue

* **Nginx Hardening**: El frontend incluye `nginx.conf` con headers de seguridad (`Content-Security-Policy`, `X-Frame-Options: DENY`) para evitar ataques XSS y Clickjacking.
* **SSL Automático**: Coolify/Traefik gestiona los certificados Let's Encrypt automáticamente.

## 🐛 Troubleshooting

**El Frontend da 404 al recargar:**

* Verifica que `nginx.conf` tiene la regla `try_files $uri $uri/ /index.html;`.

**Error de conexión en Frontend:**

* Revisa la consola del navegador (F12). Si hay errores de CSP, ajusta `nginx.conf`.
* Verifica que `API_BASE_URL` apunta correctamente a HTTPS.

**Base de datos vacía tras deploy:**

* Recuerda ejecutar el seed script manualmente si es una instalación limpia:
    `python backend/scripts/remote_seed_v2.py`
