# Arquitectura de Despliegue y Flujo de Datos

## Infraestructura (Coolify & Docker)

### Flujo de CI/CD (Registro Privado)

Este proyecto está diseñado para funcionar con un registro de contenedores privado (`registry.jljimenez.es`).

1. **Build**: El código se construye (idealmente en GitHub Actions o localmente).
2. **Push**: La imagen Docker resultante se sube a `registry.jljimenez.es/usuario/diabetics-backend:tag`.
3. **Deploy (Coolify)**:
    * Coolify detecta el cambio (vía Webhook) o se dispara manualmente.
    * Lee la variable `DOCKER_IMAGE` (ej. `registry.jljimenez.es/...`).
    * Hace `docker pull` de la nueva imagen dentro del VPS.
    * Reinicia el servicio `api` sin tiempo de inactividad (Zero Downtime), esperando a que el Healthcheck `/health` responda OK antes de cambiar el tráfico.

### Mantenibilidad y Migraciones

* **Alembic**: Gestiona el esquema de la base de datos.
  * `alembic upgrade head`: Se ejecuta automáticamente al iniciar el contenedor (ver `backend/entrypoint.sh`).
  * Modelos definidos en `src/infrastructure/db/models.py`.

### Seguridad

* **Autenticación**: JWT (JSON Web Tokens) con expiración corta (30 min).
* **Cifrado**: Datos sensibles (sensibilidad insulínica, ratios) cifrados en reposo (Fernet) y en tránsito (TLS).

### Aislamiento de Red

El servicio utiliza dos redes:

* `coolify_network` (Externa): Permite que el Proxy Inverso (Traefik) envíe tráfico HTTP a la API.
* `internal_db_network` (Interna): Permite que la API hable con PostgreSQL. **PostgreSQL NO es accesible desde Internet ni desde `coolify_network`**.

## Dominio: Usuario y Salud

El núcleo de la aplicación se basa en dos entidades:

1. **User**: Credenciales e identidad.
2. **HealthProfile**: Datos metabólicos críticos para el cálculo de insulina.
    * *Insulin Sensitivity*: Cuánto baja la glucosa 1 unidad de insulina.
    * *Carb Ratio*: Cuántos gramos de carbohidratos cubre 1 unidad.
    * **Validación Estricta**: Usamos Pydantic para rechazar valores biológicamente imposibles (ej. sensibilidades negativas), protegiendo la integridad de los datos médicos desde la entrada.
