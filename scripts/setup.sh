#!/usr/bin/env bash
# setup.sh — Create symlinks from this project to the workflow-template clone
#
# Run from the project root after cloning workflow-template anywhere on disk.
# Safe to re-run — uses ln -sf (force-overwrites existing symlinks).
#
# The template location is resolved automatically via symlink; no config needed.
# Override with WORKFLOW_TEMPLATE_DIR if needed.

set -euo pipefail

TEMPLATE="${WORKFLOW_TEMPLATE_DIR:-$(cd "$(dirname "$(realpath "$0")")/.." && pwd)}"

if [[ ! -d "$TEMPLATE" ]]; then
  echo "Error: workflow-template not found at $TEMPLATE"
  exit 1
fi

echo "Linking commands/..."
mkdir -p commands
for cmd in complete.md design.md design-review.md feature.md fix-baseline.md \
           implement.md investigate.md resolve.md review-plan.md spec.md triage.md \
           review.md upgrade-workflow.md; do
  ln -sf "$TEMPLATE/$cmd" "commands/$cmd"
  echo "  linked commands/$cmd"
done

echo ""
echo "Linking scripts..."
for script in implement check-tests check-workflow gh-aliases.sh update-workflow verify-links; do
  ln -sf "$TEMPLATE/scripts/$script" "./$script"
  chmod +x "./$script"
  echo "  linked $script"
done

echo ""
echo "Linking Claude Code stubs..."
mkdir -p .claude/commands
for stub in complete.md design.md design-review.md feature.md fix-baseline.md \
            implement.md investigate.md resolve.md review-impl.md review-plan.md \
            spec.md triage.md upgrade-workflow.md; do
  ln -sf "$TEMPLATE/claude-stubs/$stub" ".claude/commands/$stub"
  echo "  linked .claude/commands/$stub"
done

echo ""
echo "Linking configs..."
ln -sf "$TEMPLATE/configs/.aider.conf.yml" "./.aider.conf.yml"
echo "  linked .aider.conf.yml"

mkdir -p .gemini
ln -sf "$TEMPLATE/configs/.gemini/settings.json" "./.gemini/settings.json"
echo "  linked .gemini/settings.json"

if [[ -f ".codex" ]] && [[ ! -d ".codex" ]]; then
  echo "  skipped .codex/config.toml (.codex exists as a file — remove it to enable)"
else
  mkdir -p .codex
  ln -sf "$TEMPLATE/configs/.codex/config.toml" "./.codex/config.toml"
  echo "  linked .codex/config.toml"
fi

echo ""
# Write .workflow-version so the project tracks which template version it started from
TEMPLATE_VERSION=$(tr -d '[:space:]' < "$TEMPLATE/VERSION" 2>/dev/null || echo "unknown")
echo "$TEMPLATE_VERSION" > ".workflow-version"
echo "Wrote .workflow-version = $TEMPLATE_VERSION"

echo ""
echo "Done. Symlinks created."
echo ""
echo "Next steps for a new project:"
echo "  1. Copy and customize skeleton files:"
echo "       cp $TEMPLATE/skeleton/.implement.conf .implement.conf"
echo "       cp $TEMPLATE/skeleton/REVIEW-template.md REVIEW.md"
echo "       cp $TEMPLATE/skeleton/WORKFLOW-template.md WORKFLOW.md"
echo "       cp $TEMPLATE/skeleton/AGENT-template.md AGENT.md"
echo "       cp $TEMPLATE/skeleton/CODING-template.md CODING.md"
echo "       cp $TEMPLATE/skeleton/DESIGN-template.md DESIGN.md"
echo "  2. Edit each file — fill in project-specific content"
echo "  3. Create CLAUDE.md for Claude Code session guidance"
