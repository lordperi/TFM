# 🚀 Guía de Inicio Rápido - DiaBeaty Mobile

## ⚠️ IMPORTANTE: Instalación de Flutter

Este proyecto requiere Flutter SDK. Si aún no lo tienes instalado:

### Windows

```powershell
# 1. Descargar Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# 2. Extraer en C:\src\flutter

# 3. Añadir al PATH
# C:\src\flutter\bin

# 4. Verificar instalación
flutter doctor
```

### Verificar Instalación

```bash
flutter --version
# Debería mostrar: Flutter 3.x.x

flutter doctor
# Debería mostrar checkmarks en:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Chrome (para Web)
# ✓ VS Code / Android Studio
```

---

## 📋 Pasos para Ejecutar el Proyecto

### 1️⃣ Navegar al Directorio Frontend

```bash
cd d:\trabajo\TFM\frontend
```

### 2️⃣ Instalar Dependencias

```bash
flutter pub get
```

**Salida esperada**:

```
Running "flutter pub get" in frontend...
Resolving dependencies...
+ dio 5.4.0
+ flutter_bloc 8.1.3
+ retrofit 4.0.3
...
Got dependencies!
```

### 3️⃣ Generar Código

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Archivos generados**:

- `lib/data/models/auth_models.g.dart`
- `lib/data/datasources/auth_api_client.g.dart`

**Salida esperada**:

```
[INFO] Generating build script...
[INFO] Generating build script completed, took 2.3s
[INFO] Creating build script snapshot...
[INFO] Creating build script snapshot completed, took 3.1s
[INFO] Building new asset graph...
[INFO] Building new asset graph completed, took 1.2s
[INFO] Succeeded after 6.6s with 2 outputs
```

### 4️⃣ Verificar que No Hay Errores

```bash
flutter analyze
```

**Salida esperada**:

```
Analyzing frontend...
No issues found!
```

### 5️⃣ Ejecutar la Aplicación

#### Opción A: Web (Recomendado para desarrollo)

```bash
flutter run -d chrome
```

#### Opción B: Android (requiere emulador o dispositivo)

```bash
# Listar dispositivos
flutter devices

# Ejecutar
flutter run -d android
```

#### Opción C: iOS (solo macOS)

```bash
flutter run -d ios
```

---

## 🎯 Verificación de Funcionamiento

### Pantalla de Login

Al ejecutar la app, deberías ver:

**Modo Adulto** (por defecto):

- Logo médico azul
- Título "DiaBeaty"
- Campos de email y contraseña con bordes sutiles
- Botón azul "Iniciar Sesión"
- Link "Cambiar a Modo Niño"

**Modo Niño** (al cambiar):

- Icono de corazón animado
- Título "¡Bienvenido, Héroe!"
- Campos con bordes gruesos y coloridos
- Botón rosa "🚀 ¡Comenzar Aventura!"
- Fondo con gradiente

### Probar Login

1. Ingresa un email: `test@example.com`
2. Ingresa una contraseña: `password123`
3. Presiona "Iniciar Sesión"

**Comportamiento esperado**:

- Si las credenciales son correctas: Mensaje verde "¡Login exitoso!"
- Si son incorrectas: Mensaje rojo "Credenciales incorrectas"
- Si hay error de red: Mensaje "Error de conexión"

---

## 🔧 Solución de Problemas Comunes

### Error: "Flutter SDK not found"

```bash
# Verificar que Flutter está en el PATH
flutter --version

# Si no funciona, añadir al PATH manualmente
# Windows: Variables de entorno > Path > Añadir C:\src\flutter\bin
```

### Error: "Gradle build failed" (Android)

```bash
# Limpiar proyecto
flutter clean
flutter pub get

# Actualizar Gradle
cd android
./gradlew wrapper --gradle-version 8.0
cd ..
```

### Error: "CocoaPods not installed" (iOS)

```bash
# Instalar CocoaPods
sudo gem install cocoapods

# Instalar pods
cd ios
pod install
cd ..
```

### Error: "Code generation failed"

```bash
# Limpiar y regenerar
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "Dio/Retrofit not found"

```bash
# Verificar que las dependencias están instaladas
flutter pub get

