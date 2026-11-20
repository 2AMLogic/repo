#!/usr/bin/env bash
# print_failures / strip_ansi / suite_count coverage (repo#820) — pins the
# output-rendering helpers in hooks/repo/tests/run.sh that a green `pnpm test`
# run never executes.
#
# WHY THIS FILE EXISTS: print_failures (repo#817/#819) renders a failing
# delegated suite's diagnostics in run.sh's per-suite breakdown, and
# strip_ansi + suite_count parse every delegated suite's output. All three run
# only on a failing or unparseable suite, so a fully-green run exercises none
# of their awk/sed — a regression there would silently strip the failure
# diagnostics #817 restored, and no assertion would catch it. This suite
# feeds the real helpers fixtures built from the repo's REAL suite printers
# (lib/assert.sh ok/no/skip, the guard suite's `Got:` continuation shape, the
# standard Total/Passed/Failed summary block), so the byte shapes asserted
# here are the byte shapes production emits.
#
# The helpers are EXTRACTED FROM run.sh ITSELF, never copied: run.sh executes
# its whole body when sourced, so sourcing it directly would run the entire
# guard suite as a side effect. Instead the three function definitions are
# lifted with sed and eval'd; if the extraction ever yields nothing (a helper
# renamed or moved), this suite fails loudly instead of passing vacuously.
# Because there is no copy, drift between test and source is impossible by
# construction — the tested code IS the shipped code.
#
# Wired into hooks/repo/tests/run.sh as a delegated suite, so it also runs in
# the macOS CI job (bash 3.2, BSD awk/sed) — the exact awk dialect
# print_failures ships on there. Accordingly this file sticks to bash 3.2
# (no mapfile/associative arrays) and system awk/sed.
#
# Usage: ./commands/repo/tests/test-run-sh-failure-output.sh
# Exit code 0 = all tests pass, 1 = failures detected.

set -uo pipefail

# Assertion helpers (ok/no/skip/assert_eq/assert_contains/assert_not_contains)
# plus the PASS/FAIL/SKIP/TOTAL counters and color vars are shared across the
# repo test suites — see lib/assert.sh (repo#307).
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

REPO_TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RUN_SH="$REPO_TOP/hooks/repo/tests/run.sh"
ASSERT_SH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/assert.sh"

# ---------------------------------------------------------------------------
echo "-- helper extraction from run.sh (source of truth, never a copy) --"

if [[ -f "$RUN_SH" ]]; then
    ok "hooks/repo/tests/run.sh exists"
else
    no "hooks/repo/tests/run.sh exists" "not found at $RUN_SH"
fi

# strip_ansi and suite_count are single-line definitions; print_failures is a
# multi-line block whose body ends at the first column-0 `}`.
HELPERS="$(sed -n '/^strip_ansi()/p; /^suite_count()/p; /^print_failures()/,/^}/p' "$RUN_SH")"

EXTRACT_OK=0
if [[ -n "$HELPERS" ]] && eval "$HELPERS" 2>/dev/null; then
    EXTRACT_OK=1
fi

if [[ "$EXTRACT_OK" -eq 1 ]] \
   && declare -F strip_ansi >/dev/null \
   && declare -F suite_count >/dev/null \
   && declare -F print_failures >/dev/null; then
    ok "sed extraction + eval defines strip_ansi, suite_count, print_failures"
else
    no "sed extraction + eval defines strip_ansi, suite_count, print_failures" \
        "extraction over $RUN_SH was empty or unevaluable — a helper was renamed or moved?"
fi

# Loud early exit: without the real helpers the rest of this suite would test
# nothing, and passing vacuously is exactly the failure mode repo#820 exists
# to prevent. The summary block below keeps the delegated-block accounting in
# run.sh parseable (it folds our counts into its totals).
if [[ "$EXTRACT_OK" -eq 0 || ! -f "$RUN_SH" ]]; then
    echo ""
    echo "========================================="
    echo "  Total:  $TOTAL"
    printf "  ${GREEN}Passed${NC}: %s\n" "$PASS"
    printf "  ${RED}Failed${NC}: %s\n" "$FAIL"
    echo "========================================="
    exit 1
fi

