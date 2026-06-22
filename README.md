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

## Contributing & security
See [`CONTRIBUTING.md`](CONTRIBUTING.md) to propose changes and [`SECURITY.md`](SECURITY.md) to report a
vulnerability privately. The credentials you supply are listed in [`manifest/credentials.md`](manifest/credentials.md).

## Credits & license
Built on the **Van Clief / ICM** methodology (Jake Van Clief · Clief Notes · Eduba) and the ICM/MWP paper
([arXiv 2603.16021](https://arxiv.org/abs/2603.16021), MIT). The source course material is **not redistributed** —
this is an independent implementation with attribution. Licensed **MIT** — see [`LICENSE`](LICENSE).
