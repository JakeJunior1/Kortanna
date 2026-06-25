#!/usr/bin/env bash
# Global PreToolUse(Edit|Write|NotebookEdit|Bash) guard for the REVIEWER session only. The reviewer
# reviews — it edits NO project code and NEVER merges (the worker merges in its own session). Active
# ONLY when the session root carries a `.reviewer` marker; every other session is untouched.
#
#   Edit/Write to anything except review/** or planning/status/reviewer.md ... DENY (review-only)
#   Bash `gh pr merge` ....................................................... DENY (the worker merges)
#   everything else (Read/Grep, gh pr view/diff/edit/review, git fetch/worktree, test runs) ... pass
#
# The reviewer's writes are its findings (review/**) and its status line (planning/status/reviewer.md);
# it RUNS tests (read-only execution) — so test/build runners are intentionally NOT gated here.
# FAIL-OPEN: any error → exit 0.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -f "$ROOT/.reviewer" ] || exit 0     # only a session explicitly marked as the reviewer

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null || true)"
deny() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }

case "$tool" in
  Edit|Write|NotebookEdit)
    fp="$(printf '%s' "$input" | "$JQ" -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)"
    [ -n "$fp" ] || exit 0
    # Reject any traversal outright (a `..` segment could resolve back into code).
    case "$fp" in *..*) deny "🔎 Reviewer: path with '..' rejected ('$fp')."; exit 0 ;; esac
    # Anchor to the project-ROOT artifact dir: strip a leading "$ROOT/" so `src/review/x` (a code
    # module that merely contains 'review/') does NOT match — only top-level `review/` + the status line.
    rel="${fp#"$ROOT"/}"
    case "$rel" in
      review/*)                      exit 0 ;;   # project-root review artifacts (findings-<pr>.md)
      planning/status/reviewer.md)   exit 0 ;;   # the reviewer's own status line
    esac
    deny "🔎 Reviewer session is review-only — it edits no project code ('$fp').
Write only your findings (review/findings-<pr>.md) and your status line (planning/status/reviewer.md).
The worker fixes code (you label the PR \`changes-requested\`; the planner re-dispatches the worker)."
    exit 0
    ;;
  Bash)
    cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null || true)"
    [ -n "$cmd" ] || exit 0
    if printf '%s' "$cmd" | grep -Eq '\bgh\b.*\bpr\b[[:space:]]+merge([[:space:]]|$)'; then
      deny "🔎 Reviewer never merges — the WORKER runs \`gh pr merge\` in its own session after the human's go-ahead.
Your job ends at the verdict: label the PR \`reviewed-pass\` (or \`changes-requested\`) and write your status line."
      exit 0
    fi
    exit 0
    ;;
  *) exit 0 ;;
esac
