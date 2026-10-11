# DESIGN.md

Architecture and design reference for workflow-template. Read before changing how commands, scripts or skeletons reach projects.

---

## Overview

workflow-template is the shared source for a two-role development workflow: Claude designs, specs and reviews, and an implementor tool writes code. It is one clone per machine. Projects link to it, so a change to a command takes effect in every project at once, and `skeleton/` files are copied into projects for each to customise.

It is made of Markdown prompts (the commands), Bash scripts, and a few configs. There is no application code.

---

## Architecture

```
commands/*.md         the workflows, written as prompts for an LLM
claude-stubs/*.md     one per skill; the manifest (name, description, which command)
codex-skills/*/       generated from the stubs for Codex
scripts/              project-root tooling (setup, update, verify, check-*, implement)
skeleton/             files copied into a project and customised there
configs/              tool configuration, linked into projects
```

A project gets:
- `commands/*.md` symlinks to the template's `commands/`
- `.claude/commands/*.md` symlinks to the stubs
- `.agents/skills/*/SKILL.md` symlinks to the generated skills
- root symlinks to the scripts and tool configs
- copies of `skeleton/` files (`AGENTS.md`, `CODING.md`, `REVIEW.md`, …)
- `.workflow-version`, compared against the template's `VERSION` by `check-workflow`

---

## Key Patterns

### The stub manifest
`claude-stubs/` is the one list of what skills exist. `workflow-lib.sh` derives the command files from it, `gen-codex-skills.sh` generates the Codex wrappers from it, and `setup.sh`, `update-workflow` and `verify-links` all use it.

### Linked versus copied
Linked files update everywhere immediately. Copied files drift, so changes to them are announced through `VERSION`, the CHANGELOG, and `/upgrade-workflow`.

### The template as its own project
This repo runs the workflow on itself: `specs/`, `plans/` and `PLAN.md` track changes to the template. `commands/` holds real files here, so link-writing scripts skip it (`in_template_root`).

### Release signal
`VERSION` plus a CHANGELOG entry. `check-workflow` in each project compares its `.workflow-version` to it.

---

## Design Decisions Log

| Date | Decision | Why |
|------|----------|-----|
| 2026-10-06 | Command files live in `commands/`, not the repo root | At the root, the lowercase command files (`design.md`, `review.md`) collided with this repo's own `DESIGN.md` and `REVIEW.md` on case-insensitive filesystems, so the template could not run its own workflow |
