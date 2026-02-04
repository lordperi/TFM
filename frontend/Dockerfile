# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app

# Copiamos primero las dependencias para aprovechar la caché de Docker
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiamos el resto del código
COPY . .

# -----------------------------------------------------------
# 🔥 PASO CRÍTICO AÑADIDO: Generar archivos .g.dart
# Sin esto, la compilación fallará porque faltan los modelos generados
# -----------------------------------------------------------
RUN dart run build_runner build --delete-conflicting-outputs

# Build the web application release
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Limpiar assets por defecto
RUN rm -rf /usr/share/nginx/html/*

# Copiar los artefactos construidos en la etapa anterior
COPY --from=build /app/build/web /usr/share/nginx/html

# Copiar tu configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
