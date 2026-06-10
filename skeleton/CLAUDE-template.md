# CLAUDE.md — [PROJECT NAME]

<!-- CUSTOMIZE: Replace [PROJECT NAME] with your project's name -->
<!-- CUSTOMIZE: Replace the line below with a one-sentence description of what this project does -->
[One-line project description]

---

## Session Startup

**Mandatory read sequence at the start of every session:**

1. `WORK_LOG.md` — recent session progress and next steps
2. `PLAN.md` — feature status and active work
3. `./check-workflow` — detect if workflow template has updates
4. `git log --oneline -10` — recent commits
<!-- CUSTOMIZE: Add any additional startup reads specific to this project -->

Continue from where the previous session left off. Do not re-derive context already in WORK_LOG.md.

---

## Work Log Protocol

Update `WORK_LOG.md` immediately after completing any of the following:
- Writing or editing code
- Running tests
- Making or preparing commits
- Debugging or investigating issues
- Completing any item from PLAN.md

**Template:**
```bash
echo "---
### $(date '+%Y-%m-%d %H:%M') - [Brief task description]
- **Completed**: [What was done, with file references]
- **Tests**: [Results and counts if applicable]
- **Next**: [Next steps or issues discovered]" >> WORK_LOG.md
```

**Before each commit:**
1. Review WORK_LOG.md entries since last commit
2. Clear and reset WORK_LOG.md:
```bash
cat > WORK_LOG.md << 'EOF'
# Work Log

This file tracks development progress during active work sessions. It gets cleared after each commit.

---
EOF
```

**Self-audit**: Before responding, ask: "Did I complete work without updating WORK_LOG.md?" If yes — update first.

---

## Workflow Version

This project uses the shared workflow template at `~/Development/workflow_template/`.

At session startup, run `./check-workflow` to detect if the template has been updated since this project was last migrated. If it reports an update available, run `/upgrade-workflow` to review and apply changes.

Current project version is in `.workflow-version`. Template version is in `~/Development/workflow_template/VERSION`.

---

## Role

Claude's responsibilities are **architecture, design, planning, and code review**. Implementation is handled by a separate tool (see `.implement.conf` for the configured tool).

- Use `/spec` to produce a structured implementation spec before handing off to an implementor
- Use `/review-impl` to review implementation output against the spec and architectural principles
- `CODING.md` is the coding reference all implementors use — keep it up to date when patterns change
- `AGENT.md` contains behavioral rules for all implementation agents

---

## Workflow Commands

All commands are available via `/command-name` in Claude Code (symlinked from workflow template).

| Command | When to use |
|---------|-------------|
| `/feature <desc>` | Register a new feature idea |
| `/design F[N]` | Design or update a feature |
| `/spec F[N]` | Write an implementation spec |
| `/implement F[N]` | Implement via Agent spawn (isolated context) |
| `/review-plan F[N]` | Review and approve an implementation plan |
| `/review-impl F[N]` | Review completed implementation |
| `/complete F[N]` | Ship a feature — commit, close issue, update PLAN.md |
| `/triage N` | Assess severity/effort for a bug |
| `/investigate N` | Find root cause of a bug |
| `/resolve N` | Fix a non-feature issue |
| `/upgrade-workflow` | Review and apply pending workflow template updates |

See `WORKFLOW.md` for the full process guide.

---

## Key Files

| File | Purpose |
|------|---------|
| `WORK_LOG.md` | Session continuity log (read first, clear on commit) |
| `PLAN.md` | Feature registry |
| `WORKFLOW.md` | Full process guide |
| `DESIGN.md` | Architecture pointer + decisions log |
| `specs/` | Feature implementation specs |
| `plans/` | Implementation plans and progress logs |
| `AGENT.md` | Rules for the implementation agent |
| `CODING.md` | Coding conventions |
| `REVIEW.md` | Review checklist |
| `.workflow-version` | Tracks which template version this project is at |
<!-- CUSTOMIZE: Add project-specific files to this table -->

---

## Project Overview

<!-- CUSTOMIZE: Replace this section with a description of what the project does,
     its tech stack, key entry points, and any critical runtime rules.
     Examples of what to include:
       - What the project does (1-3 sentences)
       - Primary language and runtime (e.g., "Always use uv run python / uv run pytest")
       - Key config files and where they live
       - Output locations or important paths
       - Credentials / secrets handling (e.g., "Do not commit .env")
-->

[Project description]

**Runtime**: <!-- e.g., Always use `uv run python` / `uv run pytest` — never bare `python` -->

---

## Commands

<!-- CUSTOMIZE: Replace with the actual commands for this project -->

```bash
# Run tests
[test command]

# Start dev server / run the application
[run command]
```

---

## Architecture

<!-- CUSTOMIZE: This section is optional but highly recommended for complex projects.
     Include:
       - Directory structure overview (key directories and what lives in them)
       - Core patterns the implementor must follow (data flow, auth, naming conventions)
       - What is off-limits or requires special care
     
     For simpler projects, a brief paragraph is fine.
     For complex projects, consider using an architecture/ directory and linking here.
-->

[Architecture overview]

---

## Reasoning Quality

When reasoning from evidence to a conclusion, explicitly label it as an inference and verify before presenting it as fact.

- Say so when a conclusion is derived from reasoning rather than direct observation: "My inference is X — let me verify that."
- Before asserting, ask: "Did I observe this directly, or did I reason to it?" If reasoned, verify first.
- Name the verification step explicitly — reading a file, fetching docs, running a command, grepping for a symbol — then do it.
- Risk is highest when a plausible analogy is at hand and circumstantial evidence fits: those conditions make an inference feel like a fact.

**Applies to all inference types:**
- Third-party tool behavior → fetch official documentation
- Code behavior → read the code or run it
- File contents → read the file
- Git history or authorship → run `git log` / `git blame`
- Codebase patterns → grep for them
- System or runtime behavior → test it

---

## Git

<!-- CUSTOMIZE: Update branch name if not `main` -->
- Branch: `main`
- Stage specific files only — never `git add -A`
- Never commit `.env`, `.pem`, or credential files
<!-- CUSTOMIZE: Add any project-specific git rules here -->
