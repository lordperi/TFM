# DiaBeaty Mobile - Scripts de Desarrollo

## 🚀 Inicio Rápido

### 1. Configuración Inicial

```bash
# Navegar al directorio frontend
cd frontend

# Instalar dependencias
flutter pub get

# Generar código (modelos, API clients)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Ejecutar la Aplicación

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en Chrome (Web)
flutter run -d chrome

# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS (solo macOS)
flutter run -d ios
```

### 3. Desarrollo

```bash
# Hot Reload: Presiona 'r' en la terminal
# Hot Restart: Presiona 'R' en la terminal
# Quit: Presiona 'q' en la terminal
```

## 🔧 Comandos Útiles

### Generación de Código

```bash
# Generar código una vez
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch (regenera automáticamente)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/bloc/auth_bloc_test.dart

# Ejecutar con cobertura
flutter test --coverage
```

### Análisis de Código

```bash
# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Verificar formato
flutter format --set-exit-if-changed lib/
```

### Build

```bash
# Android APK (Debug)
flutter build apk --debug

# Android APK (Release)
flutter build apk --release

# Android App Bundle (para Play Store)
flutter build appbundle --release

# iOS (solo macOS)
flutter build ios --release

# Web
flutter build web --release
```

## 🐛 Debugging

### Limpiar Caché

```bash
# Limpiar build
flutter clean

# Reinstalar dependencias
flutter pub get
```

### Logs

```bash
# Ver logs en tiempo real
flutter logs

# Logs de dispositivo Android
adb logcat

# Logs de dispositivo iOS
idevicesyslog
```

## 📦 Gestión de Dependencias

### Actualizar Dependencias

```bash
# Ver dependencias desactualizadas
flutter pub outdated

# Actualizar dependencias
flutter pub upgrade

# Actualizar dependencias mayores
flutter pub upgrade --major-versions
```

### Añadir Nueva Dependencia

```bash
# Añadir dependencia
flutter pub add nombre_paquete

# Añadir dependencia de desarrollo
flutter pub add --dev nombre_paquete
```

## 🔐 Configuración de API

### Variables de Entorno

Editar `lib/core/constants/app_constants.dart`:

```dart
// Producción
static const String baseUrl = 'https://diabetics-api.jljimenez.es';

// Desarrollo Local
// static const String baseUrl = 'http://localhost:8000';
```

## 📱 Configuración de Plataformas

### Android

```bash
# Abrir proyecto Android en Android Studio
cd android && studio .

# Actualizar Gradle
cd android && ./gradlew wrapper --gradle-version 8.0
```

### iOS

```bash
# Abrir proyecto iOS en Xcode
open ios/Runner.xcworkspace

# Instalar pods
cd ios && pod install
```

### Web

```bash
# Ejecutar en servidor local
flutter run -d chrome --web-port 8080

# Build optimizado
flutter build web --release --web-renderer canvaskit
```

## 🧪 Testing Avanzado

### Integration Tests

```bash
# Ejecutar integration tests
flutter test integration_test/app_test.dart

# Con dispositivo específico
flutter test integration_test/app_test.dart -d chrome
```

### Widget Tests

```bash
# Ejecutar widget tests
flutter test test/screens/

# Con cobertura
flutter test test/screens/ --coverage
```

## 📊 Análisis de Performance

### Profile Mode

```bash
# Ejecutar en modo profile
flutter run --profile

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Análisis de Tamaño

```bash
# Analizar tamaño del APK
flutter build apk --analyze-size

# Analizar tamaño del App Bundle
flutter build appbundle --analyze-size
```

## 🎨 Assets

### Generar Iconos de App

```bash
# Instalar flutter_launcher_icons
flutter pub add --dev flutter_launcher_icons

# Configurar en pubspec.yaml y ejecutar
flutter pub run flutter_launcher_icons
```

### Generar Splash Screen

```bash
# Instalar flutter_native_splash
flutter pub add --dev flutter_native_splash

# Configurar en pubspec.yaml y ejecutar
flutter pub run flutter_native_splash:create
```

## 🚀 Deployment

### Android (Google Play)

```bash
# 1. Build App Bundle
flutter build appbundle --release

# 2. Archivo generado en:
# build/app/outputs/bundle/release/app-release.aab

# 3. Subir a Google Play Console
```

### iOS (App Store)

```bash
# 1. Build iOS
flutter build ios --release

# 2. Abrir Xcode
open ios/Runner.xcworkspace

# 3. Archive y subir a App Store Connect
```

### Web (Hosting)

```bash
# 1. Build Web
flutter build web --release

# 2. Archivos generados en:
# build/web/

# 3. Desplegar en Firebase Hosting, Netlify, etc.
```

## 📚 Recursos Adicionales

### Documentación

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [BLoC Library](https://bloclibrary.dev/)

### Herramientas

- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [VS Code Extensions](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Android Studio Plugin](https://plugins.jetbrains.com/plugin/9212-flutter)

### Comunidad

- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues)
