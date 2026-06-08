# workflow-template

Shared Claude Code workflow commands and scripts for the two-role development workflow
(Claude = architect/reviewer, implementor tool = code writer).

## How it works

This repo is a single source of truth cloned once per machine. All projects symlink into
it rather than copying files. Edit a command here, and every project picks it up immediately —
no syncing or per-project updates needed.

```
*.md                  # Generic workflow commands (symlinked as commands/ in each project)
scripts/              # Shell scripts (symlinked into each project root)
configs/              # Tool config files (symlinked into each project root)
claude-stubs/         # Claude Code command stubs (symlinked into .claude/commands/)
skeleton/             # Starting-point files — copy and customize per project
```

## First-time setup (once per machine)

Clone this repo anywhere you like:

```bash
git clone https://github.com/marvinmednick/workflow-template <your-chosen-path>
# e.g. ~/Development/workflow_template  or  ~/.workflow-template
```

Scripts self-locate via symlink resolution — no path configuration needed.
Set `WORKFLOW_TEMPLATE_DIR` only if you need to override the resolved path.

## Setting up a new project

From your project directory:

```bash
# Creates all symlinks: commands/, scripts, Claude stubs, and tool configs
<your-chosen-path>/scripts/setup.sh
```

Then copy and fill in the project-specific skeleton files:

```bash
cp <your-chosen-path>/skeleton/.implement.conf       .implement.conf
cp <your-chosen-path>/skeleton/WORKFLOW-template.md  WORKFLOW.md
cp <your-chosen-path>/skeleton/AGENT-template.md     AGENT.md
cp <your-chosen-path>/skeleton/CODING-template.md    CODING.md
cp <your-chosen-path>/skeleton/DESIGN-template.md    DESIGN.md
cp <your-chosen-path>/skeleton/REVIEW-template.md    REVIEW.md
```

Edit each file to fill in project-specific content, then create `CLAUDE.md` for Claude Code
session guidance.

Finally, verify all symlinks are in place:

```bash
./verify-links
```

## Keeping projects up to date

```bash
./update-workflow
```

Pulls the latest template clone. Since all commands, scripts, stubs, and configs are
symlinks, they update instantly — no per-project changes needed.

## Improving shared commands

Commands in `commands/` are symlinks, so editing one means you're editing the file
directly in the template clone. Commit and push from there:

```bash
cd <your-chosen-path>
git add <name>.md
git commit -m "improve: ..."
git push
```

## New machine setup

Symlinks embed the template path, so they must be recreated on each machine:

```bash
git clone https://github.com/marvinmednick/workflow-template <your-chosen-path>
cd <project>
<your-chosen-path>/scripts/setup.sh   # recreates all symlinks
./verify-links                        # confirm everything is correct
```

## Project-specific files

These files are copied from `skeleton/` and customized per project. They live in the
project repo and are never overwritten by `update-workflow`:

| File | Purpose |
|------|---------|
| `.implement.conf` | Implementor tool, model, test command, file path pattern |
| `WORKFLOW.md` | Project workflow guide — commands, use cases, file reference |
| `AGENT.md` | Behavioral rules for the implementor tool |
| `CODING.md` | Coding conventions and patterns |
| `DESIGN.md` | Architecture and design reference |
| `REVIEW.md` | Review checklist (read by `/review-impl` and `/review`) |
| `CLAUDE.md` | Claude Code session guidance (not in skeleton — create from scratch) |
