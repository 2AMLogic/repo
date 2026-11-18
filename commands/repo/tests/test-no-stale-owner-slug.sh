#!/usr/bin/env bash
# Guard test: the shipped surface must not name this repo by its pre-move
# owner slug (`rjwalters/repo`) outside of history references.
#
# Repo Skills moved from rjwalters/repo to 2AMLogic/repo (#844). The old path
# redirects, so prose that still names it works today but breaks if the old
# path is ever recreated, and functional constants that read the slug from the
# shipped text (org-policy's SOURCE_REPO, followups' self-target short-circuit,
# the CLAUDE.md install block) would keep pointing consumers at the redirect.
# This suite fails when a shipped file carries the old slug, allowing:
#   - CHANGELOG.md / WORK_LOG.md / work_log/ / docs/ history prose
#   - issue/PR-number references (rjwalters/repo#NN, /issues/NN, /pull/NN),
#     which point at real issues the old path still redirects
#   - the .loom/ vendored tree (tracked by the Loom repo, not this one)
#
# The sibling-tool slugs (rjwalters/loom, @rjwalters/squad, ...) and the
# npm scope are deliberately NOT asserted here — scope deliberately does not
# imply owner, and history refs to those repos stay valid through the same
# redirects.
#
# Usage: ./commands/repo/tests/test-no-stale-owner-slug.sh
# Exit code 0 = all pass, 1 = failures. Pure bash, hermetic (reads the tree only).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$REPO_ROOT"

# The consumer-visible surface install.sh copies (plus the canonical policies/
# directory /repo:org-policy reads from GitHub — same surface the VERSION-bump
# CI gate watches). .loom/ is vendored from the Loom repo and out of scope.
SCAN_PATHS=(install.sh uninstall.sh scripts/repo commands hooks lib skills policies)

PASS=0; FAIL=0

# Allowed forms of the old slug, stripped before the residue check:
#   rjwalters/repo#NN, rjwalters/repo/issues/NN, rjwalters/repo/pull/NN —
#   issue/PR-number references that still resolve through the redirect.
strip_allowed_refs() {
    sed -E 's,rjwalters/repo(#[0-9]+|/issues/[0-9]+|/pull/[0-9]+),,g'
}

offenders=()
while IFS= read -r f; do
    while IFS= read -r line; do
        stripped="$(printf '%s\n' "$line" | strip_allowed_refs)"
        if [[ "$stripped" == *rjwalters/repo* ]]; then
            offenders+=("$f:$line")
        fi
    done < <(grep -n 'rjwalters/repo' "$f" | sed 's/^[0-9]*://')
done < <(git ls-files -- "${SCAN_PATHS[@]}" \
         | grep -Ev '(^|/)(CHANGELOG\.md|WORK_LOG\.md)$|(^|/)work_log/|(^|/)docs/' \
         | grep -v -- "$(basename "$0")")
# ^ this suite is excluded from its own scan: it is the detector, and its code
# and comments must name the literal it detects to detect it.

if [[ ${#offenders[@]} -eq 0 ]]; then
    PASS=$((PASS + 1)); echo "PASS: no stale owner slug in the shipped surface (history and issue refs excepted)"
else
    FAIL=$((FAIL + 1)); echo "FAIL: stale owner slug 'rjwalters/repo' found in shipped files"
    echo "      (allowed: CHANGELOG/WORK_LOG/work_log/docs history, rjwalters/repo#NN issue refs, .loom/):"
    printf '  %s\n' "${offenders[@]}"
fi

echo ""
echo "========================================="
echo "  Total:  $((PASS + FAIL))"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "========================================="
[[ $FAIL -eq 0 ]] || exit 1
echo "ALL TESTS PASSED"
