#!/bin/bash
# LUVI Development Runner
# Loads credentials from .env.development and passes them via --dart-define
#
# Usage:
#   ./scripts/run_dev.sh                    # Run on default device
#   ./scripts/run_dev.sh -d "iPhone 16 Pro" # Run on specific device
#   ./scripts/run_dev.sh -d chrome          # Run on Chrome

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env.development"

# Check if .env.development exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found!"
    echo "Please create .env.development with SUPABASE_URL and SUPABASE_ANON_KEY"
    exit 1
fi

# Load environment variables from .env.development (safely handle spaces/quotes)
set -a  # Auto-export all variables
source "$ENV_FILE"
set +a  # Disable auto-export

# Validate required variables
if [ -z "$SUPABASE_URL" ]; then
    echo "Error: SUPABASE_URL not set in $ENV_FILE"
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "Error: SUPABASE_ANON_KEY not set in $ENV_FILE"
    exit 1
fi

echo "Starting LUVI in development mode..."
echo "  SUPABASE_URL: ${SUPABASE_URL:0:30}..."

# Pass all arguments to flutter run (e.g., -d "device name")
cd "$PROJECT_ROOT"
flutter run \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
    "$@"
