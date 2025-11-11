#!/usr/bin/env bash
set -euo pipefail
echo "[db-dry-run] starting..."

link_and_push() {
  echo "[db-dry-run] linking project (requires SUPABASE_PROJECT_REF + SUPABASE_DB_PASSWORD)"
  supabase link --project-ref "${SUPABASE_PROJECT_REF:?}" --password "${SUPABASE_DB_PASSWORD:?}"
  supabase db push --dry-run --linked
}

run_with_db_url() {
  echo "[db-dry-run] using --db-url"
  local tmp_err
  tmp_err="$(mktemp)"
  if ! supabase db push --dry-run --db-url "$SUPABASE_DB_URL" 2> >(tee "$tmp_err" >&2); then
    if grep -qi "invalid userinfo" "$tmp_err"; then
      echo "[db-dry-run] detected invalid userinfo in SUPABASE_DB_URL; falling back to supabase link..."
      rm -f "$tmp_err"
      link_and_push
      return
    fi
    echo "[db-dry-run] supabase db push via --db-url failed (see logs above)." >&2
    rm -f "$tmp_err"
    exit 1
  fi
  rm -f "$tmp_err"
}

if [[ -n "${SUPABASE_DB_URL:-}" ]]; then
  run_with_db_url
else
  link_and_push
fi

echo "[db-dry-run] done."
