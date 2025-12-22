#!/usr/bin/env bash
set -euo pipefail

echo "[secrets-scan] starting..."

if command -v trufflehog >/dev/null 2>&1; then
  echo "[secrets-scan] using trufflehog (filesystem, only-verified, report-only)"
  trufflehog filesystem --no-update --only-verified --json . || true
  echo "[secrets-scan] done (non-blocking)."
  exit 0
fi

if command -v detect-secrets >/dev/null 2>&1; then
  echo "[secrets-scan] using detect-secrets (baseline-less quick scan)"
  detect-secrets scan || true
  echo "[secrets-scan] done (non-blocking)."
  exit 0
fi

echo "[secrets-scan] no scanner available (trufflehog/detect-secrets missing). Skipping."
exit 0

