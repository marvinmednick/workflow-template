# CODING.md

Read this file before writing any code. It defines mandatory patterns, tech stack, and coding conventions for this project. All implementors (Gemini, Codex, aider) read this file at the start of every session.

---

## Tech Stack

- Markdown: the workflow commands (`commands/*.md`) are prompts, written for an LLM to follow
- Bash: all scripts in `scripts/` (`set -euo pipefail`)
- Python 3 + pytest: `tests/`, run through `uv run --with pytest`
- GitHub CLI (`gh`): issues, labels, PRs

---

## Directory Layout

- `commands/` — the workflow commands. Real files here; in a project they are symlinked
- `claude-stubs/` — one stub per skill. **The manifest**: filename = skill name, first line = description, the `commands/<x>.md` it names = the workflow
- `codex-skills/` — generated from the stubs by `scripts/gen-codex-skills.sh`. Never edit by hand
- `codex-skills.d/` — per-skill overrides for the generator
- `scripts/` — shell scripts, symlinked into each project root
- `configs/` — tool configs, symlinked into projects
- `skeleton/` — starting-point files, **copied** (not linked) into projects and customised there
- `specs/` — specs for changes to this template
- `plans/` — logs, progress and review ledgers for that work
- `architecture/` — documentation conventions and, over time, how the template works
- `tests/` — checks on the template itself

---

## Mandatory Coding Patterns

These patterns are checked during every `/review-impl`. Missing any of them is a blocking review failure.

### Single source of truth for the skill set

Adding, renaming or removing a command means changing `claude-stubs/`, then running `scripts/gen-codex-skills.sh` and committing the result. The command file, the stub and the generated skill must agree; `gen-codex-skills.sh --check` enforces it.

### Linked versus copied files

Anything in `commands/`, `scripts/`, `claude-stubs/`, `codex-skills/` and `configs/` reaches projects by symlink, so a change takes effect everywhere at once. Anything in `skeleton/` is copied and then drifts. A change to a linked file must be safe for every project already using it; a change to a skeleton file needs a CHANGELOG note saying how existing projects pick it up.

### Scripts that run in a project must not assume they are in the template

Scripts run from a project root and locate the template through symlink resolution. In the template's own checkout `commands/` holds real files, so anything that writes links must use `in_template_root` (in `scripts/workflow-lib.sh`) before replacing them.

### Releases

A change that existing projects must act on bumps `VERSION` and adds a CHANGELOG entry with the migration steps. `check-workflow` is what tells projects they are behind.

---

## Naming Conventions

- Commands: lowercase, hyphenated (`review-plan.md`)
- Scripts: lowercase, hyphenated, no extension for commands run directly (`check-tests`); `.sh` for ones that are sourced or run only from other scripts
- Project files that skeletons produce: UPPERCASE (`DESIGN.md`). Commands are lowercase, so the two never collide on a case-insensitive filesystem
- Specs: `specs/F<n>-<slug>.md`; issue-path work: `I<n>`

---

## Testing Conventions

- Tests live in `tests/` and run with `uv run --with pytest pytest tests`
- Test the scripts through their behaviour: run `setup.sh` in a `tmp_path` project and verify what it produced
- Never write to the real working tree from a test
- Never skip a test; report it as a blocker instead

---

## Mandatory Test Cases

- A change to the manifest (stubs, command files, `workflow-lib.sh`): `test_setup_creates_a_project_that_verifies` must cover it
- A new script: it must pass `bash -n` (covered by `test_scripts_parse`)

---

## Key Patterns

- Commands are instructions for an LLM. Write them as procedures with explicit stop conditions, and keep the "when this applies" test at the top.
- Reuse shared logic in `scripts/workflow-lib.sh` rather than repeating it in each script.

---

## Off-Limits Without a Spec Section

- Do not rename or move a command file without updating the manifest, the scripts that link it, and the CHANGELOG
- Do not change what `setup.sh` or `update-workflow` does to a project without a spec; they act on repos outside this one
- Do not edit `codex-skills/*` by hand
