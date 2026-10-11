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

## 2026-10-11 — Phase 2 closed
- **Commit:** 3bb1e31 `feat(F2.2): load PROJECT_AGENTS.md in every tool, hard-stop ./implement without it`
- **Tests:** 38/38 passed; GATE_CMD, verify-links and check-spec-tests (13/13) clean
- **Review:** plans/F2.2-review.md Passed in round 2 (3 findings, all verified)
- **Manual verification:** none required by the user; reviewer ran `./implement` and `./verify-repo` for real in a scratch copy without the file (stop message, warning, exit 0)
- **Hazard:** phase 2 is live in every linked project once merged; do not release without phase 3 (upgrade step, CHANGELOG, VERSION 34)
- **Next phase:** `/spec F2.3`, then `./implement F2.3 --plan`

## 2026-10-11 — Phase 3 detail written (/spec F2.3)
- **Spec:** Phase 3 section of `specs/F2-project-rules-split.md` (marker now `detail: written`)
- **Changes to the picture:** real projects show the migration meets appended sections inside shared sections and hand-written AGENTS.md files, so Step 1b flags those hunks; dry-run fixtures are now patent-analysis, a literal v33 skeleton and daystrom-patent-analysis; patent-analysis Test Rules 4–5 move as additions and 1–3 are flagged with an append proposal.

## 2026-10-11 — Phase 3 (F2.3) review round 1 (Needs Fixes)
- **Result:** Needs Fixes — 2 blocking, 2 non-blocking still open
- **This round:** new 4, verified 0, reopened 0
- **Next:** run `./implement F2.3` to address open findings, then `/review-impl F2.3` again
- **Ledger:** plans/F2.3-review.md

## 2026-10-11 — Phase 3 (F2.3) review round 2 (Passed)
- **Result:** Passed — all blocking resolved; non-blocking verified
- **Tests:** 47/47 passed
- **Ledger:** plans/F2.3-review.md

## 2026-10-11 — Phase 3 closed
- **Commit:** 6f5160d `feat(F2.3): v34 migration (upgrade-workflow Step 1b), changelog and version bump`
- **Tests:** 47/47 passed; GATE_CMD, verify-links, check-spec-tests (9/9) and check-workflow (v34) clean
- **Review:** plans/F2.3-review.md Passed in round 2 (4 findings, all verified)
- **Manual verification:** dry-runs on scratch copies (patent-analysis, literal v33 skeleton, daystrom-patent-analysis, second pass) recorded in plans/F2.3-progress.md and re-read by the reviewer; the user's own check that `./implement` prompts name both files in a migrated project is still open
- **Next:** `/complete F2` closes the feature and issue #2

## 2026-10-11 — Shipped
- **Commit:** `feat(F2.3): v34 migration (upgrade-workflow Step 1b), changelog and version bump` (final phase; phases at 77da107, 3bb1e31, 6f5160d)
- **Closed:** #2
