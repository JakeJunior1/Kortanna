#!/usr/bin/env bash
# Planner worker-comms monitor (companion, NOT a hook): tails worker SESSION TRANSCRIPTS (.jsonl)
# and surfaces ONLY genuine worker→planner handoff signals, so the planner notices "ready to
# verify / blocked / @planner" without polling each session. Complements merge-watch.sh — that
# watches merged PRs + planning/status/*.md; this watches the live transcript stream.
#
# Run per planner session, in the background:
#   worker-monitor.sh <worker1.jsonl> <worker2.jsonl> ...
#   (transcripts live at ~/.claude/projects/<encoded-cwd>/<session-id>.jsonl)
#
# RESUME: background monitors do NOT survive a Claude Desktop restart or /compact — the planner
# RELAUNCHES this on resume (it's part of the planner's resume-ops checklist). Needs `jq`.
#
# Robustness notes (this is the PROVEN-robust shape; the fragile version kept dying / tripping the
# harness "too many events → auto-stop"):
#   • ONE `tail -F | while read` pipeline — never backgrounded per-file `tail -F` + `wait` (one
#     sub-tail exiting would kill the whole monitor).
#   • Match ONLY assistant *text* (skip thinking blocks + tool I/O) → kills false positives.
#   • A TIGHT handoff filter — a loose one ("ready to verify", "blocked on") floods events.
#   • No `.{0,N}` bounded repetition in the regex — it blows ugrep's complexity limit.
set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "worker-monitor: jq not found" >&2; exit 1; }
[ "$#" -ge 1 ] || { echo "usage: worker-monitor.sh <transcript.jsonl> [more.jsonl ...]" >&2; exit 1; }

# Only genuine worker→planner handoffs. Keep it tight (and free of `.{0,N}`).
FILTER='@planner|planner:|ready to (land|merge)|BLOCKER|blocked:|ping planner'

echo "worker-monitor armed — $# transcript(s); filter: $FILTER"

# tail -F follows by name (survives rotation/recreation) and prints a `==> FILE <==` header when its
# output switches files — track that header to attribute each line to its worker. -n0 = only NEW lines
# (a handoff emitted BEFORE (re)launch isn't replayed — merge-watch + planning/status/*.md cover durable signals).
cur=""; [ "$#" -eq 1 ] && cur="$1"   # one file → tail prints no ==> header, so attribute directly
tail -F -n0 "$@" 2>/dev/null | while IFS= read -r line; do
  case "$line" in
    "==> "*" <==") cur="${line#==> }"; cur="${cur% <==}"; continue ;;
    "") continue ;;
  esac
  # Each transcript line is one JSON event. Keep ONLY assistant text (drop thinking + tool I/O).
  text="$(printf '%s' "$line" | jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' 2>/dev/null || true)"
  [ -n "$text" ] || continue
  printf '%s\n' "$text" | grep -niE "$FILTER" 2>/dev/null | while IFS= read -r hit; do
    echo "HANDOFF [${cur##*/}] $hit"
  done
done
