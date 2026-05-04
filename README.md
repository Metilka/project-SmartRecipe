# SmartRecipe / Dietrix

Веб-приложение для подбора рецептов под медицинские диеты.
Фронтенд (React + Vite) подключён к Flask API и PostgreSQL.

## Что есть в этой версии

- Реальный API без моков: HTTP-клиент с JWT, авто-refresh, обработкой 401.
- Регистрация и вход по email/паролю без обязательного подтверждения почты.
- Гостевой режим (выбор диеты → лента) и персональный режим (профиль → рекомендации).
- Дневной план («корзина»): добавление рецептов, подсчёт нутриентов, предупреждения о превышении норм диеты и личных целей.
- Docker Compose: весь стек (Postgres + Flask + React/nginx) запускается одной командой.

## Структура проекта

```
project-SmartRecipe/
├── backend/                 # Flask API (gunicorn)
│   ├── app/                 # routes, models, services, auth
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── wait-for-db.sh       # ждёт готовности Postgres перед стартом
│   └── run.py
├── frontend/                # React + Vite SPA
│   ├── src/api/             # HTTP-клиент и API-обёртки
│   ├── src/components/
│   ├── src/pages/
│   ├── Dockerfile           # multistage: build vite -> nginx
│   ├── nginx.conf           # /api -> backend, SPA fallback
│   └── package.json
├── database/
│   ├── seed.sql             # дамп схемы и данных (pg_dump)
│   └── init-db.sh           # авто-загрузка seed.sql при первом запуске
├── docker-compose.yml
├── .env.example
└── README.md
```

## Требования

- Docker 20.10+ и Docker Compose v2 (`docker compose`, без дефиса)
- 2 ГБ свободной RAM, ~1.5 ГБ места на диске для образов и БД

Если запускаете без Docker, понадобится: Python 3.10+, Node.js 20+, PostgreSQL 14+.

---

## Быстрый запуск через Docker (рекомендуется)

### 1. Подготовка `.env`

Windows (cmd):
```cmd
cd project-SmartRecipe
copy .env.example .env
```

Linux/Mac:
```bash
cd project-SmartRecipe
cp .env.example .env
```

По желанию замените `JWT_SECRET_KEY` на длинную случайную строку.

### 2. Запуск

```
docker compose up --build -d
```

Первый запуск занимает 2-3 минуты:
- сборка образов backend и frontend,
- инициализация Postgres из `seed.sql` (~1 МБ, ~50 тысяч строк).

Когда всё запустится:
- **Фронт:** http://localhost:8080
- **Backend API:** http://localhost:5000
- **Postgres:** `localhost:5432`, логин/пароль из `.env`

### 3. Проверка

Откройте http://localhost:8080 — должна появиться страница выбора диеты.

Логи:
```bash
docker compose logs -f backend     # логи Flask
docker compose logs -f frontend    # логи nginx
docker compose logs -f db          # логи Postgres
```

### 4. Остановка

```bash
docker compose down                # остановить, данные БД сохранены
docker compose down -v             # + удалить том БД (полный сброс)
```

## Запуск без Docker (для разработки)

### Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Настройте .env в корне backend/ или экспортируйте переменные:
export DB_HOST=localhost DB_PORT=5432 DB_USER=postgres DB_PASSWORD=postgres DB_NAME=med_diet_db
export JWT_SECRET_KEY=dev-secret

# Перед первым запуском загрузите seed.sql (см. ниже)
python run.py                      # http://localhost:5000
```

### База данных

Загрузите `database/seed.sql` в локальный Postgres. Дамп сделан с Windows-машины
(локаль `Russian_Russia.1251`), поэтому может потребоваться pgAdmin или psql под Windows.
Альтернатива — поднять только Postgres через Docker:

```bash
docker compose up -d db
```

### Frontend

```bash
cd frontend
npm install
npm run dev                        # http://localhost:5173
```

Vite в dev-режиме проксирует `/api/*` на `http://localhost:5000` (см. `vite.config.js`).
Если backend на другом адресе, задайте `VITE_BACKEND_URL` в `.env.local`.

---

## Тесты

Frontend unit-тесты запускаются через Vitest:

```bash
cd frontend
npm install
npm test
```

Backend unit-тесты можно запустить внутри Docker-контейнера:

```bash
docker compose up --build -d backend
docker compose exec -T backend python -m unittest discover -s tests
```

Если backend-зависимости установлены локально, те же тесты можно запустить без Docker:

```bash
cd backend
python -m unittest discover -s tests
```

Для проверки production-сборки frontend:

```bash
cd frontend
npm run build
```

---

## Решение проблем

### «Не удалось связаться с сервером»

- Проверьте, что все три контейнера живы: `docker compose ps`
- Логи бэка: `docker compose logs backend` — обычно ошибка в подключении к Postgres
- Если seed.sql загрузился с ошибками, БД может быть частично пустой — пересоздайте том:
  ```bash
  docker compose down -v
  docker compose up --build -d
  ```

### Порт 8080 / 5000 / 5432 уже занят

Поправьте порты в `.env`:
```
FRONTEND_PORT=8081
BACKEND_EXTERNAL_PORT=5001
DB_EXTERNAL_PORT=5433
```

### Кодировка в seed.sql

Дамп сгенерирован с `LOCALE = 'Russian_Russia.1251'`. Скрипт `init-db.sh`
вырезает эту настройку, а БД создаётся с UTF-8. Если видите кракозябры в
данных — пересоздайте том (`docker compose down -v`) и попробуйте снова с UTF-8 локалью.

---

## Что внутри: коротко об архитектуре

**Backend** — Flask + SQLAlchemy + Flask-JWT-Extended + Flask-Bcrypt.
Слой рекомендаций (`app/services/recommendations.py`, `scoring.py`) фильтрует и
ранжирует рецепты по правилам диеты, медицинским флагам и личным предпочтениям.

**Frontend** — React 19 + React Router 7 + Vite. Архитектура data-слоя:

- `src/api/client.js` — fetch-клиент с авто-refresh access-токенов на 401
- `src/api/auth.js` — register / login / logout / me
- `src/api/index.js` — diets / recipes / profile / recommendations
- `src/hooks/useDietrixStore.jsx` — глобальное состояние (Context API)

Все мок-данные удалены: фронт работает только с настоящим бэком. Гостевой режим использует публичные эндпоинты `/diets`, `/recipes`, `/feed`. Авторизованный режим — `/profile`, `/recommendations`, `/recipes/:id/personal`.
