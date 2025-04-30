# Stage 1: build React app
FROM node:18-alpine AS builder
WORKDIR /app

# Копируем package.json и package-lock.json, устанавливаем зависимости
COPY package.json package-lock.json ./
RUN npm ci

# Копируем исходники и билдим
COPY . .
RUN npm run build

# Stage 2: serve with nginx
FROM nginx:stable-alpine AS runner

# Удаляем дефолтную конфигурацию (если нужно)
RUN rm /etc/nginx/conf.d/default.conf

# Копируем готовый билд
COPY --from=builder /app/build /usr/share/nginx/html

# Добавляем базовые настройки nginx для SPA (History API)
COPY nginx.conf /etc/nginx/conf.d/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"] 