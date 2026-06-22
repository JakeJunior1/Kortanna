#!/usr/bin/env bash
# Global PreCompact guard. Mode is passed as $1 by the matcher in
# ~/.claude/settings.json so we never need jq to read the trigger:
#   manual — gate the manual /compact: BLOCK unless a fresh save-gate exists, and
#            hand the user the exact line to paste (/wrap). /wrap does the
#            intelligent save and DROPS the gate file; the next /compact then
#            consumes the gate and proceeds. (Two steps, because a hook can pause
#            compaction but cannot invoke the model — only the user can, by pasting.)
#   auto   — auto-compact: NEVER block; just a mechanical commit/push
#            backstop so an unattended auto-compact can't lose uncommitted code.
# The gate is PER-SESSION + PER-WORKTREE: keyed by CLAUDE_CODE_SESSION_ID (so two sessions
# sharing a checkout never consume each other's gate — no redundant re-wrap) and placed in the
# resolved git dir via --absolute-git-dir (a real writable dir even in a worktree, where
# $TOPLEVEL/.git is a FILE, not a directory). A /wrap in one repo/worktree never unlocks another.
# The legacy per-repo gate is still honored for back-compat with an older /wrap. Never committed.
set -uo pipefail

MODE="${1:-manual}"
REPO="${CLAUDE_PROJECT_DIR:-$PWD}"
TOPLEVEL="$(cd "$REPO" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)"
SID="${CLAUDE_CODE_SESSION_ID:-shared}"
GITDIR="$(cd "$REPO" 2>/dev/null && git rev-parse --absolute-git-dir 2>/dev/null || true)"
GATE=""; [ -n "$GITDIR" ] && GATE="$GITDIR/.precompact-ready-$SID"
GATE_LEGACY=""; [ -n "$TOPLEVEL" ] && GATE_LEGACY="$TOPLEVEL/.git/.precompact-ready"

commit_push() {
  [ -n "$TOPLEVEL" ] || return 0
  cd "$TOPLEVEL" || return 0
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -A
    git commit -q --no-verify -m "wip: pre-compact autosave $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || true
    git push -q 2>/dev/null || true
  fi
}

if [ "$MODE" = "auto" ]; then
  commit_push          # backstop only; do NOT block auto-compact
  exit 0
fi

# manual: consume a FRESH gate (dropped by /wrap, < 30 min old) -> allow; else block.
# Check this session's gate AND the legacy per-repo gate; consume-once whichever exist.
now=$(date +%s); fresh=0
for g in "$GATE" "$GATE_LEGACY"; do
  [ -n "$g" ] && [ -f "$g" ] || continue
  mt=$(stat -f %m "$g" 2>/dev/null || stat -c %Y "$g" 2>/dev/null || echo 0)
  rm -f "$g"                          # consume-once either way
  [ $((now - mt)) -lt 1800 ] && fresh=1
done
[ "$fresh" = 1 ] && exit 0           # a fresh save exists -> ALLOW compaction

# No fresh gate -> BLOCK with the exact paste line. printf %s keeps the \n literal
# (two chars) so the emitted reason string is valid JSON, not raw newlines.
reason='⛔ Pre-compact save not done yet.\n\nPaste this, let it finish, then run /compact again:\n\n    /wrap\n\n(/wrap = I read this session, then update the repo CONTEXT.md / planning / roadmap / memories as needed, commit + push, and clear this gate. Auto-compact is NOT gated, only manual /compact.)'
printf '{"decision":"block","reason":"%s"}\n' "$reason"
exit 0
