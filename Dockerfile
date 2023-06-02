# build front-end
FROM node:lts-alpine AS builder

COPY ./ /app
WORKDIR /app

RUN apk add --no-cache git \
    && npm install pnpm -g \
    && pnpm install \
    && pnpm run build \
    && rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache /tmp/*

# service
FROM nginx:mainline-alpine-slim

#COPY /service /app
COPY --from=builder /app/dist /usr/share/nginx/html

WORKDIR /app
RUN echo 'server {\
    listen 80;\
    server_name _;\
    location / {\
      root /usr/share/nginx/html;\
      index index.html;\
    }\
    location /api {\
      proxy_pass http://chat-java:8080/api;\
      proxy_set_header Host $host;\
      proxy_set_header X-Real-IP $remote_addr;\
      proxy_set_header X-Forwarded-Proto $scheme;\
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
    }\
}' > /etc/nginx/conf.d/default.conf


