#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"
env_file="${repo_root}/.env.local"

if [[ ! -f "${env_file}" ]]; then
  echo "Missing ${env_file}. Create it with SUPABASE_PROJECT_REF and SUPABASE_DB_PASSWORD." >&2
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "psql not found. Install PostgreSQL client tools and retry." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${env_file}"
set +a

: "${SUPABASE_PROJECT_REF:?SUPABASE_PROJECT_REF is required (in .env.local)}"
: "${SUPABASE_DB_PASSWORD:?SUPABASE_DB_PASSWORD is required (in .env.local)}"

db_url="postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require"

run_psql_file() {
  local sql_file="$1"

  if [[ ! -f "${sql_file}" ]]; then
    echo "Missing SQL file: ${sql_file}" >&2
    exit 1
  fi

  PGPASSWORD="${SUPABASE_DB_PASSWORD}" \
    psql "${db_url}" \
      -v ON_ERROR_STOP=1 \
      -P pager=off \
      -f "${sql_file}"
}

run_psql_file "${script_dir}/rls_smoke.sql"
run_psql_file "${script_dir}/rls_smoke_negative.sql"

echo "OK: RLS smoke tests passed."
