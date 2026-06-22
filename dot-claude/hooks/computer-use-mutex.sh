#!/usr/bin/env bash
# Global PreToolUse(mcp__computer-use__*) guard: only ONE session may drive the physical
# mouse/keyboard/screen at a time. A session "holds" the screen by taking a mutating action; it
# releases the key the instant its turn ends (the Stop/SessionEnd hook computer-use-mutex-release.sh),
# and the TTL below is just a crash/abandon safety net (auto-expire after idle). Another session's
# mutating action is DENIED while the lock is held fresh by someone else — it should use Preview
# (mcp__Claude_Preview__*) or wait.
#
#   read-only actions (screenshot, cursor_position, list_granted_applications, read_clipboard, zoom) ... always pass
#   lock free / held by me / stale (> TTL) ... (re)acquire, pass
#   lock held fresh by another session ....... DENY (point to Preview / wait)
#
# Keyed by CLAUDE_CODE_SESSION_ID. Solo session always acquires → never self-blocks.
# FAIL-OPEN: any error → exit 0.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0

SID="${CLAUDE_CODE_SESSION_ID:-}"
[ -n "$SID" ] || exit 0               # no session id → can't arbitrate → defer

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null || true)"
[ -n "$tool" ] || exit 0           # unparseable tool name → fail-open (allow)

# Read-only computer-use actions don't contend for control — let them through.
case "$tool" in
  *screenshot|*cursor_position|*list_granted_applications|*read_clipboard|*zoom) exit 0 ;;
esac

TTL=90
LOCK_DIR="$HOME/.claude/.locks"
LOCK="$LOCK_DIR/computer-use.lock"
mkdir -p "$LOCK_DIR" 2>/dev/null || exit 0
now="$(date +%s)"

holder=""; ts=0
if [ -f "$LOCK" ]; then
  holder="$(sed -n '1p' "$LOCK" 2>/dev/null || true)"
  ts="$(sed -n '2p' "$LOCK" 2>/dev/null || echo 0)"
  printf '%s' "$ts" | grep -qE '^[0-9]+$' || ts=0
fi

# Held fresh by ANOTHER session → deny.
if [ -n "$holder" ] && [ "$holder" != "$SID" ] && [ $((now - ts)) -lt "$TTL" ]; then
  "$JQ" -n --arg r "🖱️ Another session is driving the screen right now (computer-use lock held by another session, active < ${TTL}s ago). Only one agent can control the physical mouse/keyboard at a time.

Prefer Preview (mcp__Claude_Preview__*) to check a web UI without the shared screen, or wait a few seconds and retry — the lock frees once the other session goes idle." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
fi

# Free / mine / stale → (re)acquire and allow.
printf '%s\n%s\n' "$SID" "$now" > "$LOCK" 2>/dev/null || true
exit 0
