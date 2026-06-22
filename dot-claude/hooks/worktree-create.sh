#!/usr/bin/env bash
# WorktreeCreate hook — redirect Claude Code's native "worktree" toggle into our convention:
#   <repo-root>/branches/<name>/   (gitignored per-task worktree, kept inside the project)
# instead of the default .claude/worktrees/<name>. This converges the native toggle with the
# Van Clief root=main + branches/<task> model (VAN-CLIEF §9) — a worker session toggles
# worktree ON and lands exactly where the methodology says it should.
#
# Configuring this hook REPLACES git's default worktree creation, so the hook must create the
# worktree itself (it then appears in `git worktree list`) and echo ITS PATH on stdout — that
# is the only thing Claude reads back. Branch = the (sanitized) worktree name. Any non-zero
# exit makes Claude report "WorktreeCreate hook failed" and abort — fail loudly, never hand
# back a broken path.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || { echo "WorktreeCreate hook: jq not found — skipping (fail-open)" >&2; exit 0; }

input="$(cat 2>/dev/null || true)"
name="$(printf '%s' "$input" | "$JQ" -r '.name // empty' 2>/dev/null || true)"
cwd="$(printf '%s' "$input" | "$JQ" -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$name" ] || { echo "WorktreeCreate hook: no worktree name in payload" >&2; exit 1; }
[ -n "$cwd" ] || cwd="$PWD"

# Sanitize the name into one safe path segment (no spaces, no nested slashes, no oddities).
safe="$(printf '%s' "$name" | tr ' /' '--' | tr -cd 'A-Za-z0-9._-')"
[ -n "$safe" ] || { echo "WorktreeCreate hook: name '$name' sanitized to empty" >&2; exit 1; }

root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] || { echo "WorktreeCreate hook: '$cwd' is not inside a git repository" >&2; exit 1; }

path="$root/branches/$safe"
[ -e "$path" ] && { echo "WorktreeCreate hook: '$path' already exists" >&2; exit 1; }

# Create the worktree on a branch named after it: reuse the branch if it already exists,
# otherwise cut a fresh one from HEAD. All git progress goes to stderr so stdout stays clean.
if git -C "$root" show-ref --verify --quiet "refs/heads/$safe"; then
  git -C "$root" worktree add "$path" "$safe" >&2 || exit 1
else
  git -C "$root" worktree add -b "$safe" "$path" >&2 || exit 1
fi

# The ONLY stdout line: the worktree path Claude should use.
printf '%s\n' "$path"