# ---------------------------------------------------------------------------
# Fixture plumbing. Each fixture runs a snippet inside a child bash that
# sources the repo's REAL assertion printers, then appends the standard
# summary block every delegated suite prints — so the fixtures reproduce the
# production output shapes byte-for-byte (ANSI colours included).
run_real_suite_snippet() {  # <snippet-text> -> suite-shaped output on stdout
    SUITE_SNIPPET="$1" ASSERT_SH="$ASSERT_SH" bash --norc <<'EOS'
source "${ASSERT_SH:?}"
eval "${SUITE_SNIPPET:?}"
echo "========================================="
echo "  Total:  $TOTAL"
printf "  ${GREEN}Passed${NC}: %s\n" "$PASS"
printf "  ${RED}Failed${NC}: %s\n" "$FAIL"
echo "========================================="
EOS
}

# A rich delegated-suite failure: real ok/no/skip printers, a multi-line
# no() detail (Expected/Got), a SKIP after the FAIL, and the summary block.
FIXTURE_STD="$(run_real_suite_snippet '
ok "passing case"
no "failing case" "Expected: [foo]
Got: [bar]"
ok "second passing case"
skip "skipped case" "not exercisable here"
')"

# The guard suite's failure shape (test-guard-destructive.sh): a coloured
# FAIL line followed by 7-space-indented continuation lines ending in `Got:`.
FIXTURE_GUARD="$(run_real_suite_snippet '
echo -e "  ${RED}PASS${NC}: passing guard case"
echo -e "  ${RED}FAIL${NC}: guard description"
echo -e "       Command: rm -rf /tmp/x (env: none, cwd: /repo)"
echo -e "       Expected: deny"
echo -e "       Got: {\"hookSpecificOutput\":\"deny\"}"
')"

# A single-line FAIL (no() with no detail) bracketed by real ok() PASS lines.
FIXTURE_SINGLE="$(run_real_suite_snippet '
ok "passing case"
no "single-line failure"
ok "after failure"
')"

# A suite with no failures at all: print_failures must take its bounded
# tail -30 fallback so the reader still sees what happened.
FIXTURE_TAIL="$(printf 'suite header line\n  PASS: only passing case\n=========================================\n  Total:  1\n  Passed: 1\n  Failed: 0\n=========================================\n')"

# A suite that died mid-case: the FAIL is the last thing printed, with a
# continuation line and no summary or terminator after it.
FIXTURE_LASTLINE="$(printf 'preamble\n  FAIL: trailing failure\n          continuation detail\n')"

# ---------------------------------------------------------------------------
echo "-- strip_ansi --"

assert_eq "strip_ansi: plain text passes through unchanged" \
    "hello world" "$(strip_ansi "hello world")"

assert_eq "strip_ansi: SGR colour escape removed, text kept" \
    "red text" "$(strip_ansi $'\033[0;31mred text\033[0m')"

assert_eq "strip_ansi: multi-parameter SGR (38;5;N) removed" \
    "deep red" "$(strip_ansi $'\033[38;5;196mdeep red\033[0m')"

