Complete and ship a feature or non-feature issue. Input ($ARGUMENTS) is a feature ID (F1) or GitHub issue number (42).

## Setup

Determine the type from $ARGUMENTS:

**Feature ID (F[N]):** Look up the GitHub issue number from the PLAN.md row for this feature. This is a feature completion — PLAN.md will need updating.

**GitHub issue number:** Treat as a non-feature issue (bug, cleanup, task, etc.). No PLAN.md row to update.

Fetch the issue for context:
```bash
gh issue view [N] --json number,title,body,labels 2>/dev/null
```

---

## Step 1 — Verify Tests

Run the suite, skipping the re-run if the saved results are still fresh (nothing changed since tests last passed):

```bash
./check-tests --show-known --if-stale
```

`--if-stale` skips the run and reports the saved result when `.last-test-output.txt` is newer than any uncommitted source change — typical when `/review-impl` or the implementor already ran tests on the current tree. The suite runs in full when anything has changed since the last run.

If unexpected failures are found: stop and report them. Do not proceed until the baseline is clean. If failures are pre-existing and known, note them and continue.

---

## Step 2 — Commit

**For features (F[N]): check the progress file first.**

Read `plans/F[N]-progress.md`:
- If it does **not exist**: warn the user — it should always be created by the implementor (per AGENT.md). Do not proceed until this is resolved.
- If Status ≠ `Complete`: this is a **blocking** issue — the implementor has not finished. Stop and report.
- If Issues is non-empty: flag each item before proceeding — these may represent deviations or unresolved problems that affect the commit.

The progress file must be included in the commit (it is a permanent record of what was built).

Check what is staged and unstaged:
```bash
git status
git diff --staged
git diff
```

If there are no uncommitted changes (already committed): skip to Step 3.

Otherwise, review all changes and draft a commit message:
- Use `feat:` for features, `fix:` for bugs, `chore:` for cleanup/tasks
- Reference issues with plain `#[N]` (e.g. `refs #59, #60, #65`) for traceability — do **not** use `closes #N` in commit messages; GitHub's auto-close via commit keyword is unreliable for multiple issues and issues are closed explicitly in Step 3
- Summarize *what* was implemented, not just "closes issue"
- Subject line under 72 characters; use a body for meaningful detail

Present the suggested commit message and the specific files to stage (always include `plans/F[N]-progress.md` for features). Wait for user confirmation before running:
```bash
git add [specific files — never git add -A]
git commit -m "..."
```

---

## Step 3 — Close Issues and Update Tracking

**If this is a feature (F[N]):**

Read the spec file (`specs/F[N]-*.md`) and extract the `Closes:` field from the tracking metadata comment. This lists every issue to close (the tracking issue + any batched sub-issues). Close each one individually — do not rely on commit message keywords:

```bash
gh issue close [N] --comment "Implemented and reviewed."
# repeat for every issue number in the Closes: list
```

If the spec predates this `Closes:` field (older specs may lack it), check the spec body for a batched-issues table and close those manually as well.

Update the feature's Status in PLAN.md from `In Review` to `Done`.

Append a Shipped entry to `plans/F[N]-log.md`:
```markdown
## [DATE] — Shipped
- **Commit:** `[commit message subject]`
- **Closed:** #[N], #[M], ... (all issues from the Closes: field)
```

**If this is a non-feature issue:**
Close the single issue:
```bash
gh issue close [N] --comment "Implemented and reviewed."
```
No PLAN.md update needed.

---

## Step 3.5 — Apply Doc Updates

Architectural docs are updated here — never deferred to a new issue. The review ledger captured
what to write; this step executes it.

**Read the review ledger** (`plans/F[N]-review.md`) and find the `## Doc Updates` section:

- **Section present with entries:** Apply each update directly. Read the target file, make the
  targeted edit, and commit:
  ```bash
  git add [doc files changed]
  git commit -m "docs: update [docs] for F[N] [feature name]"
  ```
  Set the ledger header `Doc Updates: Done`.

- **Section says "None":** No architectural docs need updating. Note this and skip the commit.

- **Section missing** (ledger predates this format, or reviewer omitted it): Do a targeted
  design-review scan — read the spec's `### Doc Updates` section for pointers, then check whether
  each referenced doc is current against what was actually built. Apply any gaps found now.
  **Do not create a GitHub issue for doc gaps.** If a doc needs updating, update it. If the scope
  is genuinely too large for this session, note it in a comment in the ledger (not an issue) and
  flag it to the user.

**Hard rule:** No `gh issue create` for doc gaps. Apply now or block shipping.

---

## Step 4 — Triage BACKLOG.md

**Sequencing note:** Triage is a content decision (fix now / promote / discard) — it does not depend
on Step 2's commit having happened. If Step 2 hasn't been committed yet, it's fine to do this triage
first and fold the result into one commit (feature + `BACKLOG.md` + any fix-now changes) instead of
two. The two-commit shape below is the default when Step 2 is already committed by the time you reach
this step; use your judgment, the goal is just that nothing is left untriaged when `/complete` finishes.

