# PROJECT_AGENTS.md

Project-owned implementation rules for the workflow template repository.

## Architecture boundaries

- `commands/` holds real command files here; never replace them with links.
- Do not change `scripts/implement` or `scripts/setup.sh` in ways that cannot be tested from a second checkout.

## Coding rules for this stack

- Changes to `skeleton/`, `scripts/`, `configs/`, `claude-stubs/`, or `commands/*.md` require a `CHANGELOG.md` entry describing the summary, change, and project action, plus a `VERSION` bump.
- Anything projects must act on needs a matching step in `commands/upgrade-workflow.md`.
- When adding or removing a command, update `claude-stubs/`, run `scripts/gen-codex-skills.sh`, and ensure `./verify-links` and the tests pass.
- Do not edit generated symlinks (`.claude/`, `.agents/`, or root script links); edit their targets.
- Keep skeleton text project-neutral and stack-neutral.

## Test rules for this stack

- Test the shell scripts through their behavior without writing inside this repository.
- Run the full test command and the project gate before reporting completion.

## Add-ons

Reusable project rules live in `skeleton/snippets/`.
