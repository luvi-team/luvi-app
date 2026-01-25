#!/usr/bin/env bash
# Validates that docs/bmad/global.md is updated when migration files change.
# Run via pre-commit hook.
set -euo pipefail

BMAD_FILE="docs/bmad/global.md"

# Check if bmad/global.md is also staged when migrations are staged
if ! git diff --cached --name-only | grep -q "$BMAD_FILE"; then
  echo "ERROR: Migration files changed but $BMAD_FILE not updated."
  echo ""
  echo "ACTION: Update 'Last verified' timestamp in $BMAD_FILE (line ~399)"
  echo "        and stage the file with: git add $BMAD_FILE"
  exit 1
fi

echo "OK: $BMAD_FILE is staged alongside migrations"
