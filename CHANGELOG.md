# Workflow Template Changelog

Each version entry documents what changed and what existing projects need to do.
Symlinked files (commands, scripts, stubs) auto-update — only skeleton file changes require manual action.

---

## v17 (2026-09-18)

### Summary

`./implement`'s pre-implementation baseline check always ran the full suite, even when
`/review-impl` (or a prior `./implement` pass) had just run it moments earlier with no source
changes in between — the same redundant-rerun problem `review.md` already solved for its own
pre-review check via `--if-stale`. Separately, every implementor prompt told the agent to "run
tests, fix failures, run again to confirm all pass," which agents read as "always run twice" —
including on a clean first pass with nothing to fix.

### Changes

- **`scripts/implement`** — Pre-implementation baseline check now calls `./check-tests --if-stale`
  instead of `./check-tests`, skipping the re-run when the saved result is still fresh.
- **`scripts/implement`**, **`implement.md`** — Implementor test instructions reworded: run once,
  fix and rerun only if something failed; an initial clean pass does not require a second full run.

### What existing projects need to do

Nothing. Command and script changes are symlinked and take effect immediately.

---

## v16 (2026-08-29)

### Summary

The workflow enforced *that* architecture docs get updated when a feature ships (`/spec` Doc Updates,
`/review-impl`'s required ledger section, `/complete` Step 3.5's "apply now or block shipping"), but
knew nothing about **architecture forks** — the convention where a doc being changed by open work is
copied to `<name>_<ID>.md`, leaving `<name>.md` as shipped truth until the work completes. So doc
updates were written against shipped truth while a fork was open and lost at the merge, and nothing
ever triggered the merge itself. This makes when and how architecture docs change a workflow rule
rather than a per-project convention.

### Changes

- **`skeleton/DOCUMENTATION-CONVENTIONS-template.md`** — New. What belongs in `architecture/` versus
  `docs/design/` (separated by kind, not maturity); the three gates that keep the set current;
  forking, two-level forks, and the fork banner; and the rules for migrating a large pre-convention
  design doc in one unit at a time.
- **`spec.md`** — Doc Updates must name the fork, not its base, wherever one is open.
- **`review.md`** — Same for the review ledger's Doc Updates section.
- **`complete.md`** — Step 3.5 gains **Merge architecture forks**: merge inward-out (a two-level fork
  merges into its outer fork, not the base), delete the fork, handle a fork with no base, delete any
  document the merge retires along with its index entry, and update the architecture index.
- **`scripts/setup.sh`** — Creates `plans/`, `specs/` and `architecture/` for a new project, and
  lists the conventions doc among the skeleton files to copy.
- **`scripts/verify-repo`** — Checks for `architecture/` alongside `plans/` and `specs/`.

### What existing projects need to do

1. `mkdir architecture` if the project does not have one — `verify-repo` now checks for it.
2. Copy the conventions doc and link it from the architecture index:
   ```
   cp ~/Development/workflow_template/skeleton/DOCUMENTATION-CONVENTIONS-template.md \
      architecture/01-documentation-conventions.md
   ```
   Delete its template note block and add anything project-specific to the index instead.

Command and script changes are symlinked and take effect immediately.

---

## v15 (2026-08-19)

### Summary

`/complete` Step 4 only ever triages BACKLOG.md items tagged to the feature just shipped, by
design (added in v8). With no other mechanism sweeping cross-feature items, patent-analysis's
BACKLOG.md climbed from 12 open items (last manual full scrub, 2026-06-28) to 52 by 2026-08-19,
with each `/complete` run since removing only 1-3 items. Nothing was broken — the scoped design
was working as written — but there was no periodic backstop restoring the old manual-scrub
behavior.

### Changes

- **`complete.md`** — New **Step 4a — Full Backlog Sweep Check**, after Step 4's scoped triage.
  Counts open BACKLOG.md items; if over 20, offers a full cross-feature sweep (same fix-now /
  promote / discard framework as Step 4, but without the feature-tag scoping), worked in batches
  of ~10-15 items rather than all at once, committed per batch. Skips silently under the
  threshold; does not re-prompt within a session if declined.

### Action for Existing Projects

No skeleton changes. Symlinked `complete.md` picks up Step 4a automatically. If a project's
BACKLOG.md has already grown large, the next `/complete` run will offer the sweep.

---

## v14 (2026-08-02)

### Summary

