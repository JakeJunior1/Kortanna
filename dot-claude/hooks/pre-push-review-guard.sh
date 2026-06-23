#!/usr/bin/env bash
# Global PreToolUse(Bash) guard: enforce a separate-agent REVIEW before a direct
# push to the default branch (main/master). The trunk-protecting sibling of the
# PreCompact /wrap gate. Decisions:
#
#   • not a `git push` ............................ silent pass (exit 0) — instant fast path
#   • push, but NOT on the default branch ......... silent pass (feature branch → the PR
#                                                   is the review point; nothing to gate)
#   • push ON the default branch, FRESH gate ...... consume the gate, AUTO-APPROVE — the
#                                                   review already ran, so skip the prompt
#   • push ON the default branch, no/stale gate ... DENY; the reason (shown to Claude)
#                                                   tells it to review first, then retry
#
# Gate = $REPO/.git/.review-ready : per-repo (a review in repo A never unlocks repo B),
# under .git/ so it is never committed, consume-once, must be < 30 min old. It is dropped
# by /ship (or an explicit `touch` after a review). FAIL-OPEN by construction: on ANY
# error or unknown state we exit 0 (defer to the normal permission flow) — a bug in this
# script can never lock pushes out, it just falls back to the usual confirmation.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0                       # no jq → can't parse input → defer

input="$(cat 2>/dev/null || true)"
cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null || true)"

# Fast path: only gate an actual `git push` (also `git -C <path> push`, `git -c k=v push`).
# Anything else (the 99% of Bash calls) falls straight through with no git work.
printf '%s' "$cmd" \
  | grep -Eq 'git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)' \
  || exit 0

# Resolve the repo from the push's ACTUAL working directory — NOT CLAUDE_PROJECT_DIR,
# which always points at the MAIN checkout (on the default branch). A feature-branch push
# from a gitignored branches/<task>/ worktree must read the WORKTREE's branch (→ defer to
# its PR), not main's (→ a false trunk-gate that blocks every worktree push). Signals,
# best first: an explicit `git -C <path>`, else the hook's cwd (tracks the worker's
# worktree), else CLAUDE_PROJECT_DIR/PWD. Worst case = the old behavior (fail toward gating).
cwd="$(printf '%s' "$input" | "$JQ" -r '.cwd // empty' 2>/dev/null || true)"
base="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"
gitC="$(printf '%s' "$cmd" | grep -oE '(^|[[:space:]])-C[[:space:]]+[^[:space:]]+' | tail -1 | sed -E 's/.*-C[[:space:]]+//; s/^"//; s/"$//')"
case "${gitC:-}" in
  "") REPO="$base" ;;
  /*) REPO="$gitC" ;;
  *)  REPO="$base/$gitC" ;;
esac
TOP="$(cd "$REPO" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$TOP" ] || exit 0                       # unresolvable repo → defer

cur="$(git -C "$TOP" branch --show-current 2>/dev/null || true)"
def="$(git -C "$TOP" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')"
if [ -z "$def" ]; then                        # no origin/HEAD → fall back to a canonical trunk
  if   git -C "$TOP" show-ref --verify --quiet refs/heads/main;   then def="main"
  elif git -C "$TOP" show-ref --verify --quiet refs/heads/master; then def="master"
  fi
fi

# Only gate a push made WHILE ON the default branch (direct-to-trunk). Detached HEAD or a
# feature branch → defer (the branch's PR is where review happens).
[ -n "$cur" ] && [ -n "$def" ] && [ "$cur" = "$def" ] || exit 0

deny()  { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }
allow() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:$r}}'; }

# Docs-only exemption: a default-branch push has no code-review risk and no public-leak risk when
# (a) the remote is PRIVATE and (b) EVERY file in the pushed range is *.md. Markdown never executes
# as code, and on a private remote nothing can leak to the public — so a planner's brain-docs (and
# any other docs) reach main without the review dance. ALL-OR-NOTHING: any non-.md path (code, or a
# deleted/renamed file surfaced by --no-renames) falls through to the gate, so CODE is still reviewed
# everywhere and PUBLIC repos stay gated on everything (incl. docs). FAIL-SAFE — do NOT exempt (gate
# as usual) if: origin/$def is unresolvable; visibility is anything but PRIVATE (public / internal /
# unknown / no gh); or the gh lookup errors or times out.
if git -C "$TOP" rev-parse --verify --quiet "origin/$def" >/dev/null 2>&1; then
  TMO="$(command -v timeout || command -v gtimeout || true)"
  vis=""
  command -v gh >/dev/null 2>&1 && vis="$(cd "$TOP" && ${TMO:+$TMO 5 }gh repo view --json visibility -q .visibility 2>/dev/null || true)"
  if [ "$vis" = "PRIVATE" ]; then
    changed="$(git -C "$TOP" diff --name-only --no-renames "origin/$def..$def" 2>/dev/null || true)"
    # Defense-in-depth: also reject if any entry is a symlink/gitlink (new mode 120000/160000) — a
    # non-regular file named *.md is not a doc. --raw exposes the new mode that --name-only hides.
    raw="$(git -C "$TOP" diff --raw --no-renames "origin/$def..$def" 2>/dev/null || true)"
    if [ -n "$changed" ] \
       && ! printf '%s\n' "$changed" | grep -qvE '\.md$' \
       && ! printf '%s\n' "$raw" | grep -qE '^:[0-7]{6} (120000|160000) '; then
      allow "Docs-only (*.md) push to a PRIVATE repo's $def — no code review needed."
      exit 0
    fi
  fi
fi

GATE="$TOP/.git/.review-ready"
if [ -f "$GATE" ]; then
  now=$(date +%s)
  mt=$(stat -f %m "$GATE" 2>/dev/null || stat -c %Y "$GATE" 2>/dev/null || echo 0)
  rm -f "$GATE"                               # consume-once, fresh or not
  if [ $((now - mt)) -lt 1800 ]; then
    allow "Review gate satisfied (fresh /ship review) — push to $def approved."
    exit 0
  fi
fi

deny "$(printf '%s' "⛔ Direct push to '$def' blocked — no separate-agent review on record. Good practice = an independent review before code hits the trunk.

SMALL / low-risk diff → light path: spawn an independent review agent on the unpushed diff (git log origin/$def..$def -p), fix what it flags, then:
    touch \"$TOP/.git/.review-ready\"
and push again (this gate auto-approves it).

LARGE / risky (execution, guardrails, money- or data-fidelity, migrations, broad multi-file) → full path: move the work onto a feature branch + open a PR, and let the review land on the PR instead of on $def.

The /ship command picks the right path automatically. (Rationale: ~/.claude/rules/review-before-push.md)")"
exit 0
