# Work Plan

Prioritized roadmap generated from current GitHub label state, maintained automatically by the Guide triage agent. Regenerated whenever label state changes; do not hand-edit the generated region below.

<!-- guide:plan-body:start -->
_Generated: 2026-11-20T15:09:19Z (snapshot; compare against live labels)_
## Operator Attention: Merge-Risk-Hold Pileup

These PRs require a human merge decision. PR #770 also has a merge conflict.

- **#766**: feat: remove /repo:remote and retire its installed files on reinstall/resync
- **#770**: fix: cut CHANGELOG version headings on bump and gate on a matching heading
- **#860**: fix: refresh managed CLAUDE.md link on first update from a pre-move install

## Very Important

`loom:very-important` (one counts per workspace); every stage takes these first.

- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills

## Important

`loom:important`; taken before unlabelled work.

- **#769**: CHANGELOG has no version headings since 0.16.2; tagged bumps never cut one

## Ready

Human-approved issues (`loom:issue`) ready for implementation — excluding held (`loom:blocked`/`loom:operator`/`loom:frozen`), `loom:building`, and issues closed by an open `loom:pr` PR (listed under Approved).

_None._

## In Progress

Issues currently being built (`loom:building`).

- **#859**: Refresh the managed CLAUDE.md link on the first Repo Skills update after the owner move

## PRs Awaiting Review

PRs waiting on Judge (`loom:review-requested`).

_None._

## Approved (Awaiting Merge)

PRs that passed review and are queued for Champion auto-merge (`loom:pr`).

- **#766**: feat: remove /repo:remote and retire its installed files on reinstall/resync — closes #765
- **#770**: fix: cut CHANGELOG version headings on bump and gate on a matching heading — closes #769
- **#860**: fix: refresh managed CLAUDE.md link on first update from a pre-move install — closes #859

## Proposed

Issues carrying `loom:curated`.

- **#478**: Live-verify org-policy's absent/inaccessible heuristic against a real organization *(curated)* *(held)*
- **#565**: repo:remote: support short-lived or brokered GitHub credentials instead of a long-lived PAT on the VM *(curated)* *(held)*
- **#638**: Repo Skills: make Dependabot (with cooldown) the default provider again; Renovate becomes opt-in (2am#4351) *(curated)* *(held)*
- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills *(curated)*
- **#769**: CHANGELOG has no version headings since 0.16.2; tagged bumps never cut one *(curated)*
- **#859**: Refresh the managed CLAUDE.md link on the first Repo Skills update after the owner move *(curated)*

## Proposed (Architect / Hermit)

_None._

## Epics

_None._

## Backlog Balance

| Bucket | Count |
|------|-------|
| Operator merge-risk holds | 3 |
| Very important | 1 |
| Important | 1 |
| Ready (`loom:issue`, net of holds/building/merge-pending) | 0 |
| In Progress (`loom:building`) | 1 |
| PRs awaiting review | 0 |
| Approved PRs awaiting merge | 3 |
| Curated | 6 |
| Architect / Hermit proposals | 0 |
| Active epics | 0 |
<!-- guide:plan-body:end -->
