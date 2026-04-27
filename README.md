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
cp ~/.workflow-template/skeleton/WORKFLOW-template.md WORKFLOW.md
cp ~/.workflow-template/skeleton/AGENT-template.md AGENT.md
cp ~/.workflow-template/skeleton/CODING-template.md CODING.md
cp ~/.workflow-template/skeleton/DESIGN-template.md DESIGN.md
# Edit each file — fill in project-specific content

# 4. Create CLAUDE.md for Claude Code session guidance

# 5. Verify all symlinks are correct
./verify-links
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

## Verifying symlinks

After setup or after cloning to a new machine, confirm all expected symlinks are correct:

```bash
./verify-links
```

Reports each symlink as ✓ (correct), or ✗ with the reason (missing, wrong target, dangling,
or real file). Offers to fix all fixable issues in one pass. Real files (not symlinks) must
be removed manually before they can be replaced.

## New machine setup

```bash
git clone https://github.com/marvinmednick/workflow-template ~/.workflow-template
cd <project>
~/.workflow-template/scripts/setup.sh   # recreates all symlinks
./verify-links                          # confirm everything is correct
```

## Project-specific files (not in this repo)

Each project owns these files — they are never synced from this repo:

| File | Purpose |
|------|---------|
| `REVIEW.md` | Project-specific review checklist (read by `/review-impl` and built-in `/review`) |
| `.implement.conf` | Tool, model, test command, file path pattern |
| `WORKFLOW.md` | Project workflow guide (commands, use cases, file reference) |
| `AGENT.md` | Implementor behavioral rules |
| `CODING.md` | Coding conventions |
| `DESIGN.md` | Architecture reference |
| `CLAUDE.md` | Claude Code session guidance |
