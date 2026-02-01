# ADR-003: Selección de Framework Frontend (Flutter)

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Aceptado |
| **Decisores** | UX Lead, Lead Architect |

## Contexto

La plataforma requiere aplicaciones móviles para pacientes (Android/iOS) con una particularidad: **Dual UX**. La interfaz debe adaptarse dinámicamente si el usuario es un adulto (datos técnicos, gráficos) o un niño (gamificación, avatares). Mantener dos bases de código nativas (Swift/Kotlin) es inviable para el tamaño del equipo.

## Decisión

Utilizar **Flutter** (Dart).

### Justificación

1. **Código Único**: Despliegue en iOS, Android y Web desde un solo repositorio.
2. **UI Flexibilidad**: El motor de renderizado Skia permite crear interfaces altamente personalizadas y animadas ("gamificadas") sin dolor.
3. **Rendimiento**: Compilación AOT a código nativo ARM, esencial para una app que monitoriza salud en segundo plano.

## Consecuencias

* **Positivas**: Reducción drástica del tiempo de desarrollo, consistencia visual absoluta entre plataformas.
* **Negativas**: Tamaño de la aplicación (IPA/APK) ligeramente mayor que nativo. Dependencia del ecosistema de plugins de Dart.
