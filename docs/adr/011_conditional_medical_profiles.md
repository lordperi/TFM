# ADR-011: Perfiles Médicos Condicionales con Insulina Basal

**Fecha:** 2026-02-14  
**Estado:** Aceptado  
**Decisores:** Equipo DiaBeaty, Product Owner  

## Contexto

En la versión inicial del sistema, todos los perfiles de salud (`health_profiles`) requerían los mismos campos (ISF, ICR, Target Glucose) independientemente del tipo de diabetes del usuario.

**Problemas identificados:**

1. **Guardianes sin diabetes** (diabetes_type = NONE) no necesitan datos médicos, pero el sistema los requería.
2. **Diabetes Tipo 2** puede tratarse solo con medicación oral (Metformina), sin necesidad de insulina.
3. **Falta de soporte para insulina basal** (Lantus, Levemir, Tresiba) que es crítica para pacientes insulinodependientes (T1 y algunos T2).
4. **UX confusa**: Mostrar campos irrelevantes según el tipo de usuario.

## Decisión

Implementar **perfiles médicos dinámicos** con validación condicional basada en:

- `diabetes_type` (NONE, T1, T2)
- `therapy_type` (INSULIN, ORAL_MEDICATION, MIXED, NONE)

### Cambios en Base de Datos

Añadidos 4 campos a `health_profiles`:

```sql
-- Nuevo ENUM
CREATE TYPE therapy_type_enum AS ENUM ('INSULIN', 'ORAL_MEDICATION', 'MIXED', 'NONE');

-- Nuevas columnas
ALTER TABLE health_profiles
  ADD COLUMN therapy_type therapy_type_enum,
  ADD COLUMN basal_insulin_type VARCHAR,      -- "Lantus", "Levemir", "Tresiba"
  ADD COLUMN basal_insulin_units VARCHAR,     -- CIFRADO con Fernet (PHI)
  ADD COLUMN basal_insulin_time TIME;         -- "22:00"
```

### Reglas de Validación Condicional

**Backend (Pydantic `@model_validator`):**

```python
if diabetes_type == DiabetesType.NONE:
    # NO debe tener datos médicos
    if any([insulin_sensitivity, carb_ratio, target_glucose]):
        raise ValueError("diabetes_type=NONE no debe tener datos médicos")

if therapy_type in [TherapyType.INSULIN, TherapyType.MIXED]:
    # ISF/ICR/Target son REQUERIDOS
    if not all([insulin_sensitivity, carb_ratio, target_glucose]):
        raise ValueError("Terapia con insulina requiere ISF, ICR y Target Glucose")
```

**Frontend (Flutter - Conditional Rendering):**

```dart
if (diabetesType != DiabetesType.none) {
  // Mostrar selector de terapia
  if (therapyType == TherapyType.insulin || therapyType == TherapyType.mixed) {
    // Mostrar campos ISF/ICR/Target
    // Mostrar campos de insulina basal
  }
}
```

### Flujo por Tipo de Usuario

| Diabetes Type | Therapy Type      | Campos Requeridos                          | Campos Opcionales         |
|---------------|-------------------|--------------------------------------------|---------------------------|
| **NONE**      | N/A               | Ninguno                                    | Ninguno                   |
| **T1**        | INSULIN           | ISF, ICR, Target                           | Basal Insulin (tipo, unidades, hora) |
| **T2**        | ORAL              | Ninguno                                    | Ninguno                   |
| **T2**        | INSULIN           | ISF, ICR, Target                           | Basal Insulin             |
| **T2**        | MIXED             | ISF, ICR, Target                           | Basal Insulin             |

## Consecuencias

### Positivas ✅

1. **UX Mejorada:** Formularios adaptativos que solo muestran campos relevantes.
2. **Datos más precisos:** Validación estricta según tipo de tratamiento.
3. **Soporte completo para insulina basal:** Pacientes pueden registrar Lantus, Levemir, Tresiba con dosis y horarios.
4. **Flexibilidad:** Soporta diferentes modalidades de tratamiento para T2.
5. **Seguridad:** Unidades de insulina basal cifradas con Fernet (PHI protegida).

### Negativas ⚠️

1. **Complejidad de validación aumentada:** Lógica condicional tanto en backend como frontend.
2. **Migración de datos:** Usuarios existentes tendrán `therapy_type = NULL`, requiere migración de datos o valores por defecto.
3. **Testing más complejo:** Necesidad de tests para cada combinación de diabetes_type + therapy_type.

### Mitigación de Negativos

- **Testing exhaustivo:** 11 test cases creados en `test_conditional_medical_profiles.py`.
- **Documentación actualizada:** README y Swagger reflejan los nuevos campos.
- **Retrocompatibilidad:** Campos nuevos son nullable, usuarios antiguos no se rompen.

## Alternativas Consideradas

### 1. Mantener un solo perfil genérico

- **Rechazado:** Mala UX, datos innecesarios para usuarios sin diabetes o con T2 oral.

### 2. Crear perfiles separados (HealthProfileT1, HealthProfileT2, HealthProfileNone)

- **Rechazado:** Duplicación de código, dificulta cambios de tipo (ej: T2 que empieza insulina).

### 3. Usar JSON flexible (PostgreSQL JSONB)

- **Rechazado:** Pérdida de validación en BD, dificultad para queries, no aprovecha tipado fuerte de Pydantic/SQLAlchemy.

## Implementación

### Migración Alembic

**Archivo:** `backend/alembic/versions/010_add_basal_insulin_and_therapy.py`

```python
def upgrade() -> None:
    therapy_type_enum = sa.Enum(
        'INSULIN', 'ORAL_MEDICATION', 'MIXED', 'NONE',
        name='therapy_type_enum'
    )
    therapy_type_enum.create(op.get_bind(), checkfirst=True)
    
    op.add_column('health_profiles', 
        sa.Column('therapy_type', therapy_type_enum, nullable=True))
    op.add_column('health_profiles',
        sa.Column('basal_insulin_type', sa.String(), nullable=True))
    op.add_column('health_profiles',
        sa.Column('basal_insulin_units', sa.String(), nullable=True))
    op.add_column('health_profiles',
        sa.Column('basal_insulin_time', sa.Time(), nullable=True))
```

### Domain Models

**Archivo:** `backend/src/domain/health_models.py`

- `TherapyType` (Enum)
- `BasalInsulinInfo` (Pydantic BaseModel)

**Archivo:** `backend/src/domain/user_models.py`

- `HealthProfileBase` con `@model_validator` para validación condicional
- `HealthProfileUpdate` con campos de insulina basal

### Tests

**Archivo:** `backend/tests/unit/test_conditional_medical_profiles.py`

- 11 test cases cubriendo todas las combinaciones
- Tests para validación de rangos (units: 0-100, time: HH:MM)

## Referencias

- [ADR-005: Application-Level Encryption](file:///d:/trabajo/TFM/docs/adr/005_data_encryption.md)
- [ADR-010: Flexible Health Profiles](file:///d:/trabajo/TFM/docs/adr/010_flexible_health_profiles_and_security.md)
- [Fernet Encryption (Cryptography.io)](https://cryptography.io/en/latest/fernet/)

## Notas

- **Compatibilidad con Coolify:** No se modificaron configuraciones de deployment.
- **Backward Compatibility:** Usuarios existentes con `therapy_type = NULL` seguirán funcionando.
- **Frontend pendiente:** Los cambios de UI en Flutter se implementarán en siguiente fase.

---

**Actualizado por:** DiaBeaty Supreme Orchestrator AI-TPM  
**Revisado por:** TDD Enforcer, Security Guardian, Code Specialists
