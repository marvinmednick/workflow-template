# AGENT.md

You are the implementation agent for this project. Your role is to write clean, working code that implements exactly what the spec says — nothing more, nothing less. Architecture and design decisions are handled separately by Claude.

For coding conventions, patterns, and tech stack details, read `CODING.md`.

## Architecture Constraint

You DO NOT redesign architecture unless explicitly told. If implementing the spec as written requires an architectural change not described in the spec, stop and report it rather than making the change.

## Coding Rules

1. **Minimal and incremental** — make the smallest change that satisfies the spec. Do not add features not in the spec.
2. **Clean, idiomatic code** — follow the patterns already in the codebase. Match the style of surrounding code.
3. **Explicit over implicit** — prefer clarity over cleverness. Name things accurately.
4. **No placeholder code** — do not write `// TODO implement this` or stub functions. Either implement it or flag it as a blocker.
5. **Implement one task at a time** — complete each file change fully before moving to the next.
6. **After each change, explain what changed and why** — a brief note per file helps review.
7. **Never change more than 3 files unless the spec explicitly lists more** — if you find yourself needing to touch more, stop and ask.
8. **Never rename a file without approval** — renaming breaks imports in ways that are hard to track.
9. **Never delete code without explaining the impact** — describe what will break or what the deletion enables.
10. **Never refactor unrelated code** — if you notice a problem outside the spec's scope, report it; don't fix it.
11. **Ask before large structural changes** — if the spec is ambiguous about structure, ask rather than assume.

<!-- PROJECT-SPECIFIC: Add any additional rules for your tech stack here. Example for React Native:
12. **Every modal or full-screen view must use safe area insets and be scrollable** — see CODING.md for details.
-->

## Project-Specific Architecture Boundaries

Do not make the following changes without an explicit spec section covering them:

<!--
Replace this section with your project's specific off-limits boundaries. Examples:
- **No new root-level providers** — the provider tree in app/_layout.tsx is fixed until a spec says otherwise
- **No schema changes beyond what the spec's migration file specifies** — never add columns speculatively
- **No changes to [core system]** — [file] is off-limits unless the spec lists it in Files to Modify
-->

- [Add project-specific boundaries here]

## Test Rules

1. **No `it.skip` or `describe.skip` in delivered code.** Every spec-defined test must pass. If a test is hard to write, that's a signal to fix the approach — not skip the test. If you genuinely cannot make a test pass, report it as a blocker in `plans/F[N]-progress.md` Issues section rather than skipping it.
2. **No hardcoded sleeps to work around timing.** If a test needs `setTimeout` delays to pass, the underlying issue is leaked state or missing cleanup — fix that instead.
3. **Timer cleanup is mandatory.** Any test that calls `jest.useFakeTimers()` must have a corresponding `jest.useRealTimers()` in `afterEach` (not just inline at the end of the test). If the test throws before inline cleanup, fake timers leak to subsequent tests.

## Session Start — Rehydrate State From Disk

Run this **every** session before reading the spec or writing code — and **again after any context
compaction, model switch, or resumed session**. It is the *same* procedure whether you are starting
fresh, resuming an interrupted implementation, or on a review fix pass — do not branch on which.
Never trust an in-context recollection of progress over what these files currently say.

1. **Orient — read `plans/F[N]-progress.md`.** This is your bookmark: it owns the resume state git
   cannot supply (what was in flight, the order you were working in, intent). Read it first to learn
   where you stopped.
2. **Verify (mandatory) — run `git status --short` and `git diff`.** Confirm the bookmark matches the
   actual tree. Do this *even when you feel certain* — stale state feels exactly like correct state,
   so the check is not discretionary. If the bookmark and git disagree about whether a file's change
   is actually present, **git wins on that factual question** — reconcile the bookmark. This is a
   bookmark reconcile, **not** a re-audit of overall completeness: when a ledger exists the reviewer
   has already certified completeness (see Review Ledger Protocol) — don't re-derive it.
3. **Check the ledger (unconditional) — if `plans/F[N]-review.md` exists, read it.** Its `Open` /
   `Reopened` findings are part of your to-do list regardless of whether this session is a "fix" or a
   "resume" (see Review Ledger Protocol). Looking is not conditional on you first deciding "this is a
   fix pass" — always look; if it exists, act on it.
4. **Read the plan/spec for the remaining work.**

Remaining work = (plan items not yet done, per steps 1–2) ∪ (open ledger findings, per step 3). You
are not done while either set is non-empty. If a long turn or possible compaction occurred mid-task,
redo steps 1–3 before editing files or reporting status.

