# Development Workflow

> **Details below.** This cheatsheet is the "what do I run" view — scan it for the right command, then read the relevant section for the full story.

---

## One-Time Repository Setup

After running `scripts/setup.sh` to install symlinks, create the standard workflow labels in your GitHub repo:

```bash
~/Development/workflow_template/scripts/setup-github-labels.sh OWNER/REPO
```

This creates 12 labels used by the workflow commands: `feature`, `specced`, `in-review`, `cleanup`, `test-quality`, `docs`, `severity:high/medium/low`, and `effort:small/medium/large`. Safe to re-run — skips labels that already exist.

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

### Revising a Shipped Feature

```
/revise F[N] → ./implement F[N] --plan → /review-plan F[N] → ./implement F[N] → /review-impl F[N] → /complete F[N]
```

Use `/revise` when a **shipped feature needs to evolve** (a post-implementation respec). It keeps the
same ID and issue, archives the current revision's process artifacts
(`plans/F[N]-{plan,plan-approved,progress,review}.md` → `-r{R}-`), and re-arms the normal cycle —
archiving the approved plan makes `./implement` require a fresh `--plan` with no script change.

**Revise vs. supersede:** *revise* when the existing implementation is right and you're extending it
(same ID). *Supersede* when it went the wrong direction and should be thrown away — that's a **new
feature ID** (old one marked `Superseded`, old commits kept reachable via an archive git tag).

### Other Commands

| Command | When |
|---------|------|
| `/revise F[N]` | Revise a shipped feature (post-ship respec) — archives the round's artifacts, re-arms the cycle |
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

**How it works:** Command instructions live in `commands/*.md` (single source of truth, symlinked from the workflow-template clone). Both tools reference these shared files through thin wrappers.

**Updating a command:** Edit `<command>.md` in the workflow-template clone and `git push` — all projects using symlinks pick up the change instantly.

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
| `commands/*.md` | Shared command instructions — symlinked from the workflow-template clone |
| `PLAN.md` | Checking feature status or finding the right spec |
| `BACKLOG.md` | Looking for small tasks to clean up |
| `docs/design-history.md` | Understanding why a design decision was made |
| `specs/F[N]-*.md` | Implementing or reviewing a specific feature |
| `DESIGN.md` | Understanding full system architecture before designing a feature |

---

## Phased Features

A large feature can be built in ordered phases, with a review and a decision point between them. Use
phases when a feature has three or more steps that can each be checked on their own, or whose later
steps depend on how the earlier ones turned out.

**Notation.** `F4.2` is phase 2 of F4. The design doc, spec file, GitHub issue, `PLAN.md` row and
`plans/F4-log.md` belong to `F4`. The plan, progress file and review ledger belong to the phase, and
this includes phase 1 — `plans/F4.1-plan.md`, `-plan-approved.md`, `-progress.md`, `-review.md`, exactly
like phase 2 onward. There is no special case for phase 1: `./implement F4` (bare) on a phased feature
is always an error, whether that's phase 1 or any later phase.

**The spec is one file with two tiers.** The header has `**Phases:** N`. Shared sections (context,
conventions, doc updates, what not to change) come first; each phase is a `## Phase N — Title` section.
Phase 1 is fully detailed when the spec is written — no separate `/spec F4.1` call ever happens, since
there's nothing to fill in that the initial `/spec` didn't already write. Later phases carry only their
goal, entry and exit criteria, and any parity rows, and are marked `<!-- detail: pending -->`. Their file
lists and tests are written at the start of the phase, from the code as built (`/spec F4.N`, N > 1).
`./implement` refuses a phase whose detail is pending.

**Retrofitting phases onto an already-specced, unphased feature.** If `F[N]` was originally specced
without phases and is later split into phases — typically because scope grew mid-flight — its existing
bare-named artifacts (`plans/F[N]-plan.md` etc.) are not renamed. That work stands as Phase 1 by fact;
the new phased spec starts at Phase 2, and Phase 2 onward follows the `.[P]` suffix rule above.

**The loop for each phase P:**

| Step | Command | Result |
|---|---|---|
| Write the detail (P > 1 only — phase 1's detail is in the initial `/spec`) | `/spec F4.P` | Phase section filled in; earlier phases' lessons applied |
| Plan | `./implement F4.P --plan`, then `/review-plan F4.P` | `plans/F4.P-plan-approved.md` |
| Implement | `./implement F4.P` | Code, progress file, end-of-run report with the user's next steps |
| Review | `/review-impl F4.P` | `plans/F4.P-review.md` ledger; fix loop until Passed |
| Close | `/complete F4.P` | Commit, `Phase P closed` log entry, doc updates, refresh of phase P+1 |

`./implement F4.P` (P > 1) refuses to start unless `plans/F4.(P-1)-review.md` reads `Status: Passed` and
`plans/F4-log.md` has a `Phase P-1 closed` entry. `./implement F4` on a phased feature is always an
error, including for phase 1 — use `./implement F4.1`. `/complete F4` closes the issue once every phase
is closed.

**`.implement.conf`** may set `PREFLIGHT_CMD` (for example a health check on the dev stack) and
`PREFLIGHT_HELP`. `./implement` runs the preflight before the implementor starts and tells the
implementor to run it again before its final test run.
