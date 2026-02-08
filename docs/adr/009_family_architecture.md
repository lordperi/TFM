# ADR-009: Arquitectura Familiar y de Cuidadores

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-04 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect |

## Contexto

La arquitectura inicial de DiaBeaty asumía una relación 1:1 entre un `Usuario` (Identidad) y un `Perfil de Salud` (Datos Médicos).
Sin embargo, para el caso de uso del TFM centrado en familias, el sistema debe soportar:

- **Guardianes (Tutores)**: Padres que gestionan la cuenta pero no necesariamente tienen diabetes (o tienen su propio perfil).
- **Dependientes (Hijos)**: Usuarios que necesitan seguimiento de datos pero no deberían gestionar credenciales de cuenta o configuraciones críticas inicialmente.
- **Experiencia de Usuario Dual (Dual UX)**: La interfaz debe adaptarse según *quién* está usando el dispositivo (Adulto vs Niño).

## Decisión

Cambiamos a un modelo relacional **Guardián-Paciente**.

### 1. Identidad Unificada, Múltiples Perfiles (El Modelo "Netflix")

- Una única cuenta de `Usuario` (Guardián) puede poseer múltiples perfiles de `Paciente`.
- **Inicio de Sesión**: Autentica al `Usuario`.
- **Selección de Perfil**: Tras el login, el usuario selecciona qué contexto de `Paciente` activar.

### 2. Cambios en el Esquema de Base de Datos

- **Separación**: `HealthProfile` se desacopla de `User`.
- **Nueva Entidad**: `PatientModel` (`id`, `guardian_id`, `display_name`, `theme_preference` - nombre, fecha de nacimiento, preferencia de tema).
- **Migración**: Los `Usuarios` existentes se convierten en Guardianes de un perfil de Paciente "Self" (Propio).

### 3. Vinculación de Dispositivos (Acceso Infantil)

- Para permitir que los niños accedan a la app sin credenciales completas, implementamos un flujo de **Vinculación de Dispositivos**.
- El Guardián genera un código; el dispositivo del Niño se autentica usando este código para enlazarse permanentemente a un `PatientProfile` específico.

## Consecuencias

### Positivas

- **Flexibilidad**: Soporta adultos solteros, padres con un hijo, o padres con múltiples hijos diabéticos.
- **Seguridad**: Control granular. Un dispositivo de niño puede tener permisos diferentes a los de un padre.
- **UX**: Permite cambio de tema automático (Gamificado vs Dashboard) basado en el perfil seleccionado.

### Negativas

- **Complejidad**: Todas las restricciones de Nutrición ahora deben verificar `patient_id` además de `user_id`.
- **Migración**: Requiere migrar datos existentes al nuevo esquema (Manejado en Migración 003).

## Cumplimiento (TFM)

Esta arquitectura satisface los requisitos de "Control Parental" y "Adaptabilidad" de la Tesis de Máster.
