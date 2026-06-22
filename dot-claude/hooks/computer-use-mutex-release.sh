#!/usr/bin/env bash
# Stop / SessionEnd hook — release the computer-use mutex the moment THIS session stops driving
# (its turn ends, or the session closes), so the "key" is handed back immediately rather than only
# after the TTL lapses. Only releases a lock THIS session holds (never steals another session's).
# The TTL in computer-use-mutex.sh stays as a crash/abandon safety net. FAIL-OPEN (errors → no-op).
set -uo pipefail
SID="${CLAUDE_CODE_SESSION_ID:-}"
[ -n "$SID" ] || exit 0
LOCK="$HOME/.claude/.locks/computer-use.lock"
[ -f "$LOCK" ] || exit 0
holder="$(sed -n '1p' "$LOCK" 2>/dev/null || true)"
[ "$holder" = "$SID" ] && rm -f "$LOCK" 2>/dev/null
exit 0
