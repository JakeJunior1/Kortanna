#!/usr/bin/env bash
# Global PreToolUse(Edit|Write|MultiEdit|NotebookEdit) guard: in an ORCHESTRATED project the
# planning QUEUE BOARD — `planning/todo.md` + `planning/progress.md` — is SINGLE-WRITER = the
# planner. A worker session must NEVER edit the queue files: it reads its assignment from
# progress.md, builds in its branches/<task>/ worktree, and reports status/done in its own
# output. The planner moves tasks todo→progress at dispatch and progress→completed on merge.
# This stops two sessions racing the board (VAN-CLIEF §9).
#
#   • target is not planning/(todo|progress).md ..... pass (incl. *.md.template, other files)
#   • session root has no `.orchestrated` marker .... pass (only orchestrated projects gated)
#   • session IS the planner (`.planner` marker) .... pass (the planner is the single writer)
#   • otherwise (a worker editing the board) ........ DENY
#
# FAIL-OPEN: any error / unparseable / unresolvable → exit 0 (never blocks; defers to normal flow).
# Limitation (shared with main-protection): repo + role are resolved from CLAUDE_PROJECT_DIR/cwd,
# not the file's `-C` path — a non-orchestrated session editing another repo's board isn't caught.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null || true)"
case "$tool" in Edit|Write|MultiEdit|NotebookEdit) ;; *) exit 0 ;; esac

fp="$(printf '%s' "$input" | "$JQ" -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)"
[ -n "$fp" ] || exit 0
# Only the queue board: todo.md / progress.md under a planning/ dir. `.md.template` won't match ($ anchor).
printf '%s' "$fp" | grep -qE '/planning/(todo|progress)\.md$' || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
TOP="$(cd "$ROOT" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$TOP" ] || exit 0
[ -f "$TOP/.orchestrated" ] || exit 0     # only orchestrated projects are gated
[ -f "$ROOT/.planner" ] && exit 0         # the planner IS the single writer → allow

deny() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }
deny "⛔ planning/*.md is SINGLE-WRITER — only the PLANNER edits the queue board ('$fp').

A worker never moves or claims tasks. Read your assignment from planning/progress.md, build in your
branches/<task>/ worktree, and report status/done in your final output (or message the planner if it's live).
The planner moves tasks todo→progress at dispatch and progress→completed on merge (VAN-CLIEF §9)."
exit 0
