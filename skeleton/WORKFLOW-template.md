# Development Workflow

> **Details below.** This cheatsheet is the "what do I run" view — scan it for the right command, then read the relevant section for the full story.

---

## Cheatsheet

### Feature Flow

```
Idea → /feature → [/design] → /spec → ./implement → /review-impl → /complete
```

`/feature` captures and registers the idea (creates GitHub issue, uses issue number as F-number). `/design` is optional — use it when UX, data model, or scope needs discussion before a spec can be written.

| Step | Command | When |
|------|---------|------|
| Register | `/feature <description>` | Always — creates GitHub issue, F-number = issue number, adds to PLAN.md |
| Design | `/design F[N]` | When requirements need discussion or a design doc needs updating |
| Spec | `/spec F[N]` | Always — reads design doc if one exists |
| Implement (Light) | `./implement F[N]` | Review level Light |
| Implement (Full) | `./implement F[N] --plan` → `/review-plan F[N]` → `./implement F[N]` | Review level Full |
| Review code | `/review-impl F[N]` after implementor reports tests passing | Always |
| Ship | `/complete F[N]` | After review passes |

### Bug Flow

```
File → Triage → Investigate → /resolve → /complete
```

| Step | Command | When |
|------|---------|------|
| File | `/resolve <description>` or `gh issue create` | Always; capture triage inline if cause is already known |
| Triage | `/triage N` or `/triage N1 N2 …` | Assess severity + effort; no code tracing |
| Investigate | `/investigate N` | When effort is unknown and you need root cause before deciding |
| Fix | `/resolve N` | Stage-aware — skips what's already done |
| Ship | `/complete N` | Same as feature shipping |

### Batch Bug Flow

```
Create batch issue → /resolve [batch-N] → ./implement I[batch-N] → /review-impl → /complete [batch-N]
```

Use when 2–5 small bugs share the same subsystem and can be handed to the implementor in a single pass.

### Other Commands

| Command | When |
|---------|------|
| `/design-review [context]` | After any workflow step that introduced a design decision or change |
| `/fix-baseline` | Unexpected test failures exist before starting a feature |
| `./check-tests` | Verify clean baseline before committing |
| `/triage` (no args) | Triage all open bugs in one pass |
| `./implement F1 --tool aider --model claude-sonnet-4-6` | Override tool or model |

### Implement Tool Selection

Tool is read from `.implement.conf` → `IMPLEMENT_TOOL` env → `--tool` arg (arg wins).

| Flag | Tool |
|------|------|
| `--tool codex` | Codex CLI |
| `--tool gemini` | Gemini CLI |
| `--tool aider --model <model>` | aider (interactive) |

---

## Philosophy

This project uses two distinct roles:

- **Claude** — architecture, design, planning, and code review. Claude understands intent, makes decisions about structure, and specifies exactly what the implementor should build and test.
- **Implementor** (Gemini, aider, Codex, or similar tool) — implementation and testing. The implementor writes code and tests to spec and reports back when all tests pass.

The clean separation matters: implementation tools work best with precise instructions. Claude provides those instructions in the form of specs. This prevents architectural drift, keeps patterns consistent, and ensures nothing falls through the cracks.

---

## Tracking System

| Location | Purpose | Updated by |
|----------|---------|------------|
| `SESSION_NOTES.md` | Rolling session log — design decisions made, work completed, next steps. Never cleared; committed with content. Read first at session startup. | Claude (after each significant workflow step) |
| `PLAN.md` | Feature registry — every feature has a row with ID, status, spec link, and GitHub issue link | Claude (during `/spec`, `/review-impl`, and ship) |
| `docs/design-history.md` | Architecture/design evolution log — what changed, when, why | Claude (via `/design-review`) |
| `specs/F[N]-[slug].md` | Full implementation spec — everything the implementor needs to build a feature | Claude (via `/spec`) |
| `plans/F[N]-log.md` | Feature journal — phase-by-phase history written by Claude | Claude (at each phase transition) |
| `plans/F[N]-progress.md` | Implementor's self-tracking scratchpad — file checklist and resume state | Implementor |
| `BACKLOG.md` | Short-lived inbox — deferred items land here during `/spec` and `/review-impl`, triaged after each commit | Claude |
| `IDEAS.md` | Holding area for AI-generated enhancement suggestions not yet reviewed | Claude |
| `CODING.md` | Coding conventions and patterns — the implementor's reference | Claude (when new patterns are established) |
| `AGENT.md` | Behavioral rules for all implementation agents | Claude (when scope discipline changes) |
| GitHub Issues | Formal record linked to commits | Claude (via `gh` CLI) |