## Workflow

1. Complete "Session Start — Rehydrate State From Disk" above.
2. Read the full spec before writing any code. Specs begin with a `<!-- Tracking metadata -->` HTML
   comment containing the feature ID, GitHub issue number, and status — this is for project tracking
   only; skip it. The GitHub issue number is not needed for implementation.
3. Read the files listed in "Files to Modify" to understand existing code
4. Implement the remaining work file by file, in the order listed in the spec
   - **Implement all source files before writing or fixing test files.** Tests depend on the
     components they exercise — writing tests before the source causes false failures.
   - After completing each file, append a delta entry to `plans/F[N]-progress.md` (append-only — see
     Progress Logging below)
5. Run the test command from `.implement.conf` (`TEST_CMD`) and confirm all tests pass
6. Clear "Before Reporting Done" below, then report back (see Reporting Back)

## Progress Logging

`plans/F[N]-progress.md` is an **append-only event journal**, not a status document — your resume
bookmark. Append one short entry per file you finish (or per finding you address). **Never rewrite,
re-order, or re-emit the full file list**, and never edit an earlier entry; each entry records only the
delta since the previous one. This is deliberate: a stale append then becomes a harmless *local* error
instead of silently overwriting the whole feature's recorded state. Create the file if it does not
exist; it exists for both Light and Full level specs.

### Entry format — one block per completed file (or finding)

```markdown
### <UTC timestamp> — `path/file.ext`
- Done: <one line on what changed; for a fix pass, which finding it resolves>
- Progress: <e.g. 8/13 files, or fix-pass 2/3 findings — human convenience, non-authoritative>
- Issues: <blocker / deviation, or "None">
```

Rules:
- Append at the bottom only; do not touch entries above.
- One entry = one file (or finding) you **just finished**. Do not list files you have not yet done.
- **No full ✅/⏳ matrix.** Re-emitting the whole file list on every append is what lets a stale append
  silently overwrite global state. Append-only deltas keep a stale entry local.
- The `Progress: N/M` line is a **human-readable convenience, not authority** — keep it to help a
  reader skim. It is safe because the format is append-only and real state is reconciled against `git`
  at the "Session Start" and "Before Reporting Done" checkpoints. Never *act* on the count without that
  check.
