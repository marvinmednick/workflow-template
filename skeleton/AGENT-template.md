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

## Workflow

1. Read the full spec before writing any code. Specs begin with a `<!-- Tracking metadata -->` HTML
   comment containing the feature ID, GitHub issue number, and status — this is for project tracking
   only; skip it. The GitHub issue number is not needed for implementation.
2. Read the files listed in "Files to Modify" to understand existing code
3. Implement changes file by file, in the order listed in the spec
   - **Implement all source files before writing or fixing test files.** Tests depend on the
     components they exercise — writing tests before the source causes false failures.
   - After completing each file, append a progress entry to `plans/F[N]-progress.md` (see Progress Logging below)
4. Run the test command from `.implement.conf` (`TEST_CMD`) and confirm all tests pass
5. Report back (see Reporting Back below)

## Progress Logging

After completing each file, and whenever you stop, append to (or update) the `## Progress Log` section in `plans/F[N]-progress.md`. Create the file if it doesn't exist. This file is separate from the plan file and exists for both Light and Full level specs.

### Format

```markdown
## Progress Log

### Files
- ✅ `path/file.tsx` — brief description of what was done
- 🔄 `path/file.tsx` — in progress: what's done, what remains within this file
- ⏳ `path/file.tsx` — not started

### Issues
- [Blockers, unexpected patterns, deviations from spec — or "None"]

### Status
[Complete | In progress — N/M files done | Paused — N/M files done]
```

Keep the Issues section current — flag anything that needs Claude's attention before the next session or before `/review-impl`.

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

When `plans/F[N]-review.md` (the review ledger) exists, the feature has been reviewed and you are on
a fix pass. The ledger — not the spec — is your authoritative to-do list. Read it **before** the spec.

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

1. Update `plans/F[N]-progress.md` with current state — mark any in-progress file as 🔄 and note exactly what's done and what remains within it; set Status to `Paused — N/M files done`
2. Display the progress log contents on screen so the user can see the current state
3. Do not commit anything

**Resuming:** The next session reads `plans/F[N]-progress.md` to see what's done, reads the actual file contents of completed files to confirm their state, then continues with remaining files. No input from the user is needed to orient the new session.

## Reporting Back

When done, return:
- **Files changed**: list every file modified or created
- **Tests**: paste the full test output (or confirm all pass with count)
- **Deviations**: any spec section you couldn't implement as written, with explanation
- **Blockers found**: any architectural issues or missing context that blocked full implementation

Bring this output back to Claude and run `/review-impl` to verify before committing.
