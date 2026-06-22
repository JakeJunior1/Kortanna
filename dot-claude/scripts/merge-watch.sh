#!/usr/bin/env bash
# Planner merge-watch (companion, NOT a hook): a PR merge fires no native event, so each PLANNER
# session polls its project's merged PRs and emits one line per NEWLY-merged PR. On that line the
# planner: (a) moves the task progress.md → memory/completed-tasks.md (the board move is the
# planner's — planning/*.md is single-writer, enforced by planning-single-writer.sh), and
# (b) nudges the owning worker: "merged → /wrap (memory + non-board docs + commit only) → prompt
# the human to /compact". The worker's /wrap never touches the board.
#
# Run per project, in the planner session, in the background:   merge-watch.sh <repo-path> &
# Lives in the planner session — relaunch if it ends (no native global daemon). Needs `gh`.
set -uo pipefail
cd "${1:-.}" || exit 1
command -v gh >/dev/null 2>&1 || { echo "merge-watch: gh not found" >&2; exit 1; }
seen=" $(gh pr list --state merged --json number --jq '.[].number' 2>/dev/null | tr '\n' ' ') "
echo "merge-watch armed (${PWD##*/}) — baseline merged PRs:${seen}"
while true; do
  for n in $(gh pr list --state merged --json number --jq '.[].number' 2>/dev/null); do
    case "$seen" in
      *" $n "*) ;;  # already accounted for
      *) b="$(gh pr view "$n" --json headRefName --jq .headRefName 2>/dev/null)"
         echo "MERGED: PR #$n ($b) — planner: move progress→completed-tasks + nudge owner to /wrap"
         seen="$seen$n " ;;
    esac
  done
  sleep 120
done
