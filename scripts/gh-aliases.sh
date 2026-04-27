#!/usr/bin/env bash
# GitHub issue aliases for the current project
# Usage: source gh-aliases.sh
# Requires: gh CLI authenticated, run from project root

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]\(.*\)\.git|\1|')

# All open issues (default view)
alias gi='gh issue list --state open'

# Unbatched open issues — what still needs planning
alias gi-open='gh search issues --repo '"$REPO"' --state open "NOT label:batched"'

# All batched issues (across all features)
alias gi-batched='gh issue list --label batched'

# Issues in a specific batch — e.g. gi-batch B76 (all issues batched into #76)
alias gi-batch='gh issue list --label'

# Open bugs only
alias gi-bugs='gh issue list --label bug --state open'

# Issues with no labels — good triage starting point
alias gi-triage='gh search issues --repo '"$REPO"' --state open "no:label"'
