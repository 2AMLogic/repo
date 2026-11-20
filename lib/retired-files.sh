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

report_pending_retirement() {
  local backup="$1" rel="$2" recorded legacy
  if [[ -e "$backup" || -L "$backup" ]]; then
    if [[ -d "$backup" && ! -L "$backup" && -O "$backup" &&
          -f "$backup/target" && ! -L "$backup/target" ]] &&
       IFS= read -r recorded <"$backup/target" && [[ "$recorded" == "$rel" ]]; then
      printf 'Pending retirement for %s. Inspect the recovery state at %s before retrying.\n' "$rel" "$backup" >&2
    else
      printf 'Cannot verify retirement recovery for %s at %s. Inspect it before retrying.\n' "$rel" "$backup" >&2
    fi
    return 0
  fi

  # Older staging directories used six random characters and saved no target.
  # Report an owned marker backup, but never infer what directory it authorizes.
  for legacy in "${backup%/*}"/.repo-skills-retirement.??????; do
    [[ -d "$legacy" && ! -L "$legacy" ]] || continue
    [[ -L "$legacy/SKILL.md" ]] || codex_skill_is_managed "$legacy/SKILL.md" || continue
    printf 'Unbound retirement recovery at %s. Inspect it before retrying.\n' "$legacy" >&2
    return 0
  done
  return 1
}

clear_retirement_backup() {
  local backup="$1"
  [[ -d "$backup" && ! -L "$backup" ]] &&
    rm -f -- "$backup/SKILL.md" "$backup/target" && rmdir -- "$backup"
}

# Keep the ownership marker through child cleanup and restore it if the final
# directory removal fails. Development symlinks are removed as links.
retire_managed_skill_dir() (
  local dir="$1" rel="$2" marker_backup="$3" entry
  if [[ -L "$dir" ]]; then
    rm -f -- "$dir"
    return
  fi
  cd -P -- "$dir" || return 1
  [[ . -ef "$dir" && ! -L "$dir" ]] && codex_skill_is_managed ./SKILL.md || return 1

  # Reserve the exact target's private staging path before changing the skill.
  # A retry can identify an unfinished operation without assuming a replacement
  # directory belongs to the tool.
  mkdir -m 700 -- "$marker_backup" || return 1
  if ! printf '%s\n' "$rel" >"$marker_backup/target"; then
    clear_retirement_backup "$marker_backup"
    return 1
  fi

  shopt -s dotglob nullglob
  for entry in ./*; do
    [[ "$entry" == ./SKILL.md ]] && continue
    if ! rm -rf -- "$entry"; then
      clear_retirement_backup "$marker_backup"
      return 1
    fi
  done

  if ! mv -- ./SKILL.md "$marker_backup/"; then
    if [[ ! -e "$marker_backup/SKILL.md" && ! -L "$marker_backup/SKILL.md" ]]; then
      clear_retirement_backup "$marker_backup"
    fi
    return 1
  fi

  if [[ . -ef "$dir" && ! -L "$dir" ]] && rmdir -- "$dir"; then
    clear_retirement_backup "$marker_backup"
    return
  fi

  # The working directory pins the original directory even if its old name
  # now resolves elsewhere. Never put the ownership marker in a replacement.
  if [[ . -ef "$dir" && ! -L "$dir" ]] &&
     mv -n -- "$marker_backup/SKILL.md" ./ && [[ . -ef "$dir" && ! -L "$dir" ]] &&
     [[ ! -e "$marker_backup/SKILL.md" && ! -L "$marker_backup/SKILL.md" ]]; then
    clear_retirement_backup "$marker_backup"
  else
    printf 'Could not restore the retirement marker for %s at its expected path. Inspect %s.\n' "$dir" "$marker_backup" >&2
  fi
  return 1
)

# retire_installed_files <target> <dry-run:true|false>
# Prints one "<verb>\t<target-relative-path>" line per entry acted on, where verb
# is "would drop", "removed", or "failed". Returns 1 if any removal failed.
# Silent when nothing is present. `rm -f` on a dev symlink removes just the link.
retire_installed_files() {
  local target="$1" dry="$2" rel dir backup failed=0
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
    dir="$target/$rel"
    backup="${dir%/*}/.repo-skills-retirement.${dir##*/}"
    if report_pending_retirement "$backup" "$rel"; then
      printf 'failed\t%s/\n' "$rel"
      failed=1
      continue
    fi
    [[ -d "$dir" ]] || continue
    codex_skill_is_managed "$dir/SKILL.md" || continue
    resync_ignore_is_pinned "$rel/SKILL.md" && continue
    if [[ "$dry" == true ]]; then
      printf 'would drop\t%s/\n' "$rel"
    elif retire_managed_skill_dir "$dir" "$rel" "$backup"; then
      printf 'removed\t%s/\n' "$rel"
    else
      printf 'failed\t%s/\n' "$rel"
      failed=1
    fi
  done
  return "$failed"
}
