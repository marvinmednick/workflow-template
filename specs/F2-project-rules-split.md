# F2 (v34) — Move project-specific implementor rules out of the shared `AGENTS.md`

Issue: https://github.com/marvinmednick/workflow-template/issues/2

Status: **Draft — not agreed.** Items under "Open decisions" are proposals; confirm them before
implementing. Builds on v33 (the `AGENT.md` → `AGENTS.md` rename, commit `65f1fd1`).

## Problem

`AGENTS.md` (from `skeleton/AGENTS-template.md`) is meant to be the shared implementor rulebook, but each
project edits it: the "Project-Specific Architecture Boundaries" section is a fill-in placeholder, Coding
Rules carries a `PROJECT-SPECIFIC` marker, and Test Rules 1–3 are written for one stack (`it.skip`,
`jest.useFakeTimers`) so projects on another stack rewrite them (patent-analysis changed them to
`pytest.skip` / `uv run pytest`). Once edited, a project's `AGENTS.md` can no longer be replaced from the
skeleton, so every global rule change needs a manual merge (the "unclear" path in `/upgrade-workflow`).

`PROJECT_AGENT.md` already exists as a project-owned file (introduced v25), but it is optional, is described
as for rules that "come up mid-project", and is read only when `AGENTS.md` points at it.

## Goal

All project-owned implementor rules live in one project-owned file. `AGENTS.md` contains only shared text, so
it can be replaced wholesale from the skeleton on every template upgrade, with no per-project merge.

## Proposed design

### 1. File roles

| File | Owner | Contents | On upgrade |
|------|-------|----------|-----------|
| `AGENTS.md` | Template | Shared rules only | Replaced from skeleton (backup as `AGENTS.md.bak`) |
| `PROJECT_AGENT.md` (name: see Open decision 1) | Project | Architecture boundaries, stack-specific coding and test rules, anything else project-specific | Never overwritten |

`PROJECT_AGENT.md` becomes a normal, expected file, not optional. Its wording changes from "rules that come
up mid-project" to "all rules specific to this project".

### 2. Skeleton changes

- `skeleton/AGENTS-template.md`: remove the "Project-Specific Architecture Boundaries" section, the
  `PROJECT-SPECIFIC` comment block in Coding Rules, and any stack-specific Test Rules (see Open decision 2).
  Replace the "Project-Specific Rules" section with a required read: "Read `PROJECT_AGENT.md` in full before
  making changes. Where it conflicts with this file, it wins" (confirm precedence, Open decision 4).
- New `skeleton/PROJECT_AGENT-template.md` with: the boundaries section and placeholder, a "Coding rules for
  this stack" placeholder, a "Test rules for this stack" section (the test-framework specifics that were in
  the shared Test Rules), and a pointer to `skeleton/snippets/` for known add-ons.
- `skeleton/CLAUDE-template.md`, `skeleton/WORKFLOW-template.md`: drop "(optional, may not exist)" from the
  `PROJECT_AGENT.md` rows; `WORKFLOW-template.md`'s "Starting any implementation session" row drops "if
  present".
- `skeleton/snippets/README.md`, `legacy-parity.md`, `design.md` (lines ~172-174): wording that says to
  "create `PROJECT_AGENT.md` if it doesn't exist" becomes "append to".

### 3. Tool loading

Today Codex auto-loads only `AGENTS.md`; the aider and Gemini configs and the `./implement` prompts name only
`AGENTS.md` and `CODING.md`. A rule in `PROJECT_AGENT.md` must reach the implementor as reliably as one in
`AGENTS.md`:

- `configs/.aider.conf.yml`: add `PROJECT_AGENT.md` to `read:`.
- `configs/.gemini/settings.json`: add `PROJECT_AGENT.md` to `context.fileName`.
- `scripts/implement`: every prompt that says "read AGENTS.md and CODING.md in full" (codex, claude, and the
  plan-mode prompts for each tool, lines ~365-490) adds `PROJECT_AGENT.md`; the aider message that lists
  files read adds it too. The comments that say which files each tool auto-loads are updated.
- `implement.md`: same wording change where it says "Read AGENTS.md and CODING.md".
- `complete.md`, `review.md`: the "per AGENTS.md" references stay (they refer to shared behaviour), but check
  each: any that mean boundaries or test rules must also name the project file.
- Behaviour when `PROJECT_AGENT.md` is missing: `./implement` should stop with a clear message rather than
  proceed without the project's boundaries (decide in Open decision 5).

### 4. Setup

