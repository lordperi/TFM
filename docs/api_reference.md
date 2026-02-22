# Referencia de la API — DiaBeaty

> **Base URL:** `https://diabetics-api.jljimenez.es`
> **Documentación interactiva:** `https://diabetics-api.jljimenez.es/docs`
> **Versión de la API:** v1
> **Autenticación:** Bearer JWT (cabecera `Authorization: Bearer <token>`)

---

## Índice

1. [Autenticación](#1-autenticación)
2. [Usuarios y Perfil de Salud](#2-usuarios-y-perfil-de-salud)
3. [Sistema XP y Gamificación](#3-sistema-xp-y-gamificación)
4. [Gestión Familiar](#4-gestión-familiar)
5. [Monitorización de Glucosa](#5-monitorización-de-glucosa)
6. [Motor Nutricional](#6-motor-nutricional)
7. [Sistema de Salud](#7-sistema-de-salud)
8. [Modelos Comunes](#8-modelos-comunes)
9. [Códigos de Error](#9-códigos-de-error)

---

## 1. Autenticación

### POST `/api/v1/auth/login`

Intercambia credenciales por un token JWT.

**Autenticación requerida:** No
**Content-Type:** `application/x-www-form-urlencoded`

**Request Body:**
```
username=usuario@email.com&password=contraseña
```

**Response 200:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Errores:**
| Código | Descripción |
|--------|-------------|
| 401 | Credenciales incorrectas |
| 422 | Datos de formulario inválidos |

---

## 2. Usuarios y Perfil de Salud

### POST `/api/v1/users/register`

Registra un nuevo usuario con su perfil médico inicial.

**Autenticación requerida:** No

**Request Body:**
```json
{
  "email": "usuario@email.com",
  "password": "contraseña_segura",
  "full_name": "Nombre Completo",
  "health_profile": {
    "diabetes_type": "T1",
    "therapy_type": "INSULIN",
    "insulin_sensitivity": 50.0,
    "carb_ratio": 10.0,
    "target_glucose": 100,
    "target_range_low": 70,
    "target_range_high": 180
  }
}
```

**Campos del perfil de salud:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `diabetes_type` | enum | No | `NONE`, `T1`, `T2` |
| `therapy_type` | enum | No | `INSULIN`, `ORAL_MEDICATION`, `MIXED`, `NONE` |
| `insulin_sensitivity` | float | Cond. | ISF — mg/dL por unidad de insulina (1-500) |
| `carb_ratio` | float | Cond. | ICR — gramos de carbohidratos por unidad (1-150) |
| `target_glucose` | int | Cond. | Glucosa objetivo en mg/dL (70-180) |
| `target_range_low` | int | No | Límite inferior del rango (50-100) |
| `target_range_high` | int | No | Límite superior del rango (120-300) |

> **Nota:** `insulin_sensitivity`, `carb_ratio` y `target_glucose` son obligatorios cuando `therapy_type = INSULIN`.

**Response 201:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "usuario@email.com",
  "full_name": "Nombre Completo",
  "is_active": true,
  "health_profile": {
    "diabetes_type": "T1",
    "therapy_type": "INSULIN",
    "insulin_sensitivity": 50.0,
    "carb_ratio": 10.0,
    "target_glucose": 100,
    "target_range_low": 70,
    "target_range_high": 180
  }
}
```

---

### GET `/api/v1/users/me`

Obtiene el perfil completo del usuario autenticado. Los datos médicos sensibles se descifran en tiempo real.

**Autenticación requerida:** Sí 🔒

**Response 200:** Igual que el modelo `UserPublic` (ver sección 8).

---

### PATCH `/api/v1/users/me/health-profile`

Actualiza el perfil médico del usuario autenticado.

**Autenticación requerida:** Sí 🔒

**Request Body** (todos los campos opcionales):
```json
{
  "diabetes_type": "T1",
  "therapy_type": "INSULIN",
  "insulin_sensitivity": 55.0,
  "carb_ratio": 12.0,
  "target_glucose": 100,
  "target_range_low": 70,
  "target_range_high": 180,
  "basal_insulin_type": "Lantus",
  "basal_insulin_units": 14.5,
  "basal_insulin_time": "22:00"
}
```

**Response 200:** Modelo `HealthProfile` actualizado.

---

### POST `/api/v1/users/me/change-password`

Cambia la contraseña verificando la contraseña actual.

**Autenticación requerida:** Sí 🔒

**Request Body:**
```json
{
  "old_password": "contraseña_actual",
  "new_password": "nueva_contraseña",
  "confirm_password": "nueva_contraseña"
}
```

**Response 200:**
```json
{ "message": "Contraseña actualizada correctamente" }
```

**Errores:**
| Código | Descripción |
|--------|-------------|
| 400 | Contraseña actual incorrecta o contraseñas no coinciden |
| 401 | Token inválido |

---

## 3. Sistema XP y Gamificación

### GET `/api/v1/users/me/xp-summary`

Obtiene el resumen XP del usuario: nivel actual, progreso y transacciones recientes.

**Autenticación requerida:** Sí 🔒

**Response 200:**
```json
{
  "total_xp": 150,
  "current_level": 1,
  "xp_to_next_level": 350,
  "progress_percentage": 0.30,
  "recent_transactions": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "amount": 10,
      "reason": "meal_logged",
      "description": "Comida registrada",
      "timestamp": "2026-02-22T10:30:00"
    }
  ]
}
```

**Sistema de niveles:**

| Nivel | XP requerido | Título |
|-------|-------------|--------|
| 1-2 | 0-999 | Explorador |
| 3-4 | 1000-1999 | Aventurero |
| 5-6 | 2000-2999 | Guerrero |
| 7-8 | 3000-3999 | Héroe |
| 9-10 | 4000-4999 | Campeón |
| 11+ | 5000+ | Leyenda |

**Razones de XP (`reason`):**

| Razón | XP | Descripción |
|-------|-----|-------------|
| `meal_logged` | +10 | Comida registrada |
| `bolus_calculated` | +5 | Bolus calculado |
| `daily_login` | +5 | Inicio de sesión diario |
| `perfect_glucose` | +20 | Glucosa en rango objetivo |
| `week_streak` | +50 | Racha semanal |
| `achievement_unlocked` | Variable | Logro desbloqueado |

---

### GET `/api/v1/users/me/xp-history`

Historial completo de transacciones XP.

**Autenticación requerida:** Sí 🔒

**Query Parameters:**
| Parámetro | Tipo | Defecto | Descripción |
|-----------|------|---------|-------------|
| `limit` | int | 50 | Máximo de registros |
| `skip` | int | 0 | Paginación |

**Response 200:** Array de `XPTransaction`.

---

### GET `/api/v1/users/me/achievements`

Lista de logros del usuario: desbloqueados y bloqueados.

**Autenticación requerida:** Sí 🔒

**Response 200:**
```json
{
  "unlocked": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "achievement_id": "uuid",
      "unlocked_at": "2026-02-22T10:00:00",
      "achievement": {
        "id": "uuid",
        "name": "Primera Comida",
        "description": "Has registrado tu primera comida",
        "category": "meals",
        "icon": "🍽️",
        "xp_reward": 50
      }
    }
  ],
  "locked": [
    {
      "id": "uuid",
      "name": "Racha de 7 días",
      "description": "Registra actividad 7 días seguidos",
      "category": "consistency",
      "icon": "🔥",
      "xp_reward": 100
    }
  ]
}
```

**Categorías de logros:**

| Categoría | Descripción |
|-----------|-------------|
| `consistency` | Constancia y hábitos |
| `health` | Logros de salud |
| `learning` | Conocimiento nutricional |
| `social` | Interacción familiar |
| `milestone` | Hitos importantes |

---

## 4. Gestión Familiar

### GET `/api/v1/family/members`

Lista todos los perfiles pacientes del guardián autenticado.

**Autenticación requerida:** Sí 🔒

**Response 200:**
```json
[
  {
    "id": "uuid",
    "guardian_id": "uuid",
    "display_name": "Nombre del Paciente",
    "birth_date": "2015-03-15",
    "theme_preference": "child",
    "role": "DEPENDENT",
    "target_glucose": 100,
    "target_range_low": 70,
    "target_range_high": 180
  }
]
```

---

### POST `/api/v1/family/members`

Crea un nuevo perfil de paciente vinculado al guardián autenticado.

**Autenticación requerida:** Sí 🔒

**Request Body:**
```json
{
  "display_name": "María",
  "birth_date": "2015-03-15",
  "theme_preference": "child",
  "role": "DEPENDENT",
  "diabetes_type": "T1",
  "therapy_type": "INSULIN",
  "insulin_sensitivity": 80.0,
  "carb_ratio": 15.0,
  "target_glucose": 120,
  "target_range_low": 70,
  "target_range_high": 200
}
```

**Response 201:** Modelo `PatientProfile` creado.

---

### GET `/api/v1/family/members/{patient_id}`

Obtiene el detalle completo de un perfil paciente incluyendo datos médicos descifrados.

**Autenticación requerida:** Sí 🔒

**Path Parameters:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `patient_id` | UUID | ID del perfil paciente |

**Response 200:** Modelo `PatientProfileDetail` con datos médicos completos.

---

### PATCH `/api/v1/family/members/{patient_id}`

Actualiza los datos médicos de un perfil paciente.

**Autenticación requerida:** Sí 🔒

**Request Body:** Mismo esquema que POST, todos los campos opcionales.

**Response 200:** Modelo `PatientProfile` actualizado.

---

### POST `/api/v1/family/members/{patient_id}/verify-pin`

Verifica el PIN de acceso de un perfil paciente.

**Autenticación requerida:** Sí 🔒

**Request Body:**
```json
{ "pin": "1234" }
```

**Response 200:**
```json
{ "valid": true }
```

---

### POST `/api/v1/family/device-link`

Genera un código de vinculación de dispositivo.

**Autenticación requerida:** Sí 🔒

**Response 200:**
```json
{ "link_code": "ABC123", "expires_at": "2026-02-22T11:00:00" }
```

---

## 5. Monitorización de Glucosa

### POST `/api/v1/glucose`

Registra una nueva medición de glucosa.

**Autenticación requerida:** Sí 🔒

**Request Body:**
```json
{
  "patient_id": "uuid",
  "value": 145,
  "timestamp": "2026-02-22T10:30:00Z",
  "measurement_type": "FINGER",
  "notes": "Antes del desayuno"
}
```

**Tipos de medición (`measurement_type`):**
| Valor | Descripción |
|-------|-------------|
| `FINGER` | Punción capilar (glucómetro) |
| `CGM` | Monitor continuo de glucosa |
| `MANUAL` | Entrada manual estimada |

**Response 201:**
```json
{
  "id": "uuid",
  "patient_id": "uuid",
  "glucose_value": 145,
  "timestamp": "2026-02-22T10:30:00",
  "measurement_type": "FINGER",
  "notes": "Antes del desayuno"
}
```

**Validaciones:**
- `value`: entre 20 y 600 mg/dL

---

### GET `/api/v1/glucose/history`

Historial de mediciones con filtros de fecha.

**Autenticación requerida:** Sí 🔒

**Query Parameters:**
| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| `patient_id` | UUID | Sí | ID del paciente |
| `limit` | int | No (20) | Máximo de registros |
| `start_date` | datetime | No | Filtro fecha inicio (ISO 8601) |
| `end_date` | datetime | No | Filtro fecha fin (ISO 8601) |

**Response 200:** Array de mediciones ordenadas por timestamp descendente.

---

## 6. Motor Nutricional

### GET `/api/v1/nutrition/ingredients`

Búsqueda de ingredientes por nombre. Mínimo 2 caracteres.

**Autenticación requerida:** No

**Query Parameters:**
| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| `q` | string | Sí (min 2) | Texto de búsqueda |
| `limit` | int | No (20) | Máximo de resultados |

**Response 200:**
```json
[
  {
    "id": "uuid-string",
    "name": "Arroz blanco cocido",
    "glycemic_index": 73,
    "carbs": 28.2,
    "fiber_per_100g": 0.4
  }
]
```

> **Nota:** `carbs` representa los carbohidratos por 100g del alimento.

**Base de datos de ingredientes:** 181 alimentos con índice glucémico y macronutrientes validados contra tablas internacionales (Foster-Powell et al., BEDCA, USDA FoodData Central).

---

### POST `/api/v1/nutrition/ingredients`

Crea un nuevo ingrediente en la base de datos.

**Autenticación requerida:** No

**Request Body:**
```json
{
  "name": "Nuevo Alimento",
  "glycemic_index": 55,
  "carbs_per_100g": 45.0,
  "fiber_per_100g": 3.2
}
```

**Response 201:** Modelo `IngredientResponse`.

---

### POST `/api/v1/nutrition/ingredients/seed`

Puebla la base de datos con los 181 alimentos predefinidos. Operación idempotente (no duplica).

**Autenticación requerida:** No

**Response 200:**
```json
{
  "inserted": 181,
  "total_available": 181
}
```

---

### POST `/api/v1/nutrition/bolus/calculate`

Calcula el bolo de insulina recomendado para una lista de ingredientes.

**Autenticación requerida:** No

**Request Body:**
```json
{
  "current_glucose": 150,
  "target_glucose": 100,
  "ingredients": [
    { "ingredient_id": "uuid", "weight_grams": 150 },
    { "ingredient_id": "uuid", "weight_grams": 80 }
  ],
  "icr": 10.0,
  "isf": 50.0
}
```

| Campo | Tipo | Defecto | Descripción |
|-------|------|---------|-------------|
| `current_glucose` | float | — | Glucosa actual en mg/dL |
| `target_glucose` | float | — | Glucosa objetivo en mg/dL |
| `ingredients` | array | — | Lista de ingredientes con peso |
| `icr` | float | 10.0 | Ratio Insulina:Carbohidrato (g de CH por unidad) |
| `isf` | float | 50.0 | Factor Sensibilidad a la Insulina (mg/dL por unidad) |

**Response 200:**
```json
{
  "total_carbs_grams": 65.4,
  "recommended_bolus_units": 4.18
}
```

**Fórmula aplicada:**
```
Carbohidratos_netos = (carbs_por_100g / 100) × peso_gramos

Bolo_carbohidratos = Carbohidratos_totales / ICR
Bolo_corrección = (Glucosa_actual - Glucosa_objetivo) / ISF
Bolo_total = max(0, Bolo_carbohidratos + Bolo_corrección)
```

> **Aviso médico:** El bolo calculado es una *recomendación*. El médico o paciente debe validar siempre antes de administrar insulina.

---

### POST `/api/v1/nutrition/meals`

Registra una comida en el historial del paciente y otorga **+10 XP** al usuario autenticado.

**Autenticación requerida:** Sí 🔒

**Request Body:**
```json
{
  "patient_id": "uuid",
  "ingredients": [
    { "ingredient_id": "uuid", "weight_grams": 150 },
    { "ingredient_id": "uuid", "weight_grams": 80 }
  ],
  "notes": "Almuerzo en el colegio",
  "bolus_units_administered": 3.5
}
```

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `patient_id` | UUID | Sí | ID del perfil paciente |
| `ingredients` | array | Sí | Ingredientes consumidos |
| `notes` | string | No | Notas (cifradas en BD — PHI) |
| `bolus_units_administered` | float | No | Dosis real administrada |

**Response 200:**
```json
{
  "id": "uuid",
  "patient_id": "uuid",
  "total_carbs_grams": 65.4,
  "total_glycemic_load": 42.3,
  "bolus_units_administered": 3.5,
  "timestamp": "2026-02-22T13:30:00"
}
```

**Efectos secundarios:**
- Las notas se cifran automáticamente con Fernet antes de almacenarse.
- Se otorgan **+10 XP** al usuario autenticado con `reason: meal_logged`.

---

### GET `/api/v1/nutrition/meals/history`

Historial de comidas registradas con filtros de fecha.

**Autenticación requerida:** No

**Query Parameters:**
| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|-------------|-------------|
| `patient_id` | UUID | Sí | ID del paciente |
| `limit` | int | No (20) | Máximo de registros (1-100) |
| `offset` | int | No (0) | Paginación |
| `start_date` | datetime | No | Filtro fecha inicio (ISO 8601) |
| `end_date` | datetime | No | Filtro fecha fin (ISO 8601) |

**Response 200:** Array de comidas ordenadas por timestamp descendente.

---

## 7. Sistema de Salud

### GET `/api/v1/health`

Comprueba el estado del sistema y la conexión a la base de datos.

**Autenticación requerida:** No

**Response 200:**
```json
{
  "status": "healthy",
  "database": "connected",
  "version": "1.0.0"
}
```

---

## 8. Modelos Comunes

### UserPublic
```json
{
  "id": "uuid",
  "email": "usuario@email.com",
  "full_name": "Nombre Completo",
  "is_active": true,
  "health_profile": {
    "diabetes_type": "T1",
    "therapy_type": "INSULIN",
    "insulin_sensitivity": 50.0,
    "carb_ratio": 10.0,
    "target_glucose": 100,
    "target_range_low": 70,
    "target_range_high": 180,
    "basal_insulin_type": "Lantus",
    "basal_insulin_units": 14.5,
    "basal_insulin_time": "22:00"
  }
}
```

### PatientProfile
```json
{
  "id": "uuid",
  "guardian_id": "uuid",
  "display_name": "María",
  "birth_date": "2015-03-15",
  "theme_preference": "child",
  "role": "DEPENDENT",
  "login_code": "ABC123",
  "target_glucose": 120,
  "target_range_low": 70,
  "target_range_high": 200,
  "insulin_sensitivity": 80.0,
  "carb_ratio": 15.0
}
```

### XPTransaction
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "amount": 10,
  "reason": "meal_logged",
  "description": "Comida registrada",
  "timestamp": "2026-02-22T10:30:00"
}
```

### IngredientResponse
```json
{
  "id": "uuid-string",
  "name": "Arroz blanco cocido",
  "glycemic_index": 73,
  "carbs": 28.2,
  "fiber_per_100g": 0.4
}
```

### MealLogResponse
```json
{
  "id": "uuid",
  "patient_id": "uuid",
  "total_carbs_grams": 65.4,
  "total_glycemic_load": 42.3,
  "bolus_units_administered": 3.5,
  "timestamp": "2026-02-22T13:30:00"
}
```

---

## 9. Códigos de Error

| Código HTTP | Significado | Cuándo ocurre |
|-------------|-------------|---------------|
| 200 | OK | Operación exitosa |
| 201 | Created | Recurso creado |
| 400 | Bad Request | Datos inválidos, lógica de negocio |
| 401 | Unauthorized | Token ausente, inválido o expirado |
| 404 | Not Found | Recurso no encontrado |
| 409 | Conflict | Recurso ya existe (ej. email duplicado) |
| 422 | Unprocessable Entity | Error de validación Pydantic |
| 500 | Internal Server Error | Error interno del servidor |

**Formato de error estándar:**
```json
{
  "detail": "Descripción del error"
}
```

**Ejemplo de error de validación (422):**
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    }
  ]
}
```

---

## Flujo de Autenticación

```
1. POST /auth/login  →  { access_token }
2. Todas las peticiones protegidas:
   Header: Authorization: Bearer <access_token>
```

**Duración del token:** Configurable mediante variable de entorno `ACCESS_TOKEN_EXPIRE_MINUTES` (por defecto: 60 minutos).

---

## Ejemplo de Flujo Completo — Registrar una Comida

```bash
# 1. Login
TOKEN=$(curl -s -X POST https://diabetics-api.jljimenez.es/api/v1/auth/login \
  -d "username=usuario@email.com&password=contraseña" \
  | jq -r '.access_token')

# 2. Buscar ingredientes
curl "https://diabetics-api.jljimenez.es/api/v1/nutrition/ingredients?q=arroz"

# 3. Calcular bolo recomendado
curl -s -X POST https://diabetics-api.jljimenez.es/api/v1/nutrition/bolus/calculate \
  -H "Content-Type: application/json" \
  -d '{
    "current_glucose": 150,
    "target_glucose": 100,
    "ingredients": [{"ingredient_id": "<uuid>", "weight_grams": 200}],
    "icr": 10,
    "isf": 50
  }'

# 4. Registrar la comida (otorga +10 XP)
curl -s -X POST https://diabetics-api.jljimenez.es/api/v1/nutrition/meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "<uuid>",
    "ingredients": [{"ingredient_id": "<uuid>", "weight_grams": 200}],
    "bolus_units_administered": 3.5
  }'

# 5. Consultar XP actualizado
curl -H "Authorization: Bearer $TOKEN" \
  https://diabetics-api.jljimenez.es/api/v1/users/me/xp-summary
```

---

*Documentación generada para DiaBeaty TFM — Febrero 2026*
