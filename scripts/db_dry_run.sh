#!/usr/bin/env bash
set -euo pipefail
echo "[db-dry-run] starting..."
if [[ -n "${SUPABASE_DB_URL:-}" ]]; then
  echo "[db-dry-run] using --db-url"
  supabase db push --dry-run --db-url "$SUPABASE_DB_URL"
else
  echo "[db-dry-run] linking project (requires SUPABASE_PROJECT_REF + SUPABASE_DB_PASSWORD)"
  supabase link --project-ref "${SUPABASE_PROJECT_REF:?}" --password "${SUPABASE_DB_PASSWORD:?}"
  supabase db push --dry-run --linked
fi
echo "[db-dry-run] done."

