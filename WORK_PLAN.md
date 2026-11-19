# Work Plan

Prioritized roadmap generated from current GitHub label state, maintained automatically by the Guide triage agent. Regenerated whenever label state changes; do not hand-edit the generated region below.

<!-- guide:plan-body:start -->
_Generated: 2026-11-19T19:55:00Z (snapshot; compare against live labels)_
## Operator Attention: Merge-Risk-Hold Pileup

Judge-approved PRs under a hold (`loom:blocked` or `loom:operator`) — only a human merge decision is missing.

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

- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills
- **#769**: CHANGELOG has no version headings since 0.16.2; tagged bumps never cut one

## In Progress

Issues currently being built (`loom:building`).

- **#858**: /repo:release: $0/$1 in shell and awk snippets are replaced by skill-argument substitution
- **#859**: Refresh the managed CLAUDE.md link on the first Repo Skills update after the owner move

## PRs Awaiting Review

PRs waiting on Judge (`loom:review-requested`).

- **#861**: fix: spell shell/awk positionals substitution-proof in command Markdown

## Approved (Awaiting Merge)

PRs that passed review and are queued for Champion auto-merge (`loom:pr`).

- **#770**: fix: cut CHANGELOG version headings on bump and gate on a matching heading
- **#860**: fix: refresh managed CLAUDE.md link on first update from a pre-move install

## Proposed

Issues carrying `loom:curated`.

- **#478**: Live-verify org-policy's absent/inaccessible heuristic against a real organization *(curated)* *(held)*
- **#565**: repo:remote: support short-lived or brokered GitHub credentials instead of a long-lived PAT on the VM *(curated)* *(held)*
- **#638**: Repo Skills: make Dependabot (with cooldown) the default provider again; Renovate becomes opt-in (2am#4351) *(curated)* *(held)*
- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills *(curated)*
- **#769**: CHANGELOG has no version headings since 0.16.2; tagged bumps never cut one *(curated)*
- **#816**: INSTALLER-CONTRACT: re-observe loom's install-dependent cells (C3, C5-C7, C9, C10) on a host where a full loom install is allowed *(curated)*
- **#858**: /repo:release: $0/$1 in shell and awk snippets are replaced by skill-argument substitution *(curated)*
- **#859**: Refresh the managed CLAUDE.md link on the first Repo Skills update after the owner move *(curated)*

## Proposed (Architect / Hermit)

_None._

## Epics

_None._

## Backlog Balance

| Bucket | Count |
|------|-------|
| Operator merge-risk holds | 2 |
| Very important | 1 |
| Important | 1 |
| Ready (`loom:issue`, net of holds/building/merge-pending) | 2 |
| In Progress (`loom:building`) | 2 |
| PRs awaiting review | 1 |
| Approved PRs awaiting merge | 2 |
| Curated | 8 |
| Architect / Hermit proposals | 0 |
| Active epics | 0 |
<!-- guide:plan-body:end -->
