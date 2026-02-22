# ADR-015: Integración del Sistema de XP en el Endpoint de Registro de Comidas

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-22 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect, Security Guardian |
| **Relacionado con** | ADR-014 (Modo Niño RPG), ADR-012 (Motor Nutricional), ADR-008 (Capa de Servicios) |
| **PR** | #27 `fix/card-vacia-y-xp-real-por-comidas` |

---

## Contexto

Una vez implementado el sistema de gamificación descrito en ADR-014, se detectó que el registro de comidas (`POST /api/v1/nutrition/meals`) **no otorgaba XP al paciente**. El flujo completo de registro funcionaba correctamente desde el punto de vista nutricional (cálculo de carbohidratos, carga glucémica, persistencia del log), pero la tabla `xp_transactions` permanecía vacía en la base de datos tras cualquier registro.

La causa raíz era doble:

1. **Omisión de implementación**: El endpoint `log_meal` en `nutrition.py` nunca invocaba `XPRepository.add_xp()`. La infraestructura del sistema de XP (modelo de dominio, repositorio, migración de BD) existía y funcionaba, pero ningún punto de entrada la utilizaba.

2. **Gestión silenciosa de errores**: El bloque `except` genérico en el endpoint nutricional utilizaba `pass`, lo que ocultaba completamente cualquier excepción, haciendo imposible detectar el problema en producción sin inspección manual del código fuente.

Adicionalmente, el endpoint `POST /meals` era de acceso público (sin autenticación JWT). Esto impedía identificar qué usuario había registrado la comida, condición necesaria para asociar el XP al usuario correcto.

---

## Decisión

### 1. Añadir autenticación JWT al endpoint `POST /meals`

El endpoint se modifica para requerir un token JWT válido:

```python
@router.post("/meals")
def log_meal(
    request: LogMealRequest,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
```

El `current_user_id` es extraído del token por la dependencia `get_current_user_id` (reutilizada de otros endpoints autenticados del sistema). Esto garantiza que el XP se asocie al usuario propietario del token y no al `patient_id` del payload (que es el paciente dependiente gestionado por ese usuario).

**Implicación en tests**: Los tests de integración existentes que llamaban a `POST /meals` sin cabeceras de autorización pasaron a fallar con `HTTP 401`. Se actualizaron con el helper `_get_auth_headers(client, user)` que realiza el login y devuelve la cabecera `Authorization: Bearer <token>`.

### 2. Invocar `XPRepository.add_xp()` tras el registro exitoso

```python
# Otorgar XP al usuario por registrar una comida
try:
    xp_repo = XPRepository(db)
    xp_repo.add_xp(
        user_id=UUID(current_user_id),
        amount=10,
        reason="meal_logged",
        description="Comida registrada",
    )
except Exception as e:
    logger.error("Error al otorgar XP por comida registrada: %s", e)
```

El bloque try/except **no relanza la excepción** de forma intencionada. El principio de diseño aquí es que el fallo del subsistema de gamificación no debe bloquear el flujo nutricional principal. Si `XPRepository` falla por cualquier motivo (base de datos no disponible, constraint violada, etc.), la comida queda registrada correctamente y el usuario no experimenta ningún error.

### 3. Sustituir `except: pass` por `logger.error(...)`

En todos los bloques de excepción del módulo `nutrition.py`, se sustituye el `pass` silencioso por llamadas explícitas a `logger.error(...)`. Esto permite que los errores queden registrados en los logs de la aplicación (visibles en Coolify) sin interrumpir el flujo del usuario.

```python
import logging
logger = logging.getLogger(__name__)
```

---

## Consecuencias

### Positivas

- **Sistema de XP funcional de extremo a extremo**: Los pacientes acumulan XP real al registrar comidas. El Dashboard niño y la pantalla de perfil muestran valores reales en lugar de ceros o datos hardcodeados.

- **Seguridad mejorada**: El endpoint `POST /meals` ahora requiere autenticación, consistente con el resto de endpoints de escritura del sistema. Esto previene el registro de comidas por actores no autenticados.

