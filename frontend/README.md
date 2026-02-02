# DiaBeaty Mobile - Flutter Frontend

## 🏗️ Arquitectura del Proyecto

Este proyecto sigue **Clean Architecture** con las siguientes capas:

```
lib/
├── core/                    # Configuración central
│   ├── constants/          # Constantes de API, Storage Keys, Enums
│   ├── theme/              # Sistema de Temas Duales (Adulto/Niño)
│   └── network/            # Cliente HTTP con JWT Interceptor
│
├── data/                    # Capa de Datos
│   ├── models/             # DTOs (Data Transfer Objects)
│   └── datasources/        # API Clients (Retrofit)
│
├── domain/                  # Capa de Dominio
│   ├── entities/           # Modelos de negocio
│   └── repositories/       # Interfaces de repositorios
│
└── presentation/            # Capa de Presentación
    ├── bloc/               # State Management (BLoC)
    ├── screens/            # Pantallas de la app
    └── widgets/            # Componentes reutilizables
```

## 🎨 Sistema de Dual UX

### Modo Adulto

- **Paleta**: Azul profesional, violeta, verde esmeralda
- **Tipografía**: Clean, sans-serif, eficiente
- **Estilo**: Basado en datos, gráficos, métricas

### Modo Niño

- **Paleta**: Rosa vibrante, ámbar, violeta
- **Tipografía**: Redondeada, amigable, grande
- **Estilo**: Gamificación, quests, recompensas

## 🔐 Autenticación

### Endpoints Implementados

- `POST /api/v1/auth/login` - Login con JWT
- `POST /api/v1/users/register` - Registro de usuario

### Flujo de Autenticación

1. Usuario ingresa credenciales
2. API retorna `access_token` (JWT)
3. Token se almacena en `FlutterSecureStorage`
4. Interceptor Dio añade automáticamente `Authorization: Bearer <token>` a rutas protegidas

## 🚀 Próximos Pasos

### Fase 1: Autenticación ✅

- [x] Configuración de proyecto Flutter
- [x] Clean Architecture base
- [x] Sistema de Temas Duales
- [x] BLoC de Autenticación
- [x] Pantalla de Login con Dual UX
- [x] Cliente HTTP con JWT

### Fase 2: Dashboard (Próximo)

- [ ] Pantalla Home con métricas
- [ ] Gráficos de glucosa
- [ ] Calculadora de Bolus
- [ ] Registro de comidas

### Fase 3: Gamificación (Modo Niño)

- [ ] Sistema de Quests
- [ ] Recompensas y logros
- [ ] Avatar personalizable
- [ ] Animaciones Lottie

## 📦 Dependencias Principales

- **State Management**: `flutter_bloc` ^8.1.3
- **HTTP Client**: `dio` ^5.4.0, `retrofit` ^4.0.3
- **Secure Storage**: `flutter_secure_storage` ^9.0.0
- **Code Generation**: `build_runner`, `json_serializable`

## 🛠️ Comandos de Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Generar código (modelos, API clients)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en modo debug
flutter run

# Build para producción
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web

## 🔗 API Backend

- **Producción**: <https://diabetics-api.jljimenez.es>
- **Swagger**: Ver `docs/swagger.json` en la raíz del proyecto

## 👥 Equipo de Desarrollo

- **Flutter Architect**: Clean Architecture, State Management
- **UX/UI Designer**: Dual UX System, Gamificación
- **Mobile QA**: Testing, API Integration
