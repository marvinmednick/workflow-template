# Workflow Template Changelog

Each version entry documents what changed and what existing projects need to do.
Symlinked files (commands, scripts, stubs) auto-update — only skeleton file changes require manual action.

---

## v2 (2026-06-08)

### Auto-updated (symlinks — no action needed)
- `implement` script: Added `--tool claude` for running claude CLI as an isolated subprocess
- `check-tests` script: Added pytest framework detection (auto-detects from TEST_CMD); works alongside existing Jest support
- New `/implement F[N]` Claude Code command: spawns an Agent for in-session isolated implementation
- `setup.sh`: Writes `.workflow-version` on project init; handles `.codex` file-vs-dir edge case
- `verify-links`: Added `implement.md` and workflow version entries to checks

### Skeleton file changes (review and update existing projects)

**WORKFLOW.md** — Add an "Implement: Two Options" section explaining the two paths for Claude-as-implementor:
- `/implement F[N]` spawns an Agent tool sub-agent (in-session, recommended)
- `./implement F[N]` launches `claude` CLI subprocess (most isolated, new terminal)
See `skeleton/WORKFLOW-template.md` for the exact section to add under the cheatsheet.

**.implement.conf** — `tool=claude` is now available and is the recommended default for projects using Claude Code.
If your project uses `tool=codex` or `tool=gemini`, consider switching if you primarily work in Claude Code.

**DESIGN-template.md** — New: projects can optionally use an `architecture/` directory instead of a single DESIGN.md file. DESIGN.md becomes a pointer + decisions log; the directory holds the full reference docs.
This is optional — existing single-file DESIGN.md projects do not need to change.
See updated `skeleton/DESIGN-template.md` for the pointer pattern.

### New skeleton files
- None

### New required project files
- `.workflow-version` — written automatically by `setup.sh` going forward; existing projects should create it manually containing their current version number.

---

## v1 (initial)

Initial template release. Established the two-role workflow (Claude = architect/reviewer, implementor tool = code writer) with commands: `/feature`, `/design`, `/spec`, `/review-impl`, `/review-plan`, `/complete`, `/triage`, `/investigate`, `/resolve`, `/fix-baseline`, `/design-review`.
