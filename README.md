# workflow-template

Shared Claude Code workflow commands and scripts for the two-role development workflow
(Claude = architect/reviewer, implementor tool = code writer).

## What's in here

```
*.md                  # Generic workflow commands (become commands/ in projects via git subtree)
scripts/              # Shell scripts (symlinked into project root)
configs/              # Generic config files (symlinked into project root)
claude-stubs/         # Claude Code command stubs (symlinked into .claude/commands/)
skeleton/             # Starting-point files for new projects (copy and customize)
```

## Setting up a new project

```bash
# 1. Clone this repo to a stable local location (one-time per machine)
git clone https://github.com/marvinmednick/workflow-template ~/.workflow-template

# 2. In your project directory, add the commands/ subtree
git subtree add --prefix=commands https://github.com/marvinmednick/workflow-template main --squash

# 3. Create symlinks for scripts, stubs, and configs
~/.workflow-template/scripts/setup.sh

# 4. Copy and customize the skeleton files
cp ~/.workflow-template/skeleton/.implement.conf .implement.conf
cp ~/.workflow-template/skeleton/REVIEW-template.md REVIEW.md
# Edit both files with project-specific values

# 5. Create your project files
# AGENT.md   — behavioral rules for the implementor
# CODING.md  — coding conventions and patterns
# DESIGN.md  — architecture and design reference
# CLAUDE.md  — Claude Code session guidance
```

## Updating an existing project

```bash
./update-workflow
```

This pulls the latest `~/.workflow-template` clone (instantly updates all symlinked files)
and syncs the `commands/` subtree.

## Pushing a local command improvement upstream

If you improve a generic command in `commands/` and want to share it back:

```bash
git subtree push --prefix=commands https://github.com/marvinmednick/workflow-template main
```

## New machine setup

```bash
git clone https://github.com/marvinmednick/workflow-template ~/.workflow-template
cd <project>
~/.workflow-template/scripts/setup.sh   # recreates all symlinks
```

## Project-specific files (not in this repo)

Each project owns these files — they are never synced from this repo:

| File | Purpose |
|------|---------|
| `REVIEW.md` | Project-specific review checklist (read by `/review-impl` and built-in `/review`) |
| `.implement.conf` | Tool, model, test command, file path pattern |
| `AGENT.md` | Implementor behavioral rules |
| `CODING.md` | Coding conventions |
| `DESIGN.md` | Architecture reference |
| `CLAUDE.md` | Claude Code session guidance |
