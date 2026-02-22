# 📋 Arquitectura Frontend — DiaBeaty Mobile

> Última actualización: 2026-02-22 · Flutter 3.19 · 36 tests ✅

## 🎯 Objetivo

Aplicación web/móvil multiplataforma para gestión de diabetes con **Dual UX** (Modo Adulto/Modo Niño), integrada con el backend FastAPI mediante Clean Architecture y BLoC pattern.

---

## 🏗️ Clean Architecture — 3 Capas

### 1. Presentation Layer (UI + State)

```
presentation/
├── bloc/
│   ├── auth/         # AuthBloc: Login, Register, SwitchProfile, RefreshSelectedProfile
│   ├── theme/        # ThemeBloc: SwitchTheme (Adult↔Child automático por perfil)
│   ├── profile/      # ProfileBloc: XP, achievements, nivel gamificado
│   └── nutrition/    # NutritionBloc: tray, bolus, historial, búsqueda
├── screens/
│   ├── auth/         # login_screen.dart
│   ├── dashboard/    # dashboard_screen.dart (Dual UX)
│   ├── glucose/      # add_glucose_screen.dart, glucose_history_screen.dart
│   ├── nutrition/    # nutrition_hub_screen.dart, log_meal_screen.dart, meal_history_screen.dart
│   └── profile/      # profile_screen.dart, adult/child_profile_screen.dart, edit_patient_screen.dart
└── widgets/
    ├── glucose_chart.dart              # Gráfica con marcadores de insulina ▲
    ├── conditional_medical_fields.dart  # ISF/ICR condicionales por tipo de terapia
    └── basal_insulin_fields.dart        # Insulina basal (tipo, unidades, hora)
```

### 2. Domain Layer (Business Logic)

```
domain/
├── entities/         # Entidades puras (User, Ingredient, BolusCal...)
└── repositories/     # Interfaces abstractas
```

### 3. Data Layer (API + Storage)

```
data/
├── models/
│   ├── auth_models.dart          # LoginRequest, UserPublicResponse, PatientProfile
│   ├── auth_models.g.dart        # (generado)
│   ├── nutrition_models.dart     # Ingredient(id:String), TrayItem, MealLogEntry
│   └── nutrition_models.g.dart   # (generado)
├── datasources/
│   ├── auth_api_client.dart      # Retrofit: Auth + Family endpoints
│   └── nutrition_api_client.dart # Retrofit: Nutrition endpoints
└── repositories/
    └── family_repository.dart    # getProfiles, getProfileDetails, updateProfile
```

---

## 🎨 Sistema de Dual UX

### Modo Adulto (Técnico) 🧑‍⚕️

| Elemento | Valor |
|----------|-------|
| **Colores** | Azul #2563EB, Violeta #7C3AED, Verde #059669 |
| **Tipografía** | Sans-serif, 14–16px, peso normal |
| **Componentes** | Cards planas, bordes 8px radius |
| **Dashboard** | Gráficos de glucosa, métricas numéricas, ICR/ISF explícitos |
| **Bolus** | Color verde ≤2U · naranja 2–5U · rojo >5U |

### Modo Niño (Gamificado) 🎮

| Elemento | Valor |
|----------|-------|
| **Colores** | Rosa #EC4899, Ámbar #F59E0B, Violeta #8B5CF6 |
| **Tipografía** | Redondeada, 18–20px, peso bold |
| **Componentes** | Cards elevadas, radius 24px, sombras |
| **Dashboard** | Avatar, barra de salud, medallas, nivel XP |
| **Bolus** | "¡Lista tu poción!" con colores de rareza |

**El `ThemeBloc` escucha al `AuthBloc`**: al hacer `SwitchProfile`, el tema cambia automáticamente según `patientProfile.themePreference` (`adult` | `child`).

---

## 🔐 Flujo de Autenticación y Perfiles

```
LoginScreen
  └─► AuthBloc.LoginRequested(email, password)
        └─► POST /api/v1/auth/login → JWT
              └─► GET /api/v1/family/profiles → List<PatientProfile>
                    └─► ProfileSelectionScreen
                          └─► AuthBloc.SwitchProfile(profile)
                                └─► AuthAuthenticated(user, selectedProfile)
                                      └─► ThemeBloc.SwitchTheme(profile.theme)
                                            └─► DashboardScreen (Adult|Child)
```

### RefreshSelectedProfile

