Review the code changes described or shown (use recent git diff if no specific code is provided): $ARGUMENTS

## Step 0 — Determine Review Path

**Phased features.** If $ARGUMENTS is `F[N].[P]` (phase P of F[N]): use the full ID for the progress
file and ledger (`plans/F[N].[P]-progress.md`, `plans/F[N].[P]-review.md`; finding IDs `F[N].[P]-1`, …);
review against the shared spec sections plus `## Phase [P]`. Phases are committed when they close, so
the phase's work is the uncommitted tree (`git status`, `git diff HEAD`). Look at every changed file
for scope: work belonging to another phase is a finding. Feature-level tracking is unchanged: the
`plans/F[N]-log.md` entry says "Phase [P] review round k"; the GitHub comment names the phase; do not
change the `PLAN.md` status at a phase review (the phase close does). `Passed` on a phase ledger does
not close the issue.

The **working tree is what you review** — `git diff` and the actual file contents, not the progress
file's self-report. `plans/[ID]-progress.md` is a *hint* to orient you, never the authority on what is
done (it can go stale under context compaction).

Check whether a progress file exists:

```bash
ls plans/F[N]-progress.md 2>/dev/null || ls plans/I[N]-progress.md 2>/dev/null
```

**If found** — this is a spec/implement-path feature. Read it as a hint, then (and run `./check-spec-tests` for the completeness check below):
- **Judge completeness against the code, not the log.** Cross-check the spec's "Files to Modify" and
  "New Files" against the actual working tree (`git status` / `git diff`). If a required change is
  genuinely missing or unimplemented, raise it as a finding (blocking if it blocks the feature) — do
  not silently pass it. Record the outcome as the **Implementation** verdict in the ledger header
  (see below). If the work is *substantially* incomplete (many spec items absent), record
  `Implementation: Incomplete` with the missing items as blocking findings and report Needs Fixes
  rather than doing a deep line-by-line review.
- **A stale or internally inconsistent progress file is a *non-blocking hygiene finding*, not a hard
  stop.** (E.g. the last entry reads "7/13" but git shows all files changed.) Note it in the ledger so
  the implementor reconciles the bookmark next pass — then proceed to review the actual code. Do NOT
  refuse to review just because the log looks stale.
- **Issues section non-empty:** flag each item prominently — problems the implementor already
  identified.

**If not found** — check for a log file:

```bash
ls plans/F[N]-log.md 2>/dev/null || ls plans/I[N]-log.md 2>/dev/null
```

- **Log file exists with `Workflow: resolve`:** This was a `/resolve`-path issue — no spec or progress file is expected. Skip progress file checks and spec-conformance checks. Review for: code correctness, test coverage of the specific fix, and that PLAN.md tracking is in order. Continue.
- **Log file exists without `Workflow: resolve`:** Progress file is missing for a spec-path feature — warn the user per AGENTS.md and do not proceed.
- **No log file either:** No process artifacts found at all — warn the user and do not proceed.

## Step 0.5 — First review or re-review?

Check for the review ledger:

```bash
ls plans/F[N]-review.md 2>/dev/null || ls plans/I[N]-review.md 2>/dev/null
```

**If it does NOT exist** — this is **round 1**. You will create the ledger in the "Review Ledger"
section below. Review the full implementation.

**If it exists** — this is a **re-review** (the implementor has acted on prior findings). Read the
ledger first, then:

1. Note the `Last round` number; this review is round `Last round + 1`.
2. Scope your reading to what changed since the previous round. Use the diff:
   ```bash
   git diff HEAD   # uncommitted work, or compare against the commit at the last round
   ```
   You do not need to re-review `Verified` findings — they are closed. Focus on:
   - Every finding with Status `Addressed` → verify the fix actually resolves it.
   - Every finding with Status `Open` or `Reopened` → the implementor did not address it; confirm it
     is still present and leave it as-is (or escalate severity if warranted).
3. After verifying, look at the incremental diff for **new** problems the changes introduced.

The ledger is the authoritative record of findings across all rounds. Update it (per the rules
below), do not start a fresh one.

---

Check the implementation against the patterns in CODING.md and the architecture in DESIGN.md.

**Verify Tests**

Before reading REVIEW.md, confirm the test suite passes. Use `--if-stale` to skip the re-run when the implementor's results are still fresh (saves time on the common case where the implementor ran tests immediately before this review):

```bash
./check-tests --show-known --if-stale
```

