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

# Cleanup: unlink project on exit and remove temp pgpass file
LINKED=false
PGPASSFILE=""
cleanup() {
  # Remove pgpass file if it exists (security: don't leave credentials on disk)
  if [[ -n "${PGPASSFILE:-}" && -f "${PGPASSFILE}" ]]; then
    rm -f "${PGPASSFILE}"
  fi
  if [[ "$LINKED" == "true" ]]; then
    echo "[db-push-smoke] unlinking project"
    supabase unlink 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "[db-push-smoke] linking project ref ${SUPABASE_PROJECT_REF}"
# Security: Pass password via stdin (here-string) to avoid exposure in process listings
supabase link --project-ref "${SUPABASE_PROJECT_REF}" <<< "${SUPABASE_DB_PASSWORD}"
LINKED=true

echo "[db-push-smoke] applying migrations (linked)"
supabase db push --linked

export PGCONNECT_TIMEOUT=10
DB_HOST="db.${SUPABASE_PROJECT_REF}.supabase.co"

# Security: Use pgpass file instead of PGPASSWORD env var to avoid exposure in process listings
PGPASSFILE=$(mktemp)
echo "${DB_HOST}:5432:postgres:postgres:${SUPABASE_DB_PASSWORD}" > "${PGPASSFILE}"
chmod 600 "${PGPASSFILE}"
export PGPASSFILE

DB_URL="postgresql://postgres@${DB_HOST}:5432/postgres?sslmode=require"

# File existence checks for required SQL test files
RLS_SMOKE="supabase/tests/rls_smoke.sql"
RLS_SMOKE_NEG="supabase/tests/rls_smoke_negative.sql"

if [[ ! -f "${RLS_SMOKE}" ]]; then
  echo "[db-push-smoke] ERROR: Missing required test file: ${RLS_SMOKE}" >&2
  exit 1
fi

if [[ ! -f "${RLS_SMOKE_NEG}" ]]; then
  echo "[db-push-smoke] ERROR: Missing required test file: ${RLS_SMOKE_NEG}" >&2
  exit 1
fi

echo "[db-push-smoke] running RLS smoke tests via ${DB_HOST}"
psql "${DB_URL}" -v ON_ERROR_STOP=1 -P pager=off -f "${RLS_SMOKE}"
psql "${DB_URL}" -v ON_ERROR_STOP=1 -P pager=off -f "${RLS_SMOKE_NEG}"

echo "[db-push-smoke] OK"

