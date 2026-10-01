---
name: triage
description: "Triage bug GitHub issues: assess severity and estimated effort and label them, without investigating root causes or fixing. With no issue numbers, triages every open bug-labeled issue."
---

# triage

Before taking any action, read `commands/triage.md` (in the project root) from start to finish and
follow it exactly. It is the canonical workflow; do not duplicate or reinterpret its steps here.
Wherever it refers to `$ARGUMENTS`, use the arguments the user supplied with this skill.
The `$ARGUMENTS` value is one or more space-separated GitHub issue numbers (e.g. 18 or 18 19 20), or empty to triage all open bug issues.

If `commands/triage.md` is missing, run `./verify-links` and tell the user.
