# Work Log Archive — 2026-09

Sections moved byte-for-byte from [WORK_LOG.md](../WORK_LOG.md) by `loom-daemon work-docs archive`.

### 2026-09-22
- **PR #445**: feat: install canonical organization dependency policy from clients
- **Issue #458** (closed): repo-remote: stale SSH alias + auto-assigned public IPs silently re-point a project at a stranger's instance
- **PR #460**: feat(repo-remote): verify the host identity behind the SSH alias
- **Issue #451** (closed): repo-remote: idle guard stops instances mid-build with no held SSH session; stop/start churns public IP, alias + SG ingress go stale
- **PR #457**: fix(repo-remote): refresh SSH ingress on every reuse path and poll for the public IP
- **Issue #453** (closed): Guard: acn==0 is not a sound 'top level' proxy — a nested $( ) with a quote phantom-closes the active span, re-opening the #450 apostrophe hole
- **PR #459**: fix(guard): a nested $( ) quote must not phantom-close the active span (#453)
- **Issue #448** (closed): /repo:all doc fixes applied in a Loom primary checkout are quarantined by the next sweep; land them on a branch or warn
- **PR #456**: fix(repo): land /repo:* doc fixes where a sweep cannot quarantine them
- **Issue #449** (closed): repo-remote: wait for fresh-instance SSH readiness before declaring provisioning failure
- **PR #455**: fix(repo-remote): wait for fresh-instance SSH readiness before declaring provisioning failure
- **Issue #450** (closed): Guard regression from #446: an apostrophe inside a LIVE double-quoted span makes a real executing $( ) inert, allowing a destructive command
- **PR #452**: fix: scope single-quoted-span inertness to the top level of ml_segment()
- **Issue #443** (closed): rmScope guard denies rm inside a remote command string (ssh host '…') — classify remote deletions separately and default them to ask
- **PR #446**: fix(guard): treat single-quoted spans as inert in ml_segment() (#443)

### 2026-09-21
- **Issue #133** (closed): layout/reports/README.md's array-level LVS section is stale: documents mismatch, lvs-array.json now reads match
- **Issue #128** (closed): Machine-gradeable T1 rows: re-mint LVS input provenance, a klt sim envelope, and repo-relative MC yield records so signoff items 4-6 can verify
- **Issue #127** (closed): Guard-decision review: scratch-var exemption misses the klt/KLayout layout cold-start idiom (inline ./layout/verify.sh reproduction denied), propose extending the #65 exemption
- **Issue #125** (closed): Commit a klt signoff block manifest so this block's T1 state is graded, not hand-read
- **Issue #124** (closed): T1 item 11 (power delivery, structural): no klt erc supply spec or report in this repo

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

