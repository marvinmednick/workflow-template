#!/usr/bin/env bash
# workflow-lib.sh — Shared helpers, sourced by setup.sh, update-workflow, verify-links, and
# gen-codex-skills.sh. Not linked into projects. Requires $TEMPLATE to be set.
#
# claude-stubs/ is the manifest: each stub's filename is the skill name, its first line is the
# description, and the `commands/<x>.md` it names is the canonical workflow.

# Skill names, one per claude-stubs/*.md
stub_names() {
  local f
  for f in "$TEMPLATE"/claude-stubs/*.md; do
    basename "$f" .md
  done
}

# Canonical command file (e.g. review.md) that stub $1 points at
stub_target() {
  local t
  t=$(grep -o 'commands/[A-Za-z0-9_-]*\.md' "$TEMPLATE/claude-stubs/$1.md" | head -1)
  echo "${t#commands/}"
}

# Unique canonical command files across all stubs
command_files() {
  local n
  for n in $(stub_names); do stub_target "$n"; done | sort -u
}

# Create/refresh .agents/skills/<name>/SKILL.md symlinks to the template's codex-skills/
link_codex_skills() {
  local n
  for n in $(stub_names); do
    mkdir -p ".agents/skills/$n"
    ln -sf "$TEMPLATE/codex-skills/$n/SKILL.md" ".agents/skills/$n/SKILL.md"
    echo "  linked .agents/skills/$n/SKILL.md"
  done
}