If the saved results are still fresh (no source changes since the last run; edits to the work log, plan, ledger and spec files do not count), `check-tests` reports the prior result without re-running. If anything changed since the last run, it runs in full. If unexpected failures are found, stop and report them before continuing the review.

**Gate, test names, test strength, and a real run** (every round; all four are the reviewer's own checks,
never the implementor's report)

1. **The project gate.** If `.implement.conf` sets `GATE_CMD` (for example `make ci`), run it and record the
   result in the ledger's round line. A non-zero exit is a blocking finding on its own. A passing test run
   does not stand in for it: lint and format failures were reported "verification complete" on three
   phases of one feature.
2. **Named tests exist.** Run `./check-spec-tests F[N].[P]` (or `F[N]`). Every name it lists as missing is a
   finding unless the progress file maps it to a renamed test that exists. Judge the mapping, not the count.
3. **Tests can fail.** For each new test file, look for tests that cannot fail: placeholder assertions
   (`callable`, `exists`), assertions on a value the test computed itself, a precondition that is never
   reached (the code exits earlier, so "file is absent" is trivially true), and assertions weaker than the
   behaviour the spec names. For the two or three highest-risk behaviours, prove a test would catch a defect:
   run the test against a deliberately broken copy of the code (a scratch copy or probe outside the tree
   under review; never edit the tree and never leave a probe behind). A test that stays green when its
   behaviour is broken is a blocking finding.
4. **Run the new thing once, for real.** For a tool, script, command or integration the tests drive only
   through fakes, run it for real once in round 1, bounded and read-only (for example a zero-experiment or
   dry-run mode, a `--limit`, or one request against the running stack), and record what happened. Tests
   written against fakes prove the fake. Do this before reading the code in detail: a stub, a wrong host or
   a missing credential shows up in minutes.

**Project-Specific Checklist**

Read `REVIEW.md` in the project root. For each checklist item listed there, evaluate the implementation and report **pass** / **fail** / **not-applicable** with a brief explanation.

If no `REVIEW.md` exists, note this and review for general correctness only (no project-specific patterns to check).

**Checks diff** (every review)

Diff the tests, measurement or comparison tools and expected-difference files (`git diff` on those paths)
against what the spec and plan allow. Any weakening is a **blocking** finding unless the spec names it: a
value rewritten or special-cased for one side, a loosened tolerance, a new or widened acceptance, a removed
or softened assertion, a skipped test, or code that only makes a measurement agree (for example CSS transforms
that shift boxes to measured coordinates). Also look at the real output (screenshots, reports), not only the
numbers: a check that passes while the result looks wrong is a finding.

**Gate first.** Where the project has a legacy-comparison gate command, run it before reading the code and
record its per-screen counts in the ledger's round line. A non-zero exit (check, capture or hack-scan
failure) is a blocking finding on its own; the implementor's paste is never a substitute for your run. The
comparison counts are advisory: they help you find candidates and never block by themselves.

