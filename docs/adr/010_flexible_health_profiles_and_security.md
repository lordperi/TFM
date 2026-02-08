# ADR-010: Perfiles de Salud Flexibles y Seguridad

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-08 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect, Security Lead |

## Contexto

El modelo de datos inicial asumía que cada usuario era un paciente con Diabetes Tipo 1, requiriendo datos médicos estrictos (ratios de insulina, modo de terapia) en el momento de creación. Sin embargo, la aplicación necesita soportar:

1. **Guardianes (Adultos)**: Usuarios que gestionan la cuenta pero no tienen diabetes, por lo que no necesitan proporcionar datos de salud.
2. **Dependientes (Niños)**: Usuarios que tienen diabetes pero no deben tener permiso para modificar sus propios ajustes médicos o rol sin supervisión.

Necesitábamos una forma de:

- Permitir la creación de perfiles de "Guardián" sin métricas de salud obligatorias.
- Permitir que los perfiles de "Niño" personalicen su experiencia (Avatar/Tema) sin exponerlos a cambios accidentales o intencionados en su configuración médica.
- Asegurar el backend para prevenir actualizaciones no autorizadas de datos críticos de salud, incluso si los controles del frontend fueran eludidos.

## Decisión

Decidimos implementar un **Sistema de Perfiles Flexibles con Seguridad Escalonada**:

### 1. Esquema de Base de Datos

- Modificamos `PatientModel` para hacer que los campos relacionados con la salud (`diabetes_type`, `therapy_mode`, `insulin_sensitivity`, `carb_ratio`, `target_glucose`) sean **anulables (nullable)**.
- Esto permite crear perfiles de Guardián con solo `display_name`, `role`, y `pin`.

### 2. Seguridad en el Backend

- Implementamos **Actualizaciones Protegidas por PIN** para campos sensibles.
- Cuando se llama a `update_patient_profile`:
  - Si la actualización afecta a campos sensibles (`role`, `medical_data`), el cuerpo de la petición **DEBE** incluir el `pin` correcto.
  - Si la actualización afecta solo a campos no sensibles (`theme_preference`, `display_name`), el `pin` es **OPCIONAL**.
- Esto asegura que un niño (que podría tener acceso al dispositivo) no pueda lanzar peticiones de API para cambiar su configuración terapéutica sin una autorización válida.

### 3. Experiencia de Usuario en Frontend (Restricciones Dual UX)

- **Guardianes**: Deben introducir su PIN para acceder a la pantalla de "Editar Perfil" (Puerta de Autenticación).
- **Dependientes**:
  - Pueden acceder a "Editar Perfil" **sin PIN** para fomentar el uso (cambiar avatares/temas).
  - **Campos Sensibles BLOQUEADOS**: Nombre, Rol y Ajustes Médicos aparecen visualmente deshabilitados.
  - **Mecanismo de Desbloqueo**: Un botón específico de "Desbloquear" permite a un Guardián introducir su PIN *dentro* de la sesión del niño para habilitar temporalmente la edición de campos sensibles.

## Consecuencias

### Positivas

- **Flexibilidad**: Soporta diversas estructuras familiares (padres no diabéticos, múltiples hijos).
- **Seguridad**: Los datos médicos críticos están protegidos por un segundo factor (PIN) a nivel de API.
- **Usabilidad**: Los niños pueden interactuar con las funciones de gamificación de la app (temas) sin fricción, manteniendo la seguridad.

### Negativas

- **Complejidad**: La lógica del frontend para "Editar Perfil" es ahora más compleja (estados de Bloqueo/Desbloqueo, prompts de PIN condicionales).
- **Carga de la API**: El endpoint `update` ahora requiere condicionalmente un campo `pin`, lo que debe ser manejado cuidadosamente por los clientes para evitar errores 401.