### Feature IDs vs GitHub Issue Numbers

**Feature IDs match their GitHub issue number.** When `/feature` creates a new issue, the assigned issue number becomes the F-number. F76 = issue #76, F81 = issue #81.

- No lookup table needed — `gh issue view 76` is `F76`
- The `F` prefix distinguishes features from bugs and other issues
- Commit messages use the issue number directly: `closes #76`

---

## Feature Lifecycle

```
Idea → Backlog → [Designed] → Specced → In Progress → In Review → Done
```

| Status | Meaning | Files updated |
|--------|---------|---------------|
| Backlog | Planned but not yet designed or specced | PLAN.md row added |
| Designed | Design doc written, decisions recorded; ready to spec | `docs/design/F[N]-[slug].md` created, PLAN.md updated |
| Specced | Spec written, GitHub issue open, ready for implementor | spec file created, PLAN.md updated, issue created, `plans/F[N]-log.md` created |
| In Progress | Implementor is implementing | (implementor working) |
| Needs Fixes | Review ran, found blocking issues; implementor must act | PLAN.md updated, log file updated, `plans/F[N]-progress.md` updated with `## Needs Fixes` section |
| In Review | Review passed, ready to ship | PLAN.md updated, log file updated |
| Done | Committed, GitHub issue closed | PLAN.md updated to Done, issue closed, log file updated |

---

## Use Cases

### 1. Handing Off to the Implementor

#### Review Levels

Each spec has a `**Review Level:**` header — **Light** or **Full**. The spec author sets this.

| | Light | Full |
|---|---|---|
| **When** | 1–2 files, no new files, no schema changes, existing patterns only | 3+ files, new files, schema changes, or new patterns |
| **Flow** | Implement → `/review-impl` → tests → commit | Plan → Claude plan review → implement → `/review-impl` → tests → commit |

**Light workflow:**
```
./implement F1                    # implementor writes code, runs tests, fixes failures
  ↓
/review-impl                      # review code and test quality
  ↓
./check-tests                     # pre-commit baseline verify
  ↓
Commit
```

**Full workflow:**
```
./implement F1 --plan             # implementor writes plans/F1-plan.md, then exits
  ↓
/review-plan F1                   # Claude reviews, writes plans/F1-plan-approved.md
  ↓
./implement F1                    # implementor runs full session: code + tests + fixes
  ↓
/review-impl                      # review code and test quality
  ↓
./check-tests                     # pre-commit baseline verify
  ↓
Commit
```

#### Automated (recommended)

```bash
./implement F1                        # implement (uses tool from .implement.conf)
./implement F1 --plan                 # write plan only (Full level, step 1)
./implement F1 --tool codex           # Codex (explicit override)
./implement F1 --tool gemini          # Gemini CLI
./implement F1 --tool aider           # aider (interactive)
./implement I42                       # issue spec (I-number = GitHub issue number)
```

### 2. Running Tests and Managing the Baseline

The project keeps acknowledged pre-existing test failures in the file set by `KNOWN_FILE` in `.implement.conf`. This separates signal from noise.

**`./check-tests`** runs the full test suite and categorizes results:
- **Unexpected failures** — not in the known list → exits 1, blocks the workflow
- **Known failures** — in the known list → noted but not blocking
- **Stale entries** — in the known list but not currently failing → prompts cleanup

```bash
./check-tests                 # run tests, fail on unexpected failures
./check-tests --show-known    # also show known failures that were observed
./check-tests --show-all      # show all failures regardless of baseline
```

