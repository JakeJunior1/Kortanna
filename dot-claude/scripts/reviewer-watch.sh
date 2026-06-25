#!/usr/bin/env bash
# reviewer-watch.sh — the REVIEWER session's watch loop (companion, NOT a hook).
# A pushed PR fires no native event, so the standing reviewer session polls its project for PRs
# labeled `needs-review` and emits one REVIEW: line per newly-seen PR — the trigger to run the
# per-PR review loop (claim in-review → fresh code-reviewer subagent → reviewed-pass/changes-requested).
# It ALSO surfaces orphaned `in-review` PRs at arm time (crash-recovery: a PR left mid-review by a
# dead reviewer) so the session can resume the oldest unfinished one.
#
# Sibling of ~/.claude/scripts/merge-watch.sh (planner: merged PRs + status files) and
# ~/Developer/scripts/planner-watch.sh (planner: single-shot re-arm). This is the reviewer's variant.
#
# Run per project, in the reviewer session, in the background:   reviewer-watch.sh <repo-path> &
# Background → it does NOT survive /compact, a Claude restart, or an external kill. The reviewer
# RE-CHECKS it every turn and restarts it if it isn't running (no native daemon). Needs `gh`.
set -uo pipefail
cd "${1:-.}" || exit 1
command -v gh >/dev/null 2>&1 || { echo "reviewer-watch: gh not found" >&2; exit 1; }

labelled(){ gh pr list --state open --label "$1" --json number -q '.[].number' 2>/dev/null | sort -n; }

# Crash-recovery hint: any PR already in-review when we arm is one a (possibly dead) reviewer left mid-flight.
orphaned="$(labelled in-review | tr '\n' ' ')"
seen=" $(labelled needs-review | tr '\n' ' ') "
echo "reviewer-watch armed (${PWD##*/}) — baseline needs-review:${seen}· in-review(resume oldest):[${orphaned}]"
# Emit the baseline needs-review PRs too — on (re)arm those are unhandled work, not noise.
for n in ${seen}; do
  b="$(gh pr view "$n" --json headRefName -q .headRefName 2>/dev/null)"
  echo "REVIEW: PR #$n ($b) — claim in-review, run the review loop"
done

while true; do
  sleep 90
  for n in $(labelled needs-review); do
    case "$seen" in
      *" $n "*) ;;  # already surfaced
      *) b="$(gh pr view "$n" --json headRefName -q .headRefName 2>/dev/null)"
         echo "REVIEW: PR #$n ($b) — claim in-review, run the review loop"
         seen="$seen$n " ;;
    esac
  done
done