assert_eq "strip_ansi: bracket text without an escape prefix is left alone" \
    "[0;31m not an escape" "$(strip_ansi "[0;31m not an escape")"

# ---------------------------------------------------------------------------
echo "-- suite_count --"

# Built by the real boilerplate, so the Passed:/Failed: labels arrive
# ANSI-coloured exactly as in production — suite_count must strip before the
# awk field match, or every count would come back empty.
FIXTURE_SUMMARY="$(run_real_suite_snippet '
ok "one"
no "two"
')"

assert_eq "suite_count: Total from a coloured summary block" \
    "2" "$(suite_count Total "$FIXTURE_SUMMARY")"

assert_eq "suite_count: Passed from a coloured summary block" \
    "1" "$(suite_count Passed "$FIXTURE_SUMMARY")"

assert_eq "suite_count: Failed from a coloured summary block" \
    "1" "$(suite_count Failed "$FIXTURE_SUMMARY")"

assert_eq "suite_count: first matching summary line wins" \
    "7" "$(suite_count Passed "$(printf '  Passed: 7\n  Passed: 9\n')")"

assert_eq "suite_count: missing summary yields empty string" \
    "" "$(suite_count Passed "no summary in here at all")"

assert_eq "suite_count: empty input yields empty string" \
    "" "$(suite_count Passed "")"

# ---------------------------------------------------------------------------
echo "-- print_failures: real delegated-suite shapes --"

# The fixture itself must be coloured, or the "colour stripped" assertions
# below would pass vacuously.
if [[ "$FIXTURE_STD" == *$'\033['* ]]; then
    ok "fixture built from real printers is genuinely ANSI-coloured"
else
    no "fixture built from real printers is genuinely ANSI-coloured" \
        "raw fixture contains no escape byte — fixture plumbing broken"
fi

OUT_STD="$(print_failures "$FIXTURE_STD")"
assert_eq "print_failures: multi-line no() detail kept, PASS/SKIP/summary excluded" \
    '    FAIL: failing case
          Expected: [foo]
          Got: [bar]' "$OUT_STD"

# Targeted pins over the same fixture, so a regression names what broke.
assert_contains "print_failures: keeps the Got continuation line (repo#817)" \
    "$OUT_STD" "Got: [bar]"

assert_not_contains "print_failures: indented PASS terminates the failure block" \
    "$OUT_STD" "PASS:"

assert_not_contains "print_failures: indented SKIP terminates the failure block" \
    "$OUT_STD" "SKIP:"

if [[ "$OUT_STD" != *"Total:"* && "$OUT_STD" != *"Passed:"* && "$OUT_STD" != *"Failed:"* ]]; then
    ok "print_failures: summary block (Total:/Passed:/Failed:) not swallowed into failure text"
else
    no "print_failures: summary block (Total:/Passed:/Failed:) not swallowed into failure text" \
        "got: $OUT_STD"
fi

if [[ "$OUT_STD" != *$'\033['* ]]; then
    ok "print_failures: ANSI colour stripped from failure diagnostics"
else
    no "print_failures: ANSI colour stripped from failure diagnostics" "escape byte present"
fi

OUT_GUARD="$(print_failures "$FIXTURE_GUARD")"
assert_eq "print_failures: guard-style Got: continuation block kept intact" \
    '    FAIL: guard description
         Command: rm -rf /tmp/x (env: none, cwd: /repo)
         Expected: deny
         Got: {"hookSpecificOutput":"deny"}' "$OUT_GUARD"

OUT_SINGLE="$(print_failures "$FIXTURE_SINGLE")"
assert_eq "print_failures: single-line FAIL with no continuation" \
    '    FAIL: single-line failure' "$OUT_SINGLE"

# ---------------------------------------------------------------------------
echo "-- print_failures: no-FAIL fallback and edges --"

OUT_TAIL="$(print_failures "$FIXTURE_TAIL")"
assert_eq "print_failures: no FAIL anywhere falls back to indented tail" \
    '    suite header line
      PASS: only passing case
    =========================================
      Total:  1
      Passed: 1
      Failed: 0
    =========================================' "$OUT_TAIL"

# The fallback is bounded at 30 lines: a 35-line no-FAIL suite shows only its
# last 30 lines, each 4-space indented.
TAIL_INPUT="$(for i in $(seq 1 35); do printf 'line %02d\n' "$i"; done)"
OUT_TAIL30="$(print_failures "$TAIL_INPUT")"
assert_eq "print_failures: tail fallback keeps at most 30 lines (of 35)" \
    "30" "$(printf '%s\n' "$OUT_TAIL30" | wc -l | tr -d ' ')"
assert_eq "print_failures: tail fallback starts at the 6th input line" \
    "    line 06" "$(printf '%s\n' "$OUT_TAIL30" | head -1)"
assert_eq "print_failures: tail fallback ends at the last input line" \
    "    line 35" "$(printf '%s\n' "$OUT_TAIL30" | tail -1)"

OUT_LAST="$(print_failures "$FIXTURE_LASTLINE")"
assert_eq "print_failures: FAIL as the last line (no terminator) still rendered" \
    '    FAIL: trailing failure
            continuation detail' "$OUT_LAST"

OUT_EMPTY="$(print_failures "")"
if [[ -z "${OUT_EMPTY//[[:space:]]/}" ]]; then
    ok "print_failures: empty suite output degrades to (whitespace-only) tail fallback"
else
    no "print_failures: empty suite output degrades to (whitespace-only) tail fallback" \
        "unexpected content: $OUT_EMPTY"
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
