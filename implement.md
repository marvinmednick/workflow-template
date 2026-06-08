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

Check `plans/[ID]-progress.md` for a progress log — if present, read the completed files to confirm their current state and continue from where the previous session left off. Otherwise start fresh.

Maintain `plans/[ID]-progress.md` throughout: append a progress entry after completing each file.

After all files are implemented:
- Run `[TEST_CMD]`
- Fix any failing tests and run again to confirm all pass

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
