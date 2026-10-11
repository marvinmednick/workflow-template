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

## 2026-10-10 — Phase 2 detail written (/spec F2.2)
- **Spec:** `specs/F2-project-rules-split.md` Phase 2 section (marker now `detail: written`)
- **Changes to the picture:** gemini and aider prompts do not tell the tool to read files (configs load them), so only the codex and claude `CONTEXT_PREFIX` strings change; `commands/implement.md` Step 0 also refuses on a missing file; `complete.md`/`review.md` "per AGENTS.md" lines checked, unchanged.

## 2026-10-10 — Phase 1 closed
- **Commit:** 77da107 `F2.1: skeleton and docs, split project-owned rules into PROJECT_AGENTS.md (#2)` (spec/PLAN edits in 362f568)
- **Tests:** 11/11 passed; GATE_CMD, verify-links and check-spec-tests (7/7) clean
- **Review:** plans/F2.1-review.md Passed in round 2 (5 findings, all verified)
- **Manual verification:** none required (no screens)
- **Next phase:** Phase 3 note added (v33 skeleton is `git show 65f1fd1:skeleton/AGENTS-template.md`); Phase 2 detail already written. Run `./implement F2.2 --plan`.

## 2026-10-10 — Phase 2 (F2.2) review round 1 (Needs Fixes)
- **Result:** Needs Fixes — 2 blocking, 1 non-blocking still open
- **This round:** new 3, verified 0, reopened 0
- **Next:** run `./implement F2.2` to address open findings, then `/review-impl F2.2` again
- **Ledger:** plans/F2.2-review.md

## 2026-10-10 — Phase 2 (F2.2) review round 2 (Passed)
- **Result:** Passed — all blocking resolved; non-blocking verified
- **Tests:** 38/38 passed
- **Ledger:** plans/F2.2-review.md
