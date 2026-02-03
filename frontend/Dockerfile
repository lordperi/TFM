# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app

# Copy pubspec files first to cache dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the app source code
COPY . .

# Build the web application release
# Note: We use --release for optimized build.
# PWA (Progressive Web App) approach.
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy the build artifacts from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy our custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
