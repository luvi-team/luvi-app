#!/usr/bin/env bash
set -euo pipefail

DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
if [[ -z "${REPORT:-}" ]]; then
  REPORT="$DIR/_drift_report.md"
fi

pass() { printf -- "- [OK] %s\n" "$1" >>"$REPORT"; }
fail() { printf -- "- [DRIFT] %s\n" "$1" >>"$REPORT"; EXIT=1; }

EXIT=0

# Dependency check (ripgrep)
if ! command -v rg >/dev/null 2>&1; then
  printf 'error: Dependency ripgrep (rg) is not installed.\n' >&2
  exit 1
fi

printf "# Agents Drift Report\n\nGenerated: %s\n\n" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" >"$REPORT"

# 1) Dossiers 01–05: acceptance_version 1.1 present, and no 1.0 remnants
#    Dynamisch ermitteln; Fallback auf bekannte Liste
FOUND=0
for path in "$DIR"/0*-*.md; do
  [ -f "$path" ] || continue
  FOUND=1
  f="$(basename "$path")"
  if rg -n "^acceptance_version:\s*\"?1\.1\"?\s*$" "$path" >/dev/null 2>&1; then
    pass "$f: acceptance_version 1.1"
  else
    fail "$f: acceptance_version 1.1 fehlt"
  fi
  if rg -n "^acceptance_version:\s*\"?1\.0\"?\s*$" "$path" >/dev/null 2>&1; then
    fail "$f: enthält noch acceptance_version 1.0"
  else
    pass "$f: keine 1.0-Blöcke mehr"
  fi
  if rg -n "^---$" "$path" >/dev/null 2>&1 && rg -n "^role:\s*" "$path" >/dev/null 2>&1; then
    pass "$f: YAML Front-Matter vorhanden"
  else
    fail "$f: YAML Front-Matter fehlt"
  fi
done
if [ "$FOUND" -eq 0 ]; then
  # Fallback (historische Liste)
  for f in 01-ui-frontend.md 02-api-backend.md 03-db-admin.md 04-dataviz.md 05-qa-dsgvo.md; do
    path="$DIR/$f"
    [ -f "$path" ] || { fail "$f: Datei nicht gefunden"; continue; }
    if rg -n "^acceptance_version:\s*\"?1\.1\"?\s*$" "$path" >/dev/null 2>&1; then
      pass "$f: acceptance_version 1.1"
    else
      fail "$f: acceptance_version 1.1 fehlt"
    fi
    if rg -n "^acceptance_version:\s*\"?1\.0\"?\s*$" "$path" >/dev/null 2>&1; then
      fail "$f: enthält noch acceptance_version 1.0"
    else
      pass "$f: keine 1.0-Blöcke mehr"
    fi
    if rg -n "^---$" "$path" >/dev/null 2>&1 && rg -n "^role:\s*" "$path" >/dev/null 2>&1; then
      pass "$f: YAML Front-Matter vorhanden"
    else
      fail "$f: YAML Front-Matter fehlt"
    fi
  done
fi

# 2) README verweist auf _acceptance_v1.1.md
if rg -n "_acceptance_v1\.1\.md" "$DIR/README.md" >/dev/null 2>&1; then
  pass "README.md: SSOT-Verweis auf _acceptance_v1.1.md"
else
  fail "README.md: SSOT-Verweis fehlt oder zeigt auf alte Version"
fi

# 3) AGENTS.md enthält v1.1-Hinweis oder Pfad
ROOT="$(CDPATH= cd -- "$DIR/../.." && pwd)"
if rg -n "_acceptance_v1\.1\.md|SSOT Acceptance v1\.1" "$ROOT/AGENTS.md" >/dev/null 2>&1; then
  pass "AGENTS.md: v1.1-Hinweis/Pfad vorhanden"
else
  fail "AGENTS.md: v1.1-Hinweis/Pfad fehlt"
fi

# 3b) AGENTS.md referenziert das verbindliche Antwortformat
if rg -n "docs/engineering/assistant-answer-format\.md" "$ROOT/AGENTS.md" >/dev/null 2>&1; then
  pass "AGENTS.md: Antwortformat-Verweis vorhanden"
else
  fail "AGENTS.md: Antwortformat-Verweis fehlt"
fi

# 3c) AGENTS.md verlinkt die Auto-Role Map (SSOT)
if rg -n "context/agents/_auto_role_map\.md" "$ROOT/AGENTS.md" >/dev/null 2>&1; then
  pass "AGENTS.md: Auto-Role Map verlinkt"
else
  fail "AGENTS.md: Auto-Role Map-Verweis fehlt"
fi

# 3d) CLAUDE.md verlinkt die Auto-Role Map (SSOT)
if [ -f "$ROOT/CLAUDE.md" ]; then
  if rg -n "context/agents/_auto_role_map\.md" "$ROOT/CLAUDE.md" >/dev/null 2>&1; then
    pass "CLAUDE.md: Auto-Role Map (SSOT) verlinkt"
  else
    fail "CLAUDE.md: Auto-Role Map (SSOT) fehlt oder veraltet"
  fi
else
  pass "CLAUDE.md: Datei nicht gefunden (Interop optional)"
fi

# 3e) CLAUDE.md referenziert Antwortformat (CLI)
if [ -f "$ROOT/CLAUDE.md" ]; then
  if rg -n "docs/engineering/assistant-answer-format\.md" "$ROOT/CLAUDE.md" >/dev/null 2>&1; then
    pass "CLAUDE.md: Antwortformat-Verweis vorhanden"
  else
    fail "CLAUDE.md: Antwortformat-Verweis fehlt"
  fi
fi

# 4) Soft-Gates: Operativer Modus vorhanden
for s in reqing-ball.md ui-polisher.md; do
  if rg -n "^#+\\s*Operativer Modus" "$DIR/$s" >/dev/null 2>&1; then
    pass "$s: Operativer Modus vorhanden"
  else
    fail "$s: Operativer Modus fehlt"
  fi
done

printf "\nExit status: %s\n" "$( [ "$EXIT" -eq 0 ] && echo OK || echo DRIFT )" >>"$REPORT"
exit "$EXIT"
