#!/usr/bin/env bash
# verifier-watch.sh — the VERIFIER session's watch loop (companion, NOT a hook).
# A planner-minted claim fires no native event, so the standing verifier session polls its project's
# ON-DISK claim queue (planning/claims/*.md) for claims with `status: needs-verify` that do NOT yet have
# a verdict (verify/verdict-<id>.md), and emits one VERIFY: line per newly-seen OPEN claim — the trigger
# to run the per-claim verify loop (read claim → spawn a fresh BLINDED claim-verifier subagent → write
# verify/verdict-<id>.md + planning/status/verifier.md). The id is the claim file's name stem
# (planning/claims/<id>.md ⇒ <id>); the matching verdict is verify/verdict-<id>.md.
#
# Sibling of ~/.claude/scripts/reviewer-watch.sh — but the verifier's state rail is ON-DISK (a claim is
# not code, so there are no PR labels): a claim is OPEN iff its file says `status: needs-verify` AND no
# verify/verdict-<id>.md exists. That existence check doubles as crash-recovery — a needs-verify claim
# with no verdict is one a (possibly dead) verifier left mid-flight, surfaced again at arm.
#
# Run per project, in the verifier session, in the background:   verifier-watch.sh <repo-path> &
# Background → it does NOT survive /compact, a Claude restart, or an external kill. The verifier
# RE-CHECKS it every turn and restarts it if it isn't running (no native daemon).
set -uo pipefail
cd "${1:-.}" || exit 1

# A claim is OPEN (needs surfacing) iff its file says `status: needs-verify` AND the verifier has NOT yet
# SIGNALLED it — i.e. there is no `claim <id> …` line in planning/status/verifier.md. The done-marker is
# the STATUS LINE (the signal that actually reaches the planner's merge-watch), NOT the mere existence of
# a verdict file: a verdict written without its status line (verifier died mid-handoff) stays OPEN so a
# not-CONFIRMED result can't silently rot. The `status:` match tolerates optional quotes + a trailing
# comment; the canonical form is bare `status: needs-verify`. Claim ids are [A-Za-z0-9._-]+ (no
# whitespace — see the verifier/planner spec), which keeps the `grep -F "claim $id "` match exact.
open_claims(){
  [ -d planning/claims ] || return 0
  status="planning/status/verifier.md"
  for f in planning/claims/*.md; do
    [ -e "$f" ] || continue
    grep -Eiq '^[[:space:]]*status:[[:space:]]*"?needs-verify"?[[:space:]]*(#.*)?$' "$f" || continue
    id="$(basename "$f" .md)"
    [ -f "$status" ] && grep -qF "claim $id " "$status" 2>/dev/null && continue   # signalled ⇒ not open
    printf '%s\n' "$id"
  done
}

seen=" $(open_claims | tr '\n' ' ') "
echo "verifier-watch armed (${PWD##*/}) — baseline open claims (needs-verify, no verdict):${seen}"
# Emit the baseline open claims too — on (re)arm those are unhandled work (incl. crash-recovery), not noise.
for id in ${seen}; do
  echo "VERIFY: claim $id (planning/claims/$id.md) — spawn a blinded claim-verifier, write verify/verdict-$id.md"
done

while true; do
  sleep 90
  for id in $(open_claims); do
    case "$seen" in
      *" $id "*) ;;  # already surfaced
      *) echo "VERIFY: claim $id (planning/claims/$id.md) — spawn a blinded claim-verifier, write verify/verdict-$id.md"
         seen="$seen$id " ;;
    esac
  done
done
