# Work Plan

Prioritized roadmap generated from current GitHub label state, maintained automatically by the Guide triage agent. Regenerated whenever label state changes; do not hand-edit the generated region below.

<!-- guide:plan-body:start -->
## Operator Attention: Merge-Risk-Hold Pileup

Judge-approved PRs under a hold (`loom:blocked` or `loom:operator`) — only a human merge decision is missing.

- **#770**: fix: cut CHANGELOG version headings on bump and gate on a matching heading

## Very Important

`loom:very-important` (one counts per workspace); every stage takes these first.

- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills

## Important

`loom:important`; taken before unlabelled work.

- **#769**: CHANGELOG has no version headings since 0.16.2; tagged bumps never cut one

## Ready

Human-approved issues ready for implementation (`loom:issue`).

- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills

## In Progress

Issues currently being built (`loom:building`).

- **#851**: docs/ROADMAP.md Now item 3 is stale: the conformance table it describes has already been re-observed

## PRs Awaiting Review

PRs waiting on Judge (`loom:review-requested`).

- **#852**: docs: restate ROADMAP Now item 3 against the re-observed conformance table

## Approved (Awaiting Merge)

PRs that passed review and are queued for Champion auto-merge (`loom:pr`).

- **#770**: fix: cut CHANGELOG version headings on bump and gate on a matching heading

## Proposed

Issues carrying `loom:curated`.

- **#478**: Live-verify org-policy's absent/inaccessible heuristic against a real organization *(curated)*
- **#565**: repo:remote: support short-lived or brokered GitHub credentials instead of a long-lived PAT on the VM *(curated)*
- **#638**: Repo Skills: make Dependabot (with cooldown) the default provider again; Renovate becomes opt-in (2am#4351) *(curated)*
- **#765**: Remove /repo:remote (cloud dev-VM command) from Repo Skills *(curated)*
- **#769**: CHANGELOG has no version headings since 0.16.2; tagged bumps never cut one *(curated)*
- **#816**: INSTALLER-CONTRACT: re-observe loom's install-dependent cells (C3, C5-C7, C9, C10) on a host where a full loom install is allowed *(curated)*
- **#851**: docs/ROADMAP.md Now item 3 is stale: the conformance table it describes has already been re-observed *(curated)*

## Proposed (Architect / Hermit)

_None._

## Epics

_None._

## Backlog Balance

| Bucket | Count |
|------|-------|
| Operator merge-risk holds | 1 |
| Very important | 1 |
| Important | 1 |
| Ready (`loom:issue`) | 1 |
| In Progress (`loom:building`) | 1 |
| PRs awaiting review | 1 |
| Approved PRs awaiting merge | 1 |
| Curated | 7 |
| Architect / Hermit proposals | 0 |
| Active epics | 0 |
<!-- guide:plan-body:end -->
