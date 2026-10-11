Begin a new **revision** of an already-implemented feature. Input ($ARGUMENTS) is a feature ID (e.g. `F88`).

Use this when a feature is **correct and shipping** but needs to evolve — a post-implementation respec.
It archives the current revision's process artifacts, scaffolds a new revision section in the spec, and
re-arms the plan→approve→implement→review cycle for the delta. The feature **keeps its ID and GitHub
issue** — a revision is a property of the feature, not a new feature.

> **Revise vs. supersede — pick the right one.**
> - **Revise** (this command): the existing implementation is right and you're extending/adjusting it.
>   Same ID, same issue, spec evolves in place with dated Revision sections, process files archived
>   per revision.
> - **Supersede**: the existing implementation went the *wrong direction* and should be thrown away.
>   That is a **new feature ID** (the old one is marked `Superseded`), the old code is removed, and its
>   commits are kept reachable with an archive git tag. Do **not** use `/revise` for a throwaway.

---

## Step 1 — Setup and guards

Read the spec (`specs/$ARGUMENTS-*.md`) and the feature's `PLAN.md` row.

**Guards — stop and report if any fail:**
- The feature must have a spec and be **past its first implementation** — i.e. PLAN.md Status is `Done`,
  `In Review`, or already `Revising`. If the feature is still `Specced` / `In Progress` (never
  implemented), there is nothing shipped to revise: just edit the spec directly and continue the normal
  cycle — do not run `/revise`.
- If a prior `/review-impl` round did not reach **Passed**, note it: you are revising on top of
  unverified work. Confirm with the user before proceeding.

Determine the **current revision number R** from the spec header `**Revision:** N` (absent ⇒ R = 1).
The new revision is **R+1**.

---

## Step 2 — Checkpoint the tree (make "prior work" a real ref)

A revision's whole premise is that the previous work is a coherent, committed baseline the next
implementer builds on. Verify this:

```bash
git status --short
```

- If the feature's files are **all committed**: record the current HEAD as the prior-work ref.
- If there are **uncommitted feature changes**: present them and commit a checkpoint first (never
  `git add -A` — stage specific files). This becomes the "Revision R shipped at `<ref>`" anchor.
- Unrelated dirty files in the repo are fine — leave them; only the feature's own files must be coherent.

Optionally create a hard history anchor at the pre-revision state:
```bash
git tag ${ARGUMENTS,,}-r${R}-shipped   # e.g. f88-r1-shipped  (lightweight, additive, reversible)
```

---

## Step 3 — Archive the current revision's process artifacts

Move the round-scoped process files aside with `git mv` (preserves history). The **feature log**
(`plans/$ARGUMENTS-log.md`) is **not** archived — it is the continuous chronicle across revisions.

```bash
for f in plan plan-approved progress review; do
  [ -f "plans/$ARGUMENTS-$f.md" ] && git mv "plans/$ARGUMENTS-$f.md" "plans/$ARGUMENTS-r$R-$f.md"
done
```

Archive only what exists (a non-Full feature may have had no approved plan; a feature may predate the
review ledger). Before moving `plans/$ARGUMENTS-review.md`, **read it** — carry any `Open`, `Deferred`,
or still-relevant `Wontfix` findings forward into the Step 4 prior-work note (don't leave them buried in
the archive).

**Why archive rather than append:** removing `plans/$ARGUMENTS-plan-approved.md` re-arms the existing
Full-level gate in `./implement` automatically — the next `./implement $ARGUMENTS` will correctly demand
a fresh `--plan`. No script change, and no ambiguity about what's already built. The archived files stay
as history; the active revision uses the canonical **unsuffixed** names.

---

## Step 4 — Evolve the spec

Edit `specs/$ARGUMENTS-*.md` **in place** (do not fork the spec file — the spec is the single evolving
narrative; only a near-total rewrite justifies archiving the old spec as `$ARGUMENTS-r$R-*.md`).

1. Update the header:
   - Tracking metadata comment: `Status: Revising`.
   - `**Revision:** R+1 — active work is the "<section title>" section at the end of this spec.`
     Note where Revision R shipped (`<ref>`) and that its artifacts are archived as
     `plans/$ARGUMENTS-r$R-*.md`.

2. Append a new section: `## Revision R+1 — <date>: <short title>`. It **must** open with a
   **"Prior work & context for the implementer"** block containing:
   - **What the previous revision shipped** and its commit ref — with the instruction that the
     *committed code is the source of truth* for what exists; this revision **extends** it.
   - **Do-not-touch** list (modules/tests unchanged by this revision).
   - **Pointers to the archived** `plans/$ARGUMENTS-r$R-*.md` files (history — not required reading).
   - **Carried-forward findings** from the archived review ledger (or "nothing carried").
   - **Known pending** items (e.g. Doc Updates not yet applied) that are expected and reconciled at
     `/complete`, not by this implementer.

3. Author the actual change spec (Files to Modify / New Files / Tests / Acceptance / What NOT to change)
   for the delta, same as `/spec`. If the change was already drafted in conversation, fold it in here.

The implementer's context is **spec + approved plan + the committed code** — not the archived logs — so
this prior-work note plus a delta-scoped plan is sufficient; do not teach the tooling to read archived
files.

---

## Step 5 — Update PLAN.md and log

- Set the feature's PLAN.md Status to `Revising (r{R+1})`.
- Append to `plans/$ARGUMENTS-log.md`:
  ```markdown
  ## [DATE] — Revision R+1 begun
  - Archived R{R} process artifacts → plans/$ARGUMENTS-r$R-*.md (R{R} shipped at `<ref>`, review <result>).
  - Spec header → Revision R+1; added prior-work/context note.
  - PLAN.md → Revising (r{R+1}). Archiving the approved plan re-arms the Full-level gate.
  - Next: ./implement $ARGUMENTS --plan → /review-plan $ARGUMENTS → ./implement $ARGUMENTS → /review-impl $ARGUMENTS → /complete $ARGUMENTS.
  ```

---

## Step 6 — Commit the revision-begin checkpoint

Stage the renames + spec + PLAN.md + log (specific files only) and commit, so the next implementer starts
from a coherent tree:

```bash
git add specs/$ARGUMENTS-*.md PLAN.md plans/$ARGUMENTS-log.md plans/$ARGUMENTS-r$R-*.md
git commit -m "$ARGUMENTS: begin revision R+1 (<short title>)"
```

Do not push (the user handles pushes); report the unpushed count.

---

## Done

Report:
- **Revised:** $ARGUMENTS → Revision R+1 — <title>
- **Archived:** `plans/$ARGUMENTS-r$R-*.md` (R{R} shipped at `<ref>`)
- **Gate re-armed:** `./implement $ARGUMENTS` now requires a fresh `--plan`.
- **Next:** `./implement $ARGUMENTS --plan` → `/review-plan $ARGUMENTS` → `./implement $ARGUMENTS` →
  `/review-impl $ARGUMENTS` (ledger restarts at round 1 for this revision) → `/complete $ARGUMENTS`.
