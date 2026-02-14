# STAGE 1: Build Environment
FROM ubuntu:22.04 AS build-env

# Prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
# Using 3.16.x or stable to match typical requirements. Adjust version if needed.
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor -v

# Set working directory
WORKDIR /app

# Copy dependency definitions
COPY pubspec.yaml pubspec.lock ./

# Get packages (this layer will be cached if pubspec hasn't changed)
RUN flutter pub get

# Copy source code
COPY . .

# Build args
ARG API_BASE_URL
ENV API_BASE_URL=${API_BASE_URL}

# Generate code (Already generated locally, skip in Docker to avoid errors)
# RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build for Web
# --release is default for build web
RUN flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL="$API_BASE_URL"

# STAGE 2: Runtime Environment (Nginx)
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets from Stage 1
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
