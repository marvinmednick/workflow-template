---
name: review-plan
description: "Review a feature's implementation plan against its spec in an iterative session with the user, producing the approved plan file the implementor executes."
---

# review-plan

Before taking any action, read `commands/review-plan.md` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to `$ARGUMENTS`, use the arguments the user supplied with this skill.
The `$ARGUMENTS` value is a feature ID (e.g. F1) or a phase ID (e.g. F1.2).

If `commands/review-plan.md` is missing, run `./verify-links` and tell the user.
