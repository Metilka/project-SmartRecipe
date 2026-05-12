FROM python:3.12-slim

# Runtime-зависимости для PostgreSQL и health/startup-скриптов.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpq5 \
        postgresql-client \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Зависимости отдельным слоем для кеша Docker.
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

COPY . .

# Ожидаем готовность Postgres перед запуском API.
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
RUN chmod +x /usr/local/bin/wait-for-db.sh

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FLASK_APP=run.py \
    BACKEND_PORT=5000

EXPOSE 5000

CMD ["sh", "-c", "wait-for-db.sh && gunicorn -b 0.0.0.0:${BACKEND_PORT} -w 2 --timeout 90 run:app"]
