#!/usr/bin/env bash
# monitor-reminder.sh — keeps a planner/reviewer/verifier session's background monitors alive across the
# gaps where they silently die: a /compact, a Claude restart, or an external kill (VAN-CLIEF §9). It does
# NOT start them — a hook runs in a throwaway subprocess, so anything it backgrounds is detached and its
# output never reaches the session; the monitors MUST run via the session's OWN Bash tool so their stream
# lands in context. So this REMINDS, with the exact relaunch commands.
#
# Two modes, wired to two events:
#   start  (SessionStart: startup|resume|compact) — ALWAYS remind: right after a session (re)starts the
#          monitors are gone, so list them unconditionally. Concurrency-immune (no process scan).
#   check  (UserPromptSubmit: every turn) — liveness: pgrep each expected monitor and remind ONLY for the
#          ones not running (silent when healthy). Catches a MID-SESSION kill that SessionStart never sees.
#
# Role from the session-root marker:
#   .planner  (at the dev-root — no worker shares that root) → merge-watch.sh + worker-monitor.sh
#   .reviewer (at the PROJECT root — workers share it!) → SESSION-BOUND: only the session whose id is in
#             the marker is the reviewer → reviewer-watch.sh
#   .verifier (at the PROJECT root — workers + reviewer share it!) → SESSION-BOUND likewise → verifier-watch.sh
#   neither → silent (zero noise for normal/worker sessions).
# NOTE the session-bound markers (.reviewer/.verifier) can BOTH exist at one root (a reviewer session and
# a verifier session bound there). They are checked INDEPENDENTLY (not elif): a non-matching .reviewer
# must not shadow a matching .verifier. The one whose id == THIS session wins.
# Output to stdout = context injected for the agent to act on.
#
# LIVENESS SCOPE (check mode): pgrep is GLOBAL by monitor type, not repo-scoped. With one planner per
# project this is exact; if TWO projects' orchestrations run AT THE SAME TIME it can under-nag (a type
# alive in project B masks its death in project A) — which degrades to the pre-hook manual behavior,
# never worse. A project-scoped registry is the upgrade if concurrent orchestrations become routine.
#
# FAIL-OPEN: any error → exit 0 (never blocks a turn / session start).
set -uo pipefail

mode="${1:-check}"
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

role=""
if [ -f "$ROOT/.planner" ]; then
  role="planner"
else
  # Session-bound markers sit at the SHARED project root; multiple may exist at once. Match the one whose
  # id == THIS session — check each independently (NOT elif: a non-matching .reviewer must not shadow a
  # matching .verifier). bash-3.2-safe: a plain for over literals, no arrays.
  for m in reviewer verifier; do
    [ -f "$ROOT/.$m" ] || continue
    want="$(head -n1 "$ROOT/.$m" 2>/dev/null | tr -d '[:space:]')"
    if [ -n "$want" ] && [ "$want" = "${CLAUDE_CODE_SESSION_ID:-}" ]; then role="$m"; break; fi
  done
fi
[ -n "$role" ] || exit 0

P_MERGE='  • bash ~/.claude/scripts/merge-watch.sh <your project repo> &   (merged PRs + planning/status/*.md)'
P_WORKER='  • bash ~/.claude/scripts/worker-monitor.sh <worker1.jsonl> [more…] &   (worker @planner handoffs)'
R_WATCH="  • bash ~/.claude/scripts/reviewer-watch.sh \"$ROOT\" &   (needs-review PRs)"
V_WATCH="  • bash ~/.claude/scripts/verifier-watch.sh \"$ROOT\" &   (needs-verify claims)"

if [ "$mode" = "start" ]; then
  echo "[monitor-reminder] $role session (re)started — background monitors do NOT survive a compact/restart,"
  echo "so (re)start them NOW via your OWN Bash tool (a hook can't — its output wouldn't reach you), then"
  echo "re-check every turn:"
  case "$role" in
    planner)  printf '%s\n%s\n' "$P_MERGE" "$P_WORKER" ;;
    reviewer) printf '%s\n' "$R_WATCH" ;;
    verifier) printf '%s\n' "$V_WATCH" ;;
  esac
  exit 0
fi

# mode=check — nag only for monitors not currently running (silent when all up).
nag=""
case "$role" in
  planner)
    pgrep -f 'merge-watch.sh'    >/dev/null 2>&1 || nag="$nag"$'\n'"$P_MERGE"
    pgrep -f 'worker-monitor.sh' >/dev/null 2>&1 || nag="$nag"$'\n'"$P_WORKER"
    ;;
  reviewer)
    pgrep -f 'reviewer-watch.sh' >/dev/null 2>&1 || nag="$nag"$'\n'"$R_WATCH"
    ;;
  verifier)
    pgrep -f 'verifier-watch.sh' >/dev/null 2>&1 || nag="$nag"$'\n'"$V_WATCH"
    ;;
esac
[ -n "$nag" ] || exit 0
printf '%s\n' "[monitor-reminder] ⚠️ $role monitor(s) NOT running — restart via your Bash tool now:$nag"
exit 0