- `scripts/setup.sh` "next steps": add `cp $TEMPLATE/skeleton/PROJECT_AGENT-template.md PROJECT_AGENT.md`.
- `README.md`: add the file to the copy list and to the file table.
- `scripts/verify-repo`: add a check that `PROJECT_AGENT.md` exists (warn, not fail, until a project has
  migrated).

### 5. Migration for existing projects (`/upgrade-workflow` Step 1b, after Step 1a)

Project version below 34. The split needs judgment per project, so it proposes and the user approves.

1. If `PROJECT_AGENT.md` exists, read it. It is kept and appended to; never overwritten.
2. Diff the project's `AGENTS.md` against the **v33** `AGENTS-template.md`. Classify each section or rule:
   - identical to the skeleton → shared, nothing to move;
   - added by the project (the boundaries entries, extra Coding Rules, extra Test Rules) → project-specific;
   - an edit of a shared rule (reworded rule, language-specific substitution) → ask the user which wording
     is project-specific (typically the stack substitution) and which is just older template text.
3. Show the user the proposed `PROJECT_AGENT.md` content and the proposed `AGENTS.md` (the new skeleton).
   Apply only after approval.
4. Save the old `AGENTS.md` as `AGENTS.md.bak` (not committed), write `PROJECT_AGENT.md`, replace `AGENTS.md`
   with the skeleton, and update the project's own `CLAUDE.md`/`WORKFLOW.md` rows.
5. Because v33's skeleton is the diff baseline, projects that skipped earlier versions may have older shared
   text mixed in; flag those hunks for the user rather than moving them.

The same logic means that after v34, `/upgrade-workflow` for any later version treats `AGENTS.md` as
"replace from skeleton" with no customization check.

### 6. Changelog and version

`CHANGELOG.md` v34 entry (summary, what changed, what projects need to do) and `VERSION` = 34. v33's
changelog line "`PROJECT_AGENT.md` keeps its name" becomes history; v34 says whether it is renamed.

## Open decisions (agree before implementing)

1. **Name.** Keep `PROJECT_AGENT.md`, or rename to `PROJECT_AGENTS.md` to match `AGENTS.md`. Cheap now,
   costly later. A rename adds a rename step to the migration (checked 2026-10-06: no `PROJECT_AGENT.md` exists in
   any project under `~/Development/*/` or one level below, so the rename costs no migration).
2. **Which Test Rules are shared.** Proposal: Rules 4–7 (every test can fail, write every named test, no
   stand-in data, run the gate) are framework-neutral and stay shared. Rules 1–3 (`it.skip`, hardcoded
   sleeps, fake-timer cleanup) are shown in JS terms; keep the neutral intent ("no skipped tests, no
   sleeps") shared and move the framework specifics to the project file. Check the other sections
   (Coding Rules, "Tests Before Reporting") for the same mixing.
3. **Migration mechanism.** Interactive classification as in section 5, or a simpler rule: move only the
   named project sections (boundaries, extra rules, extra tests) and leave reworded shared text for manual
   review.
4. **Precedence on conflict.** Proposal: `PROJECT_AGENT.md` wins over `AGENTS.md` for project specifics
   (a project may tighten, e.g. a smaller file limit than "3 files"), but must not weaken the shared safety
   rules (Review Ledger Protocol, "Checks Are Not Yours To Change"). Decide whether to state that.
5. **Missing-file behaviour** in `./implement`: hard stop vs warn.
6. **Scope of v34.** One version with skeleton, tool loading, setup and migration together, or split
   loading (safe, additive) from the migration.

## Verification

- `grep` the template for `PROJECT_AGENT.md` and `AGENTS.md` and confirm each remaining mention matches the
  new roles (sweep semantically, not only by token).
- `bash -n scripts/implement scripts/setup.sh`; Gemini config parses as JSON.
- Dry-run the migration on copies of patent-analysis's `AGENTS.md` (heavily customized; has boundaries and
  stack-adapted Test Rules) and one project with an untouched skeleton `AGENTS.md`; confirm the second
  needs no user decisions and the first produces a `PROJECT_AGENT.md` that retains the four boundaries and
  Test Rules 3-5 content.
- Run `./implement <F> --plan` in a migrated project with each tool that can run locally and confirm the
  prompt names both files.
- Confirm a project's `PROJECT_AGENT.md` is untouched by a later `/upgrade-workflow`.

## Not in scope

- Merging the older shared wording in patent-analysis's `AGENTS.md` up to the current skeleton (handled by the
  v34 migration as a side effect, otherwise separate).
- Changing `CODING.md` ownership; it stays project-owned.