Después de guardar datos del perfil (`AdultProfileScreen`), se dispara `RefreshSelectedProfile` para que `AuthBloc` recargue los datos médicos del perfil activo (ICR/ISF/rangos) sin necesidad de cerrar sesión.

---

## 🍎 Hub Nutricional (NutritionBloc)

El `NutritionBloc` gestiona una **bandeja multi-ingrediente** con el estado `MealTrayUpdated`:

```
MealTrayUpdated {
  tray: List<TrayItem>        // ingredientes añadidos
  searchResults: List<Ingredient>  // resultados búsqueda activos
}
```

**Invariante clave**: Cuando el usuario busca mientras tiene ingredientes en la bandeja, el bloc emite `copyWith(searchResults: results)` — preservando la bandeja. Esto evita resetear el estado de la bandeja por una búsqueda.

### Flujo completo (LogMealScreen)

```
Buscar ingrediente
  └─► SearchIngredients → MealTrayUpdated(tray, searchResults)
        └─► AddIngredientToTray → MealTrayUpdated(tray+1, results)
              └─► CalculateBolusForTray → TrayBolusCalculated(result, tray)
                    └─► (usuario ajusta dosis)
                          └─► CommitMealFromTray → MealHistoryLoaded
```

---

## 📱 Pantallas Implementadas

### Dashboard (`dashboard_screen.dart`)

| Sección | Adulto | Niño |
|---------|--------|------|
| Gráfica glucosa | Línea con rangos color | Barra de "salud" |
| Lectura actual | Número + color rango | Estado del avatar |
| Nav inferior | Inicio · Comidas · Glucosa · Perfil | Mismos, iconos grandes |
| Insulina history | Botón "Historial Insulina" | Botón "Mis Dosis" |

### NutritionHubScreen

5 secciones accesibles desde el botón "Comidas":
1. **Resumen del día** — CHO total, carga glucémica, insulina administrada
2. **Hero "Registrar Comida"** — abre LogMealScreen (bandeja multi-ingrediente)
3. **Dosis rápida de insulina** — log directo sin comida
4. **Guía de Índice Glucémico** — tabla de referencia (ExpansionTile)
5. **Comidas recientes** — las últimas 5 del historial

### LogMealScreen

Flujo completo de registro de comida:
- Búsqueda incremental con debounce 500ms
- Bandeja con remove y totales en tiempo real
- FAB "Calcular bolus (N)" habilitado solo con bandeja no vacía
- Vista de resultado con desglose por ingrediente
- Campo editable de dosis administrada
- Botón "Registrar Comida" → CommitMealFromTray

### AdultProfileScreen

Replica exacta de `EditPatientScreen` (vista del perfil desde el miembro seleccionado):
- Carga `getProfileDetails()` en init para obtener campos médicos cifrados
- Formulario: tipo diabetes, tipo terapia, ISF, ICR, glucosa objetivo, rangos bajo/alto, insulina basal
- Oculta "Cambiar Contraseña" para perfiles DEPENDENT
- Al guardar: `updateProfile()` + `RefreshSelectedProfile`

---

## 🧪 Testing

```bash
cd frontend && flutter test
```

| Test File | Tests | Descripción |
|-----------|-------|-------------|
| `auth_bloc_test.dart` | 9 | Login, logout, switch profile |
| `nutrition_bloc_test.dart` | 8 | Búsqueda, bolus, perfil params |
| `nutrition_tray_bloc_test.dart` | 6 | Bandeja multi-ingrediente |
| `member_profile_view_test.dart` | 6 | Vista perfil miembro activo |
| `conditional_medical_fields_test.dart` | 7 | Campos condicionales por terapia |
| **Total** | **36** | ✅ All passing |

---

## 🛠️ Code Generation

El proyecto usa `json_serializable` y `retrofit` para generar código boilerplate:

```bash
cd frontend
dart run build_runner build --delete-conflicting-outputs
```

Archivos generados (no editar manualmente):
- `lib/data/models/*.g.dart`
- `lib/data/datasources/*.g.dart`

---

## 📦 Dependencias Clave

| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_bloc` | ^8.1 | BLoC pattern |
| `dio` | ^5.0 | HTTP client |
| `retrofit` | ^4.0 | Type-safe API client |
| `json_annotation` | ^4.8 | JSON serialization |
| `flutter_secure_storage` | ^9.0 | Token storage |
| `fl_chart` | ^0.68 | Gráficas de glucosa |
| `equatable` | ^2.0 | Estado BLoC equality |
| `rxdart` | ^0.27 | debounceTime para búsqueda |
