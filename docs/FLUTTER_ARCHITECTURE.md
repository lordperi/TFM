# 📋 Plan de Desarrollo - DiaBeaty Mobile

## 🎯 Objetivo del Proyecto

Aplicación móvil multiplataforma para gestión de diabetes con **Dual UX** (Modo Adulto/Modo Niño) integrada con backend FastAPI.

---

## 🏗️ Arquitectura Técnica

### Clean Architecture - 3 Capas

#### 1️⃣ **Presentation Layer** (UI + State)

```
presentation/
├── bloc/
│   ├── auth/           # AuthBloc (Login, Register, Logout)
│   ├── theme/          # ThemeBloc (Dual UX Toggle)
│   ├── bolus/          # BolusBloc (Cálculo de insulina)
│   └── nutrition/      # NutritionBloc (Búsqueda de ingredientes)
├── screens/
│   ├── auth/           # Login, Register
│   ├── home/           # Dashboard principal
│   ├── bolus/          # Calculadora de bolus
│   └── profile/        # Perfil de usuario
└── widgets/
    ├── dual_ux/        # Componentes que cambian según UiMode
    └── common/         # Componentes compartidos
```

#### 2️⃣ **Domain Layer** (Business Logic)

```
domain/
├── entities/
│   ├── user.dart
│   ├── bolus_calculation.dart
│   └── ingredient.dart
└── repositories/
    ├── auth_repository.dart
    └── nutrition_repository.dart
```

#### 3️⃣ **Data Layer** (API + Storage)

```
data/
├── models/
│   ├── auth_models.dart        # LoginRequest, UserPublic
│   ├── bolus_models.dart       # BolusRequest, BolusResponse
│   └── nutrition_models.dart   # Ingredient
├── datasources/
│   ├── auth_api_client.dart    # Retrofit API
│   └── nutrition_api_client.dart
└── repositories/
    └── auth_repository_impl.dart
```

---

## 🎨 Sistema de Dual UX

### Modo Adulto 🧑‍⚕️

**Filosofía**: Eficiencia, datos, control médico

| Elemento | Diseño |
|----------|--------|
| **Colores** | Azul #2563EB, Violeta #7C3AED, Verde #059669 |
| **Tipografía** | Sans-serif, 14-16px, peso normal |
| **Componentes** | Cards planas, bordes sutiles (8px) |
| **Dashboard** | Gráficos de línea, métricas numéricas |
| **Navegación** | Bottom Nav clásico |

### Modo Niño 🎮

**Filosofía**: Gamificación, aventura, recompensas

| Elemento | Diseño |
|----------|--------|
| **Colores** | Rosa #EC4899, Ámbar #F59E0B, Violeta #8B5CF6 |
| **Tipografía** | Redondeada, 18-20px, peso bold |
| **Componentes** | Cards elevadas (24px radius), sombras |
| **Dashboard** | Barras de progreso, avatares, medallas |
| **Navegación** | Iconos grandes con animaciones |

---

## 🔐 Flujo de Autenticación

```
┌─────────────┐
│ LoginScreen │
└──────┬──────┘
       │
       ├─► AuthBloc.LoginRequested(email, password)
       │
       ├─► AuthApiClient.login() → POST /api/v1/auth/login
       │
       ├─► Response: { access_token, token_type }
       │
       ├─► FlutterSecureStorage.write('access_token', token)
       │
       └─► AuthBloc.emit(AuthAuthenticated)
           │
           └─► Navigate to HomeScreen
```

### Interceptor JWT Automático

```dart
// DioClient añade automáticamente:
headers['Authorization'] = 'Bearer <token>'

// Solo en rutas protegidas:
- /api/v1/nutrition/*
- /api/v1/users/me
```

---

## 📊 Pantallas Principales

### 1. Login Screen ✅ (Implementado)

- Dual UX completo
- Validación de formularios
- Manejo de errores
- Toggle de modo

### 2. Home Screen (Próximo)

**Modo Adulto**:

- Gráfico de glucosa (últimas 24h)
- Última medición destacada
- Acceso rápido a Bolus Calculator
- Historial de comidas

**Modo Niño**:

- Avatar con barra de salud
- Quest del día: "Registra 3 comidas"
- Medallas ganadas
- Botón grande: "¡Calcular Insulina!"

