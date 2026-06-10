#!/usr/bin/env bash
# setup-claude.sh — Generate a customized CLAUDE.md from the workflow template skeleton
#
# Run from the project root. Asks questions, then writes CLAUDE.md.
# If CLAUDE.md already exists, backs it up to CLAUDE.md.bak before overwriting.
#
# Usage:
#   ~/Development/workflow_template/scripts/setup-claude.sh
#   ~/Development/workflow_template/scripts/setup-claude.sh --dry-run   # Print to stdout, don't write

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "$(realpath "$0")")/.." && pwd)"
SKELETON="$TEMPLATE_DIR/skeleton/CLAUDE-template.md"
OUTPUT="CLAUDE.md"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

if [[ ! -f "$SKELETON" ]]; then
  echo "Error: CLAUDE-template.md not found at $SKELETON"
  exit 1
fi

echo ""
echo "=== CLAUDE.md Setup ==="
echo "This script creates a customized CLAUDE.md for this project."
echo "Answer the questions below. Press Enter to accept defaults."
echo ""

# ── Project Name ──────────────────────────────────────────────────────────────
read -rp "Project name (used in the title): " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$(basename "$(pwd)")"
  echo "  Using: $PROJECT_NAME"
fi

# ── Project Description ───────────────────────────────────────────────────────
echo ""
read -rp "One-line description of what this project does: " PROJECT_DESC
if [[ -z "$PROJECT_DESC" ]]; then
  PROJECT_DESC="[Project description — fill this in]"
fi

# ── Runtime / Language ────────────────────────────────────────────────────────
echo ""
echo "Primary language/framework:"
echo "  1) Python (uv)      — uv run python / uv run pytest"
echo "  2) Python (bare)    — python / pytest"
echo "  3) Node/npm         — npm test / npm start"
echo "  4) Node/yarn        — yarn test / yarn start"
echo "  5) Other            — enter manually"
read -rp "Choice [1-5] (default: 5): " LANG_CHOICE

case "${LANG_CHOICE:-5}" in
  1)
    RUNTIME_NOTE="Always use \`uv run python\` / \`uv run pytest\` — never bare \`python\`."
    TEST_CMD="uv run pytest"
    RUN_CMD="uv run python main.py"
    ;;
  2)
    RUNTIME_NOTE="Use \`python\` and \`pytest\` directly."
    TEST_CMD="pytest"
    RUN_CMD="python main.py"
    ;;
  3)
    RUNTIME_NOTE="Use \`npm\` for all commands."
    TEST_CMD="npm test"
    RUN_CMD="npm start"
    ;;
  4)
    RUNTIME_NOTE="Use \`yarn\` for all commands."
    TEST_CMD="yarn test"
    RUN_CMD="yarn start"
    ;;
  *)
    read -rp "  Runtime note (e.g., 'Always use docker exec ...'): " RUNTIME_NOTE
    read -rp "  Test command: " TEST_CMD
    read -rp "  Run command: " RUN_CMD
    ;;
esac

# ── Branch Name ───────────────────────────────────────────────────────────────
echo ""
DETECTED_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")"
read -rp "Primary git branch [default: $DETECTED_BRANCH]: " GIT_BRANCH
GIT_BRANCH="${GIT_BRANCH:-$DETECTED_BRANCH}"

# ── Credentials / Secrets ─────────────────────────────────────────────────────
echo ""
echo "What credentials file should never be committed?"
echo "  1) .env"
echo "  2) secrets.env"
echo "  3) Both .env and secrets.env"
echo "  4) Other"
read -rp "Choice [1-4] (default: 1): " CREDS_CHOICE
case "${CREDS_CHOICE:-1}" in
  1) CREDS_NOTE="Do not commit \`.env\` — contains live credentials." ; GITIGNORE_NOTE="Never commit \`.env\`, \`.pem\`, or credential files" ;;
  2) CREDS_NOTE="Do not commit \`secrets.env\` — contains live credentials." ; GITIGNORE_NOTE="Never commit \`secrets.env\`, \`.pem\`, or credential files" ;;
  3) CREDS_NOTE="Do not commit \`.env\` or \`secrets.env\` — contain live credentials." ; GITIGNORE_NOTE="Never commit \`.env\`, \`secrets.env\`, \`.pem\`, or credential files" ;;
  *) read -rp "  Credentials note: " CREDS_NOTE ; GITIGNORE_NOTE="$CREDS_NOTE" ;;
