#!/usr/bin/env bash
# Global PreToolUse(Bash) guard: in an ORCHESTRATED project, a PR reaches `main` only after an
# INDEPENDENT review. The reviewer session signals a passing review with the `reviewed-pass` label
# (VAN-CLIEF §9). So DENY a `gh pr merge` for a PR that does NOT carry `reviewed-pass`.
#
#   • not a `gh pr merge` ....................... pass (exit 0)
#   • repo has no `.orchestrated` marker ........ pass (only opted-in projects are gated)
#   • PR carries `reviewed-pass` ................ pass (independently reviewed)
#   • PR labels resolved, no `reviewed-pass` .... DENY with reason
#
# The label is NECESSARY, not sufficient — the human still verifies the live feature and gives the
# final merge go-ahead. This hook only removes "merge without a review," never "merge without the human."
#
# FAIL-OPEN: no jq/gh, unparseable command, or any `gh` lookup error → exit 0 (defer to the normal
# flow). A bug or an unresolvable PR can never WRONG-BLOCK a legit merge; it just falls back to the
# usual confirmation. Only a clean label resolution that lacks `reviewed-pass` denies.
set -uo pipefail

JQ="$(command -v jq || true)"
[ -n "$JQ" ] || exit 0
command -v gh >/dev/null 2>&1 || exit 0
deny() { "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; }

input="$(cat 2>/dev/null || true)"
cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null || true)"

# Confirm this is actually `gh … pr merge` as the SUBCOMMAND (not the words "pr merge" appearing
# inside a --body/--title), AND extract the PR identifier, in one pass. awk finds `gh` (basename, so
# /usr/bin/gh and a VAR=val prefix both work), skips global flags (and the value of -R/--repo/
# --hostname), and requires the first two positionals to be `pr` then `merge`; the ident is the first
# non-flag token after `merge` (empty ⇒ current-branch PR). Not a `gh pr merge` ⇒ awk exits non-zero
# ⇒ we pass. A misparse can only fail-open (gh lookup fails below), never wrong-block.
ident="$(printf '%s' "$cmd" | awk '
  { gi=0; for(i=1;i<=NF;i++){ b=$i; sub(/.*\//,"",b); if(b=="gh"){gi=i; break} }
    if(!gi) exit 1
    c=0; s1=""; s2=""; mi=0; i=gi+1
    while(i<=NF && c<2){ t=$i
      if(t ~ /^-/){ if(t=="-R"||t=="--repo"||t=="--hostname"){i+=2}else{i++}; continue }
      c++; if(c==1){s1=t}else{s2=t; mi=i}; i++
    }
    if(s1!="pr" || s2!="merge") exit 1
    for(j=mi+1;j<=NF;j++){ if($j !~ /^-/){print $j; exit 0} }
    exit 0
  }')" || exit 0

REPO="${CLAUDE_PROJECT_DIR:-$PWD}"
TOP="$(cd "$REPO" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$TOP" ] || exit 0
[ -f "$TOP/.orchestrated" ] || exit 0   # opt-in: only orchestrated projects are gated

# Resolve the PR's labels. Any gh error (bad ident, no PR, no network) → fail open.
labels="$(cd "$TOP" 2>/dev/null && gh pr view ${ident:+$ident} --json labels --jq '.labels[].name' 2>/dev/null)" || exit 0

printf '%s\n' "$labels" | grep -qx 'reviewed-pass' && exit 0   # independently reviewed → allow

deny "⛔ Merge blocked — PR ${ident:-(current branch)} is not labeled \`reviewed-pass\`.
In an orchestrated project, code reaches main only after an INDEPENDENT review (VAN-CLIEF §9).
The reviewer session reviews a \`needs-review\` PR and labels it \`reviewed-pass\` when it passes.

Current labels: ${labels:-（none）}

Wait for the reviewer's pass (or, if the reviewer flagged a critical trigger, run /code-review ultra).
This hook enforces the review prerequisite only — you still verify the live feature before merging."
exit 0
