# 📱 DiaBeaty Frontend (Flutter)

Arquitectura y guías de desarrollo para la aplicación móvil/web hecha en Flutter.

## 🏗️ Arquitectura

Seguimos **Clean Architecture** estructurada por *Features* (Nutrición, Auth, Dashboard). Uso estricto de **BLoC** para gestión de esto.

Para detalles profundos de arquitectura, ver [Architecture Guide](architecture.md).

## 🚀 Build Process (Web)

Debido a limitaciones de memoria en el servidor de despliegue, la compilación de Flutter Web se realiza **LOCALMENTE** y los artefactos se suben al repositorio.

### Comandos de Compilación

```bash
# 1. Limpiar (Opcional pero recomendado)
flutter clean
flutter pub get

# 2. Generar código (JSON Serializable, Retrofit, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Compilar Web Release
flutter build web --release --no-tree-shake-icons
```

Esto generará la carpeta `build/web`.

### Despliegue

1. Asegúrate de que `build/web` está incluida en tu commit.
2. Haz Push a `main`.
3. Coolify desplegará el contenedor Nginx con estos archivos estáticos.

## 📂 Estructura de Carpetas

* `lib/core`: Utilidades, red (`DioClient`), constantes.
* `lib/data`: Repositorios, Modelos (DTOs), Data Sources.
* `lib/domain`: Entidades puras (si aplica), Interfaces de repositorios.
* `lib/presentation`: Screens, Widgets y BLoCs.
