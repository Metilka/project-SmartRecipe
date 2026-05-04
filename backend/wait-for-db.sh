#!/bin/sh
# Ждём готовности Postgres перед запуском приложения.

set -e

HOST="${DB_HOST:-db}"
PORT="${DB_PORT:-5432}"
USER="${DB_USER:-postgres}"
DBNAME="${DB_NAME:-med_diet_db}"

echo "[wait-for-db] Waiting for Postgres at ${HOST}:${PORT}/${DBNAME}..."

TRIES=0
MAX_TRIES=60

until PGPASSWORD="${DB_PASSWORD}" psql -h "${HOST}" -p "${PORT}" -U "${USER}" -d "${DBNAME}" -c '\q' > /dev/null 2>&1; do
  TRIES=$((TRIES + 1))
  if [ "${TRIES}" -ge "${MAX_TRIES}" ]; then
    echo "[wait-for-db] Timed out waiting for Postgres." >&2
    exit 1
  fi
  echo "[wait-for-db] Still waiting... (${TRIES}/${MAX_TRIES})"
  sleep 1
done

echo "[wait-for-db] Postgres is ready."
