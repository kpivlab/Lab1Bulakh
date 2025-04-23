# Використовуємо офіційний образ Nginx
FROM nginx:latest

# Копіюємо HTML та CSS у директорію, яку Nginx використовує як кореневу
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./styles.css /usr/share/nginx/html/styles.css

# Відкриваємо порт 80 для доступу
EXPOSE 80