**Illustrative UI detail is not a contract.** If the spec marked its markup/CSS/layout as
illustrative (see spec.md's "Binding vs. illustrative detail"), a deviation from that sample markup
is not itself a finding — judge screens against the Acceptance Criteria and the binding tier
(data, routes, permissions, state ownership), and against the user's own look at the built screen,
not against whether the implementation reproduces the spec's sample HTML. Raise a finding only when
a binding item is actually wrong, or when the spec gave no illustrative-detail split for a screen at
all (itself a spec-review finding — see spec.md).

**UI Review Gate (any phase that adds or changes a screen, with or without a Legacy Parity
Matrix).** A test suite passing, and your own read of the template/view code, are not the same as
the screen looking and working right — that only gets judged once a human has actually looked, not
from your inference about what they would think. This is required in addition to everything else in
this file, and it blocks `Status: Passed` exactly like an open finding does.

1. **Look yourself first.** Confirm the stack is actually reachable (start it, or ask the user to,
   per the project's container-lifecycle convention) and open every screen the phase touched — a
   live browser, the project's own capture/screenshot tool, or a Playwright-based browser test if one
   exists. Reading the template is not looking at the screen. Confirm each one renders and the
   Acceptance Criteria hold before involving the user.
2. **Then get the user's own look — and wait for an answer.** Tell them exactly what to open (URL,
   steps) or show them what you saw, and ask directly: does this look and work the way you expect?
   A screenshot or description with no response back is not sign-off. Do not infer approval from
   silence, from the user moving on to a different topic, or from your own confidence that it's fine.
3. **Record the outcome before setting `Status: Passed`.** Fill the ledger's `## UI Review` section
   (below) with what the user actually said. Until they have looked and responded, the ledger stays
   `Needs Fixes` no matter how clean the code and tests are.

This applies even when the spec marked every screen's markup illustrative, and even when there is no
legacy equivalent to compare against — "illustrative, not a contract" governs what counts as a
*finding*, never whether anyone needs to look at the built result.

**Legacy parity check** (when the design doc has a Legacy Parity Matrix)

For the screens in scope, compare the implementation with the legacy system (its running instance and
source, or the comparison harness report if the project has one), not with the spec's description. Your
job is function, scope and the matrix (texts, elements, behaviour), not pixels. Every difference in texts,
elements or behaviour must be a forced change, a drop or an approved suggestion in the design doc; any other
is a defect. Open the side-by-side images as a second pair of eyes; the user's look is the acceptance. Grade
by what a person notices:
- **blocking**: visible at a glance (a missing or wrong element, text, colour, weight or icon, or a
  size or position difference of about 10 px or more), or any weakening of a check;
- **not raised**: differences of a few pixels, and computed-style differences that look the same. If you want
  to record them, put all of a screen's in **one grouped backlog line**, not a finding.
**At most two review rounds per phase with screens.** Round 1 lists every blocking item in one pass; round 2
verifies. After round 2 do not open new findings for polish: put the remainder in the backlog and ask the
user whether to ship. Check also that nothing was added that legacy does not have, and that each state in the
matrix was compared. Record the verdict under the Implementation heading of the ledger.

---

## Review Ledger — `plans/F[N]-review.md`

The ledger is the single, structured, machine-and-human-readable record of every review finding and
its status across rounds. Both `/review-impl` and `./implement` read and write it, with **strict
field ownership** so neither side certifies its own work.

### File format

```markdown
# Review Ledger: F[N] — [Feature Name]
**Last round:** [k] | **Status:** [Needs Fixes | Passed]
**Implementation:** [Complete | Incomplete] — [as of round k: all spec files present & reviewed | N items unimplemented, see findings]
**Open blocking:** [count] | Open non-blocking: [count]
**UI Review:** [N/A | Pending | Confirmed] — [N/A: no screen touched this round; Pending: not yet shown to the user or awaiting their response; Confirmed: one line on what the user actually said]
**Doc Updates:** [Pending | Done | None]

---

## F[N]-1  [blocking]  Status: Verified
- **Opened:** round 1
- **Location:** `path/file.py:42`
- **Finding:** What is wrong and why it matters.
- **Required change:** The specific change that resolves it.
- **Resolution (implementor):** What was done, with file ref. (round k)
- **Verification (reviewer):** What was confirmed. Verified (round k).

## F[N]-2  [non-blocking]  Status: Open
- **Opened:** round 2
- **Location:** `path/file.py:88`
- **Finding:** ...
- **Required change:** ...
- **Resolution (implementor):** _(unfilled)_
- **Verification (reviewer):** _(unfilled)_

---

## UI Review
<!-- Filled by reviewer. Required whenever this round touched a screen — cannot set Status: Passed
     without it being N/A or Confirmed. "Confirmed" means the user actually looked and responded,
     not that the reviewer looked, ran tests, or inferred approval. -->
- **Screens touched this round:** [list the URLs/templates, or "None — no UI files changed"]
- **Shown to the user:** [how — screenshots pasted, a description + URL to open themselves, a live walkthrough]
- **User's response:** [quote or summarize what they actually said; "awaiting response" if not yet answered]
<!-- If no screen was touched, write: N/A — no UI files changed this round -->

## Doc Updates
<!-- Filled by reviewer when recording Implementation: Complete. Required — cannot set Status: Passed without this section. -->
<!-- Name the FORK, not its base, wherever one is open — see architecture/01-documentation-conventions.md -->
- `architecture/some-doc.md` §Section: [concrete description of what to add or change — enough for Claude to open the file and make the edit without re-reading the whole feature]
- `DESIGN.md` §Section: [what to update]
<!-- If no architectural docs need updating, write: None -->
```

**Architecture forks.** In a project with an `architecture/` directory, a doc being changed by open work is forked to `<name>_<ID>.md` and that fork is the only edit surface. Before listing a doc here, check whether a fork of it exists and name the fork instead — an update applied to the base is lost when the fork merges. If this feature opened its own fork, that is the doc to name.

### Finding IDs

Monotonic per feature: `F[N]-1`, `F[N]-2`, … New findings get the next unused number. A finding's ID
never changes — a reopened finding keeps its number so its full history stays in one block.

### Severity

`blocking` (must fix before the feature can ship) or `non-blocking` (should fix; only deferred for a
stated reason — see Convergence).

### Status lifecycle

- `Open` — reviewer raised it; implementor has not addressed it.
- `Addressed` — implementor made the fix and filled Resolution; awaiting reviewer verification.
- `Verified` — reviewer confirmed the fix. **Terminal.**
- `Reopened` — reviewer re-checked an `Addressed` finding and it is still wrong; add a note to
  Verification explaining what's still missing. Goes back to the implementor.
- `Deferred` — agreed not to fix in this feature; **requires a reason** and a pointer to where it's
  tracked (BACKLOG.md line or a new issue number). **Terminal** for this feature.
- `Wontfix` — agreed the finding is invalid or not worth fixing; requires a one-line justification.
  **Terminal.**

### Field ownership (do not cross these lines)

- **Reviewer (this command) owns:** ID, severity, Location, Finding, Required change, the Verification
  field, and setting Status to `Open` / `Verified` / `Reopened` / `Deferred`.
- **Implementor (`./implement`) owns:** the Resolution field, and setting Status `Open`/`Reopened` →
  `Addressed` only.
- **The implementor must never set `Verified`.** Only the reviewer verifies. This is the whole point
  of a separate review pass — it prevents self-certification.

### What you do each round

1. **Round 1:** confirm completeness against the working tree (per Step 0) and record the
   `Implementation:` verdict in the header; create the ledger; write one block per finding (blocking
   and non-blocking), all `Status: Open`.
2. **Re-review:** for each `Addressed` finding, verify against the diff → set `Verified`, or set
   `Reopened` with a note. Add new findings as new blocks (next monotonic ID, `Status: Open`).
   Recompute the header counts, `Last round`, and the `Implementation:` verdict's round marker.
3. Decide each non-blocking finding consciously: it must end the feature as `Verified` or `Deferred`
   (with reason) — never left silently `Open`. The default is to fix it; defer only when it is
   genuinely too costly for this pass.
4. **Before claiming `Status: Passed`, resolve `## UI Review`.** If this round touched any screen,
   look yourself, then get the user's own look per the UI Review Gate above, and fill the section
   with what they actually said. Set the header field to `N/A` only when no UI file changed this
   round; otherwise it must be `Confirmed` — never set it to `Confirmed` from your own inference,
   and never leave it `Pending` while also writing `Status: Passed`.
5. **When recording `Status: Passed`:** fill the `## Doc Updates` section and set the header
   `Doc Updates:` field. This is required — you cannot set `Status: Passed` without it. Write
   concrete, targeted entries (enough for Claude to open the file and make the edit). If no
   architectural docs need updating, write `None` in both places. Read the spec's `### Doc Updates`
   section first — it lists pointers Claude identified at spec time; flesh those out with specific
   section names and content based on what was actually built.

### Convergence — when the ledger is `Passed`

Set `**Status:** Passed` only when **all** hold:
- `UI Review` is `N/A` or `Confirmed` — never `Pending`.
- **Zero** `blocking` findings remain in `Open`, `Addressed`, or `Reopened` (i.e. all blocking are
  `Verified`, `Deferred`-with-reason, or `Wontfix`).
- **Every** non-blocking finding is `Verified`, `Deferred`-with-reason, or `Wontfix` — none left
  `Open` / `Addressed` / `Reopened`.

Until all hold, `**Status:** Needs Fixes`.

---

**Summary (report to the user each round)**
Give an overall assessment and the current ledger state:
- Round number and `Status` (Needs Fixes / Passed)
- New findings this round (count + IDs)
- Findings verified this round (count + IDs)
- Findings reopened this round (count + IDs)
- Still open: blocking and non-blocking counts
- `UI Review` state — if `Pending`, say so plainly and ask for the user's look now; do not bury
  this in the findings list or let a clean test run stand in for it

## Design Review

If any of the following were found during this review:
- A pattern violation that reveals the current approach should change
- A new pattern being established or codified
- Architecture boundaries being tested or redefined
- A finding added to BACKLOG.md that represents a general inconsistency

Run `/design-review review` before closing out. If the review was clean (patterns followed, no new patterns), skip.

---

## After the review:

**Write/update the ledger first.** It is the authoritative record — everything below is a summary or
pointer derived from it.

**Update the GitHub Issue:**
If a feature ID is known (from the spec or $ARGUMENTS), post a per-round summary (not the full
finding detail — that lives in the ledger):
```bash
gh issue comment [N] --body "## Review round [k] — [Passed | Needs Fixes]\nNew: [count] · Verified: [count] · Reopened: [count] · Still open: [B blocking / NB non-blocking]\nLedger: plans/F[N]-review.md"
```
Only when the ledger is `Passed`, add the `in-review` label:
```bash
gh issue edit [N] --add-label "in-review"
```

**Deferred non-blocking items → BACKLOG.md:**
When (and only when) a non-blocking finding is set to `Deferred`, append it to BACKLOG.md under
"Found in Review" and reference it back from the ledger:
```
- [ ] [Description] — (deferred from F[N] review round [k], ledger F[N]-[id])
```

**Update PLAN.md status:**
- Ledger `Passed` → set the feature's Status to `In Review`.
- Ledger `Needs Fixes` → set the feature's Status to `Needs Fixes`.

**Write entry to feature log (`plans/F[N]-log.md`):**
Append a dated **summary** entry (the detail is in the ledger). Create the file if it doesn't exist.

If the ledger is `Passed`:
```markdown
## [DATE] — Review round [k] (Passed)
- **Result:** Passed — all blocking resolved; non-blocking verified or deferred
- **Tests:** [X]/[X] passed
- **Ledger:** plans/F[N]-review.md
```

If the ledger is `Needs Fixes` **and this is a spec/implement-path feature** (progress file found
in Step 0):
```markdown
## [DATE] — Review round [k] (Needs Fixes)
- **Result:** Needs Fixes — [B] blocking, [NB] non-blocking still open
- **This round:** new [count], verified [count], reopened [count]
- **Next:** run `./implement F[N]` to address open findings, then `/review-impl F[N]` again
- **Ledger:** plans/F[N]-review.md
```

If the ledger is `Needs Fixes` **and this is a no-spec resolve-path issue** (log file with
`Workflow: resolve` found in Step 0, no spec/progress file): there is no implementor agent to
hand this off to automatically, so ask the user how to proceed:
```
AskUserQuestion — Needs Fixes: [B] blocking / [NB] non-blocking open. How do you want to address them?
  - Fix now — apply the fixes directly this session, then re-run /review-impl to verify.
  - Defer to /resolve I[N] — leave the findings Open in the ledger; running /resolve I[N] later
    (a fresh session, optionally a different model) will detect the open ledger and address them.
```

**If "Fix now":** apply each `Open`/`Reopened` finding directly with Edit/Write, fill its
`Resolution` field and set `Addressed` (same field ownership `./implement` follows for spec-path
work — never set `Verified`/`Deferred`/`Wontfix` on your own fix). Then write:
```markdown
## [DATE] — Review round [k] (Needs Fixes — fixed inline)
- **Result:** Needs Fixes — [B] blocking, [NB] non-blocking still open
- **This round:** new [count], verified [count], reopened [count], addressed inline [count]
- **Next:** run `/review-impl I[N]` again to verify the inline fixes
- **Ledger:** plans/I[N]-review.md
```

**If "Defer":** leave the ledger untouched (`Open`/`Reopened`) and write:
```markdown
## [DATE] — Review round [k] (Needs Fixes)
- **Result:** Needs Fixes — [B] blocking, [NB] non-blocking still open
- **This round:** new [count], verified [count], reopened [count]
- **Next:** run `/resolve I[N]` to address open findings, then `/review-impl I[N]` again
- **Ledger:** plans/I[N]-review.md
```

**If `Needs Fixes` on a spec/implement-path feature, tell the user the loop continues:**
```
Needs Fixes — [B] blocking / [NB] non-blocking open. Findings in plans/F[N]-review.md.
Next: ./implement F[N]   (implementor addresses open findings)
Then: /review-impl F[N]  (re-review — verifies fixes, adds any new findings)
Repeat until the ledger reads Passed.
```

**If `Needs Fixes` on a no-spec resolve-path issue, tell the user the loop continues** (matching
the Fix now / Defer choice above):
```
Needs Fixes — [B] blocking / [NB] non-blocking open. Findings in plans/I[N]-review.md.
[Fix now chosen]  Fixed inline this round — run /review-impl I[N] again to verify.
[Defer chosen]    Next: /resolve I[N]     (reads open ledger findings and fixes them)
                  Then: /review-impl I[N] (re-review — verifies fixes, adds any new findings)
Repeat until the ledger reads Passed.
```
