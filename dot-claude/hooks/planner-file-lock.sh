#!/usr/bin/env bash
# Global PreToolUse(Edit|Write|MultiEdit|NotebookEdit|Bash) guard for the PLANNING session only. The planner
# coordinates (writes the plan, CLAUDE.md / CONTEXT / planning(todo,progress) / memory) but never
# writes or runs CODE — that's the workers' job. Active ONLY when the session root carries a
# `.planner` marker; every other session (workers, the guide repo, your projects, normal work)
# is untouched.
#
#   Edit/Write on a non-.md path .......... DENY (planner edits docs only)
#   Bash that is a build/run command ...... DENY (npm/node/python/cargo/make/pytest/docker/…)
#   everything else (.md edits, git, ls/grep/cat/mkdir/cp) ... pass
#
# FAIL-OPEN: any error → exit 0.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -f "$ROOT/.planner" ] || exit 0     # only a session explicitly marked as the planner

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null || true)"
deny() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    fp="$(printf '%s' "$input" | "$JQ" -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)"
    [ -n "$fp" ] || exit 0
    printf '%s' "$fp" | grep -iqE '\.md$' && exit 0    # markdown = the planner's brain docs → allow
    deny "🧭 Planning session is docs-only — editing non-.md files is the workers' job ('$fp').

The planner writes the plan, CLAUDE.md / CONTEXT.md, planning/todo.md + progress.md, and memory.
To build code: add a task to planning/todo.md and dispatch a worker session (it works in branches/<task>/)."
    exit 0
    ;;
  Bash)
    cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null || true)"
    [ -n "$cmd" ] || exit 0
    # First meaningful token (skip leading VAR=val env assignments).
    first="$(printf '%s' "$cmd" | awk '{for(i=1;i<=NF;i++){if($i !~ /=/){print $i; exit}}}')"
    base="$(basename "$first" 2>/dev/null || printf '%s' "$first")"
    case "$base" in
      npm|npx|yarn|pnpm|bun|node|deno|ts-node|tsx|python|python3|pip|pip3|pytest|ruby|rails|rake|cargo|go|make|gradle|mvn|dotnet|docker|docker-compose|vite|next|webpack)
        deny "🧭 Planning session: no builds/runs. '$base' is execution work — add a task to planning/todo.md and dispatch a worker. (The planner coordinates; workers build.)"
        exit 0
        ;;
    esac
    exit 0
    ;;
  *) exit 0 ;;
esac
