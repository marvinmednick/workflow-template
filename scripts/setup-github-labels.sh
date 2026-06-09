#!/usr/bin/env bash
# setup-github-labels.sh — Create the standard workflow labels in a GitHub repository.
#
# Run once per repo after initial setup.
# Usage: ./setup-github-labels.sh [OWNER/REPO]
# If OWNER/REPO is omitted, gh resolves the repo from the current directory.

set -euo pipefail

REPO_ARG="${1:-}"
REPO_FLAG=""
if [[ -n "$REPO_ARG" ]]; then
  REPO_FLAG="--repo $REPO_ARG"
fi

create_label() {
  local name="$1" description="$2" color="$3"
  if gh label create "$name" --description "$description" --color "$color" $REPO_FLAG 2>/dev/null; then
    echo "  created: $name"
  else
    echo "  skipped (already exists): $name"
  fi
}

echo "Creating workflow labels..."
echo ""

echo "── Status labels ──────────────────────────────────────"
create_label "feature"     "New feature"                      "0075ca"
create_label "specced"     "Feature has a written spec"       "e4e669"
create_label "in-review"   "Implementation under review"      "c5def5"

echo ""
echo "── Issue type labels ───────────────────────────────────"
create_label "cleanup"      "Code quality improvement"          "fef2c0"
create_label "test-quality" "Test improvement or coverage gap"  "f9d0c4"
create_label "docs"         "Documentation issue or update"     "0075ca"

echo ""
echo "── Severity labels (for bugs) ──────────────────────────"
create_label "severity:high"   "High severity bug"    "d73a4a"
create_label "severity:medium" "Medium severity bug"  "e99695"
create_label "severity:low"    "Low severity bug"     "fbca04"

echo ""
echo "── Effort labels ───────────────────────────────────────"
create_label "effort:small"  "Small effort estimate"   "0e8a16"
create_label "effort:medium" "Medium effort estimate"  "006b75"
create_label "effort:large"  "Large effort estimate"   "1d76db"

echo ""
echo "Done. Run 'gh label list' to verify."
