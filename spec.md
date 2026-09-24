Produce a structured implementation spec for the following feature: $ARGUMENTS

Read the relevant sections of DESIGN.md, docs/design/ui-guidelines.md (if present), and any applicable docs/design/ files before writing the spec.

---

## Phased features

Use phases when the feature has three or more steps that can each be checked on their own, or whose
later steps depend on how earlier ones turn out (see "Phased Features" in WORKFLOW.md). Write **one**
spec file:

- Header: `**Review Level:** Full` and `**Phases:** N`.
- Shared sections first: Context, conventions, reference assets, Deferred Items, Doc Updates, What the
  Implementor Should NOT Change.
- Then one `## Phase N — Title` section per phase. Each contains: `### Goal`, `### Entry criteria`
  (which earlier phases must be closed and what must be true), `### Acceptance Criteria` (the exit
  criteria), and, once detailed: `### Files to Modify`, `### New Files`, `### Database / Schema
  Changes`, `### Tests to Write`, `### Manual verification (user)`, `### Gate`.
- **Phase 1 is fully detailed. Later phases carry only Goal, Entry criteria, Acceptance Criteria and
  any parity rows, and the marker `<!-- detail: pending -->` right under the heading.** Detail written
  now for code that does not exist yet goes stale.

**Detail mode — `/spec F[N].[P]`.** Used at the start of phase P (P > 1) after phase P-1 is closed.
Read the design doc, the whole spec, `plans/F[N]-log.md`, the closed phases' ledgers and progress files,
and the code as built. Edit **only** the `## Phase P` section: fill in the detail tier, replace the
marker with `<!-- detail: written [DATE] -->`, and correct its Goal and Acceptance Criteria if the
earlier phases changed the picture. If earlier phases changed anything the shared sections or later
phases rely on, list the changes to make and make them with the user's agreement. Then suggest
`./implement F[N].[P] --plan`.

---

## Step 0: Design Doc Check

Before assigning an F-number or writing anything, check for an existing design doc.

**Identify the feature and F-number (if already assigned):**
- If $ARGUMENTS is an F-number (e.g. `F9`): look up the feature in PLAN.md
- If $ARGUMENTS is a name: search PLAN.md for a matching row; note its F-number and design doc link if present

**Check for a design doc:**
```bash
ls docs/design/F[N]-*.md 2>/dev/null     # F-number known
# or check the design doc link in PLAN.md
```

### If a design doc is found

1. Read it fully
2. **Consistency check** — scan the codebase for key items the design doc references about *existing* code (file paths, function names, hook names, schema elements, patterns). A quick grep per key item is sufficient; this is not a deep investigation.
3. If anything looks stale (referenced item renamed, removed, or structurally changed):
   - Present the drift to the user
   - Ask how to proceed:
     - **Option A:** Stop — run `/design F[N]` first to update the design doc, then re-run `/spec`
     - **Option B:** Proceed — note the discrepancies in the spec as caveats and continue
4. If consistent (or user chose Option B): proceed to Step 1 with the design doc informing every decision in the spec

### If no design doc is found

Proceed to Step 1. Treat any design choices that arise as calls for user interaction (see **Mid-Spec Interaction** below).

---

## Step 1: Assign a Feature ID

> **The F-number always equals the GitHub issue number.** Never derive it from local file counts.

