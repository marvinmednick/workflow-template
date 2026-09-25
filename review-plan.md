Review the implementation plan for $ARGUMENTS (e.g. `F1`) against its spec. This is an
iterative Claude + user session — the goal is a correct, complete plan that both parties have
approved, written out as `plans/$ARGUMENTS-plan-approved.md` for the implementor to execute.

## Setup

**Phased features.** If $ARGUMENTS is `F[N].[P]` (phase P of F[N]): find the spec by the base ID
(`specs/F[N]-*.md`) and review the plan against the shared sections plus `## Phase [P]` only; the plan
and approved-plan files use the full ID (`plans/F[N].[P]-plan.md`, `plans/F[N].[P]-plan-approved.md`).
Check that the plan does not reach into other phases. In the rest of this file, `$ARGUMENTS` means
the full ID for file names and the base ID for the spec.

1. Glob `specs/$ARGUMENTS-*.md` to find the spec file
2. Read `plans/$ARGUMENTS-plan.md` (the implementor's draft) — **do not modify this file**
3. Read the spec in full before reviewing

## Review checklist

Check the plan against the spec for each item:

**Completeness**
- All files from spec "Files to Modify" are listed with accurate descriptions
- All new files listed: component files + test files (from "Tests to Write") + migration files
  (from "Database / Schema Changes") — all three categories required
- Each test file entry maps to the specific test cases in the spec's "Tests to Write" section
- Patterns Applying addresses all three: Realtime Mutation Tracking, Household Guard, Undo
  Registration
- Nothing contradicts the spec's "What the Implementor Should NOT Change" section

**Legacy parity** (when the design doc has a Legacy Parity Matrix)
- The plan builds what the matrix rows and approved suggestions describe, nothing more: no added
  features, texts or styling, no omitted rows
- Every difference from legacy the plan introduces is a listed forced change, a drop, or an approved
  suggestion; anything else is a finding

**Gate and coverage** (when the phase has screens compared with legacy): the plan names the gate command
and the harness covers every visible element of each state (an element walk, not only named points); if
coverage depends on points the plan lists, ask whether every visible element of the screen is reachable
through them.

**Checks** (tests, measurement or comparison tools, expected-difference lists, thresholds)
- Every change to a test, harness or expectation file is listed in the plan by file and is justified by the
  spec; an unlisted change, or one that loosens a check, is a finding
- The plan does not give the implementor a way to make a check pass by editing the check

**Precision**
- UI element additions state: what the element is, where it appears in the layout (position
  relative to siblings), and what triggers it — not just that it exists
- Spec-defined specifics are present: query key names, exact field names, API call ordering
  constraints, and enumerated values from the spec are captured verbatim — not paraphrased away
- Behavioral details match the spec exactly: default values, fallback chains, color defaults,
  exact field names
- Tests for locale/timezone-sensitive values (dates, numbers) use self-consistent assertions:
  compute the expected string in the test using the same function call as the component, rather
  than hardcoding a locale-specific string
- External library or package assumptions are either confirmed in CODING.md or flagged in
  Ambiguities / Questions
- Test files that contain JSX (render calls, component trees) use `.tsx` extension, not `.ts`

## During review

Do NOT modify `plans/$ARGUMENTS-plan.md`. The draft is preserved as-is so the original output
can be compared against the approved version later.

Instead, track the corrections you would make and present them to the user:
1. **Gaps found** — bullet list of what is missing or imprecise and why
2. **Open questions** — anything requiring user input before the plan is final
3. **Remaining concerns** — anything you couldn't resolve (spec gaps, unknown library choices)

**Do NOT proceed silently on:**
- Architectural misunderstandings (implementor planned something structurally wrong)
- Spec gaps (the plan reveals missing or ambiguous information in the spec itself)
- Decisions that require user judgment

## Iterate

Discuss with the user until both agree the corrections are right and complete.

## When approved

When both you and the user confirm the plan is ready:

1. Write the corrected plan to `plans/$ARGUMENTS-plan-approved.md` — this is the draft with
   all identified gaps filled in, not a copy of the unmodified draft
2. Confirm: "Plan approved. Written to `plans/$ARGUMENTS-plan-approved.md`.
   Ready to implement: `./implement $ARGUMENTS` (auto-detects the approved plan file)"
