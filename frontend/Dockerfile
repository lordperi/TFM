# YA NO HAY FLUTTER AQUÍ. SOLO NGINX.
FROM nginx:alpine

# 1. Limpiamos el servidor por defecto
RUN rm -rf /usr/share/nginx/html/*

# 2. Copiamos la carpeta que TU has compilado en Windows y subido a Git
# La ruta depende de tu estructura, pero suele ser esta:
COPY build/web /usr/share/nginx/html

# 3. Copiamos la config de Nginx (asegúrate de que existe el archivo nginx.conf)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 4. Exponemos y arrancamos
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
