#!/usr/bin/env bash
# Lint: first-party command and skill Markdown must not contain bare
# skill-argument positional tokens (repo#858).
#
# Usage: ./commands/repo/tests/test-no-positional-params.sh
# Exit code 0 = all tests pass, 1 = failures detected.
#
# WHY THIS FILE EXISTS (repo#858): when a Claude Code command is invoked with
# arguments (`/repo:release minor — …`), the harness substitutes the bare
# positional tokens dollar-digit ($0..$9) and the all-arguments token
# $ARGUMENTS throughout the command body BEFORE the model reads it. Commands
# ship literal shell/awk snippets the operator is meant to copy verbatim, so
# substitution silently rewrites them — the live incident had the release-notes
# extractor rendered as `awk -v v="—"` with a broken program body. The
# substitution does not touch the braced shell spelling "${1}" or the
# parenthesized awk field spellings $(0)/$(1)/$(2), and prose can spell out
# currency (8.60 USD), so this lint holds every first-party Markdown body to
# those safe spellings. Bare token finds here are always a defect: no command
# in this repo is meant to interpolate invocation arguments.
#
# Scope: `commands/**/*.md` and first-party `skills/**/SKILL.md` — the
# installed skill surfaces. Shell scripts, test data (`*.txt`), `hooks/`, and
# `lib/` are not skill bodies and are out of scope (they may legitimately use
# positional parameters).
#
# Structured like commands/repo/tests/test-release-notes-extraction.sh: pure
# bash, no test framework, PASS/FAIL/TOTAL counters via lib/assert.sh.
# `pnpm test` delegates to this file via hooks/repo/tests/run.sh.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Assertion helpers (ok/no/skip/assert_eq/assert_contains/assert_not_contains/
# assert_matches) plus the PASS/FAIL/SKIP/TOTAL counters and color vars are
# shared across the repo test suites — see lib/assert.sh (repo#307).
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

# scan <file>... -> offending `file:line:text` lines on stdout, empty when clean.
# The pattern matches a `$` immediately followed by a digit or by ARGUMENTS.
scan() {
    grep -nE -- '\$[0-9]|\$ARGUMENTS' "$@" || true
}

SCRATCH="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$SCRATCH"' EXIT

echo "no-positional-params lint test suite"
echo "===================================="
echo ""

# ---------------------------------------------------------------------------
echo "-- the lint bites: unsafe spellings are flagged --"
# ---------------------------------------------------------------------------
# Proof the lint is not vacuous: seed fixtures carrying the exact defect
# classes and require each to be caught.
BITER="$SCRATCH/bite-positional.md"
cat > "$BITER" <<'EOF'
# scratch fixture
extract_release_notes() {
  awk -v v="$1" '
    $0 ~ "^##[[:space:]]+v?\\[?" v "([[:space:]]|\\]|$)" {f=1; next}
    /^##[[:space:]]/ {f=0}
    f' CHANGELOG.md
}
EOF
HIT="$(scan "$BITER")"
assert_matches 'lint bites: bare "$1" in a shell snippet is flagged' "$HIT" '\$1'
assert_matches 'lint bites: bare "$0" in an awk program is flagged' "$HIT" '\$0'

ARGS="$SCRATCH/bite-arguments.md"
printf 'Run with %s to customize the flow.\n' '$ARGUMENTS' > "$ARGS"
assert_matches 'lint bites: literal $ARGUMENTS is flagged' "$(scan "$ARGS")" 'ARGUMENTS'

PROSE="$SCRATCH/bite-prose.md"
printf 'The worker costs ~$8/day and storage is $0.08 per GB-month.\n' > "$PROSE"
assert_matches 'lint bites: dollar amounts in prose are flagged' "$(scan "$PROSE")" '\$8'

# ---------------------------------------------------------------------------
echo "-- safe spellings pass --"
# ---------------------------------------------------------------------------
SAFE="$SCRATCH/safe-spellings.md"
cat > "$SAFE" <<'EOF'
# scratch fixture — every substitution-proof spelling this repo relies on
extract_release_notes() {
  awk -v v="${1}" '
    $(0) ~ "^##[[:space:]]+v?\\[?" v "([[:space:]]|\\]|$)" {f=1; next}
    /^##[[:space:]]/ {f=0}
    f' CHANGELOG.md
}
attrib() { ipaths "${1}" | git -c core.excludesFile=/dev/null check-ignore -v --stdin; }
ps -eo state,pid,pcpu,comm | awk '$(1) == "D"'
git worktree list --porcelain | awk '{printf "%+d\t%s\n", $(1) - $(2), $(3)}'
# Named shell variables are untouched: "$NEW", "$VS_BUMP", "$NOTES_FILE".
# Pricing prose spells out currency: about 8.60 USD/day, 0.08 USD per GB-month.
# Regex metacharacter "$" at end of pattern: "([[:space:]]|\\]|$)".
EOF
assert_eq "safe spellings (braced shell, parenthesized awk, spelled-out currency) pass" "" "$(scan "$SAFE")"

# ---------------------------------------------------------------------------
echo "-- the first-party tree is clean --"
# ---------------------------------------------------------------------------
# The real lint: every installed command Markdown and the skill router must be
# free of the tokens. Enumerate with find (not a hardcoded list) so a newly
# added command file is covered the moment it lands.
COMMAND_MDS="$(find "$REPO_ROOT/commands" -type f -name '*.md' | sort)"
SKILL_MDS="$(find "$REPO_ROOT/skills" -type f -name 'SKILL.md' | sort)"

N_COMMAND_MDS="$(printf '%s\n' "$COMMAND_MDS" | sed '/^$/d' | wc -l | tr -d ' ')"
N_SKILL_MDS="$(printf '%s\n' "$SKILL_MDS" | sed '/^$/d' | wc -l | tr -d ' ')"
if [[ "$N_COMMAND_MDS" -ge 1 ]]; then
    ok "command Markdown files found ($N_COMMAND_MDS) — the lint is not vacuous"
else
    no "command Markdown files found" "find returned nothing under $REPO_ROOT/commands — the tree scan below would pass vacuously"
fi
if [[ "$N_SKILL_MDS" -ge 1 ]]; then
    ok "first-party SKILL.md files found ($N_SKILL_MDS) — the lint is not vacuous"
else
    no "first-party SKILL.md files found" "find returned nothing under $REPO_ROOT/skills — the tree scan below would pass vacuously"
fi

TREE_HITS="$( { printf '%s\n' "$COMMAND_MDS"; printf '%s\n' "$SKILL_MDS"; } \
    | sed '/^$/d' | xargs grep -nE -- '\$[0-9]|\$ARGUMENTS' || true)"
if [[ -z "$TREE_HITS" ]]; then
    ok "no bare positional tokens in commands/**/*.md or skills/**/SKILL.md"
else
    no "bare positional tokens in first-party command/skill Markdown" \
        "$TREE_HITS"
fi

# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  Total:  $TOTAL"
printf "  ${GREEN}Passed${NC}: %s\n" "$PASS"
printf "  ${RED}Failed${NC}: %s\n" "$FAIL"
echo "========================================="

if [[ $FAIL -gt 0 ]]; then
    printf "\n${RED}TESTS FAILED${NC}\n"
    exit 1
fi
printf "\n${GREEN}ALL TESTS PASSED${NC}\n"
exit 0
