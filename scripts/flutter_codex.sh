#!/usr/bin/env bash
set -euo pipefail

# Flutter wrapper for Codex CLI: sandboxed HOME/PUB_CACHE, telemetry off,
# and default --no-pub for analyze/test. Supports optional real HOME via env
# CODEX_USE_REAL_HOME=1.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

if [[ "${CODEX_USE_REAL_HOME:-0}" != "1" ]]; then
  export HOME="$REPO_ROOT/.tooling/home"
  export PUB_CACHE="$REPO_ROOT/.tooling/pub-cache"
fi

mkdir -p "$HOME" "$PUB_CACHE" || true

# Prefer repo-local Flutter SDK if present
if [[ -d "$REPO_ROOT/.tooling/flutter-sdk/bin" ]]; then
  export PATH="$REPO_ROOT/.tooling/flutter-sdk/bin:$PATH"
fi

# Suppress analytics/prompts
export FLUTTER_SUPPRESS_ANALYTICS="true"
export CI="true"

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/flutter_codex.sh {analyze|test} [args...]" >&2
  exit 2
fi

cmd="$1"; shift || true

case "$cmd" in
  analyze)
    set -x
    flutter analyze --no-pub "$@"
    ;;
  test)
    # Ensure -j 1 unless explicitly provided
    ARGS=("$@")
    if [[ " ${ARGS[*]} " != *" -j "* ]]; then
      ARGS=("-j" "1" "${ARGS[@]}")
    fi
    set -x
    flutter test --no-pub "${ARGS[@]}"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    echo "Usage: scripts/flutter_codex.sh {analyze|test} [args...]" >&2
    exit 2
    ;;
esac

