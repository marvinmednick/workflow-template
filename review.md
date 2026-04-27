Review the code changes described or shown (use recent git diff if no specific code is provided): $ARGUMENTS

## Step 0 — Determine Review Path

Before reviewing any code, check whether a progress file exists:

```bash
ls plans/F[N]-progress.md 2>/dev/null || ls plans/I[N]-progress.md 2>/dev/null
```

**If found** — this is a spec/implement-path feature. Read the progress file:
- **Status ≠ `Complete`:** Blocking — stop and report. Do not review incomplete work.
- **Issues non-empty:** Flag each item prominently. These are problems the implementor already identified.
- **File checklist:** Cross-check ✅/🔄/⏳ entries against the spec's "Files to Modify" list. Note any omissions or scope creep.

Continue to code review only when Status is `Complete` and Issues is empty (or all issues are understood and explained).

**If not found** — check for a log file:

```bash
ls plans/F[N]-log.md 2>/dev/null || ls plans/I[N]-log.md 2>/dev/null
```

- **Log file exists with `Workflow: resolve`:** This was a `/resolve`-path issue — no spec or progress file is expected. Skip progress file checks and spec-conformance checks. Review for: code correctness, test coverage of the specific fix, and that PLAN.md tracking is in order. Continue.
- **Log file exists without `Workflow: resolve`:** Progress file is missing for a spec-path feature — warn the user per AGENT.md and do not proceed.
- **No log file either:** No process artifacts found at all — warn the user and do not proceed.

---

Check the implementation against the patterns in CODING.md and the architecture in DESIGN.md.

**Project-Specific Checklist**

Read `REVIEW.md` in the project root. For each checklist item listed there, evaluate the implementation and report **pass** / **fail** / **not-applicable** with a brief explanation.

If no `REVIEW.md` exists, note this and review for general correctness only (no project-specific patterns to check).

**Summary**
Provide an overall assessment and a prioritized list of issues to fix, separated into:
- Blocking (must fix before use — includes any failing tests)
- Non-blocking (should fix but won't break things)
- Suggestions (optional improvements)

## Design Review

If any of the following were found during this review:
- A pattern violation that reveals the current approach should change
- A new pattern being established or codified
- Architecture boundaries being tested or redefined
- A finding added to BACKLOG.md that represents a general inconsistency

Run `/design-review review` before closing out. If the review was clean (patterns followed, no new patterns), skip.

---

## After the review:

**Update the GitHub Issue:**
If a feature ID is known (from the spec or $ARGUMENTS), run:
```bash
gh issue comment [N] --body "## Review complete\n**Result:** [Pass/Needs fixes]\n\n**Blocking:**\n[list]\n\n**Non-blocking:**\n[list]"
```
If review passes, add the `in-review` label and note it's ready to merge:
```bash
gh issue edit [N] --add-label "in-review"
```

**Append non-blocking items to BACKLOG.md:**
For each non-blocking finding and suggestion, append to BACKLOG.md under "Found in Review":
```
- [ ] [Description] — (found in F[N] review)
```

**Update PLAN.md status:**
If the implementation passed review, update the feature's Status column to `In Review`.
If it needs fixes, update the status to `Needs Fixes`.

**Write entry to feature log (`plans/F[N]-log.md`):**
Append a dated entry to the feature log. Create the file if it doesn't exist yet.

If review passed:
```markdown
## [DATE] — Review [N] (Passed)
- **Result:** Passed — no blocking issues
- **Tests:** [X]/[X] passed
- **Non-blocking:** [list, or "none"]
```

If needs fixes:
```markdown
## [DATE] — Review [N] (Needs Fixes)
- **Result:** Needs Fixes — [N] blocking issue(s)
- **Blocking:** [list each blocking issue]
- **Non-blocking:** [list, or "none"]
- **Next:** [what the implementor needs to do]
```
