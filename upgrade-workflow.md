Review and apply pending workflow-template updates for this project.

## Step 0 — Fix symlinks first

Before checking versions, ensure all workflow symlinks are intact. Run:

```bash
./verify-links
```

If any symlinks are reported as wrong (pointing to an old template path) or missing (new commands added since this project was set up), offer to fix them automatically — `verify-links` will prompt. Accept the fix.

If `verify-links` itself is a broken symlink and cannot run, tell the user:
```
verify-links is broken. Run this to fix it manually:
  ln -sf ~/Development/workflow_template/scripts/verify-links ./verify-links
Then re-run /upgrade-workflow.
```

Only proceed once `verify-links` reports all symlinks correct (the `.codex` entry is a known exception and can be ignored).

## Step 0b — Check repo health

Run:

```bash
./verify-repo
```

This checks GitHub authentication, required workflow labels, and project file structure. Fix any issues before continuing:

- **Missing labels** → run `~/Development/workflow_template/scripts/setup-github-labels.sh` (safe to re-run)
- **Missing directories** → `mkdir plans specs`
- **Missing files** → create empty `PLAN.md`, `BACKLOG.md`, or `IDEAS.md` as needed
- **`.workflow-version` missing** → will be set at the end of this upgrade process

If `verify-repo` is not yet symlinked (project predates v3), run it directly:
```bash
~/Development/workflow_template/scripts/verify-repo
```

Only proceed to Step 1 once both `verify-links` and `verify-repo` are clean (or issues are acknowledged).

---

## Step 1 — Check version state

```bash
./check-workflow
```

If `.workflow-version` does not exist, the project predates the versioning system. Ask the user:
```
No .workflow-version found. This project was initialized before workflow versioning was added.
What version should I record as the starting point?
  - v1 (the original template, before the implement command and pytest support)
  - v0 (treat everything as pending — show all CHANGELOG entries)
```

Write their answer to `.workflow-version` before continuing.

If the output says the project is current after that, stop — nothing to do.

Read `.workflow-version` and the template `VERSION` file to confirm the version gap. Then read every CHANGELOG.md entry for versions between the project version (exclusive) and the template version (inclusive). These entries are your migration checklist.

---

## Step 1 — Process each skeleton file change

For each item listed under "Skeleton file changes" in the relevant CHANGELOG entries, do the following:

### Read the current state of both files

1. Read the **project's current file** (e.g. `WORKFLOW.md`, `AGENT.md`, `.implement.conf`)
2. Read the **current skeleton template file** (e.g. `workflow_template/skeleton/WORKFLOW-template.md`)
3. Read the CHANGELOG description of what changed

### Assess: clear or unclear?

**Clear** — the change is safe to propose automatically when ALL of the following are true:
- The CHANGELOG describes an additive change (new section, new option, new paragraph)
- The project's file has not been customized in the exact area being changed
- You can identify precisely where to insert or what to change without ambiguity

**Unclear** — flag for manual review when ANY of the following apply:
- The project's file has significant customization in the area being changed
- The change is structural (not purely additive)
- The CHANGELOG is ambiguous about where exactly the change goes
- The project's file has diverged enough from the skeleton that a diff is hard to interpret

### For clear changes: propose and apply

Show the user exactly what you intend to change:
```
File: WORKFLOW.md
Change: Add "Implement: Two Options" section after the cheatsheet table
─────────────────────────────────────────────────────
+ ## Implement: Two Options
+
+ ### `/implement F[N]` (in-session Agent spawn — recommended)
+ [...]
─────────────────────────────────────────────────────
Accept this change? [y/N]
```

If accepted: apply the edit with the Edit tool.
If declined: note it as skipped and continue to the next item.

### For unclear changes: explain and ask

Tell the user specifically what's ambiguous:
```
File: AGENT.md
Change: CHANGELOG says "add project-specific boundaries section"
Issue: Your AGENT.md has already been customized with project-specific boundaries
       that differ from the skeleton. I cannot safely auto-apply without risk of
       overwriting your customizations.

Options:
  1. Show me both versions — I'll decide what to keep
  2. Skip this file — I'll update it manually later
  3. Replace with skeleton version — I'll re-apply my customizations afterward
```

Wait for the user's choice before proceeding.

---

## Step 2 — Handle new required project files

For each item listed under "New required project files" in the CHANGELOG:
- Check if the file already exists
- If not: create it with the appropriate initial content (usually just a version number or empty template)
- If yes: confirm it has the expected format and skip

---

## Step 3 — Update `.workflow-version`

After processing all items (whether applied, skipped, or manually handled):

Ask: "All items have been reviewed. Update `.workflow-version` from v[N] to v[M]? [y/N]"

If yes: write the new version number to `.workflow-version`.

Note: updating `.workflow-version` records that you have reviewed the migration, even if you chose to skip some changes. Skipped items should be tracked in BACKLOG.md if they need follow-up.

---

## Step 4 — Report

Summarize:
- Changes applied (with file names)
- Changes skipped (with reason)
- Items flagged for manual review
- Whether `.workflow-version` was updated

Suggest `git add` and commit the updated files.
