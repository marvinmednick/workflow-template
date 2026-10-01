---
name: complete
description: "Complete and ship a feature or issue: verify review and tests, commit, close the GitHub issue, and update PLAN.md. Also closes a single phase of a phased feature."
---

# complete

Before taking any action, read `commands/complete.md` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to `$ARGUMENTS`, use the arguments the user supplied with this skill.
The `$ARGUMENTS` value is a feature ID (e.g. F1), a phase ID (e.g. F1.2), or a GitHub issue number (e.g. 42).

If `commands/complete.md` is missing, run `./verify-links` and tell the user.
