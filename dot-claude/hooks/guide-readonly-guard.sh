#!/usr/bin/env bash
# Global PreToolUse(Edit|Write|MultiEdit|NotebookEdit) guard: the methodology guide at
# ~/Developer/guide-setup is READ-ONLY to every session EXCEPT the guide-setup session itself.
# Workers (and any other session) mount it as a read-only additional dir — role prompts + the
# method — and may READ it freely, never EDIT it. Only a session rooted IN guide-setup (the
# planner that owns the guide) may write it.
#
#   • not an Edit/Write/MultiEdit/NotebookEdit ... pass (exit 0)
#   • target not under ~/Developer/guide-setup ... pass (not the guide)
#   • this session IS rooted in guide-setup ...... pass (the guide's own session)
#   • target under the guide, foreign session .... DENY with reason
#
# FAIL-OPEN: any error / unparseable → exit 0 (defer to the normal flow). A bug here can never
# block an edit; it just falls back to the usual confirmation. (Covers the model-driven write
# tools, not raw Bash sed/cp — those are a rare edge, not the worker path.)
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0

input="$(cat 2>/dev/null || true)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null || true)"
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit) ;;
  *) exit 0 ;;
esac

target="$(printf '%s' "$input" | "$JQ" -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)"
[ -n "$target" ] || exit 0

rp() { cd "$1" 2>/dev/null && pwd -P; }   # realpath for an existing dir

GUIDE="$HOME/Developer/guide-setup"
guide_rp="$(rp "$GUIDE")"; guide_rp="${guide_rp:-$GUIDE}"

# Normalize target to an absolute path (Edit/Write pass absolute paths), resolving its parent dir
# (the file may not exist yet on a Write).
case "$target" in
  /*) abs="$target" ;;
  *)  abs="$PWD/$target" ;;
esac
tdir="$(rp "$(dirname "$abs")")"; tdir="${tdir:-$(dirname "$abs")}"
abs_rp="$tdir/$(basename "$abs")"

# Target under the guide?
case "$abs_rp/" in
  "$guide_rp"/*) ;;        # under the guide → keep checking
  *) exit 0 ;;             # not the guide → not our concern
esac

# Is THIS session rooted in the guide? (its owning planner may edit it.)
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
proj_rp="$(rp "$proj")"; proj_rp="${proj_rp:-$proj}"
case "$proj_rp/" in
  "$guide_rp"/*) exit 0 ;;   # session IS in guide-setup → allow
esac

# Foreign session writing the guide → deny.
"$JQ" -n --arg r "⛔ Edit to the methodology guide blocked — ~/Developer/guide-setup is READ-ONLY to this session.
Only the guide-setup session (rooted there) edits the method/templates; worker and other sessions mount it
read-only (role prompts + reference). Read it freely — make your changes inside your own project instead.
Target: $target" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
exit 0
