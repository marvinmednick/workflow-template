---
name: resolve
description: "Resolve a non-feature GitHub issue: fix a bug or cleanup by following the repository workflow, implementing the scoped fix, testing it, and recording the result on the issue."
---

# resolve

Before taking any action, read `commands/resolve.md` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to `$ARGUMENTS`, use the arguments the user supplied with this skill.
The `$ARGUMENTS` value is a GitHub issue number (e.g. 42), or a plain-text description of the problem (a new issue is created first).

If `commands/resolve.md` is missing, run `./verify-links` and tell the user.