If `./check-tests` reports unexpected failures before you start a feature, address them first:
```
/fix-baseline
```

### 3. Reviewing the Implementation

Once the implementor reports back (all tests passing, files listed):

```
/review-impl F1
```

Claude will:
1. Check all mandatory patterns (from REVIEW.md)
2. Check test coverage against the spec's Tests to Write section
3. Post a review comment on the GitHub issue
4. Append non-blocking findings to `BACKLOG.md`
5. Update PLAN.md status to `In Review` (if passing) or `Needs Fixes` (if blocking issues found)

### 4. Shipping a Feature

```
/complete F1
```

Claude will:
1. Confirm `./check-tests` is clean
2. Show the diff, suggest a commit message, and commit (with `closes #N`)
3. Close the GitHub issue and update PLAN.md to `Done`
4. Triage BACKLOG.md
5. Push

### 5. Non-Feature Issues (Bugs, Cleanup, Tasks)

Non-feature issues use their GitHub issue number directly. Issue #42 gets spec file `specs/I42-[slug].md` if one is needed.

| Stage | Command | What happens |
|-------|---------|-------------|
| **File** | `gh issue create` or `/resolve <description>` | Log the bug |
| **Triage** | `/triage N` | Assess severity + effort; no code investigation |
| **Investigate** | `/investigate N` | Locate root cause; don't fix yet |
| **Fix** | `/resolve N` | Stage-aware: skips completed stages |
| **Ship** | `/complete N` | Commit, close issue, triage backlog |

### 6. Backlog Triage

`BACKLOG.md` is a short-lived inbox. Items land there during `/spec` and `/review-impl`; triage clears it after every ship.

**Fix now** — 1–5 minute change with no risk: apply and commit.
**Promote to GitHub Issue** — non-trivial: `gh issue create --title "..." --label "enhancement"`, then remove from BACKLOG.md.
**Discard** — no longer relevant: delete from BACKLOG.md.

---

## Command Architecture

All workflow commands are available in both **Claude Code** and **Codex CLI**:

| Claude Code | Codex CLI | What it does |
|---|---|---|
| `/review-impl F1` | `$review F1` | Review implementation code |
| `/spec F1` | `$spec F1` | Write an implementation spec |
| `/design F1` | `$design F1` | Design or update a feature |
| `/complete F1` | `$complete F1` | Ship a feature or issue |
| `/feature desc` | `$feature desc` | Register a new feature idea |
| `/fix-baseline` | `$fix-baseline` | Fix pre-existing test failures |
| `/investigate 42` | `$investigate 42` | Investigate a bug's root cause |
| `/resolve 42` | `$resolve 42` | Fix a non-feature issue |
| `/review-plan F1` | `$review-plan F1` | Review an implementation plan |
| `/triage 18 19` | `$triage 18 19` | Assess severity/effort for bugs |

**How it works:** Command instructions live in `commands/*.md` (single source of truth, symlinked from `~/.workflow-template`). Both tools reference these shared files through thin wrappers.

**Updating a command:** Edit `~/.workflow-template/<command>.md` and `git push` — all projects using symlinks pick up the change.

---

## File Reference

| File | Read when |
|------|-----------|
| `WORKFLOW.md` | Learning or explaining the process (this file) |
| `SESSION_NOTES.md` | Starting a session — recent progress and decisions |
| `CLAUDE.md` | Starting a Claude session — project guidance |
| `AGENT.md` | Starting any implementation session — behavioral rules |
| `CODING.md` | Starting any implementation session — coding conventions |
| `REVIEW.md` | Project-specific review checklist (read by `/review-impl`) |
| `commands/*.md` | Shared command instructions — symlinked from `~/.workflow-template` |
| `PLAN.md` | Checking feature status or finding the right spec |
| `BACKLOG.md` | Looking for small tasks to clean up |
| `docs/design-history.md` | Understanding why a design decision was made |
| `specs/F[N]-*.md` | Implementing or reviewing a specific feature |
| `DESIGN.md` | Understanding full system architecture before designing a feature |
