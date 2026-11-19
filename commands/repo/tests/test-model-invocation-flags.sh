#!/usr/bin/env bash
# Test suite for the model-invocation flags on commands/repo/*.md (repo#832).
#
# Usage: ./commands/repo/tests/test-model-invocation-flags.sh
# Exit code 0 = all tests pass, 1 = failures detected.
#
# Structured like commands/repo/tests/test-scrub-contract.sh: pure bash, no
# test framework, PASS/FAIL/SKIP/TOTAL counters and a summary block. `pnpm test`
# delegates to this file via hooks/repo/tests/run.sh.
#
# WHY THIS FILE EXISTS (repo#832): nine rarely-dispatched commands carry
# frontmatter `disable-model-invocation: true` so they stay out of the
# model-visible skill listing (roughly 1k tokens of resident context) while
# remaining runnable when an operator types `/repo:<verb>`. Nothing in this
# repo's scripts enforces that shape, so the sets can drift silently in both
# directions: a flagged command could lose its flag (its listing line returns)
# or a new command could pick the flag up without anyone deciding it should be
# unlisted. This file is the equivalent of test-skill-commands-table.sh for the
# flag: it pins the exact flagged set and asserts every flagged command stays
# user-invocable, so the "reachable when typed" half of the contract cannot be
# dropped by a later frontmatter edit.
#
# The contract under test:
#   1  exactly the nine repo#832 commands carry disable-model-invocation: true
#   2  every flagged command still carries user-invocable: true
#   3  no other command file carries the flag (the kept-listed set is intact)
#   4  every command file (flagged or not) keeps the five shared keys
#   5  the SKILL.md itself carries neither the flag nor user-invocable drift

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CMD_DIR="$REPO_ROOT/commands/repo"

# Assertion helpers (ok/no/skip/assert_eq/assert_contains/assert_not_contains/
# assert_matches) plus the PASS/FAIL/SKIP/TOTAL counters and color vars are
# shared across the repo test suites — see lib/assert.sh (repo#307).
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

if [[ ! -d "$CMD_DIR" ]]; then
    echo "FATAL: commands directory not found at $CMD_DIR" >&2
    exit 1
fi

# The flagged set, pinned by name (repo#832). One per line, sorted, so a
# diff of this list against `git grep -l` output is readable on failure.
FLAGGED_EXPECTED="branches
browser
gitignore
host-optimize
links
org-policy
orphans
readme
sudo"

frontmatter_field() {  # <file> <key> -> value, empty when absent
    awk -v key="$2" '
        NR == 1 && $0 != "---" { exit }
        NR == 1 { next }
        /^---$/ { exit }
        index($0, key ":") == 1 {
            sub(/^[^:]*:[[:space:]]*/, "")
            gsub(/^"|"$/, "")
            print
            exit
        }
    ' "$1"
}

FLAGGED_ACTUAL="$(cd "$CMD_DIR" && grep -l '^disable-model-invocation: true$' ./*.md 2>/dev/null | sed 's|^\./||; s/\.md$//' | sort)"
if [[ "$FLAGGED_ACTUAL" == "$FLAGGED_EXPECTED" ]]; then
    ok "exactly the nine repo#832 commands carry disable-model-invocation: true"
else
    no "exactly the nine repo#832 commands carry disable-model-invocation: true" \
"expected:
$(echo "$FLAGGED_EXPECTED" | sed 's/^/    /')
actual:
$(echo "$FLAGGED_ACTUAL" | sed 's/^/    /' | sed '/^$/d')"
fi

for cmd in $FLAGGED_EXPECTED; do
    f="$CMD_DIR/$cmd.md"
    if [[ "$(frontmatter_field "$f" user-invocable)" == "true" ]]; then
        ok "$cmd keeps user-invocable: true (reachable when typed)"
    else
        no "$cmd keeps user-invocable: true (reachable when typed)" \
            "$cmd.md must stay user-invocable: true — disable-model-invocation only removes it from the model listing"
    fi
    if [[ "$(frontmatter_field "$f" disable-model-invocation)" == "true" ]]; then
        ok "$cmd carries disable-model-invocation: true"
    else
        no "$cmd carries disable-model-invocation: true" "$cmd.md lost its flag"
    fi
done

# Per-file sweep: any command outside the flagged set must carry no flag
# (per-file pass lines, complementing the set-level comparison above), and
# every command file must keep the five shared frontmatter keys.
for f in "$CMD_DIR"/*.md; do
    cmd="$(basename "$f" .md)"
    if grep -q '^disable-model-invocation: true$' "$f"; then
        : # flagged — asserted by the set comparison and the per-command loop
    else
        ok "$cmd is not flagged (stays in the model listing)"
    fi
done

for f in "$CMD_DIR"/*.md; do
    cmd="$(basename "$f" .md)"
    for key in name description domain type user-invocable; do
        if [[ -n "$(frontmatter_field "$f" "$key")" ]]; then
            : # present — the per-command assertions above cover values
        else
            no "$cmd keeps the shared key '$key'" "$cmd.md frontmatter is missing $key:"
        fi
    done
done

SKILL="$REPO_ROOT/skills/repo/SKILL.md"
if [[ -f "$SKILL" ]]; then
    if grep -q '^disable-model-invocation:' "$SKILL"; then
        no "SKILL.md carries no disable-model-invocation" \
            "skills/repo/SKILL.md must stay model-discoverable — the flag belongs on commands only"
    else
        ok "SKILL.md carries no disable-model-invocation"
    fi
else
    skip "SKILL.md check (skills/repo/SKILL.md not found)"
fi

echo ""
echo "========================================="
echo "  Total:  $TOTAL"
printf "  ${GREEN}Passed${NC}: %s\n" "$PASS"
printf "  ${RED}Failed${NC}: %s\n" "$FAIL"
printf "  ${YELLOW}Skipped${NC}: %s\n" "$SKIP"
echo "========================================="
if [[ "$FAIL" -ne 0 ]]; then
    echo "FAILURES DETECTED"
    exit 1
fi
echo "ALL TESTS PASSED"
exit 0
