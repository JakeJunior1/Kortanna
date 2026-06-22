#!/usr/bin/env bash
# WorktreeRemove hook — mirror of worktree-create.sh, so the lifecycle stays consistent when
# Claude tears down a worktree it created under <repo-root>/branches/<name>/. The payload
# carries worktree_path. We run `git worktree remove` from the MAIN worktree (you cannot
# remove the one you are standing in) WITHOUT --force, so a worktree with uncommitted changes
# is refused (non-zero) and kept rather than silently destroyed. Fail-safe by design: if removal
# can't proceed cleanly, leaving the branches/<name> worktree in place matches our convention
# (per-task branches persist until merged).
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || { echo "WorktreeRemove hook: jq not found — skipping (fail-open)" >&2; exit 0; }

input="$(cat 2>/dev/null || true)"
path="$(printf '%s' "$input" | "$JQ" -r '.worktree_path // empty' 2>/dev/null || true)"
[ -n "$path" ] || { echo "WorktreeRemove hook: no worktree_path in payload" >&2; exit 1; }

# Resolve the main worktree (first entry in the porcelain list) and remove the target from there.
main_wt="$(git -C "$path" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}' || true)"
git -C "${main_wt:-$path}" worktree remove "$path" >&2 || exit 1