- **Observabilidad**: Los errores en el subsistema de XP son ahora visibles en los logs de producción, facilitando el diagnóstico de problemas sin necesidad de inspección de código.

- **Resiliencia**: El patrón "XP como efecto secundario no bloqueante" garantiza que un fallo en el subsistema de gamificación nunca degrade la funcionalidad clínica principal.

### Negativas y trade-offs

- **XP por usuario, no por paciente**: El XP se otorga al `user_id` extraído del token JWT, no al `patient_id` enviado en el payload. En el caso de un guardián que gestiona a su hijo, el XP va a la cuenta del guardián. Esto es correcto para el MVP (el guardián es quien interactúa con la app) pero puede necesitar revisión en versiones futuras donde el niño tenga su propio login.

- **Posible doble conteo**: Si el cliente realiza dos peticiones idénticas por error de red (retry sin idempotency key), se registrarían dos entradas de XP. Este riesgo se acepta para el MVP dado que no existe actualmente un sistema de idempotency keys para este endpoint.

- **Acoplamiento entre módulos**: `nutrition.py` ahora importa `XPRepository`. Esto introduce una dependencia del módulo nutricional sobre el módulo de gamificación. La dependencia está mitigada por el bloque try/except que la hace no bloqueante, pero desde el punto de vista de arquitectura hexagonal sería más correcto un sistema de eventos de dominio donde el módulo nutricional emita un evento `MealLogged` y el módulo de gamificación lo consuma. Esta refactorización queda pendiente para una versión futura.

---

## Alternativas Consideradas

### Alternativa A: Sistema de eventos de dominio (Domain Events)

Implementar un bus de eventos simple donde `log_meal` emite `MealLoggedEvent` y `XPRepository` se suscribe a dicho evento.

**Ventajas**: Desacoplamiento total entre módulos, extensible a otros suscriptores (notificaciones push, análisis de adherencia).

**Por qué se descartó para el MVP**: Añade complejidad de infraestructura (bus de eventos, registro de suscriptores) desproporcionada para el alcance actual. La dependencia directa con try/except es suficiente para el MVP y el acoplamiento es aceptable dado que solo existe un punto de integración.

### Alternativa B: Tarea Celery asíncrona para otorgar XP

Procesar el otorgamiento de XP en una tarea de background mediante Celery + Redis.

**Ventajas**: La respuesta del endpoint no espera a que el XP se escriba en BD, reduciendo la latencia de respuesta.

**Por qué se descartó**: Introduce Redis como nueva dependencia de infraestructura. La operación de escritura de XP es O(1) y tiene una latencia < 5ms en condiciones normales, insuficiente para justificar la complejidad operacional de Celery.

### Alternativa C: Cron job periódico que recalcula XP desde el historial de comidas

Un proceso batch que calcula el XP total del usuario contando registros en `meal_logs`.

**Ventajas**: Simpler initial implementation, no coupling between modules.

**Por qué se descartó**: Introduce latencia entre la acción del usuario (registrar comida) y el feedback visual (ver XP aumentar). Para un sistema de gamificación, el feedback inmediato es fundamental para el refuerzo positivo.

---

## Métricas de Validación

Los siguientes tests (en `backend/tests/api/test_meal_xp.py`) validan la decisión:

| Test | Descripción |
| :--- | :--- |
| `test_log_meal_awards_xp` | Verifica que después de un POST /meals, la tabla `xp_transactions` contiene una entrada para el usuario |
| `test_log_meal_xp_reason_is_meal_logged` | Verifica que la razón almacenada en la transacción de XP es `"meal_logged"` |
| `test_log_meal_stores_bolus_units` | Verifica que `bolus_units_administered` se persiste correctamente (test de integración preexistente, actualizado con auth) |
| `test_log_meal_without_bolus_units_defaults_null` | Verifica que la omisión de bolus devuelve null (test preexistente, actualizado con auth) |
