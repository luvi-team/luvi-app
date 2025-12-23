#!/usr/bin/env bash
set -euo pipefail

# Apply Supabase migrations to the linked project and run RLS smoke tests.
#
# Usage:
#   scripts/db_push_and_smoke.sh .env.staging.local
#   scripts/db_push_and_smoke.sh .env.production.local
#
# Required env vars (from env file):
#   SUPABASE_PROJECT_REF
#   SUPABASE_DB_PASSWORD
#
# Notes:
# - Secrets must live only in local env files (ignored by .gitignore).
# - Uses `supabase db push --linked` to keep `supabase_migrations.schema_migrations` in sync.
# - Uses direct Postgres connection for smoke tests (psql) afterwards.

ENV_FILE="${1:-.env.local}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "[db-push-smoke] ERROR: env file not found: ${ENV_FILE}" >&2
  exit 2
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

: "${SUPABASE_PROJECT_REF:?SUPABASE_PROJECT_REF missing (project ref, e.g. cwloioweaqvhibuzdwpi)}"
: "${SUPABASE_DB_PASSWORD:?SUPABASE_DB_PASSWORD missing (db password)}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "[db-push-smoke] ERROR: supabase CLI not found in PATH" >&2
  exit 127
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "[db-push-smoke] ERROR: psql not found in PATH" >&2
  exit 127
fi

echo "[db-push-smoke] linking project ref ${SUPABASE_PROJECT_REF}"
# Security: Pass password via stdin (here-string) to avoid exposure in process listings
supabase link --project-ref "${SUPABASE_PROJECT_REF}" <<< "${SUPABASE_DB_PASSWORD}"

echo "[db-push-smoke] applying migrations (linked)"
supabase db push --linked

export PGCONNECT_TIMEOUT=10
export PGPASSWORD="${SUPABASE_DB_PASSWORD}"
DB_HOST="db.${SUPABASE_PROJECT_REF}.supabase.co"
DB_URL="postgresql://postgres@${DB_HOST}:5432/postgres?sslmode=require"

echo "[db-push-smoke] running RLS smoke tests via ${DB_HOST}"
psql "${DB_URL}" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke.sql
psql "${DB_URL}" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke_negative.sql

echo "[db-push-smoke] OK"