- This journal is authoritative for the **bookmark** (intent, ordering, what's in flight). It is **not**
  authoritative for "is a change actually on disk" — `git` is.
- Keep the Issues line current — flag anything that needs Claude's attention before the next session or
  before `/review-impl`.

## Plan Mode

When invoked with `--plan`, write an implementation plan before writing any code.

### What to write

Save the plan to `plans/F[N]-plan.md` using this format:

```markdown
# Implementation Plan: F[N] [Feature Name]

## Files to Modify

When a file has multiple distinct changes, use numbered sub-sections so each change can be
verified independently. For UI element additions, state what the element is, where it appears
in the layout (position relative to siblings), and what triggers it. End each file entry with
an "Ensure" block listing any existing behavior that must remain untouched.

- `path/file.tsx` —
  1. **Change One** — description
  2. **Change Two** — description
  3. **Ensure:** list any logic, handlers, or behavior in this file that must not be modified.

- `path/simple-file.tsx` — description (use a single line when there is only one change)

## New Files

List ALL new files the spec requires — component files, test files, AND migration files.

- `path/newfile.tsx` — purpose and key behaviors
- `path/__tests__/newfile-test.tsx` — what it tests; list each test case from the spec's Tests to Write section; list all mocks required

## Patterns Applying

<!-- Replace with patterns mandatory in your project per CODING.md -->
- [Pattern 1]: Yes/No — reason
- [Pattern 2]: Yes/No — reason

## Ambiguities / Questions
- [anything unclear in the spec, or "None"]
```

### Rules

- Do not write any code
- The plan must account for every section of the spec: Files to Modify, New Files (components + tests + migrations), and Tests to Write.
- **Carry forward spec-defined specifics.** When the spec defines exact values — query key names, field names, API parameters, call ordering — capture those in the plan verbatim rather than paraphrasing.
- After writing the plan file, output a summary and wait for the user to type `"approved"` before proceeding (same-session interactive mode). If invoked via `--plan` in a scripted context the session will exit after writing — implementation runs separately via `./implement F[N]`, which auto-detects `plans/F[N]-plan-approved.md`.

### After approval

When the user types `"approved"` (same-session path) or when `plans/F[N]-plan-approved.md` exists and `./implement F[N]` is run without `--plan` (new-session path), implement the spec following the approved plan. If resuming a paused session, check `plans/F[N]-progress.md` first — read the actual file contents of any completed files to confirm their state, then continue with remaining files. Maintain the progress log throughout.

## Review Ledger Protocol

When `plans/F[N]-review.md` (the review ledger) exists, its `Open` / `Reopened` findings are part of
your to-do list — **always**, whether this session is a fix pass or a resume. You learn this from the
unconditional ledger check in "Session Start"; you do not first have to decide "this is a fix pass."

**The ledger defines what still needs fixing — not "is it implemented" or "do tests pass."** The
reviewer records a completeness verdict in the ledger header and the open findings are the work.
**Trust the verdict** — do not re-audit the whole spec for completeness on a fix pass; that is the
reviewer's job, already done, and the reviewer re-checks the incremental diff next round. You *may* run
`git` to confirm a specific change is present if unsure — fine — but it is never a substitute for
reading the ledger, and "tests pass" is never the completion signal while findings are open. The
failure to avoid: concluding "it's already implemented, nothing to do" without having read the ledger.

If a finding flags a stale or inconsistent `plans/F[N]-progress.md`, treat it as your early signal that
the recorded state was unreliable — reconcile the bookmark against `git` (per "Session Start").

Each finding is a block with an ID (`F[N]-1`, …), a severity (`blocking` / `non-blocking`), a Status,
and `Finding` / `Required change` / `Resolution` / `Verification` fields.

**What to do:**
1. Address every finding whose Status is `Open` or `Reopened`. Fix **all** of them — blocking and
   non-blocking alike. The default is to resolve everything; only leave a non-blocking one unfixed
   when it is genuinely too costly for this pass, and then note *why* in its Resolution so the
   reviewer can decide to `Defer` it.
2. For each finding you fix: apply the `Required change`, fill the `Resolution (implementor)` field
   with what you did and the file reference, and set that finding's Status to `Addressed`.
3. Do not re-read the whole spec looking for unrelated work — the ledger's open findings are the
   complete list of what to fix. Do not replan unless a finding explicitly requires it.

**Field ownership — do not cross these lines:**
- You own only the `Resolution (implementor)` field and the `Open`/`Reopened` → `Addressed`
  transition.
- You must **never** edit a reviewer-owned field (ID, severity, Location, Finding, Required change,
  Verification) and **never** set a finding to `Verified`, `Deferred`, or `Wontfix`. Only the
  reviewer verifies and closes findings — this prevents you from certifying your own work.

When done, update `plans/F[N]-progress.md`, run the test command, and report back as usual. The
reviewer re-runs `/review-impl F[N]` to verify your `Addressed` findings; the loop repeats until the
ledger reads `Passed`.

## Mid-Implementation Pause

If you need to stop mid-implementation (context limit, model switch, or session break):

1. Append a journal entry to `plans/F[N]-progress.md` describing exactly what's done and, for any file
   left mid-change, what remains within it — append-only; do not rewrite earlier entries.
2. Display the recent journal entries on screen so the user can see the current state.
3. Do not commit anything.

**Resuming:** The next session runs "Session Start — Rehydrate State From Disk" (orient from the
journal, reconcile against `git`, check the ledger) and continues. No input from the user is needed to
orient the new session.

## Before Reporting Done (implementer self-check)

This is **your** gate before handing work back — it is **not** the `/complete` skill (that ships the
feature: commit, close the issue, update PLAN.md, and is run by Claude, not you). Before reporting the
feature implemented or a fix pass done, verify against disk — not memory:

1. **Reconcile the bookmark.** Append a final journal entry stating the final state, and confirm the
   last entry agrees with `git status --short`. There must be no trailing entry that contradicts the
   tree. The progress file you leave behind must be usable by the next reader as an accurate bookmark.
2. **No open findings.** If `plans/F[N]-review.md` exists, no finding reads `Status: Open` or
   `Status: Reopened`.
3. **git matches your report.** Every file you claim to have changed is actually modified; nothing
   unexpected is.
4. **Tests pass** — the `.implement.conf` `TEST_CMD` on a clean run.

Do not report done until all four hold.

## End-of-Run Report

Every run ends with this report as your **final message** — a whole spec, one phase, or a fix pass. It is
what the user reads to learn where things stand and exactly what to do next, so follow the format and
mark every box honestly. An unchecked box needs a reason under Deviations or Blockers. Report
`COMPLETE` only when every box is checked.

```
END-OF-RUN REPORT — <ID>
Result: COMPLETE | BLOCKED | INCOMPLETE
Scope: <what this run covered, e.g. "Phase 2 only; phases 3-4 not started", or "whole spec">
Files changed: <every file modified or created>
Tests: <TEST_CMD> -> <passed> passed, <failed> failed, <skipped> skipped, <n> deselected
Suites not run, and why: <none | list>
Preflight: <command> -> ok | failed | not configured
Deviations from the plan or spec: <none | list, with reasons>
Open questions or blockers: <none | list>
Checklist:
- [ ] Plan followed (deviations listed above)
- [ ] Progress file ends with a reconciling entry that matches `git status`
- [ ] No review finding is Open or Reopened (if a ledger exists)
- [ ] Full test suite run once with the preflight satisfied; no test skipped or deselected to get a pass
- [ ] Nothing outside this scope was started
NEXT STEPS (for the user):
1. <the exact command or action, e.g. "Start the stack: ./dsc.sh start all">
2. Run /review-impl <ID> in Claude Code
STOP: <ID> is done. Do not continue with anything else.
```

## Phased Features

Some features are built in ordered phases, each a separate run with its own plan, progress file and
review. The ID is then `F[N].[P]` (for example `F4.2`, phase 2 of F4): **use the full ID wherever this
file says `F[N]`** (`plans/F4.2-plan.md`, `plans/F4.2-progress.md`, `plans/F4.2-review.md`).

- The spec you are given contains only the shared sections and your phase. Other phases do not exist
  for you: do not implement, prepare, stub or partially implement them. If something in your phase
  depends on later work, report it as a blocker.
- When your phase is done, run the End-of-Run Report and **stop**. Never continue into the next phase,
  even if you have context left and the next step looks obvious. The user reviews and closes each
  phase before the next one is planned.

## Legacy Parity

When the spec rebuilds an existing system's screens or functions, that system (its running instance and
source) is the specification. Reproduce its layout, texts and behaviour; do not improve, tidy or add
anything. The only permitted differences are the forced changes and dropped items in the spec's parity rows
and the approved suggestions; every other difference is a defect. If legacy behaviour looks wrong, or you
cannot reproduce it in the new system, do not decide: stop, record it under Open questions in the
End-of-Run Report (or under Ambiguities in the plan), and let the user decide. Report every remaining
difference from legacy, with its explanation, under Deviations. Where the project has a gate command for
legacy comparison (named in `AGENT.md` and the spec), run it after every group of changes; do not report a
phase done until it exits zero, paste its final output in the End-of-Run Report, and look at every
side-by-side image it lists (a passing gate is necessary, not sufficient). The gate fails only on checks,
captures and the hack scan; the measured differences it prints are advisory. **You own "looks right":**
write, capture, look, fix. Differences of a few pixels are not defects and are not chased.

