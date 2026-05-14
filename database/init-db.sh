set -e

RAW_SEED="/seed-raw/seed.sql"
PREPARED_SEED="/tmp/seed-prepared.sql"

if [ ! -f "${RAW_SEED}" ]; then
    echo "[init-db] ERROR: ${RAW_SEED} not found. Seed file is not mounted." >&2
    exit 1
fi

echo "[init-db] Preparing seed SQL..."
awk '
    # пропускаем \restrict, \unrestrict, \connect строки
    /^\\restrict/     { next }
    /^\\unrestrict/   { next }
    /^\\connect/      { next }

    # пропускаем DROP DATABASE (одна строка)
    /^DROP DATABASE/  { next }

    # пропускаем многострочный блок CREATE DATABASE
    /^CREATE DATABASE/ {
        in_create_db = 1
        next
    }
    in_create_db {
        # пропускаем всё до строки, заканчивающейся на ;
        if ($0 ~ /;[[:space:]]*$/) {
            in_create_db = 0
        }
        next
    }

    # пропускаем ALTER DATABASE ... OWNER TO ...
    /^ALTER DATABASE[[:space:]]+med_diet_db[[:space:]]+OWNER/ { next }

    { print }
' "${RAW_SEED}" > "${PREPARED_SEED}"

echo "[init-db] Applying seed to ${POSTGRES_DB}..."

psql \
    --username "${POSTGRES_USER}" \
    --dbname "${POSTGRES_DB}" \
    --set ON_ERROR_STOP=0 \
    --quiet \
    --file "${PREPARED_SEED}"

echo "[init-db] Seed applied."