esac

# ── Architecture/ directory ───────────────────────────────────────────────────
echo ""
read -rp "Does this project have an architecture/ directory? [y/N]: " HAS_ARCH_DIR
HAS_ARCH_DIR="${HAS_ARCH_DIR,,}"  # lowercase

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────"
echo "Summary:"
echo "  Project name : $PROJECT_NAME"
echo "  Description  : $PROJECT_DESC"
echo "  Test command : $TEST_CMD"
echo "  Run command  : $RUN_CMD"
echo "  Branch       : $GIT_BRANCH"
echo "  Credentials  : $CREDS_NOTE"
echo "──────────────────────────────────────"
echo ""
read -rp "Generate CLAUDE.md with these settings? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-y}"
if [[ "${CONFIRM,,}" != "y" ]]; then
  echo "Aborted."
  exit 0
fi

# ── Generate ──────────────────────────────────────────────────────────────────

ARCH_FILES_ROW=""
ARCH_SECTION_BODY=""
if [[ "${HAS_ARCH_DIR:-n}" == "y" ]]; then
  ARCH_FILES_ROW="| \`architecture/\` | Reference docs for system design |"
  ARCH_SECTION_BODY="See the \`architecture/\` directory for system design reference docs."
else
  ARCH_SECTION_BODY="[Architecture overview — describe the directory structure, key patterns, and anything an implementor must know before touching the code.]"
fi

CONTENT=$(cat "$SKELETON")

# Apply substitutions
CONTENT="${CONTENT//\[PROJECT NAME\]/$PROJECT_NAME}"
CONTENT="${CONTENT//\[One-line project description\]/$PROJECT_DESC}"
CONTENT="${CONTENT//<!-- CUSTOMIZE: Replace \[PROJECT NAME\] with your project\'s name -->/$PROJECT_NAME}"

# Runtime note
CONTENT="${CONTENT/<!-- e.g., Always use \`uv run python\` \/ \`uv run pytest\` -->/$RUNTIME_NOTE}"

# Commands section — replace placeholder lines
CONTENT="${CONTENT//\[test command\]/$TEST_CMD}"
CONTENT="${CONTENT//\[run command\]/$RUN_CMD}"

# Branch
CONTENT="${CONTENT//- Branch: \`main\`/- Branch: \`$GIT_BRANCH\`}"

# Credentials note in git section
CONTENT="${CONTENT//- Never commit \`.env\`, \`.pem\`, or credential files/- $GITIGNORE_NOTE}"

# Project description
CONTENT="${CONTENT//\[Project description\]/$PROJECT_DESC
$CREDS_NOTE}"

# Architecture section
CONTENT="${CONTENT//\[Architecture overview\]/$ARCH_SECTION_BODY}"

# Insert architecture/ key files row if applicable
if [[ -n "$ARCH_FILES_ROW" ]]; then
  CONTENT="${CONTENT//<!-- CUSTOMIZE: Add project-specific files to this table -->/$ARCH_FILES_ROW
<!-- CUSTOMIZE: Add project-specific files to this table -->}"
fi

# Strip skeleton-only CUSTOMIZE comments from generated output
CONTENT=$(echo "$CONTENT" | grep -v "^<!-- CUSTOMIZE:")

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "=== DRY RUN — CLAUDE.md would contain: ==="
  echo ""
  echo "$CONTENT"
  exit 0
fi

if [[ -f "$OUTPUT" ]]; then
  cp "$OUTPUT" "${OUTPUT}.bak"
  echo "Backed up existing CLAUDE.md to CLAUDE.md.bak"
fi

echo "$CONTENT" > "$OUTPUT"

echo ""
echo "Written: $OUTPUT"
echo ""
echo "Next steps:"
echo "  1. Open CLAUDE.md and fill in the remaining <!-- CUSTOMIZE --> sections:"
echo "       - Project Overview (detailed description, key paths, config files)"
echo "       - Architecture (directory layout, key patterns, off-limits areas)"
echo "       - Session Startup (add project-specific files to read)"
echo "       - Key Files (add project-specific files to the table)"
echo "  2. Review the Role section — adjust if implementor tool setup differs"
echo "  3. Commit: git add CLAUDE.md && git commit -m \"Add CLAUDE.md\""