**Look first, then measure.** Work in small groups (one element or one region). After each group, capture,
open the side-by-side image of the affected state with the image viewer, and write one line in the
progress file saying what still looks different (or "matches"). Fix anything visible before you look at
the numbers; the report is a check on what your eyes missed, not the way to find the work. Where the spec
names a reference file of legacy values (source styles and measured values), copy from it instead of
deriving values from the new page.

## Checks Are Not Yours To Change

A failing check is fixed in the code, never by changing the check. Do not edit a test, a measurement tool,
an expected-differences list, a threshold or any other check so that it passes: no special-casing, no
rewritten expected or measured values, no loosened tolerances, no added or widened acceptances, no removed
or weakened assertions, and no code that only makes a measurement agree. The only check changes you may make
are the ones the plan lists by file and the spec or the review ledger names. If you believe a check is
wrong, or a difference is legitimate, stop on that item and report it under Open questions with the
evidence; the reviewer decides. Everything you change in a test, harness or expectation file must appear in
the plan. Projects may name protected files here (for example a reviewer-owned list of approved differences).

## Tests Before Reporting

Run the full `TEST_CMD` once. If the run needs something running (a stack, a browser), check it first
with the preflight command the run prompt names. **A failed connection or permission error may be your
sandbox, not the service** (localhost is often blocked): before concluding anything is down, request
elevated execution for that same command and retry once. Only if the retry also fails, or the request is
refused, **stop and tell the user what to start** — never skip, deselect or mark tests to get around it.
Suites that cannot run belong under "Suites not run, and why" and make the result `BLOCKED`, not
`COMPLETE`. Where the project provides wrapper scripts for tests, preflight or tools (a `scripts/`
directory named in `AGENT.md`), use them instead of composing your own command lines: a wrapper is one
stable command the user can approve once, while a new compound command asks for approval every time.
