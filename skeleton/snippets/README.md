# Opt-in project-specific snippets

Each file here is a self-contained `AGENT.md`-style section that applies only to *some* projects — not
general enough to belong in `skeleton/AGENT-template.md`, which every project inherits regardless of
whether the section is relevant. `legacy-parity.md` is the first example: it only matters for a project
rebuilding an existing system's screens or functions against a running legacy instance, which most
projects never do.

**Mechanism**: when a project first needs a snippet (today: manually, when `/design` produces a Legacy
Parity Matrix for some feature — see `design.md`'s Legacy Parity section), copy the snippet's content
into that project's own `PROJECT_AGENT.md` (create the file if it doesn't exist). `AGENT.md`'s
"Project-Specific Rules" section already tells the implementor to read `PROJECT_AGENT.md` when present,
so nothing else needs wiring up for the content to take effect once it's copied in.

Future improvements to a snippet's wording (the way `legacy-parity.md`'s content evolved across
v19/v21/v22/v23 while it still lived in `AGENT-template.md`) land here, and a project that already
copied an earlier version merges the diff in manually — the same as any other skeleton file change
tracked in `CHANGELOG.md`.

**Not yet automated**: `/design` does not yet detect "this feature just introduced a Legacy Parity
Matrix, and this project has no `PROJECT_AGENT.md` Legacy Parity section" and offer to wire it up. That
trigger is deliberately deferred — documenting the convention now, versus building the detection logic,
were treated as separable (see `CHANGELOG.md`'s entry for when `legacy-parity.md` was extracted).

## Adding a new snippet

Something in a project's own `PROJECT_AGENT.md` may turn out to be more broadly useful than that one
project — the same judgment call that put `legacy-parity.md` here. Before promoting it, place it on this
three-way split:

- **Universal** (every project needs it, or the cost of including it unconditionally is near zero) →
  belongs in `AGENT-template.md` directly, not here.
- **Known but not universal** (a real, recurring case — a comparison-harness workflow, a class of
  domain-specific safety rule — that most projects nonetheless won't hit) → belongs here, as a new
  snippet.
- **Genuinely one-off** (specific to this one project's domain or history) → stays in that project's own
  `PROJECT_AGENT.md`, never promoted.

To add one: write `skeleton/snippets/<name>.md` as a self-contained `##`-level section (so it can be
pasted straight into a `PROJECT_AGENT.md`), add a line for it below, and record the change in
`CHANGELOG.md` with a version bump — the same process as any other template change, no separate
mechanism. Say what triggered it (which project, which need) the way other CHANGELOG entries do.

**Available snippets:**
- `legacy-parity.md` — implementor rules for rebuilding an existing system's screens/functions against
  a running legacy instance. Added in v25 (moved out of the unconditional base template).
