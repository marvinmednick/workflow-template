# Workflow Template Changelog

Each version entry documents what changed and what existing projects need to do.
Symlinked files (commands, scripts, stubs) auto-update — only skeleton file changes require manual action.

---

## v7 (2026-06-13)

### Summary
Hardens the implement/review handoff against the F11 failure, where `./implement` after a review
**self-certified completion without reading the review ledger** (it confirmed the code looked
implemented, ran tests, and reported done), and the progress file had silently corrupted under context
compaction (a full-status matrix let a stale append regress the recorded state 13/13 → 7/13).

Three coordinated changes establish a clear contract across the two roles:
- **One uniform startup, no fix-vs-resume branch.** `implement.md` and `AGENT.md` now have the agent
  rehydrate state from disk every session (and after any compaction): orient from the progress
  bookmark → reconcile against `git` → **unconditionally** check `plans/[ID]-review.md`. The ledger
  check is no longer a buried conditional the agent could skip; if the file exists, its open findings
  are part of the to-do list — period.
- **Authority split made explicit.** progress journal = resume *bookmark* (intent/ordering/in-flight);
  `git` = what's actually on disk; ledger = what needs fixing + the reviewer's **completeness verdict**.
  On a fix pass the implementor trusts the verdict and does not re-audit the spec.
- **Progress journal is append-only deltas, not a rewritten matrix.** A stale append is now a harmless
  *local* blip instead of a global overwrite. The `Progress: N/M` line stays as a non-authoritative
  human convenience; real state is reconciled against `git` at two checkpoints (Session Start, Before
  Reporting Done).
- **Reviewer owns completeness.** `review.md` Step 0 now reviews against the working tree (not the
  progress file's self-report), records an `Implementation: Complete|Incomplete` verdict in the ledger
  header, and treats a stale/inconsistent progress file as a *non-blocking hygiene finding* rather than
  a hard "Status ≠ Complete → stop" block (which would have wrongly bounced the stale-but-complete F11).

### Auto-updated (symlinks — no action needed)
- `implement.md`: spawn prompt rewritten — uniform rehydrate-from-disk startup, unconditional ledger
  check, self-certification language removed, remaining-work = plan items ∪ open findings.
- `review.md`: Step 0 reviews against the working tree; records the `Implementation:` verdict; a stale
  progress file is a non-blocking hygiene finding, not a hard stop. Ledger header gains an
  `Implementation:` line; round 1 records the verdict.

### Skeleton file changes (review and update existing projects)

**AGENT.md** — five changes (see `skeleton/AGENT-template.md`):
1. New **Session Start — Rehydrate State From Disk** section (orient → git reconcile → unconditional
   ledger check), referenced as Workflow step 1.
2. **Progress Logging** rewritten to an append-only delta journal (no ✅/⏳ matrix; `Progress: N/M` is a
   non-authoritative convenience).
3. **Review Ledger Protocol** opening softened/unconditionalized: ledger defines what needs fixing,
   trust the reviewer's completeness verdict, don't re-audit; reconcile a flagged stale bookmark.
4. **Mid-Implementation Pause** updated for append-only journaling + Session Start resume.
5. New **Before Reporting Done (implementer self-check)** section (reconcile bookmark, no open findings,
   git matches report, tests pass) — distinct from the `/complete` skill; replaces the old "Completion
   Gate" naming.

### Migration for existing projects
- Symlinked `implement.md` / `review.md` update automatically.
- Apply the five AGENT.md changes above to each project's `AGENT.md` (they sit alongside any
  project-specific Coding/Boundaries sections), then bump the project's `.workflow-version` to `7`.
- **patent-analysis already has the AGENT.md changes hand-applied during the F11 post-mortem session
  (2026-06-13); its `.workflow-version` is set to 7 directly — no `/upgrade-workflow` needed there.**

---

## v6 (2026-06-13)

