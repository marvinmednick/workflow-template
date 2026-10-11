# F2 Feature Log

## 2026-10-10 — Specced
- **Spec:** `specs/F2-project-rules-split.md`
- **GitHub Issue:** #2
- **Review Level:** Full (3 phases)
- **Scope:** Make `PROJECT_AGENTS.md` (renamed from `PROJECT_AGENT.md`) the required project-owned rules file so `AGENTS.md` is shared-only and replaceable on upgrade; add tool loading, a hard stop, setup/verify-repo support and a v34 migration.
- **Closes on ship:** #2

## 2026-10-10 — Phase 1 (F2.1) review round 1 (Needs Fixes)
- **Result:** Needs Fixes — 1 blocking, 4 non-blocking still open
- **This round:** new 5, verified 0, reopened 0
- **Next:** run `./implement F2.1` to address open findings, then `/review-impl F2.1` again
- **Ledger:** plans/F2.1-review.md

## 2026-10-10 — Phase 1 (F2.1) review round 2 (Passed)
- **Result:** Passed — all blocking resolved; non-blocking verified
- **Tests:** 11/11 passed
- **Ledger:** plans/F2.1-review.md
