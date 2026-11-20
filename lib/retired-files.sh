#!/usr/bin/env bash
# retired-files.sh — installed paths this tool once shipped under fixed names and
# no longer does. Shared by install.sh and scripts/repo/resync-installed.sh so a
# reinstall and a resync retire exactly the same set (repo#765).
#
# WHY A LIST. resync-installed.sh "never uninstalls": an installed file with no
# source counterpart is only reported as left alone. That is right for a
# consumer-local file, but wrong for a file THIS tool installed under a fixed
# name — leaving it would keep a dead command on every consumer forever. These
# are names we own, so removing them by name is safe.
#
# Entries are target-relative. A path pinned in the consumer's resync-ignore
# (C10) is theirs and is never removed.

# /repo:remote was removed in repo#765.
RETIRED_CODEX_REFERENCE=".agents/skills/repo/references/remote.md"
RETIRED_CODEX_SKILL_DIR=".agents/skills/repo-remote"
RETIRED_INSTALLED_FILES=(
  ".claude/commands/repo/remote.md"
  ".claude/skills/repo/scripts/repo-remote.sh"
  "$RETIRED_CODEX_REFERENCE"
)

# Per-command Codex skill directories. Removed only when marker-managed
# (codex_skill_is_managed); an unmarked directory is someone else's.
RETIRED_CODEX_SKILL_DIRS=(
  "$RETIRED_CODEX_SKILL_DIR"
)

# Keep the ownership marker until all other entries are gone. If an extra
# entry cannot be removed, the next run still recognizes the managed skill.
retire_managed_skill_dir() (
  local dir="$1" entry
  if [[ ! -L "$dir" ]]; then
    shopt -s dotglob nullglob
    for entry in "$dir"/*; do
      [[ "$entry" == "$dir/SKILL.md" ]] && continue
      rm -rf -- "$entry" || return 1
    done
  fi
  rm -rf -- "$dir"
)

# retire_installed_files <target> <dry-run:true|false>
# Prints one "<verb>\t<target-relative-path>" line per entry acted on, where verb
# is "would drop", "removed", or "failed". Returns 1 if any removal failed.
# Silent when nothing is present. `rm -f` on a dev symlink removes just the link.
retire_installed_files() {
  local target="$1" dry="$2" rel failed=0
  for rel in "${RETIRED_INSTALLED_FILES[@]}"; do
    [[ -e "$target/$rel" || -L "$target/$rel" ]] || continue
    resync_ignore_is_pinned "$rel" && continue
    if [[ "$dry" == true ]]; then
      printf 'would drop\t%s\n' "$rel"
    elif rm -f -- "$target/$rel"; then
      printf 'removed\t%s\n' "$rel"
    else
      printf 'failed\t%s\n' "$rel"
      failed=1
    fi
  done
  for rel in "${RETIRED_CODEX_SKILL_DIRS[@]}"; do
    [[ -d "$target/$rel" ]] || continue
    codex_skill_is_managed "$target/$rel/SKILL.md" || continue
    resync_ignore_is_pinned "$rel/SKILL.md" && continue
    if [[ "$dry" == true ]]; then
      printf 'would drop\t%s/\n' "$rel"
    elif retire_managed_skill_dir "$target/$rel"; then
      printf 'removed\t%s/\n' "$rel"
    else
      printf 'failed\t%s/\n' "$rel"
      failed=1
    fi
  done
  return "$failed"
}
