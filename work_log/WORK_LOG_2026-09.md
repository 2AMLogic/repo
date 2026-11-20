# Work Log Archive — 2026-09

Sections moved byte-for-byte from [WORK_LOG.md](../WORK_LOG.md) by `loom-daemon work-docs archive`.

### 2026-09-19
- **Issue #438** (closed): test-guard-equivalence.sh cannot see worktree-write-confinement divergences: every case runs from a cwd with no sibling worktree
- **PR #440**: test: run guard-equivalence cases from a real Loom worktree cwd

### 2026-09-18
- **Issue #436** (closed): guard-destructive.sh: qsplit() mis-splits a quoted redirect target's $(...) at an embedded pipe, causing false worktree-write-confinement DENY
- **PR #437**: fix(guard): stop qsplit() splitting the outer stream at a separator inside $( )
- **Issue #434** (closed): guard: query-sink vetoes read the masked command copy, so an earlier masking pass can hide a veto token (residual from #428)
- **PR #435**: fix(guard): run the data-sink pass before literal-text redaction so a masked span cannot hide a query-sink veto
- **Issue #311** (closed): Auditor: guard-destructive fires on dangerous substrings inside test/data strings, not just executed commands
- **PR #428**: fix(guard): treat jq/grep/sed/awk query text as data, not a command (#311)

### 2026-09-15
- **Issue #432** (closed): merge-pr.sh: _check_champion_hold_state_staleness aborts the whole script on a PR with no champion:hold-state marker
- **Issue #429** (closed): guard: command_has_shell_segment() misses a shell reached through xargs/parallel
- **PR #431**: fix(guard): recognize xargs/parallel as a shell-spawning segment
- **Issue #430** (closed): merge-pr.sh: _check_champion_hold_state_staleness crashes under set -euo pipefail when no champion:hold-state marker exists
- **Issue #257** (closed): Handoff note in another repo is invisible from the repo you start in
- **PR #427**: feat(hooks): opt-in sibling-repo handoff-note visibility (#257)
- **Issue #282** (closed): Add dual-runtime Claude and Codex packaging for Repo Skills

### 2026-09-05
- **Issue #349** (closed): test: run.sh inline guard smoke cases pollute guard-decisions.log (missing ambient-env neutralization from #134)

