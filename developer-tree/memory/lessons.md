# Lessons — ~/Developer (global planner wisdom, cross-project)

How an agent should work across **every** project under `~/Developer` — your confirmed preferences + hard-won
operating lessons. The abstract *method* lives in `guide-setup/van-clief/VAN-CLIEF-RULES.md`; this is the
**environment-specific operating layer** on top of it. Actionable directives, not a changelog — pointers, not
re-explanations.

> **This is the global layer of a 3-layer memory** (VAN-CLIEF §9): always-loaded universal rules
> (`~/.claude/rules/`) · this cross-project planner memory · per-project memory = **native auto-memory**
> (auto-capture) distilled into a lean **in-repo `memory/`** (the durable, version-controlled record).
> Keep each fact in exactly one layer.
>
> *(Seed file — these are reusable defaults. Replace/extend them with your own as you learn what works.)*

## The self-improving loop (how this file stays alive)
- When you're corrected or you find a better approach, **capture it** in the right layer:
  - **project-specific** → the project's **native auto-memory** captures it (a `feedback` entry, automatic);
    `/wrap` then distills the durable ones up into the project's in-repo `memory/lessons.md`; `/groom` consolidates.
  - **global / about how planners orchestrate** → **here**.
  - **permanent + universal** (true in every repo, every tool) → graduate it into `~/.claude/rules/karpathy.md`.
- **Trim on a cadence** (the *dream pass*, VAN-CLIEF §9): merge duplicates, prune stale, keep this lean.
  Lessons bloat the same way a Current State block does — resist it.
- **Propose skills, don't auto-create them:** if a procedure keeps recurring, *suggest* capturing it as a
  reusable skill and let the human approve — never auto-author one.
- **Graduation happens on the dream pass (`/groom`):** graduate a proven-universal lesson up into a rule **and
  delete it from here** (one fact, one location).

## Working with the operator (you)
- **The human is the gate on irreversible steps.** They merge PRs manually and run `/compact` themselves.
  Workers `/wrap` then stand by — they never auto-merge or self-compact.
- **Recommend, don't survey.** When a choice has a sensible default, pick it, say so, and proceed; surface a
  real fork only when the answer changes the outcome.

## Orchestration (planner ↔ worker)
- **90/10 is a division of labor, not one agent's time budget:** the **planner** does the 90% (plan + assemble
  context + write the handoff); the **worker** does the 10% (execute the handed-off task). A worker is never
  told to "spend 90% planning."
- **60/30/10 = layer-triage** (VAN-CLIEF §1): route each piece of work to the cheapest layer that can do it —
  **deterministic → code/script · rule-based (if/then) → a skill · genuine judgment → the model.**
- **Planner sessions are read-only** (`.md` only, rooted at `~/Developer`); workers execute in their gitignored
  `branches/<task>/` worktrees. Code reaches `main` **only via PR merge**; the planner commits brain `.md` to main directly.
- **`planning/*.md` is single-writer — the planner** (globally hook-enforced: `planning-single-writer.sh`). It moves a task `todo→progress` at dispatch and `progress→completed-tasks` on merge; **workers never edit the queue files** (they read their assignment + report status/done in their output; may message the planner when it's live, but never write the shared files, even in auto mode). Stops two sessions racing the board. **Pull `main` between merges** so the next worker branches/rebases off current main.
- **Review = an agent-spawned reviewer subagent** over the diff (a worker can't invoke a `/code-review`
  slash-command). `/code-review ultra` is the human's manual billed escalation for large/risky/
  money-correctness-critical diffs — the worker **detects-and-prompts**, the human invokes.

## Docs & memory discipline
- **Current State blocks: max 3 lines** (done / in-progress / next) **+ a pointer** to the status home — never a
  growing changelog. This is the #1 cause of CLAUDE.md drift.
- **Memory index lines are one-liners** (~150 chars). Detail goes in the topic file, never the index. (A bloated
  index line can grow large enough to block memory loading — keep it short.)
- **Verify against reality before trusting** a primer/progress file — it may say something's done that isn't.

## Maintenance routines
- **Unattended/scheduled routines run on a cheaper model** (mechanical bash + format; no deep reasoning needed)
  and are **report-only** — they detect and recommend, never apply a fix. A separate review-and-apply pass (with
  the human) makes the changes.

## Environment facts worth not re-learning
- **Worktrees = Model P (root-at-parent + manual `git worktree add`); the session worktree-TOGGLE is NOT used.**
  A worker anchors at the project root `<proj>/` (the persistent main checkout) and makes each task's workspace
  with `git worktree add branches/<task>`, staying rooted at the parent; it edits only inside `branches/<task>/`,
  never main's tree at root. Toggling roots the session INSIDE the worktree, so removing it (merge/cleanup)
  orphans the session; rooting at the persistent parent is the resume-safety. Teardown = a deliberate cleanup
  pass (`git worktree remove` after merge + archive the session), never `--delete-branch`, never auto-delete.
- **Frontend brand-matching = the `design-md-reference` skill** (`~/.claude/skills/design-md-reference/`).
  It triggers only when a UI should match a **specific named brand/aesthetic**, then fetches that brand's
  ready-made `DESIGN.md` from `VoltAgent/awesome-design-md` and pairs it with `ui-ux-pro-max`. NOT for generic
  frontend (no brand → don't force one).