### 3. Bolus Calculator

**Endpoint**: `POST /api/v1/nutrition/calculate-bolus`

**Request**:

```json
{
  "total_carbs": 45.5,
  "current_glucose": 180
}
```

**Response**:

```json
{
  "units": 3.5,
  "breakdown": {
    "carb_insulin": 2.0,
    "correction_insulin": 1.5
  }
}
```

### 4. Ingredient Search

**Endpoint**: `GET /api/v1/nutrition/ingredients?q=arroz`

**Modo Adulto**: Lista con tabla nutricional
**Modo Niño**: Cards con iconos de comida

---

## 🧪 Testing Strategy

### Unit Tests

```dart
test/
├── bloc/
│   ├── auth_bloc_test.dart
│   └── theme_bloc_test.dart
├── models/
│   └── auth_models_test.dart
└── repositories/
    └── auth_repository_test.dart
```

### Widget Tests

```dart
test/
└── screens/
    ├── login_screen_test.dart
    └── home_screen_test.dart
```

### Integration Tests

```dart
integration_test/
└── app_test.dart  # Flujo completo: Login → Home → Bolus
```

---

## 📦 Generación de Código

### Comandos Necesarios

```bash
# Generar modelos JSON
flutter pub run build_runner build --delete-conflicting-outputs

# Archivos generados:
# - auth_models.g.dart
# - bolus_models.g.dart
# - nutrition_models.g.dart
# - auth_api_client.g.dart
```

---

## 🚀 Roadmap de Desarrollo

### Sprint 1: Fundamentos ✅

- [x] Estructura Clean Architecture
- [x] Sistema de Temas Duales
- [x] BLoC de Autenticación
- [x] Login Screen con Dual UX
- [x] Cliente HTTP con JWT

### Sprint 2: Dashboard (2 semanas)

- [ ] Home Screen Dual UX
- [ ] Gráficos de glucosa (fl_chart)
- [ ] Widget de última medición
- [ ] Navegación entre pantallas

### Sprint 3: Bolus Calculator (1 semana)

- [ ] Pantalla de cálculo
- [ ] Integración con API
- [ ] Historial de cálculos
- [ ] Modo Niño: "Misión Insulina"

### Sprint 4: Nutrition (2 semanas)

- [ ] Búsqueda de ingredientes
- [ ] Registro de comidas
- [ ] Scanner de códigos de barras
- [ ] Base de datos local (Hive)

### Sprint 5: Gamificación (1 semana)

- [ ] Sistema de Quests
- [ ] Logros y medallas
- [ ] Avatar personalizable
- [ ] Animaciones Lottie

### Sprint 6: Polish & Deploy (1 semana)

- [ ] Testing completo
- [ ] Optimización de rendimiento
- [ ] Build para Android/iOS/Web
- [ ] Documentación final

---

## 🔧 Configuración de Entorno

### Requisitos

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode
- VS Code con extensiones Flutter

### Variables de Entorno

```dart
// lib/core/constants/app_constants.dart
static const String baseUrl = 'https://diabetics-api.jljimenez.es';
```

### Configuración de Plataformas

#### Android (`android/app/build.gradle`)

```gradle
minSdkVersion 21
targetSdkVersion 34
```

#### iOS (`ios/Podfile`)

```ruby
platform :ios, '12.0'
```

#### Web (`web/index.html`)

```html
<meta name="description" content="DiaBeaty - Gestión de Diabetes">
```

---

## 📚 Recursos de Referencia

### Documentación

- [Flutter Docs](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Retrofit](https://pub.dev/packages/retrofit)

### API Backend

- Swagger: `docs/swagger.json`
- Base URL: <https://diabetics-api.jljimenez.es>

### Diseño

- Paletas de colores: Tailwind CSS
- Iconos: Material Icons
- Animaciones: Lottie Files

---

## 🤝 Contribución

### Flujo de Trabajo

1. Crear branch: `feature/nombre-feature`
2. Implementar según Clean Architecture
3. Escribir tests
4. Pull Request con descripción detallada

### Convenciones de Código

- Nombres en inglés (código)
- Comentarios en español (documentación)
- Usar `const` siempre que sea posible
- Trailing commas en listas
