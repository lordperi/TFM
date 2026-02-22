# ADR-013: Hub Nutricional y Arquitectura de Bandeja Multi-Ingrediente

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-22 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect, Code Specialists |
| **PR** | #23 `feature/nutrition-hub-and-meal-logger` |

## Contexto

El flujo de registro de comidas original era lineal: buscar UN ingrediente → calcular bolus → registrar. Esto no refleja la realidad clínica donde una comida incluye múltiples alimentos (arroz + pollo + ensalada). Además faltaba un punto de entrada unificado para todas las funcionalidades nutricionales.

## Decisión

### 1. NutritionHubScreen como punto de entrada único

Una pantalla central con 5 secciones:
1. Resumen del día (CHO/CG/insulina)
2. Hero "Registrar Comida" → LogMealScreen
3. Dosis rápida de insulina
4. Guía de Índice Glucémico (referencia educativa)
5. Comidas recientes → MealHistoryScreen

**Navegación**: `DashboardScreen.onTap(index=1)` abre `NutritionHubScreen` via `BlocProvider.value` para reutilizar el `NutritionBloc` existente.

### 2. Modelo `TrayItem` efímero (solo UI)

```dart
class TrayItem {
  final Ingredient ingredient;
  final double grams;
  double get carbs => (ingredient.carbs * grams) / 100;
  double get glycemicLoad => (ingredient.glycemicIndex * carbs) / 100;
}
```

`TrayItem` NO tiene anotaciones `@JsonSerializable` — es estado efímero de UI/BLoC. No se persiste, no se envía. Al llamar a la API, se mapea a `IngredientInput`.

### 3. Estado `MealTrayUpdated` compuesto

```dart
class MealTrayUpdated extends NutritionState {
  final List<TrayItem> tray;
  final List<Ingredient> searchResults;  // búsqueda activa
}
```

**Invariante clave**: el handler `_onSearchIngredients` verifica `if (state is MealTrayUpdated)` y emite `copyWith(searchResults: results)` en lugar de `IngredientsLoaded`. Esto preserva la bandeja mientras se sigue buscando — sin este patrón, cada búsqueda borraría la bandeja.

### 4. Flujo de estados

```
NutritionInitial
  → (AddIngredientToTray) → MealTrayUpdated(tray:[A], results:[])
  → (SearchIngredients)   → MealTrayUpdated(tray:[A], results:[B,C])
  → (AddIngredientToTray) → MealTrayUpdated(tray:[A,B], results:[B,C])
  → (CalculateBolusForTray) → NutritionLoading → TrayBolusCalculated(result, tray)
  → (CommitMealFromTray)    → NutritionLoading → MealHistoryLoaded
  → (ClearTray)             → NutritionInitial
```

### 5. Vista Dual UX en LogMealScreen

El resultado del bolus (`_BolusTrayResultScreen`) se adapta según `ThemeBloc`:
- **Adulto**: tabla técnica con desglose por ingrediente, campo editable de dosis
- **Niño**: "¡Lista tu poción!", dosis como "pociones de insulina", colores de rareza

### 6. Color semántico del bolus

| Rango | Color | Significado |
|-------|-------|-------------|
| ≤ 2 U | `Colors.green` | Comida ligera, riesgo bajo |
| 2–5 U | `Colors.orange` | Comida moderada, atención |
| > 5 U | `Colors.red` | Comida abundante, revisar |

Este mismo criterio aplica en adulto y niño para mantener coherencia médica.

## Consecuencias

**Positivas:**
- Una sola pantalla centraliza todo el flujo nutricional (UX más limpia).
- La bandeja persiste durante múltiples búsquedas (flujo natural de uso real).
- `TrayItem` como modelo efímero evita contaminar la capa de datos con estado UI temporal.
- La vista de resultado es extensible para mostrar alertas clínicas en el futuro.

**Trade-offs:**
- `MealTrayUpdated` es un estado "gordo" que combina dos responsabilidades (bandeja + búsqueda). En una iteración futura podría dividirse.
- El seed de 25 alimentos cubre los casos de demo pero no una BD nutricional completa. La Fase 2 (AI Vision) resolverá esto con OCR y estimación visual.
