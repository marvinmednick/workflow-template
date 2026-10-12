# F7 Feature Log

## 2026-10-11 — Committed without spec (b946b0c)
- **Scope:** Architecture documents stand alone: rule in the conventions and the Doc Updates instructions (v35).
- **GitHub Issue:** #7
- **Note:** No spec, progress file or ledger was created; the change was committed directly.

## 2026-10-11 — Review round 1 (Needs Fixes — fixed inline)
- **Result:** Needs Fixes — 1 blocking (tests hardcoded to v34; 3 failures at v35)
- **Fix:** `tests/test_f2_migration.py` — version test now compares `VERSION` to the top changelog heading; the v34 entry test no longer requires v34 to be the top entry; the check-workflow test reads the current version from `VERSION`.
- **Tests:** 47/47 passed. Gate (`gen-codex-skills.sh --check`) passes.
- **Next:** commit the test fix.
