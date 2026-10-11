---
name: investigate
description: "Investigate a bug GitHub issue to find its root cause and scope, document the findings on the issue, and stop without applying a fix. Use when a bug is logged but its effort or cause is unknown."
---

# investigate

Before taking any action, read `commands/investigate.md` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to `$ARGUMENTS`, use the arguments the user supplied with this skill.
The `$ARGUMENTS` value is a GitHub issue number (e.g. 18).

If `commands/investigate.md` is missing, run `./verify-links` and tell the user.
