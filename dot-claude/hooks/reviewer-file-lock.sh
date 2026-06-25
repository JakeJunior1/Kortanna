#!/usr/bin/env bash
# Global PreToolUse(Edit|Write|NotebookEdit|Bash) guard for the REVIEWER session only. The reviewer
# reviews — it edits NO project code and NEVER merges (the worker merges in its own session). Active
# ONLY for the reviewer session whose id is bound in the `.reviewer` marker. The reviewer roots at the
# PROJECT root (to review that project's PRs) — the SAME root the workers use, unlike the dev-root-rooted
# planner — so the marker is SESSION-BOUND (holds the reviewer's id); workers at the same root are untouched.
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
MARK="$ROOT/.reviewer"
[ -f "$MARK" ] || exit 0
# Session-bound (the reviewer shares the workers' project root): gate ONLY the session whose id is
# written in .reviewer. A worker at this same root has a different CLAUDE_CODE_SESSION_ID → NOT gated.
# An unbound/empty marker gates NOBODY (fail toward never bricking a worker; the reviewer writes its
# id into .reviewer at startup and re-binds on resume — like §9's owner·session binding).
want="$(head -n1 "$MARK" 2>/dev/null | tr -d '[:space:]')"
[ -n "$want" ] && [ "${CLAUDE_CODE_SESSION_ID:-}" = "$want" ] || exit 0

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