**Case A — Feature already has a GitHub issue** (PLAN.md row has an issue URL, or the feature came through `/feature`):
- Extract the issue number from PLAN.md's issue link (e.g. `[#28](url)` → `28`).
- **Verify alignment before doing anything else.** The F-number in the PLAN.md row must equal the
  issue number just extracted. If they already match, proceed normally. If they don't match — this
  is drift, e.g. from a pre-v8 `/spec` run that assigned F[N] from a local file count before the
  issue existed (the F23/#28 case) — correct it now rather than propagating it further:
  1. Report the mismatch to the user: "PLAN.md shows F[N] but the linked issue is #[M] — these must
     match. Renaming F[N] → F[M] across all artifacts." Wait for confirmation before proceeding —
     this touches multiple files.
  2. Rename every existing artifact from `F[N]` to `F[M]` using `git mv` (preserves history; never
     plain `mv`):
     - `specs/F[N]-*.md` → `specs/F[M]-*.md` (if it exists)
     - `docs/design/F[N]-*.md` → `docs/design/F[M]-*.md` (if it exists)
     - `plans/F[N]-*.md` — log, progress, review, plan, plan-approved, any that exist → `plans/F[M]-*.md`
  3. Update internal references inside each renamed file: header comments (`<!-- ID: F[N] | ... -->`),
     titles (`# Spec: ...`, `# Design: ...`, `# F[N] Feature Log`), and any other `F[N]` mentions in
     the body.
  4. Update the PLAN.md row's F-number from `F[N]` to `F[M]`.
  5. Update the GitHub issue title if it doesn't already read `F[M]: ...`:
     `gh issue edit [M] --title "F[M]: [feature name]"`.
  6. Use `F[M]` (the corrected, issue-aligned number) for the rest of this `/spec` run.
- Do not create a new issue — the existing issue will be *updated* after the spec is written (see "Create a GitHub Issue" below)
- Proceed to Step 2

**Case B — No GitHub issue exists yet** (PLAN.md shows `—` for issue, feature not in PLAN.md, or going straight to `/spec` without `/feature`):
- Before writing the spec, gather what you need: feature name, type label (`feature`/`enhancement`), effort label
- Create the issue first using the shared script — F-number is unknown until GitHub assigns it:
  ```bash
  N=$(./create-feature-issue.sh --title "[feature name]" --type [feature|enhancement] --effort [small|medium|large] --body "[brief summary — spec will be linked after it's written]")
  ```
- F-number = N (GitHub-assigned). Write the spec using F$N.

## Step 2: Determine the Slug

Derive a short kebab-case slug from the feature name (e.g. `list-interactions`, `duplicate-detection`).

---

## Mid-Spec Interaction

### Functional / data choices
**Stop and ask the user** when a design choice arises that cannot be resolved from DESIGN.md, CODING.md, or the design doc. This includes:
- Multiple valid approaches with meaningfully different trade-offs
- UX decisions not addressed by existing docs (how does the user interact with this edge case?)
- Scope ambiguity (is X in V1 or deferred?)
- Anything where a reasonable implementor could go two different ways

**Do not stop** for routine choices fully determined by existing patterns — apply CODING.md conventions directly without asking.

### UI choices
Check each UI element against `docs/design/ui-guidelines.md` (if present):

| Tier | What it means | Action in spec |
|------|---------------|----------------|
| **Established** | Pattern is documented in ui-guidelines.md | Apply it; cite the section in a spec comment |
| **Extension** | Similar to established but with a new variation | Note it and ask user: "Plan to use X pattern here — does that fit?" |
| **Novel** | No precedent in the app | Stop and discuss with user before writing the UI section; record decision before continuing |

**Never let the implementor invent novel UI.** If the spec reaches a UI element that is novel and hasn't been resolved through a design doc or inline discussion, stop and get a decision rather than leaving it vague.

**If significant choices accumulate during spec writing** (more than one or two non-trivial decisions made inline): offer to write or update `docs/design/F[N]-[slug].md` with those decisions before finalizing the spec, and propagate novel UI decisions to `docs/design/ui-guidelines.md`.

---

## Determine Review Level

**Full** when any of the following apply:
- 3 or more files being modified
- Any new files being created
- Any database/schema changes
- Any new patterns being introduced to the codebase

**Light** when all of the following are true:
- 1–2 files modified
- No new files
- No schema changes
- Applying existing patterns only (no new patterns)

## Write the spec to `specs/F[N]-[slug].md`:

Begin the file with:
```
# Spec: [Feature Name]
<!-- Tracking metadata — implementors skip: ID: F[N] | GitHub: #[N] (to be created) | Status: Specced | Closes: #[N], #[M] -->
**Review Level:** Full | Light

> Generated by Claude. Implement per `AGENT.md` and `CODING.md` conventions. Run all tests before reporting back.
```

The tracking comment keeps ID, GitHub issue, and Status out of the implementor's active context.
`**Review Level:**` stays visible because implementors act on it (Full triggers plan mode).

**`Closes:` field** — list every GitHub issue number that should be closed when this feature ships (the tracking issue + any batched sub-issues). If there is only one issue (the tracking issue itself), write `Closes: #[N]`. This field is read by `/complete` to close all issues explicitly via `gh issue close` — do not omit it.

## Create or Update the GitHub Issue:

**Case A — Issue already existed (from `/feature` or prior):**
Update the existing issue with spec details and add the `specced` label:
```bash
gh issue edit [N] --add-label "specced" \
  --body "[Summary paragraph]\n\n## Spec\n[specs/F[N]-[slug].md](specs/F[N]-[slug].md)\n\n## Acceptance Criteria\n[bullet list from spec]"
```
Update the tracking comment: replace `GitHub: #[N] (to be created)` with `GitHub: #[N]`.

**Case B — Issue was created in Step 1:**
The issue already exists. Update its body now that the spec is written:
```bash
gh issue edit [N] --add-label "specced" \
  --body "[Summary paragraph]\n\n## Spec\n[specs/F[N]-[slug].md](specs/F[N]-[slug].md)\n\n## Acceptance Criteria\n[bullet list from spec]"
```
Update the tracking comment: replace `GitHub: #[N] (to be created)` with `GitHub: #[N]`.

## Update PLAN.md:

Add or update a row in the Active Features table in PLAN.md:
```
| F[N] | [Feature Name] | Specced | [specs/F[N]-[slug].md](specs/F[N]-[slug].md) | [#N](url) |
```

If a row for this feature already exists (e.g. at `Backlog` or `Designed` status), update it in place rather than adding a new row.

## Create feature log (`plans/F[N]-log.md`):

Create a new file to track this feature's phase history. This file is Claude-authored and distinct from the implementor's `plans/F[N]-progress.md`.

```markdown
# F[N] Feature Log

## [DATE] — Specced
- **Spec:** `specs/F[N]-[slug].md`
- **GitHub Issue:** #[N]
- **Review Level:** [Full | Light]
- **Scope:** [1–2 sentence summary of what this feature does]
- **Closes on ship:** #[N] [, #[M] ...] — list all issues from the tracking metadata `Closes:` field
```

## The spec must include all of the following sections (omit any that genuinely don't apply, but err toward inclusion):

## Feature: [name]

### Context
Brief explanation of what this feature does and which user scenario it addresses. Reference USER_SCENARIOS.md or DESIGN.md if relevant. If a design doc exists, note it here: "Design decisions recorded in `docs/design/F[N]-[slug].md`."

### Files to Modify
List each file and what changes are needed (add a function, modify a query, add UI state, etc.). Be specific about which existing functions/hooks are touched.

### New Files (if any)
Name, location, and purpose of any new files.

### Database / Schema Changes
Any new columns, tables, or indexes required. If none, state "None."
Note: The implementor should not implement schema changes without a migration file being specified.

### Project-Specific Mandatory Sections
Read CODING.md for any mandatory spec sections required by this project (e.g. data access patterns, state management, scoping requirements, realtime tracking). Include a section for each item listed under "Mandatory Spec Sections" in CODING.md. Omit this heading if CODING.md specifies none.

### Platform Considerations
Note any platform-specific patterns required (e.g. web vs. native guards). Check CODING.md for platform compatibility requirements.

### Acceptance Criteria
Bullet list of observable behaviors that confirm the feature is working correctly.

### Tests to Write
List the specific test cases the implementor must implement. For each test, specify:
- The file to create or add to
- The test description (the `it('...')` string)
- What to assert

Always include tests for:
- Each item in Acceptance Criteria that can be verified programmatically
- Any mandatory test cases listed under "Mandatory Test Cases" in CODING.md

Example format:
```
File: [path/to/__tests__/FeatureName-test.ext]
- it('renders X when Y') → assert element is present
- it('calls pushAction with label "Added X" after adding') → mock pushAction, trigger action, assert call
```

### Deferred Items
List anything intentionally left out of this spec that was **discussed and explicitly descoped** during the design or spec conversation.

In the spec file, write this section as a plain bullet list — do NOT include "Append to BACKLOG.md" instructions; the implementor should not touch BACKLOG.md.

After writing the spec file, Claude appends each item to BACKLOG.md under "Deferred from Specs":
```
- [ ] [Description] — [reason]. (deferred from F[N])
```
This is a Claude action at spec-write time, already done before the implementor sees the spec.

### Doc Updates

List each architectural doc that will need updating when this feature ships, and what will need to change at a high level. The implementor does **not** touch these — they are applied by Claude at `/complete` time from the review ledger.

```
- `architecture/some-doc.md`: [what section needs adding or updating]
- `DESIGN.md` §[Section]: [what to update]
```

**If the project uses architecture forks** (see `architecture/01-documentation-conventions.md`, present only in projects with an `architecture/` directory): name the **fork**, not its base, wherever one is open. Check for a `<name>_<ID>.md` beside any `<name>.md` you are about to list. An update written against the base while a fork is open edits shipped truth and is lost when the fork merges. Where this feature is itself the open work, the fork it will create is the doc to name.

If no architectural docs need updating: "None." (`CODING.md` updates go in "Files to Modify" and are handled by the implementor.)

### Suggestions (AI-generated)
If Claude identified enhancement ideas during spec writing that were **not discussed with the user**, list them separately under this heading. These are Claude's own suggestions, not agreed-upon deferred work.

Present each suggestion to the user with a one-line description and ask for triage:
- **Backlog** → add to BACKLOG.md (becomes a tracked item)
- **Ideas** → add to IDEAS.md (shelved for future review)
- **Discard** → drop it

Do NOT add suggestions to BACKLOG.md without user approval. Do NOT reference "V2" or imply a roadmap that hasn't been discussed.

### What the Implementor Should NOT Change
List any files or patterns that are out of scope for this implementation. Always include:
- Architectural docs listed in `### Doc Updates` above — those are applied by Claude at `/complete` time

## Design Review

After writing the spec, check whether any design decisions were made while writing it:

- Did the spec require a new pattern, a change to an existing approach, or a departure from established conventions?
- If yes: run `/design-review spec` before finishing. If the spec applied existing patterns without modification, skip.

Common triggers: novel UI element resolved inline, new data access pattern, new state management pattern, new component structure not in ui-guidelines.md.

---

## Implementation Commands

**If Review Level is Full:**
```bash
# Step 1: Write the plan
./implement F[N] --plan
./implement F[N] --tool aider --plan --model <model-flag>

# Step 2: Review and approve the plan in Claude Code
# /review-plan F[N]

# Step 3: Implement (auto-detects plans/F[N]-plan-approved.md)
./implement F[N]
./implement F[N] --tool aider --model <model-flag>
```

**If Review Level is Light:**
```bash
./implement F[N]
./implement F[N] --tool aider --model <model-flag>
```

**Manual aider** (if you need to override the file list):
```bash
aider --model <model-flag> \
  --read specs/F[N]-[slug].md \
  [each file from "Files to Modify", "New Files", and "Tests to Write" — one per line]
```

**Copy-paste (web UI only):** Paste `AGENT.md`, `CODING.md`, `specs/F[N]-[slug].md`, then the source files.