# Si persiste, eliminar pubspec.lock y reinstalar
rm pubspec.lock
flutter pub get
```

---

## 🧪 Ejecutar Tests

### Unit Tests

```bash
flutter test test/bloc/auth_bloc_test.dart
```

### Widget Tests

```bash
flutter test test/screens/login_screen_test.dart
```

### Todos los Tests

```bash
flutter test
```

---

## 🎨 Hot Reload

Durante el desarrollo, puedes hacer cambios en el código y ver los resultados instantáneamente:

1. Ejecuta `flutter run`
2. Modifica un archivo (ej: cambiar un color en `app_theme.dart`)
3. Presiona `r` en la terminal para Hot Reload
4. Los cambios se reflejan inmediatamente

**Hot Restart** (para cambios más profundos):

- Presiona `R` (mayúscula) en la terminal

---

## 📱 Configurar Dispositivos

### Android Emulator

```bash
# Listar emuladores disponibles
flutter emulators

# Crear nuevo emulador
flutter emulators --create

# Ejecutar emulador
flutter emulators --launch <emulator_id>
```

### Dispositivo Físico Android

1. Habilitar "Opciones de desarrollador" en el dispositivo
2. Habilitar "Depuración USB"
3. Conectar por USB
4. Ejecutar `flutter devices` para verificar

### iOS Simulator (solo macOS)

```bash
# Abrir simulator
open -a Simulator

# Ejecutar app
flutter run -d ios
```

---

## 🌐 Ejecutar en Web

### Desarrollo

```bash
flutter run -d chrome --web-port 8080
```

Abre: <http://localhost:8080>

### Build para Producción

```bash
flutter build web --release

# Archivos generados en: build/web/
```

---

## 📦 Build para Producción

### Android APK

```bash
flutter build apk --release

# Archivo generado en:
# build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release

# Archivo generado en:
# build/app/outputs/bundle/release/app-release.aab
```

### iOS (solo macOS)

```bash
flutter build ios --release

# Luego abrir en Xcode:
open ios/Runner.xcworkspace
```

---

## 🔐 Configurar API Backend

### Desarrollo Local

Si tienes el backend corriendo localmente:

1. Editar `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'http://localhost:8000';
```

1. Hot Restart (`R`) para aplicar cambios

### Producción

Por defecto apunta a:

```dart
static const String baseUrl = 'https://diabetics-api.jljimenez.es';
```

---

## 📊 DevTools

### Abrir DevTools

```bash
# Ejecutar app
flutter run -d chrome

# En otra terminal, abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

Abre: <http://localhost:9100>

**Funcionalidades**:

- Inspector de widgets
- Performance profiler
- Network inspector
- Logs

---

## 🎯 Próximos Pasos

Una vez que la app esté corriendo:

1. **Explorar el Dual UX**
   - Cambiar entre Modo Adulto y Modo Niño
   - Observar los cambios de tema

2. **Probar la Autenticación**
   - Intentar login con credenciales del backend
   - Verificar que el token se guarda

3. **Revisar el Código**
   - `lib/presentation/screens/auth/login_screen.dart` - UI
   - `lib/presentation/bloc/auth/auth_bloc.dart` - Lógica
   - `lib/core/theme/app_theme.dart` - Temas

4. **Continuar con Sprint 2**
   - Implementar Home Screen
   - Añadir gráficos de glucosa
   - Crear Bolus Calculator

---

## 📚 Recursos Útiles

### Documentación del Proyecto

- `frontend/README.md` - Documentación general
- `docs/FLUTTER_ARCHITECTURE.md` - Arquitectura detallada
- `docs/FLUTTER_SCRIPTS.md` - Scripts de desarrollo
- `docs/PROYECTO_RESUMEN.md` - Resumen ejecutivo

### Documentación Externa

- [Flutter Docs](https://docs.flutter.dev/)
- [BLoC Library](https://bloclibrary.dev/)
- [Dio](https://pub.dev/packages/dio)
- [Retrofit](https://pub.dev/packages/retrofit)

### Comunidad

- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## ✅ Checklist de Verificación

Antes de empezar a desarrollar, verifica:

- [ ] Flutter SDK instalado (`flutter --version`)
- [ ] `flutter doctor` sin errores críticos
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Código generado (`build_runner build`)
- [ ] App ejecutándose sin errores (`flutter run`)
- [ ] Hot Reload funcionando (presiona `r`)
- [ ] Dual UX funcionando (cambiar entre modos)
- [ ] Login conectado al backend

---

**¡Listo para desarrollar! 🚀**

Si tienes algún problema, consulta la sección de "Solución de Problemas" o revisa la documentación en `docs/`.
