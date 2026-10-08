FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/*

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static website files
COPY . /usr/share/nginx/html/

# Remove non-web files inside container html dir
RUN rm -f /usr/share/nginx/html/Dockerfile \
          /usr/share/nginx/html/docker-compose.yml \
          /usr/share/nginx/html/nginx.conf \
          /usr/share/nginx/html/README.md

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
