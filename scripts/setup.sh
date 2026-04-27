#!/usr/bin/env bash
# setup.sh — Create symlinks from this project to the workflow-template clone
#
# Run from the project root after cloning ~/.workflow-template.
# Safe to re-run — uses ln -sf (force-overwrites existing symlinks).
#
# Prerequisites:
#   git clone https://github.com/marvinmednick/workflow-template ~/.workflow-template

set -euo pipefail

TEMPLATE="$HOME/.workflow-template"

if [[ ! -d "$TEMPLATE" ]]; then
  echo "Error: ~/.workflow-template not found."
  echo ""
  echo "Clone it first:"
  echo "  git clone https://github.com/marvinmednick/workflow-template ~/.workflow-template"
  exit 1
fi

echo "Linking commands/..."
mkdir -p commands
for cmd in complete.md design.md design-review.md feature.md fix-baseline.md \
           investigate.md resolve.md review-plan.md spec.md triage.md review.md; do
  ln -sf "$TEMPLATE/$cmd" "commands/$cmd"
  echo "  linked commands/$cmd"
done

echo ""
echo "Linking scripts..."
for script in implement check-tests gh-aliases.sh update-workflow verify-links; do
  ln -sf "$TEMPLATE/scripts/$script" "./$script"
  chmod +x "./$script"
  echo "  linked $script"
done

echo ""
echo "Linking Claude Code stubs..."
mkdir -p .claude/commands
for stub in complete.md design.md design-review.md feature.md fix-baseline.md \
            investigate.md resolve.md review-impl.md review-plan.md spec.md triage.md; do
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

mkdir -p .codex
ln -sf "$TEMPLATE/configs/.codex/config.toml" "./.codex/config.toml"
echo "  linked .codex/config.toml"

echo ""
echo "Done. Symlinks created."
echo ""
echo "Next steps for a new project:"
echo "  1. Copy and customize skeleton files:"
echo "       cp ~/.workflow-template/skeleton/.implement.conf .implement.conf"
echo "       cp ~/.workflow-template/skeleton/REVIEW-template.md REVIEW.md"
echo "       cp ~/.workflow-template/skeleton/WORKFLOW-template.md WORKFLOW.md"
echo "       cp ~/.workflow-template/skeleton/AGENT-template.md AGENT.md"
echo "       cp ~/.workflow-template/skeleton/CODING-template.md CODING.md"
echo "       cp ~/.workflow-template/skeleton/DESIGN-template.md DESIGN.md"
echo "  2. Edit each file — fill in project-specific content"
echo "  3. Create CLAUDE.md for Claude Code session guidance"
