# ADR-007: Infraestructura de Despliegue y Registro Privado

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Implementado |
| **Decisores** | Lead Architect, DevSecOps |

## Contexto

El proyecto, al ser un TFM con potencial de evolucionar a producto médico real, requiere una infraestructura que sea:

1. **Privada**: El código y, sobre todo, los modelos de IA entrenados son propiedad intelectual que no debe residir en repositorios públicos por defecto.
2. **Soberana**: Control estricto sobre dónde se ejecutan los datos para facilitar cumplimiento GDPR local.
3. **Coste-Efectiva**: Kubernetes (K8s) es excesivo y caro para la fase actual.
4. **Automatizada**: Se requiere CI/CD sin la complejidad de Jenkins o la dependencia de GitHub Actions Runners de pago.

## Decisión

Implementar un stack de infraestructura autogestionada compuesto por:

1. **Orquestador**: **Coolify** (instancia auto-alojada en VPS).
2. **Registro de Contenedores**: **Docker Registry V2** privado (`registry.jljimenez.es`).
3. **Red de Edge / WAF**: **Cloudflare** (Modo Proxy).

### Arquitectura de Solución

* El código fuente se versiona en Git.
* Coolify monitoriza los cambios y dispara un *build* utilizando el Dockerfile multi-stage.
* La imagen construida se sube (*push*) al registro privado interno `registry.jljimenez.es` para versionado y rollback.
* El servicio de producción hace *pull* desde este registro y se reinicia usando *Zero Downtime Deployment*.

## Consecuencias

### Positivas

* **Seguridad de la Cadena de Suministro**: Las imágenes Docker, que pueden llegar a contener lógica sensible de IA o configuraciones base, nunca salen de la infraestructura controlada.
* **Agilidad DevOps**: Despliegues automáticos (Push-to-Deploy) en cuestión de minutos sin configurar pipelines YAML complejos en proveedores externos.
* **Independencia**: No hay "Vendor Lock-in" con AWS/Azure/GCP. Toda la plataforma es portable a cualquier servidor Linux con Docker.

### Negativas

* **Carga Operativa**: El equipo es responsable del mantenimiento del VPS (parches de seguridad OS, actualizaciones de Docker).
* **Gestión de Backups**: A diferencia de RDS o Cloud SQL, la responsabilidad de realizar copias de seguridad de la base de datos PostgreSQL (volumen persistente) recae enteramente en nosotros.
* **Punto Único de Fallo (SPOF)**: Si el VPS (o Coolify) cae, el pipeline de despliegue y el registro se detienen. (Aceptable para el alcance de TFM).
