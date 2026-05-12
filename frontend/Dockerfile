FROM node:20-alpine AS build

WORKDIR /app

# package-lock.json включает npm ci и ускоряет повторные сборки.
COPY package*.json ./
RUN npm config set registry https://registry.npmjs.org/ && npm config set fetch-retries 5 && npm config set fetch-retry-mintimeout 20000 && npm config set fetch-retry-maxtimeout 120000 && npm config set fetch-timeout 600000 && if [ -f package-lock.json ]; then npm ci --no-audit --no-fund --loglevel=verbose; else npm install --no-audit --no-fund --loglevel=verbose; fi

COPY . .

RUN npm run build

FROM nginx:1.27-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
