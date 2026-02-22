# ✅ SPRINT 2 COMPLETADO — DiaBeaty Mobile

## Resumen

| Campo | Valor |
|-------|-------|
| **Fecha** | 2026-02-22 |
| **Sprint** | 2/3 |
| **Estado** | ✅ COMPLETADO |
| **Backend tests** | 108 ✅ |
| **Flutter tests** | 36 ✅ |
| **PRs mergeados** | #19, #20, #21, #22, #23, #24 |

---

## Funcionalidades Entregadas

### PR #19 — Historial lista + filtros + tooltip insulina

- `MealHistoryScreen`: lista de comidas con filtros de fecha (selector desde/hasta)
- `GlucoseChart`: marcadores ▲ naranjas en el gráfico cuando hay insulina administrada
- Dashboard: botones "Historial Insulina" (adulto) y "Mis Dosis" (niño)
- `bolus_units_administered` en `MealLogModel` + migración Alembic

### PR #20 — CalculateBolus usa parámetros reales del perfil

- `LogMealScreen` lee ICR/ISF/targetGlucose del perfil activo en `AuthBloc`
- Eliminados valores hardcodeados (ICR=10, ISF=50)
- Tests actualizados para verificar que los parámetros del perfil se usan correctamente

### PR #21 — Colores de glucosa según rangos del perfil activo

- `GlucoseChart` colorea las mediciones usando `targetRangeLow`/`targetRangeHigh` del perfil activo
- Color verde en rango, amarillo en límite, rojo fuera de rango
- `AuthBloc` propaga los rangos al chart

### PR #22 — Vista de perfil del miembro activo (hotfix)

- `AdultProfileScreen`: muestra datos médicos del miembro seleccionado (no del usuario principal)
- Carga `getProfileDetails()` para obtener campos cifrados (ISF, ICR, glucosa objetivo, insulina basal)
- Oculta "Cambiar Contraseña" para perfiles DEPENDENT
- `RefreshSelectedProfile` event en `AuthBloc` para sincronizar datos tras guardar
- `ChildProfileScreen`: muestra `selectedProfile.displayName` como saludo

### PR #23 — Hub Nutricional con bandeja multi-ingrediente

- `NutritionHubScreen`: 5 secciones (resumen diario, registrar comida, dosis rápida, guía IG, historial)
- `LogMealScreen`: flujo completo multi-ingrediente con bandeja
- `NutritionBloc`: extendido con `MealTrayUpdated`, `TrayBolusCalculated`, `ClearTray`
- `TrayItem`: modelo efímero de UI para la bandeja
- Dashboard botón "Comidas" conectado

### PR #24 — Endpoint CRUD de ingredientes + seed + fix frontend

- `POST /api/v1/nutrition/ingredients`: crea ingredientes (409 si duplicado)
- `POST /api/v1/nutrition/ingredients/seed`: puebla 25 alimentos comunes (idempotente)
- `IngredientResponse` corregido: `id` como string UUID, campo `carbs` (alias de `carbs_per_100g`)
- `Ingredient.id` en Flutter cambiado de `int` a `String`
- 8 nuevos tests de integración para CRUD de ingredientes

---

## Deuda Técnica Resuelta

| Deuda | PR | Descripción |
|-------|-----|-------------|
| ICR/ISF hardcodeados | #20 | Ahora usa perfil activo |
| `Ingredient.id` int vs UUID | #24 | Migrado a `String` |
| `carbs_per_100g` vs `carbs` | #24 | API ahora envía `carbs` |
| BD de ingredientes vacía | #24 | Seed idempotente con 25 alimentos |

---

## Métricas del Sprint

| Métrica | Sprint 1 | Sprint 2 | Delta |
|---------|---------|---------|-------|
| Backend tests | 95 | 108 | +13 |
| Flutter tests | 17 | 36 | +19 |
| Endpoints API | 7 | 15 | +8 |
| Pantallas Flutter | 7 | 12 | +5 |
| ADRs | 12 | 13 | +1 |
| % MVP | 78% | 93% | +15% |

---

## Arquitectura — Decisiones Clave

### BLoC Pattern para bandeja multi-ingrediente

El estado `MealTrayUpdated` combina `tray` y `searchResults` para que ambas secciones se rendericen simultáneamente. La búsqueda usa `copyWith()` para preservar la bandeja activa.

### `BlocProvider.value` para navegación con BLoC compartido

Las pantallas hijo (`LogMealScreen`, `MealHistoryScreen`) reciben el `NutritionBloc` del padre via `BlocProvider.value` en lugar de crear una nueva instancia — garantiza que el estado persiste durante la navegación.

### `RefreshSelectedProfile` para sincronización post-guardado

En lugar de invalidar la sesión o recargar todos los perfiles, el nuevo event `RefreshSelectedProfile` hace una única llamada `getProfileDetails()` y emite un nuevo estado `AuthAuthenticated` con el perfil actualizado. Mínima carga de red, máxima coherencia.

---

## Pendiente para Sprint 3 (Post-TFM)

- Pantalla de registro (`register_screen.dart`)
- Paginación en historial de comidas
- Notificaciones push para recordatorios de dosis
- OCR de menús (Fase 2 del roadmap)
- Conexión CGM en tiempo real (Fase 4)
