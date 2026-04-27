# workflow-template

Shared Claude Code workflow commands and scripts for the two-role development workflow
(Claude = architect/reviewer, implementor tool = code writer).

## What's in here

```
*.md                  # Generic workflow commands (symlinked into commands/ in projects)
scripts/              # Shell scripts (symlinked into project root)
configs/              # Generic config files (symlinked into project root)
claude-stubs/         # Claude Code command stubs (symlinked into .claude/commands/)
skeleton/             # Starting-point files for new projects (copy and customize)
```

## Setting up a new project

```bash
# 1. Clone this repo to a stable local location (one-time per machine)
git clone https://github.com/marvinmednick/workflow-template ~/.workflow-template

# 2. In your project directory, create all symlinks (commands/, scripts, stubs, configs)
~/.workflow-template/scripts/setup.sh

# 3. Copy and customize the skeleton files
cp ~/.workflow-template/skeleton/.implement.conf .implement.conf
cp ~/.workflow-template/skeleton/REVIEW-template.md REVIEW.md
# Edit both files with project-specific values

# 4. Create your project files
# AGENT.md   — behavioral rules for the implementor
# CODING.md  — coding conventions and patterns
# DESIGN.md  — architecture and design reference
# CLAUDE.md  — Claude Code session guidance
```

## Updating an existing project

```bash
./update-workflow
```

This pulls the latest `~/.workflow-template` clone. Since all files (commands/, scripts,
stubs, configs) are symlinks into that clone, they update instantly — no further steps needed.

## Pushing a local command improvement upstream

If you edit a generic command in `commands/` (remember: it's a symlink, so you're editing
`~/.workflow-template/<name>.md` directly), commit and push the shared repo:

```bash
cd ~/.workflow-template
git add <name>.md
git commit -m "improve: ..."
git push
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
