# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app

# 1. Copiamos SOLO el yaml para no arrastrar conflictos de versiones de Windows
COPY pubspec.yaml ./

# 2. Instalamos dependencias (Esto generará un pubspec.lock fresco para Linux)
RUN flutter pub get

# 3. Copiamos el resto del código
COPY . .

# 4. 🔥 CRÍTICO: Generar los archivos .g.dart (Clean Architecture)
# Sin esto, la compilación falla porque no existen los modelos JSON
RUN dart run build_runner build --delete-conflicting-outputs

# 5. Construir la Web
# Añadimos --verbose para ver el error real si falla
RUN flutter build web --release --no-tree-shake-icons --verbose

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Limpieza y Configuración
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