Closes a gap in `/resolve` and `/review-impl` for no-spec resolve-path issues: there was no
supported way to handle a fix applied out of order (before the GitHub issue existed) or to loop
review findings back to a fix pass, since `./implement` requires a spec file and errors out
without one.

### Changes

- **`resolve.md`** — Setup now checks, before the label branch, for (1) an existing review
  ledger with `Open`/`Reopened` findings, routing to new **Path C — Addressing Review Findings**
  (reads the ledger, fixes each finding, fills `Resolution`, sets `Addressed` — same field
  ownership `./implement` follows, never sets `Verified`/`Deferred`/`Wontfix`), and (2) a fix
  already on disk with no log file yet, routing straight to "Create Log Entry" to backfill
  `plans/I[N]-log.md` from the actual diff instead of redoing the fix. "Create Log Entry" also
  gained an explicit backfilling note for the same out-of-order case.
- **`review.md`** — When a ledger comes back `Needs Fixes` on a no-spec resolve-path issue (log
  file with `Workflow: resolve`, no spec/progress file), the reviewer now asks the user to choose
  **Fix now** (apply fixes directly this session, matching `./implement`'s field-ownership rules)
  or **Defer to `/resolve I[N]`** (leave the ledger `Open`, pointing at `/resolve` instead of
  `./implement` in both the feature-log entry and the loop-continues message) — since spec-path
  features still fix by handing back to `./implement` as before.

### Migration for existing projects

Both files are symlinked commands — `/upgrade-workflow` (or `./verify-links`) picks up the change
automatically. No skeleton files changed; no manual action needed.

---

## v13 (2026-07-13)

### Summary

Adds `/revise` — a first-class path for revising an *already-implemented* feature (a post-ship respec), distinct from *superseding* (throw away → new ID). It archives the current revision's process artifacts, scaffolds a new revision section in the spec, and re-arms the plan→implement→review cycle **with no `implement` script change** (archiving the approved plan is what re-arms the Full-level gate).

### Changes

- **`revise.md`** (new command) — `/revise F[N]`: guard (feature must be past its first implementation), checkpoint the tree so "prior work" is a real ref, `git mv` the round's `plans/F[N]-{plan,plan-approved,progress,review}.md` → `-r{R}-` archive, evolve the spec in place with a `Revision N` section + a mandatory prior-work/context note (what shipped + ref, do-not-touch, archived-file pointers, carried-forward findings), set `PLAN.md` → `Revising`, optional `f{N}-r{R}-shipped` tag. Includes a revise-vs-supersede callout.
- **`claude-stubs/revise.md`** (new) — slash-command stub.
- **`skeleton/WORKFLOW-template.md`** — documents the revising-a-shipped-feature flow and the revise-vs-supersede distinction; adds `/revise` to Other Commands.

### Migration for existing projects

Commands and stubs are symlinked, so `/upgrade-workflow` (or `./verify-links`) creates the `commands/revise.md` and `.claude/commands/revise.md` symlinks automatically. For the skeleton file, add the "Revising a Shipped Feature" section + `/revise` row to your project's `WORKFLOW.md` (copy from the template).

---

## v12 (2026-07-02)

### Summary

Adds `--if-stale` to `check-tests` so `/review-impl` and `/complete` can skip re-running the test suite when the implementor's results are still fresh. Fixes the `client/` hardcode in `complete.md` Step 1 that made the staleness check always miss on non-frontend projects.

### Changes

- **`scripts/check-tests`** — new `--if-stale` flag: skips the run and re-surfaces the saved summary when `.last-test-output.txt` is newer than any uncommitted source change (`git diff --name-only HEAD`). Runs in full when stale or when the saved file doesn't exist. Works with both `date -d` (GNU) and `date -r` (BSD) for the timestamp display.
- **`complete.md` Step 1** — replaced the inline staleness check (which hardcoded `client/` and was broken for non-frontend projects) with `./check-tests --show-known --if-stale`. Description updated to explain the skip logic.
- **`review.md`** — added a "Verify Tests" preamble block before the project-specific checklist. Instructs the reviewer to run `./check-tests --show-known --if-stale` rather than re-running the full suite unconditionally.
- **`skeleton/REVIEW-template.md`** — updated the "Do all tests pass?" checklist item to note that tests are verified in the preamble, not re-run inline.

### Migration for existing projects

All changes are to symlinked files (`scripts/check-tests`, `complete.md`, `review.md`) and one skeleton file (`REVIEW-template.md`). Symlinked files auto-update. For the skeleton file, apply this change to your project's `REVIEW.md`:

Change the "Do all tests pass?" line under Test Coverage from:
```
- Do all tests pass? (Run `./check-tests --show-known` from project root)
```
to:
```
- Do all tests pass? (verified by `./check-tests --show-known --if-stale` in review preamble — do not re-run here)
```

---

## v11 (2026-06-25)

### Summary

Adds a `decision-needed` status and label for features that are blocked on a design or policy
decision before normal `/design` → `/spec` work can begin.

The pattern arose organically on patent-analysis (F43/#43): a feature was registered not to be
implemented immediately but to formally track a pending design decision. Without this status, the
only options were `Backlog` (implies ready to design) or leaving the feature out of the registry
entirely. `Decision Needed` fills the gap — it's a first-class PLAN.md status that signals the
feature exists but is explicitly blocked upstream.

Changes:
1. **New `decision-needed` GitHub label** — orange (#e4860e), created by `setup-github-labels.sh`
   and required by `verify-repo`. Safe to re-run `setup-github-labels.sh` on existing repos.
2. **`feature.md` Step 5 updated** — new Step 5b documents when to choose `Decision Needed` vs.
   `Backlog`, how to apply the label, and the bold PLAN.md row convention. Steps 5b/5c/5d
   renumbered (5b was previously unlabeled, now has an explicit status-selection step before it).

### Auto-updated (symlinks — no action needed)
- `scripts/setup-github-labels.sh`: adds `decision-needed` label.
- `scripts/verify-repo`: `REQUIRED_LABELS` now includes `decision-needed`.
- `feature.md`: Step 5 gains an explicit Step 5b for status selection; Step 5d shows both PLAN.md
  row variants (Backlog vs. Decision Needed); Step 6 adds the decision-resolution next step.
- `upgrade-workflow.md`: Step 0b now directs Claude to run `setup-github-labels.sh` automatically
  when `verify-repo` reports missing labels (previously advisory; now directive).

### Skeleton file changes
- None.

### Migration for existing projects
- Run `/upgrade-workflow` — Step 0b will detect the missing label and run `setup-github-labels.sh`
  automatically. No manual steps required.
- Bump `.workflow-version` to `11`.

---

## v10 (2026-06-16)

### Summary

Two more gaps found while verifying v9 readiness end-to-end:

1. **`enhancement` was never added to the required-labels list**, even though `feature.md` has
   created `enhancement`-labeled issues since v6, and the new `create-feature-issue.sh` (v9) does
   too. `gh issue create --label X` hard-fails if the label doesn't exist in the repo. It happened
   to work everywhere so far because `enhancement` ships as a GitHub default label on new repos —
   but `verify-repo` (run by `/upgrade-workflow` and meant to catch exactly this kind of gap) would
   never have flagged it missing if that default were ever absent or deleted.

2. **`/spec` Case A trusted PLAN.md's F-number without checking it against the linked issue.** The
   v8 fix stopped *new* drift but did nothing for features where drift already happened (the
   original F23/#28 case) or could recur from a manual edit. `/spec` now extracts the issue number
   from PLAN.md's issue link, compares it to the F-number, and — if they don't match — corrects it:
   renames every existing artifact (`specs/`, `docs/design/`, `plans/`) from `F[N]` to `F[M]` via
   `git mv`, updates internal references, fixes the PLAN.md row, and renames the GitHub issue title
   if needed. This makes `/spec` self-healing for the exact failure mode that started this whole
   round of fixes, with user confirmation before any renames.

### Auto-updated (symlinks — no action needed)
- `setup-github-labels.sh`: now creates `enhancement` alongside `feature`.
- `verify-repo`: `REQUIRED_LABELS` now includes `enhancement`.
- `spec.md`: Case A gains a verify-and-correct sub-step before proceeding — detects F#/issue#
  mismatch and repairs it (renames files via `git mv`, updates references, fixes PLAN.md and the
  issue title), with user confirmation before renaming.

### Skeleton file changes
- None.

### Migration for existing projects
- Symlinked scripts auto-update. Run `./verify-repo` to confirm `enhancement` is present (it almost
  certainly already is, as a GitHub default label) — if missing, `./setup-github-labels.sh` is safe
  to re-run.
- No action needed for the `/spec` self-healing change — it runs automatically next time `/spec` is
  invoked on a feature with a mismatched F#/issue#.
- Bump `.workflow-version` to `10`.

---

## v9 (2026-06-16)

### Summary

Closes two gaps left by v8:

1. **`/design` Fresh Mode had the same F#-drift bug `/spec` did.** When `/design` was invoked on a
   feature not yet in PLAN.md (skipping `/feature`), it assigned the F-number from the highest local
   file count and created no GitHub issue. If `/spec` ran later, its issue-creation step would get a
   *different* GitHub-assigned number than the one already baked into the design doc's filename and
   PLAN.md row — the same class of mismatch that caused F23/#28. Fixed: `/design` Fresh Mode now
   creates the issue first (when one doesn't already exist) and derives F# from it, matching `/spec`.

2. **The create-issue-then-rename-to-`F$N`-sequence was duplicated three times** (`feature.md`,
   `spec.md` Case B, `design.md` Fresh Mode) — exactly the kind of copy-pasted logic that drifts
   silently when one call site is updated and the others aren't. Extracted into a single shared
   script, `scripts/create-feature-issue.sh`, that all three now call. Plain (non-feature) issue
   creation in `resolve.md` and `complete.md` is unaffected — it has no F#-derivation step and
   doesn't need the script.

### Auto-updated (symlinks — no action needed)
- New `scripts/create-feature-issue.sh`: creates a GitHub issue, derives the F-number from it,
  renames the issue title to `F$N: ...`, prints the number to stdout.
- `feature.md`: Step 5b/5c collapsed into a single call to the shared script.
- `spec.md`: Case B (no issue yet) now calls the shared script instead of inline `gh issue create`.
- `design.md`: Fresh Mode Step 1 rewritten — issue-first numbering via the shared script, matching
  `feature.md`/`spec.md`. Step 6's PLAN.md note corrected (issue link is no longer expected to stay
  `—` until `/spec` — it's created at first registration, whichever command runs first).
- `setup.sh` / `verify-links`: `create-feature-issue.sh` added to the scripts symlink list.

### Skeleton file changes
- None.

### Migration for existing projects
- Symlinked files auto-update — no action needed for in-flight features.
- **Existing projects need the new script symlinked manually** (it didn't exist when they last ran
  `setup.sh`): run `./verify-links` and accept the fix-it prompt, or manually:
  ```bash
  ln -sf "$WORKFLOW_TEMPLATE_DIR/scripts/create-feature-issue.sh" ./create-feature-issue.sh
  chmod +x ./create-feature-issue.sh
  ```
- Bump each project's `.workflow-version` to `9`.

---

## v8 (2026-06-16)

### Summary

Two correctness fixes surfaced when completing F23:

1. **F# must always equal the GitHub issue number.** `spec.md` was assigning the F-number by
   incrementing the highest local file count, then creating the GitHub issue afterward — an
   independent counter that silently drifts when any non-feature issue is filed between features
   (F23 landed on issue #28). `feature.md` fixed this in v6; `spec.md` now matches: if no issue
   exists, create it first and derive F# from the GitHub-assigned number. If an issue already exists
   (from `/feature`), use it — no new issue created.

2. **Architectural doc updates collected incrementally, applied at `/complete` — never deferred.**
   Doc update obligations are now tracked in two places: a `### Doc Updates` section in the spec
   (Claude's architectural judgment at spec time — which docs, what high-level change) and a
   `## Doc Updates` section in the review ledger (filled by the reviewer when recording `Passed` —
   concrete, ready-to-execute instructions). `/complete` step 3.5 reads the ledger section and
   applies updates directly. No `gh issue create` for doc gaps; apply now or block.

### Auto-updated (symlinks — no action needed)
- `spec.md`: Step 1 rewritten — Case A (issue exists, use it) / Case B (no issue, create first);
  "Create GitHub Issue" section rewritten to update vs. create; `### Doc Updates` section added to
  spec template; standing "What NOT to Change" bullet for architectural docs.
- `review.md`: `Doc Updates: Pending | Done | None` added to ledger header; `## Doc Updates`
  section added to ledger format; step 4 of "What you do each round" requires filling this section
  before setting `Status: Passed`.
- `complete.md`: Step 3.5 rewritten — reads ledger `## Doc Updates` and applies changes directly;
  hard rule: no `gh issue create` for doc gaps.

### Skeleton file changes
- None. No AGENT.md or other skeleton changes required.

### Migration for existing projects
- Symlinked files auto-update — no action needed for existing in-flight features.
- Future `/spec` runs will create the issue first (Case B) or update the existing one (Case A).
- Future `/review-impl` passing rounds must fill `## Doc Updates` in the ledger.
- Future `/complete` runs will apply doc updates from the ledger rather than deferring.
- Bump each project's `.workflow-version` to `8`.

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
