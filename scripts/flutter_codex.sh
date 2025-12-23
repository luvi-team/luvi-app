#!/usr/bin/env bash
set -euo pipefail

# Flutter wrapper for Codex CLI in sandboxed environments.
# - Uses workspace-local HOME and PUB_CACHE to avoid forbidden writes
# - Suppresses analytics/telemetry writes
# - Defaults to --no-pub for analyze/test unless explicitly overridden

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FLUTTER_BIN="${REPO_ROOT}/.local_flutter/bin/flutter"
DART_BIN="${REPO_ROOT}/.local_flutter/bin/dart"
USE_REAL_HOME="${CODEX_USE_REAL_HOME:-0}"

if [[ ! -x "${FLUTTER_BIN}" ]]; then
  echo "[flutter_codex] Error: ${FLUTTER_BIN} not found or not executable." >&2
  echo "[flutter_codex] Ensure the vendored Flutter SDK exists at .local_flutter." >&2
  exit 127
fi

# HOME/PUB_CACHE handling
if [[ "${USE_REAL_HOME}" == "1" || "${USE_REAL_HOME}" == "true" ]]; then
  # Use real HOME and default pub cache (useful for signed builds / global caches)
  : # no-op, keep existing HOME and PUB_CACHE
else
  # Workspace-local tool dirs to avoid forbidden writes in sandboxed environments
  mkdir -p "${REPO_ROOT}/.tooling/home" "${REPO_ROOT}/.tooling/pub-cache"
  export HOME="${REPO_ROOT}/.tooling/home"
  export PUB_CACHE="${REPO_ROOT}/.tooling/pub-cache"
fi
export FLUTTER_SUPPRESS_ANALYTICS=1
export DART_SUPPRESS_ANALYTICS=1

# Build and run command; inject --no-pub by default for analyze/test
run_cmd() {
  local subcmd="$1"; shift || true
  local -a cmd

  if [[ "${subcmd}" == "dart" ]]; then
    cmd=("${DART_BIN}")
  else
    cmd=("${FLUTTER_BIN}" "${subcmd}")
  fi

  if [[ "${subcmd}" == "analyze" || "${subcmd}" == "test" ]]; then
    local have_pub_flag=0
    if [[ $# -gt 0 ]]; then
      for a in "$@"; do
        case "${a}" in
          --no-pub|--pub|--offline)
            have_pub_flag=1
            ;;
        esac
      done
    fi
    if [[ ${have_pub_flag} -eq 0 ]]; then
      cmd+=("--no-pub")
    fi
  fi

  # Append remaining args and exec
  if [[ $# -gt 0 ]]; then
    cmd+=("$@")
  fi
  exec "${cmd[@]}"
}

if [[ "$#" -eq 0 ]]; then
  # Show version to verify toolchain works in this environment
  exec "${FLUTTER_BIN}" --version
else
  subcmd="$1"; shift || true
  if [[ "${subcmd}" == "analyze-test" ]]; then
    # Shortcut: run analyze then test sequentially.
    # analyze runs without args (safe default - doesn't need test-specific flags)
    # test receives all original args (--coverage, --reporter, etc.)
    "${SCRIPT_DIR}/flutter_codex.sh" analyze
    "${SCRIPT_DIR}/flutter_codex.sh" test "$@"
    exit # Natural exit after successful completion (set -e handles failures)
  fi
  run_cmd "${subcmd}" "$@"
fi
