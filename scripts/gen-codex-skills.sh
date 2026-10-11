#!/usr/bin/env bash
# gen-codex-skills.sh — Generate Codex skill wrappers (codex-skills/<name>/SKILL.md) from
# claude-stubs/. Run from anywhere; commit the output.
#
# Optional per-skill overrides live in codex-skills.d/<name>.conf (description=, arguments=).
#
# Usage:
#   scripts/gen-codex-skills.sh           # (re)write codex-skills/
#   scripts/gen-codex-skills.sh --check   # exit 1 if codex-skills/ is out of date

set -euo pipefail

TEMPLATE="${WORKFLOW_TEMPLATE_DIR:-$(cd "$(dirname "$(realpath "$0")")/.." && pwd)}"
# shellcheck source=workflow-lib.sh
source "$TEMPLATE/scripts/workflow-lib.sh"

CHECK=false
[[ "${1:-}" == "--check" ]] && CHECK=true

OUT="$TEMPLATE/codex-skills"
STALE=0
EXPECTED=()

for name in $(stub_names); do
  target=$(stub_target "$name")
  if [[ -z "$target" ]]; then
    echo "Error: claude-stubs/$name.md names no commands/<file>.md" >&2
    exit 1
  fi
  desc=$(head -1 "$TEMPLATE/claude-stubs/$name.md")
  desc="${desc%: \$ARGUMENTS}"
  desc="${desc//\$ARGUMENTS/the item named by the user}"

  # Optional overrides: codex-skills.d/<name>.conf with description= and/or arguments= lines
  conf="$TEMPLATE/codex-skills.d/$name.conf"
  args_note=""
  if [[ -f "$conf" ]]; then
    o=$(sed -n 's/^description=//p' "$conf" | head -1)
    [[ -n "$o" ]] && desc="$o"
    o=$(sed -n 's/^arguments=//p' "$conf" | head -1)
    [[ -n "$o" ]] && args_note="
The \`\$ARGUMENTS\` value is $o."
  fi
  desc="${desc//\"/\\\"}"

  content=$(cat <<BODY
---
name: $name
description: "$desc"
---

# $name

Before taking any action, read \`commands/$target\` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to \`\$ARGUMENTS\`, use the arguments the user supplied with this skill.$args_note

If \`commands/$target\` is missing, run \`./verify-links\` and tell the user.
BODY
)
  file="$OUT/$name/SKILL.md"
  EXPECTED+=("$name")
  if [[ "$CHECK" == true ]]; then
    if [[ ! -f "$file" ]] || [[ "$(cat "$file")" != "$content" ]]; then
      echo "  stale: codex-skills/$name/SKILL.md"
      STALE=$((STALE + 1))
    fi
  else
    mkdir -p "$OUT/$name"
    printf '%s\n' "$content" > "$file"
  fi
done

# Skills whose stub was removed
if [[ -d "$OUT" ]]; then
  for d in "$OUT"/*/; do
    n=$(basename "$d")
    if [[ ! -f "$TEMPLATE/claude-stubs/$n.md" ]]; then
      if [[ "$CHECK" == true ]]; then
        echo "  orphan: codex-skills/$n/"
        STALE=$((STALE + 1))
      else
        rm -r "$OUT/$n"
        echo "  removed orphan codex-skills/$n/"
      fi
    fi
  done
fi

if [[ "$CHECK" == true ]]; then
  if [[ $STALE -gt 0 ]]; then
    echo "$STALE codex skill(s) out of date — run scripts/gen-codex-skills.sh"
    exit 1
  fi
  echo "codex-skills/ up to date (${#EXPECTED[@]} skills)."
else
  echo "Generated ${#EXPECTED[@]} Codex skills in codex-skills/"
fi
