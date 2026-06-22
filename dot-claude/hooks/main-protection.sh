#!/usr/bin/env bash
# Global PreToolUse(Bash) guard: in an ORCHESTRATED project, production CODE reaches `main`
# only via PR merge — never a direct commit. So while ON the default branch, DENY a `git commit`
# whose staged set includes any non-`.md` file. Brain docs (*.md only) are exempt — the planning
# session commits CLAUDE.md / CONTEXT / planning(todo,progress) / memory to main directly.
#
#   • not a `git commit` ........................ pass (exit 0)
#   • repo has no `.orchestrated` marker ........ pass (only opted-in projects are gated)
#   • the very first (scaffold) commit .......... pass (no HEAD yet → bootstrap)
#   • not on the default branch ................. pass (feature branch → merges in via PR)
#   • staged set is .md-only .................... pass (brain-doc commit)
#   • staged set has any non-.md ................ DENY with reason
#
# FAIL-OPEN: any error / unparseable / unresolvable → exit 0 (defer to the normal flow). A bug
# here can never block a commit; it just falls back to the usual confirmation.
# Limitation: the repo is resolved from CLAUDE_PROJECT_DIR/cwd, not the command's `-C <path>`; a
# `git -C /other commit` is judged by THIS repo's staged set (rare; fails toward a re-issuable deny).
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0
deny() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }

input="$(cat 2>/dev/null || true)"
cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null || true)"

# Only gate an actual `git commit` (also `git -C <path> commit`, `git -c k=v commit`).
printf '%s' "$cmd" \
  | grep -Eq 'git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' \
  || exit 0

REPO="${CLAUDE_PROJECT_DIR:-$PWD}"
TOP="$(cd "$REPO" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$TOP" ] || exit 0

# Opt-in: only orchestrated projects (merge-only main) are gated.
[ -f "$TOP/.orchestrated" ] || exit 0

# The very first commit on a fresh repo has no HEAD yet — that's the scaffold; allow it.
git -C "$TOP" rev-parse --verify HEAD >/dev/null 2>&1 || exit 0

# Only on the default branch (feature branches merge in via PR — nothing to gate).
cur="$(git -C "$TOP" branch --show-current 2>/dev/null || true)"
def="$(git -C "$TOP" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')"
if [ -z "$def" ]; then
  if   git -C "$TOP" show-ref --verify --quiet refs/heads/main;   then def="main"
  elif git -C "$TOP" show-ref --verify --quiet refs/heads/master; then def="master"
  fi
fi
[ -n "$cur" ] && [ -n "$def" ] && [ "$cur" = "$def" ] || exit 0

# What's staged? Nothing staged → defer (a plain `git commit` may just open an editor).
staged="$(git -C "$TOP" diff --cached --name-only 2>/dev/null || true)"
[ -n "$staged" ] || exit 0

# Any staged path that is NOT a .md file → this commit carries code/assets → deny.
nonmd="$(printf '%s\n' "$staged" | grep -ivE '\.md$' || true)"
[ -n "$nonmd" ] || exit 0   # all .md → brain-doc commit → allow

list="$(printf '%s\n' "$nonmd" | sed 's/^/    /')"
deny "⛔ Direct CODE commit to '$def' blocked — this project is orchestrated (.orchestrated):
production code reaches main ONLY via PR merge, never a direct commit.

Non-.md files staged:
$list

Move the work onto a per-task branch (branches/<task>/), open a PR, and let it merge into $def.
Brain docs (*.md only) may be committed to $def directly. To override a one-off, unstage the code."
exit 0
