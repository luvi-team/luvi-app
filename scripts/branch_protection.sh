#!/usr/bin/env bash
# Requires authenticated GitHub CLI session (run `gh auth login` first).
set -euo pipefail

REPO="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
BRANCHES=("main" "develop")
REQUIRED_CHECKS=("Flutter CI / analyze-test" "Flutter CI / privacy-gate" "Supabase DB Dry-Run" "Greptile Review")

echo "[branch-protection] configuring repository: $REPO"
echo "[branch-protection] required checks:"
printf '  - %s\n' "${REQUIRED_CHECKS[@]}"

for branch in "${BRANCHES[@]}"; do
  echo "[branch-protection] updating protection rules for $branch"

  check_fields=()
  for check in "${REQUIRED_CHECKS[@]}"; do
    check_fields+=(-f "required_status_checks.checks[][context]=$check")
  done

  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO/branches/$branch/protection" \
    -f required_status_checks.strict=true \
    -f required_status_checks.enforcement_level=everyone \
    "${check_fields[@]}" \
    -f enforce_admins=true \
    -f required_pull_request_reviews.required_approving_review_count=1 \
    -F required_pull_request_reviews.dismiss_stale_reviews=true \
    -F required_pull_request_reviews.require_code_owner_reviews=false \
    -F required_pull_request_reviews.require_last_push_approval=false \
    -F restrictions=null \
    -F lock_branch=false \
    -f allow_force_pushes=false \
    -f allow_deletions=false \
    -f block_creations=false

  echo "[branch-protection] ensuring pull request requirement is enabled"
  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO/branches/$branch/protection/required_pull_request_reviews" \
    -f required_approving_review_count=1 \
    -F dismiss_stale_reviews=true \
    -F require_code_owner_reviews=false \
    -F require_last_push_approval=false \
    -F bypass_pull_request_allowances=null
done

echo "[branch-protection] done."
