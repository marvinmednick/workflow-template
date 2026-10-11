# Project Review Checklist

This file is read by `/review-impl` (and the built-in `/review`) to evaluate implementations
against project-specific patterns. Each item below is checked and reported as pass / fail / not-applicable.

---

**Manifest**
- Do the command file, its stub and its generated Codex skill agree? (`scripts/gen-codex-skills.sh --check` passes)
- Is every file a script or stub names present?

**Existing projects**
- Does the change keep working for a project whose links were made by an earlier version? If not, is there a `VERSION` bump and a CHANGELOG entry with the migration steps?
- Does a script that writes links guard against running in the template's own checkout (`in_template_root`)?
- Does a change to `skeleton/` say how projects already holding a copy pick it up?

**Scripts**
- `set -euo pipefail`, quoted expansions, and no destructive `ln -sf` or `rm` on a path that could be a real file
- Reads `$TEMPLATE` and resolves the project from the current directory, with no hardcoded paths

**Commands (prompt files)**
- Each one has a clear start condition, explicit stop conditions, and no step that depends on an artifact an earlier step has not yet created
- References to other commands, files and sections resolve

**Test Coverage**
- Does every item in the spec's Acceptance Criteria have a corresponding test?
- Do all tests pass? (verified by `./check-tests --show-known --if-stale` in review preamble; do not re-run here)
- Are there zero skipped tests?
- Is there a test that would fail if the change were reverted?