### Summary
Fixes `/feature` so the **F-number always equals the GitHub issue number**. The old Step 5 derived
the F-number from "highest F in PLAN.md + 1" — an independent counter that silently drifts from the
issue number the moment any non-feature issue is filed between two features (e.g. F4 landed on issue
`#8`). `skeleton/WORKFLOW-template.md` already documented the correct intent ("F-number = issue
number"); the command now matches it: create the issue first, read the number GitHub assigns, then
set the title to `F<N>: …` and add the PLAN row. Also formalizes that the `feature`/`enhancement`
label conveys **significance only** — both types get an F-number and the same
`/design` → `/spec` → `/review` workflow.

### Auto-updated (symlinks — no action needed)
- `feature.md`: Step 5 rewritten — issue-first numbering (`F<N>` = issue number, no separate
  counter), a type-label (significance) step, and a PLAN row that carries the `feature|enhancement`
  type.

### Skeleton file changes (review and update existing projects)
- None. `WORKFLOW-template.md` already stated the rule; no skeleton edits required.

### Migration for existing projects
- Symlinked `feature.md` updates automatically — new `/feature` runs use issue-number IDs.
- **Existing rows where `F<N> ≠ #<N>` are not auto-fixed.** To realign: rename `specs/`, `plans/`,
  and `docs/design/` files to the issue number, update PLAN.md (add a `Type` column;
  `feature`/`enhancement`), and `gh issue edit <N> --title "F<N>: …"`. (patent-analysis did this on
  2026-06-13: F4→F8, F5→F9, enhancements #4–#7 adopted as F4–F7.)

---

## v5 (2026-06-12)

### Summary
Closes the review → implement → re-review loop with a structured **review ledger**
(`plans/F[N]-review.md`). `/review-impl` now records each finding as a tracked block with a stable
ID, severity, and status; `./implement` reads the ledger and addresses open findings, marking them
`Addressed`; re-running `/review-impl` verifies the fixes and adds any new findings. Repeat until the
ledger reads `Passed`. Strict field ownership keeps the implementor from certifying its own work
(only the reviewer sets `Verified`). The default is to fix **all** findings — blocking and
non-blocking — deferring a non-blocking item to BACKLOG/a new issue only with a stated reason.

This replaces the previously stubbed `## Needs Fixes` handoff (which pointed the implementor at a
`## Needs Fixes` section in `plans/F[N]-progress.md` that `/review-impl` never actually wrote).

### Auto-updated (symlinks — no action needed)
- `review.md`: detects the ledger (round 1 vs. re-review), defines the ledger format / field
  ownership / status lifecycle / convergence rule, scopes re-reviews to the incremental diff, and
  gates PLAN.md `In Review` + the issue `in-review` label on the ledger reaching `Passed`.
- `implement.md`: the implementation-agent prompt now reads `plans/[ID]-review.md` when present and
  addresses `Open`/`Reopened` findings; Step 3 documents the implement → review loop.

### Skeleton file changes (review and update existing projects)

**AGENT.md** — Replace the `## Needs Fixes` section with a `## Review Ledger Protocol` section. See
`skeleton/AGENT-template.md` for the exact text. It tells the implementor: when
`plans/[ID]-review.md` exists, address every `Open`/`Reopened` finding (blocking and non-blocking),
fill the `Resolution (implementor)` field, set Status `Addressed`, and never touch reviewer-owned
fields or set `Verified`.

Projects whose `AGENT.md` predates the `Needs Fixes` section should simply add the new
`## Review Ledger Protocol` section (e.g. after Progress Logging).

### New required project files
- None. The ledger (`plans/F[N]-review.md`) is created automatically by `/review-impl` on the first
  review round.

### Action required for existing projects (one-time, per repo)
Update each project's `AGENT.md` per above. Either copy `## Review Ledger Protocol` from
`skeleton/AGENT-template.md`, or run `/upgrade-workflow` to apply it automatically.

---

## v4 (2026-06-09)

### Auto-updated (symlinks — no action needed)
- `setup.sh`: Step 3 now references `setup-claude.sh` and the CLAUDE-template.md skeleton
- New `setup-claude.sh` script: interactive CLAUDE.md generator; asks project name, description, language/runtime, branch, credentials, and architecture directory; available at `~/Development/workflow_template/scripts/setup-claude.sh`

### Skeleton file changes (review and update existing projects)

**CLAUDE.md** — Add a "Reasoning Quality" section before the Git section. It instructs Claude to explicitly label inferences before asserting them as facts. See `skeleton/CLAUDE-template.md` for the exact section.

The section to add:

```markdown
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
```

### New required project files
- None (CLAUDE.md is an existing file in each project — update it per above)

### Action required for existing projects (one-time, per repo)
Add the "Reasoning Quality" section to each project's `CLAUDE.md`. Either:
- Copy the section from `skeleton/CLAUDE-template.md`, or
- Run `/upgrade-workflow` — it will offer to apply the change automatically.

---

## v3 (2026-06-08)

### Auto-updated (symlinks — no action needed)
- `upgrade-workflow.md`: Added Step 0b — runs `./verify-repo` before the version check
- `verify-links`: Now also checks that `verify-repo` is symlinked
- `setup.sh`: Now symlinks `verify-repo` for new projects; mentions `setup-github-labels.sh` in next steps
- New `verify-repo` script: checks gh auth, required labels, and project file structure

### Skeleton file changes (review and update existing projects)

**WORKFLOW.md** — Add a "One-Time Repository Setup" section near the top (after the intro, before the Cheatsheet). It documents the `setup-github-labels.sh` step that creates the 12 required workflow labels. See `skeleton/WORKFLOW-template.md` for the exact section.

### New required project files
- None

### Action required for existing projects (one-time, per repo)
Run the label setup script once for each GitHub repo using this workflow:
```bash
~/Development/workflow_template/scripts/setup-github-labels.sh OWNER/REPO
```
Creates: `feature`, `specced`, `in-review`, `cleanup`, `test-quality`, `docs`, `severity:high/medium/low`, `effort:small/medium/large`. Safe to re-run — skips existing labels.

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
