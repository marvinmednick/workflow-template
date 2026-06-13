Implement the spec: $ARGUMENTS

## Step 0 — Parse and validate

Identify the spec ID from $ARGUMENTS (e.g. `F1`, `I4`).

Find the spec file:
```bash
find specs -name "${ID}-*.md" | head -1
```

If not found, list available specs and stop.

Read the spec fully. Note:
- `**Review Level:**` header — Full or Light
- Files listed under "Files to Modify" and "New Files"
- Test cases listed under "Tests to Write"

For **Full** level: confirm `plans/${ID}-plan-approved.md` exists. If it doesn't:
```
Error: F[N] is a Full-level spec and requires an approved plan.
  Step 1: ./implement F[N] --plan     # write the plan (or /review-plan F[N] to write interactively)
  Step 2: /review-plan F[N]           # review and approve in Claude Code
  Step 3: /implement F[N]             # implement with approved plan
```

---

## Step 1 — Read TEST_CMD from config

```bash
grep '^TEST_CMD=' .implement.conf | sed 's/^TEST_CMD=//'
```

You will pass this exact command to the implementation agent.

---

## Step 2 — Spawn the implementation agent

Use the Agent tool to launch a fresh implementor agent with this prompt (substitute actual values for `[ID]`, `[spec-path]`, `[TEST_CMD]`):

```
You are the implementation agent for this project. Read AGENT.md and CODING.md in full before making any changes to code.

Your task: implement `[spec-path]`.

[IF Full level and approved plan exists]:
The approved implementation plan is at `plans/[ID]-plan-approved.md`. Follow it exactly.

Before writing any code, rehydrate state from disk — the SAME procedure whether this is a fresh start,
a resume, or a review fix pass (see "Session Start" in AGENT.md). Do not branch on which one you think
it is:
1. Read `plans/[ID]-progress.md` to orient — where the last session stopped and what was in flight.
2. Run `git status --short` and `git diff` to confirm that bookmark against the actual tree. This is a
   bookmark reconcile, NOT a completeness re-audit; git wins on "is this change actually on disk."
3. ALWAYS check `plans/[ID]-review.md` (the review ledger), regardless of whether you think this is a
   fix pass. If it exists, its `Open`/`Reopened` findings are part of your to-do list — do NOT
   conclude "already implemented, nothing to do" and stop. Read the "Review Ledger Protocol" section
   of AGENT.md and follow it: address every `Open`/`Reopened` finding (blocking AND non-blocking;
   defer a non-blocking one only when genuinely too costly, noting the reason in its Resolution for the
   reviewer to set `Deferred`); for each, fill the `Resolution (implementor)` field and set its Status
   to `Addressed`. Never edit a reviewer-owned field and NEVER set `Verified`/`Deferred`/`Wontfix` —
   only the reviewer verifies. Trust the reviewer's completeness verdict in the ledger header; do not
   re-audit the whole spec.

Remaining work = (approved-plan items not yet done) ∪ (open ledger findings).

Maintain `plans/[ID]-progress.md` throughout: append one delta entry per file finished — append-only,
never rewrite or re-emit the full file list.

When every plan item is complete AND no finding reads `Open`/`Reopened`:
- Run `[TEST_CMD]`; fix any failing tests and run again to confirm all pass.
- Clear the "Before Reporting Done" self-check in AGENT.md: reconcile the progress bookmark so no stale
  trailing entry survives, confirm `git status` matches what you'll report, no open findings, tests pass.

Report back:
- Every file modified or created
- Full test output (or confirmation all pass with count)
- Any deviations from the spec, with explanation
- Any blockers found (architectural issues, missing context, ambiguous spec)
```

---

## Step 3 — Present results

When the agent reports back, display its report and suggest:
```
Run /review-impl [ID] to review the implementation before committing.
```

If a review ledger (`plans/[ID]-review.md`) was present, this was a fix pass — re-running
`/review-impl [ID]` verifies the `Addressed` findings and surfaces any new ones. Repeat the
implement → review loop until the ledger reads `Passed`.
