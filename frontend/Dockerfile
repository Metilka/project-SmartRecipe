# ---- Этап 1: собираем SPA ---------------------------------------------------
FROM node:20-alpine AS build

WORKDIR /app

# Сначала lock-файлы для кэша npm
COPY package.json ./
# package-lock.json может отсутствовать — используем wildcard
COPY package-lock.json* ./

RUN npm install

COPY . .

# Собираем в /app/dist
RUN npm run build

# ---- Этап 2: nginx, который отдаёт сборку и проксирует /api -> backend ------
FROM nginx:1.27-alpine

# Свой конфиг вместо дефолтного
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Статика
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
