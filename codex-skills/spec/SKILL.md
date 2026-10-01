---
name: spec
description: "Produce a structured implementation spec for a feature, reading DESIGN.md and the relevant design docs first, with phases where the feature warrants them."
---

# spec

Before taking any action, read `commands/spec.md` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to `$ARGUMENTS`, use the arguments the user supplied with this skill.
The `$ARGUMENTS` value is the feature to specify: a feature ID (e.g. F1) or a description.

If `commands/spec.md` is missing, run `./verify-links` and tell the user.
