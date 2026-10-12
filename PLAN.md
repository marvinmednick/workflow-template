# PLAN.md

Feature and issue registry. Every tracked item has a row here.

The `F<N>` ID **always equals the GitHub issue number** (`F2` ⇔ `#2`). The label conveys *significance only*: `feature` = significant work, `enhancement` = minor work. Both share the same `/design` → `/spec` → `/review-impl` workflow and the same ID scheme.

**Status vocabulary**: `Backlog` → `Designing` → `Designed` → `Specced` → `In Progress` → `In Review` → `Done`. `Blocked` is orthogonal to that sequence.

## Active Features

| ID | Type | Name | Status | Design / Spec | Issue |
|----|------|------|--------|---------------|-------|
| F1 | feature | Architecture written during design; doc standards by kind; `/review-doc` | Backlog | — (proposal in issue comments) | [#1](https://github.com/marvinmednick/workflow-template/issues/1) |
| F2 | enhancement | Move project-specific implementor rules out of the shared `AGENTS.md` (v34) | Done | [specs/F2-project-rules-split.md](specs/F2-project-rules-split.md) | [#2](https://github.com/marvinmednick/workflow-template/issues/2) |
| F3 | enhancement | Non-feature issues get an explicit lighter workflow | Backlog | — | [#3](https://github.com/marvinmednick/workflow-template/issues/3) |
| F4 | enhancement | Standard locations for analysis, guides and tech debt | Backlog | — | [#4](https://github.com/marvinmednick/workflow-template/issues/4) |
| F7 | enhancement | Architecture documents stand alone: rule in the conventions and the Doc Updates instructions (v35) | In Review | — | [#7](https://github.com/marvinmednick/workflow-template/issues/7) |

## Order

F4 first (locations unblock where new docs go), then F2, F3, and F1 in phases. Not yet scheduled as releases.