Read BACKLOG.md and list all open (unchecked `[ ]`) items.

If there are no open items: note this and skip to Step 5.

**Scope:** Only triage items related to the feature or issue being completed (identified by their `found in F[N] review`, `deferred from F[N]`, or similar tag). Leave items from other features/issues untouched — they'll be triaged when their own feature completes. Exception: if completing this feature makes an unrelated item obsolete, discard it now with a note.

For each in-scope item, propose one of three actions with a brief reason:

- **Fix now** — 1–5 line change, low risk, clearly scoped. Apply in this session.
- **Promote to GitHub Issue** — non-trivial, needs its own work session, or useful to track. Pick a label: `bug`, `enhancement`, `cleanup`, `test-quality`, or `docs`.
- **Discard** — no longer relevant given recent changes.

Present the full triage plan to the user before taking any action. Once confirmed:

1. Apply any "fix now" items, then commit them together:
   ```bash
   git add [specific files]
   git commit -m "chore: [description] (backlog triage after [ID])"
   ```

2. Create GitHub issues for promoted items:
   ```bash
   gh issue create --title "..." --label "..." --body "..."
   ```

3. Update BACKLOG.md: remove triaged items (leave items from other features). If the backlog is now empty, replace the item list with:
   ```
   _(empty — all items triaged to GitHub Issues)_
   ```
   Commit the BACKLOG.md update (combine with fix-now commit if there is one, otherwise standalone):
   ```bash
   git add BACKLOG.md
   git commit -m "chore: triage backlog after [ID]"
   ```

**IDEAS.md scan:** After backlog triage, read IDEAS.md. If any shelved ideas are relevant to the feature just shipped (e.g., the feature enables or supersedes an idea), present them to the user:
- **Promote** → move to BACKLOG.md or create a GitHub issue
- **Keep** → leave in IDEAS.md
- **Discard** → remove (feature made it obsolete)

If no ideas are relevant, note "no relevant ideas" and continue. Include any IDEAS.md changes in the backlog triage commit.

---

## Step 4a — Full Backlog Sweep Check (cross-feature)

Step 4's scope is deliberately narrow — only items tagged to the feature just shipped. That means
items from *other* features never get triaged unless something else sweeps them. This step is
that something else.

Count open items:
```bash
grep -c '^\s*- \[ \]' BACKLOG.md
```

If the count is **20 or fewer**, skip this step — no action needed.

If **over 20**, tell the user the current count and ask whether to run a full cross-feature sweep
now or defer it. If deferring, note it and move on — do not nag on every future `/complete` once
declined for this session.

If running the sweep, apply the same fix-now / promote / discard framework as Step 4, but drop the
feature-tag scoping restriction — every open item is in play. Work through the backlog in batches
(roughly 10–15 items per batch) rather than presenting all of them at once: propose actions for one
batch, get confirmation, apply it, then move to the next batch. This keeps each review pass
reviewable instead of dumping the whole file on the user in one shot.

Commit each batch's BACKLOG.md/issue changes as they're confirmed, same commit shape as Step 4
(`chore: full backlog sweep (batch N, triage after [ID])`). It's fine for the sweep to span the
rest of this session or be picked up again later — partial progress is still progress, unlike the
scoped Step 4 triage which is expected to fully clear in one pass.

---

## Step 4.5 — SESSION_NOTES Archive Check

Check whether SESSION_NOTES.md has grown large enough to archive:

```bash
wc -l SESSION_NOTES.md
```

If under 150 lines: skip this step.

If over 150 lines: move entries older than 90 days to a quarterly archive file. Determine the target quarter from the entry dates (Q1=Jan–Mar, Q2=Apr–Jun, Q3=Jul–Sep, Q4=Oct–Dec):

```bash
# Archive destination — use the quarter of the oldest entries being moved
# e.g., docs/session-archive/2026-Q1.md
```

Create `docs/session-archive/` if it doesn't exist. Create the quarterly file if it doesn't exist (start it with a `# Session Archive — YYYY-QN` header). Move the older entries by cutting them from SESSION_NOTES.md and appending to the archive file. Keep the SESSION_NOTES.md header block (format/protocol description) intact.

Archive files are permanent — never delete them. They are the full history of session context for that period.

Commit SESSION_NOTES.md and the archive file together:
```bash
git add SESSION_NOTES.md docs/session-archive/
git commit -m "chore: archive SESSION_NOTES entries older than 90 days"
```

---

## Step 5 — Push

Check whether there are unpushed commits:
```bash
git log --oneline origin/main..HEAD
```

Report how many commits are unpushed. Pushing is not a gate — for solo development, all work is local and pushing is just a remote sync. Note the status and offer to push, but do not block completion on it.

If the user wants to push:
```bash
git push
```

---

## Done

Report a summary:
- **Shipped:** [ID] — [issue title] (closes #[N])
- **Backlog:** [empty / N items promoted to issues / N items fixed now]
- **New issues created:** list with numbers and titles (if any)
- **Unpushed:** N commits ahead of origin/main (if any)
