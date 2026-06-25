#!/usr/bin/env bash
# Global PreToolUse(Edit|Write|MultiEdit|NotebookEdit|Bash) guard for the VERIFIER session only. The verifier
# checks high-stakes CLAIMS — it edits NO project code and assigns/merges nothing (the answer-side twin
# of reviewer-file-lock). Active ONLY for the verifier session whose id is bound in the `.verifier`
# marker. The verifier roots at the PROJECT root (to verify that project's claims) — the SAME root the
# workers + reviewer use — so the marker is SESSION-BOUND (holds the verifier's id); other sessions at
# the same root are untouched.
#
#   Edit/Write to anything except verify/** or planning/status/verifier.md ... DENY (verify-only)
#   Bash `gh pr merge` ........................................................ DENY (the verifier never merges)
#   everything else (Read/Grep, read-only git/gh, web-fetch, read-only exec, test runs) ...... pass
#
# The verifier's writes are its verdicts (verify/**) and its status line (planning/status/verifier.md);
# it RUNS read-only checks (fetch/query/compute, tests) to re-ground a claim — so those are NOT gated.
# FAIL-OPEN: any error → exit 0.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
MARK="$ROOT/.verifier"
[ -f "$MARK" ] || exit 0
# Session-bound (the verifier shares the workers'/reviewer's project root): gate ONLY the session whose
# id is written in .verifier. Another session at this same root has a different CLAUDE_CODE_SESSION_ID →
# NOT gated. An unbound/empty marker gates NOBODY (fail toward never bricking a worker; the verifier
# writes its id into .verifier at startup and re-binds on resume — like §9's owner·session binding).
want="$(head -n1 "$MARK" 2>/dev/null | tr -d '[:space:]')"
[ -n "$want" ] && [ "${CLAUDE_CODE_SESSION_ID:-}" = "$want" ] || exit 0

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null || true)"
deny() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    fp="$(printf '%s' "$input" | "$JQ" -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)"
    [ -n "$fp" ] || exit 0
    # Reject any traversal outright (a `..` segment could resolve back into code).
    case "$fp" in *..*) deny "🔎 Verifier: path with '..' rejected ('$fp')."; exit 0 ;; esac
    # Anchor to the project-ROOT artifact dir: strip a leading "$ROOT/" so `src/verify/x` (a code module
    # that merely contains 'verify/') does NOT match — only top-level `verify/` + the status line.
    rel="${fp#"$ROOT"/}"
    case "$rel" in
      verify/*)                      exit 0 ;;   # project-root verdict artifacts (verdict-<id>.md)
      planning/status/verifier.md)   exit 0 ;;   # the verifier's own status line
    esac
    deny "🔎 Verifier session is verify-only — it edits no project code ('$fp').
Write only your verdicts (verify/verdict-<id>.md) and your status line (planning/status/verifier.md).
You check CLAIMS; you do not change code or assign work (you are not a planner). The planner mints and
owns the claim file (planning/claims/<id>.md) — you never edit it."
    exit 0
    ;;
  Bash)
    cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null || true)"
    [ -n "$cmd" ] || exit 0
    if printf '%s' "$cmd" | grep -Eq '\bgh\b.*\bpr\b[[:space:]]+merge([[:space:]]|$)'; then
      deny "🔎 Verifier never merges — it is outside the PR lifecycle entirely. Your job ends at the claim
verdict: write verify/verdict-<id>.md and your planning/status/verifier.md line."
      exit 0
    fi
    exit 0
    ;;
  *) exit 0 ;;
esac
