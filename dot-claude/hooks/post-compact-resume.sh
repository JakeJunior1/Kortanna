#!/usr/bin/env bash
# SessionStart(compact) hook — after a /compact, surface THIS session's unfinished work so it
# resumes without a re-prompt. Walks the Van Clief layer chain (routes live in docs, not hardcoded):
# CLAUDE.md (L1 gate) → CONTEXT.md (L2 root) → planning/progress.md (in-progress board) +
# planning/todo.md (pending queue). Tasks move between files as state changes (VAN-CLIEF §9):
# todo.md (⏳ pending, each tagged `owner: <handle> · session: <uuid>`) → progress.md (🔄) → memory/completed-tasks.md (✅).
#
# RESUME IS ASSIGNMENT-BASED, not greedy: a session resumes ONLY the task assigned to IT — its
# in-progress entry in progress.md, else its session-matched next ⏳ in todo.md. If nothing is
# assigned to this session, it STOPS and asks (never grabs unassigned / another session's task).
# The hook only SURFACES context (incl. this session's id); the assistant matches its id to `session:` + decides.
# No-op outside a repo with such a queue. Fails open (never blocks).
#
# Pairs with the precompact `/wrap` gate: wrap → /compact → (this) resume YOUR task.
set -uo pipefail

# SessionStart stdin carries JSON (session_id/cwd/source). Best-effort grab the session id so the
# assistant can match this session's id against each task's `session:` field; absence is harmless.
input="$(cat 2>/dev/null || true)"
sid="$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
layer1="$root/CLAUDE.md"
[ -f "$layer1" ] || exit 0   # Layer 1 is the entry gate — not this kind of repo otherwise

# Walk the chain to find the queue files: CLAUDE.md → CONTEXT.md (root) → planning/{progress,todo}.md.
# Pull each "next" path from the layer above; fall back to the conventional path if a pointer is absent,
# so moving a queue later = update a doc pointer, NOT this hook.
ctx_rel=$(grep -oE 'CONTEXT\.md' "$layer1" | head -1)
layer2="$root/${ctx_rel:-CONTEXT.md}"
todo_rel=$([ -f "$layer2" ] && grep -oE 'planning/todo\.md' "$layer2" | head -1)
prog_rel=$([ -f "$layer2" ] && grep -oE 'planning/progress\.md' "$layer2" | head -1)
todo="$root/${todo_rel:-planning/todo.md}"
prog="$root/${prog_rel:-planning/progress.md}"
[ -f "$todo" ] || todo="$layer1"   # last resort: an inline queue still living in CLAUDE.md

# A task line = a list item (bullet `-`/`*` OR numbered `N.`) whose flag comes RIGHT AFTER the marker.
# Matches both `- ⏳ **#N` and `N. ⏳ …`; skips `> …` blockquote legends AND indented sub-bullets like
# `  - status: ⏳ blocked` (the flag there follows text, not the marker, so it isn't a task line).
flag_re='^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]+(🔄|⏳)'
inprog=$([ -f "$prog" ] && awk -v re="$flag_re" '$0 ~ re' "$prog" 2>/dev/null || true)
pending=$([ -f "$todo" ] && awk -v re="$flag_re" '$0 ~ re' "$todo" 2>/dev/null || true)

sid_line=""
[ -n "$sid" ] && sid_line="This session's id: $sid (claim the task whose \`session:\` matches this id; \`owner\` is its worker handle). "

if [ -z "$inprog" ] && [ -z "$pending" ]; then
cat <<EOF
[post-compact resume] Compaction complete. No open tasks in this repo's queue (planning/progress.md + planning/todo.md, routed via CLAUDE.md → CONTEXT.md). ${sid_line}Don't sit idle — ask the operator what they'd like to do next, or recommend a next step from the open threads.
EOF
exit 0
fi

# Narrow the board to THIS session: a worker should see only its OWN assigned work, not every other
# worker's tasks (keeps the resume injection small). Keep only lines whose `session:` tag contains this
# session's id. FAIL-SAFE: if nothing matches (no sid, or the planner put `session:` on a sub-line),
# fall back to the full board so a worker never loses sight of its task.
scope_note="resume yours if its \`session:\` matches this id"
if [ -n "$sid" ]; then
  inprog_mine=$(printf '%s\n' "$inprog" | grep -F "$sid" 2>/dev/null || true)
  pending_mine=$(printf '%s\n' "$pending" | grep -F "$sid" 2>/dev/null || true)
  if [ -n "$inprog_mine" ] || [ -n "$pending_mine" ]; then
    inprog="$inprog_mine"; pending="$pending_mine"
    scope_note="filtered to THIS session's id — your assigned work only"
  fi
fi

cat <<EOF
[post-compact resume] Compaction complete. ${sid_line}Resume is ASSIGNMENT-BASED — resume ONLY the task assigned to THIS session; if none is yours, STOP and ask the operator (never grab unassigned or another session's task).

IN PROGRESS (planning/progress.md — ${scope_note}):
${inprog:-  (none)}

PENDING (planning/todo.md — start your \`session:\`-matched next item only):
${pending:-  (none)}

Follow this repo's build/verify flow (CLAUDE.md → CONTEXT.md): work in your branches/<task>/ worktree → independent review (a fresh-context agent, per review-before-push) → verify → PR/merge → /wrap before /compact. READ your task's full detail in the queue file first; if its scope is ambiguous, confirm with the operator before building.
EOF
exit 0
