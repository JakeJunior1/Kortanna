# Kortanna

> *"When the game is over, the king and the pawn go back into the same box."*

A ready-made **Claude Code dev-environment harness** — drop-in commands, hooks, rules, templates, a curated
plugin/MCP set, and the **Van Clief / Interpretable Context Methodology (ICM)** guide — so you can stand up a
disciplined, multi-session AI-dev workflow without re-making every decision.

## What's inside
- **`guide/`** — the **methodology guide**: `van-clief/VAN-CLIEF-RULES.md` (§1–§9) + project/worker templates.
- **`dot-claude/`** — the **wiring** for `~/.claude/`: slash-commands (`/wrap`, `/groom`, `/ship`, `/freshness`),
  guardrail **hooks** (merge-only `main`, review-before-push, single-writer planning board, post-compact
  resume, planner/worker locks, …), always-loaded rules, a skill, a scheduled maintenance task, and `settings.json`.
- **`developer-tree/`** — a `~/Developer/` skeleton: a global "brain" (`CLAUDE.md` · `CONTEXT.md` · `memory/`)
  + lean project/client `_template/`s.
- **`manifest/`** — which plugins / MCPs / CLIs to install (and which need your own keys).

## Quickstart
Read **[`SETUP.md`](SETUP.md)** — it walks you through placing the files into `~/.claude` and `~/Developer`,
filling the `<placeholders>`, and installing the plugins. Then point any agent at `~/Developer/CLAUDE.md` and
it routes itself from there.

> **Windows:** the guardrail hooks are bash scripts — install **Git Bash** or use **WSL** so they run
> (otherwise they fail open: nothing breaks, but the guardrails won't fire). Semgrep ships **disabled** (it's
> optional — see `manifest/plugins.md`).

## How it works (the operating model)

The harness runs your AI dev work as a **planner + workers** model — all of them ordinary Claude Code sessions
that coordinate through **files**, not a server. You don't *have* to use multiple sessions (a single session +
the commands and guardrails works fine), but the model scales to parallel, multi-day work.

### Planner vs workers
- **The planner** orchestrates from your dev root (`~/Developer`). It writes the plan and the **task board**, is
  the **sole writer** of `planning/*.md`, dispatches tasks, and reviews/merges. It edits **docs only** — never code.
- **Workers** each own a slice (frontend / backend / data / …). A worker anchors at the project root and does its
  task in a gitignored **`branches/<task>/` worktree**, then opens a PR. **Code reaches `main` only via a merged
  PR** — never a direct commit.

### `.orchestrated`
An empty **`.orchestrated`** file at a project root turns on the guardrail hooks for that project: merge-only
`main` (no code commits to trunk), the single-writer planning board (only the planner edits `todo.md`/`progress.md`),
and the planner/worker locks. No marker → the project behaves like a normal repo.

### The per-task loop
1. The planner assigns a task (tagged with an `owner` + the worker's `session` id) and moves it onto the board.
2. The worker builds it in its worktree → pushes a branch → opens a PR.
3. An **independent reviewer** (a fresh-context agent) checks the diff; large/risky diffs get flagged for you to run `/code-review ultra`.
4. **You** verify the live feature — the gate stays human — then the **worker merges its own PR** (the planner never merges); the planner watches the merge, nudges `/wrap`, and moves the board.
5. The worker `/wrap`s (saves memory + docs), you `/compact`, and it picks up its next assigned task.

### The board (the file *is* the state)
- `planning/todo.md` — pending queue (⏳), each task owner-tagged.
- `planning/progress.md` — in-progress board (🔄: owner · session · branch · status).
- `memory/completed-tasks.md` — done archive (✅).
- `planning/status/<owner>.md` — a worker's own status line. Workers can't message the planner; they leave **PRs
  and status files**, and the planner **pulls** them (a background `merge-watch` polls both).

### Goal-driven work + `/goal`
Every task is a **goal** with a *verifiable* done-condition ("done = `npm test` passes & the PR is open"). A
worker runs goal-driven by default: execute → **verify** (run the check, show the output) → loop until it
provably holds. For a **Claude** worker you can go fully hands-off: paste the native **`/goal <condition>`**
command into the worker and it loops autonomously across turns until a separate evaluator confirms the condition.
(A worker can't self-start it and it can't be sent cross-session — so you paste it, selecting `/goal` from the
command list so it registers.)

### Commands you'll use
- **`/wrap`** — save the session (docs + memory, commit) before you `/compact`, so nothing is lost.
- **`/groom`** — periodic "dream pass": consolidate memory, prune drift, graduate lessons.
- **`/ship`** — run an independent review, then push (small diffs) or open a branch + PR (big ones).
- **`/freshness`** — report-only health check (stale references, plugin drift, MCP health).
- **`/council`** — pressure-test a hard decision: opposed-incentive personas debate it, rank each other
  anonymously, and a chair synthesizes a verdict (an anti-sycophancy check).

### Memory (three layers, one fact per layer)
Always-loaded **rules** (`~/.claude/rules/`, universal) · a **global** cross-project brain (`~/Developer/memory/`,
how you orchestrate) · **per-project** memory (the platform's auto-memory for capture + a lean in-repo `memory/`
as the durable record). `/wrap` distills upward each session; `/groom` consolidates.

The full method is in [`guide/van-clief/VAN-CLIEF-RULES.md`](guide/van-clief/VAN-CLIEF-RULES.md) (§1–§9).

## Contributing & security
See [`CONTRIBUTING.md`](CONTRIBUTING.md) to propose changes and [`SECURITY.md`](SECURITY.md) to report a
vulnerability privately. The credentials you supply are listed in [`manifest/credentials.md`](manifest/credentials.md).

## Credits & license
Built on the **Van Clief / ICM** methodology (Jake Van Clief · Clief Notes · Eduba) and the ICM/MWP paper
([arXiv 2603.16021](https://arxiv.org/abs/2603.16021), MIT). The source course material is **not redistributed** —
this is an independent implementation with attribution. Licensed **MIT** — see [`LICENSE`](LICENSE).
