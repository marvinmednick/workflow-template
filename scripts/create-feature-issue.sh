#!/usr/bin/env bash
# create-feature-issue.sh — Create a GitHub issue and derive its F-number
#
# The canonical way to create a feature/enhancement issue. Used by /feature,
# /spec (when no issue exists yet), and /design (Fresh Mode, when no issue
# exists yet) so the F# = issue# invariant can't drift between call sites —
# each one used to duplicate this create-then-rename sequence independently.
#
# Usage:
#   ./create-feature-issue.sh --title "TITLE" --type feature|enhancement \
#       --effort small|medium|large [--body "BODY"]
#
# Creates the issue, reads the GitHub-assigned number, renames the issue
# title to "F<N>: TITLE", and prints the F-number to stdout.
#
# Exit codes:
#   0 — success, F-number printed to stdout
#   2 — usage error

set -euo pipefail

TITLE=""
TYPE=""
EFFORT=""
BODY="_Pending design/spec details._"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2;;
    --type) TYPE="$2"; shift 2;;
    --effort) EFFORT="$2"; shift 2;;
    --body) BODY="$2"; shift 2;;
    -h|--help)
      echo "Usage: create-feature-issue.sh --title TITLE --type feature|enhancement --effort small|medium|large [--body BODY]"
      exit 0;;
    *) echo "Unknown argument: $1" >&2; exit 2;;
  esac
done

if [[ -z "$TITLE" || -z "$TYPE" || -z "$EFFORT" ]]; then
  echo "Usage: create-feature-issue.sh --title TITLE --type feature|enhancement --effort small|medium|large [--body BODY]" >&2
  exit 2
fi

if [[ "$TYPE" != "feature" && "$TYPE" != "enhancement" ]]; then
  echo "Error: --type must be 'feature' or 'enhancement', got '$TYPE'" >&2
  exit 2
fi

if [[ "$EFFORT" != "small" && "$EFFORT" != "medium" && "$EFFORT" != "large" ]]; then
  echo "Error: --effort must be 'small', 'medium', or 'large', got '$EFFORT'" >&2
  exit 2
fi

N=$(gh issue create \
  --title "$TITLE" \
  --label "$TYPE" \
  --label "effort:$EFFORT" \
  --body "$BODY" \
  | grep -oE '[0-9]+$')

gh issue edit "$N" --title "F$N: $TITLE" >/dev/null

echo "$N"
