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

# ─────────────────────────────────────────────────────────────────────────────
# Connection Setup
# ─────────────────────────────────────────────────────────────────────────────
# NOTE: Using postgres superuser is intentional for RLS smoke tests.
# The superuser privilege is required to execute SET ROLE statements that
# simulate different authentication contexts (authenticated, anon, service_role).
# RLS policies are actually tested by switching roles via SET ROLE, not by
# the connection user's privileges. The test flow is:
#   1. Connect as postgres (superuser)
#   2. SET ROLE authenticated (simulate app client)
#   3. Set JWT claims via set_config()
#   4. Execute queries that should respect RLS policies
# A less-privileged test user would require CREATEROLE or similar permissions
# to SET ROLE, which defeats the purpose. See: PostgreSQL SET ROLE documentation.
# ─────────────────────────────────────────────────────────────────────────────
# Authentication Note:
# The db_url below deliberately omits the password. Authentication is handled
# via the PGPASSWORD environment variable (set from SUPABASE_DB_PASSWORD in
# .env.local). This approach avoids URL-encoding issues with special characters.
# If you ever need to embed the password in the URL, ensure special characters
# (like @, %, /, etc.) are URL-encoded to prevent connection failures.
# ─────────────────────────────────────────────────────────────────────────────
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
negative_sql="${script_dir}/rls_smoke_negative.sql"
if [[ -f "${negative_sql}" ]]; then
  run_psql_file "${negative_sql}"
else
  # TODO: track missing negative RLS tests when rls_smoke_negative.sql is absent.
  echo "WARN: run_psql_file skipped; rls_smoke_negative.sql not found at ${negative_sql}." >&2
fi

echo "OK: RLS smoke tests passed."
