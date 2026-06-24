# CLI prerequisites

Install these before placing the files. Recent stable versions are fine.

| CLI | Why the harness needs it | Install |
|-----|--------------------------|---------|
| **Claude Code** | the harness itself (commands, hooks, plugins, MCPs) | https://claude.com/claude-code |
| **git** | every project is a git repo; the orchestration model (branches/worktrees, merge-only main) is git-based | https://git-scm.com |
| **gh** (GitHub CLI) | PR create/merge + repo ops used by the `/ship` + review flow; `gh auth login` once | https://cli.github.com |
| **node** | **required for hooks to run** (they're invoked as `bash` commands but several plugins/MCPs are Node) and for most MCP servers | https://nodejs.org (LTS) |
| **python3** | used by some tooling/skills and general scripting | https://python.org (3.11+) |
| **jq** | used by the worktree-placement hooks (they fail open without it — optional) | https://jqlang.github.io/jq |

## Windows
The guardrail hooks are **bash `.sh` scripts**. On Windows, Claude Code must be able to run `bash` — install
**Git Bash** (ships with Git for Windows) or use **WSL**. Without a `bash` on PATH the hooks silently no-op
(they fail open — nothing breaks, but the guardrails won't fire). macOS/Linux have bash already. **Run the
`SETUP.md` install commands in that same bash, too** — in cmd.exe/PowerShell `~`/`$HOME` and `cp` don't work,
so the copy steps create a stray literal `~` folder instead of installing into your home directory.

## One-time auth
- `gh auth login` (GitHub)
- any MCP/plugin marked "needs your auth" in `mcps.md` / `plugins.md` — with **your own** accounts/keys.

## Optional — cross-vendor coding agent (Codex CLI)
Not required; nothing in the harness depends on it. With a **paid ChatGPT plan** (Plus/Pro/Team), the **OpenAI
Codex CLI** gives a worker — and the `council` skill — a genuinely cross-vendor voice that runs on your
*subscription*, not metered API:
```bash
npm i -g @openai/codex      # or: brew install codex
codex login                 # "Sign in with ChatGPT" — uses your plan, no API key/credits
codex exec "…"              # one-shot, scriptable — how a worker / council member drives it
```
Gating: subscription sign-in needs a **paid** plan (the free tier won't get CLI access), and the sign-in flow
may auto-create an API key in your OpenAI org — review your keys afterward. Skip entirely on free.

## Optional — frontend design system (Impeccable)
Not required; nothing in the harness depends on it. **Impeccable** (`pbakaus/impeccable`) is a design-quality
system for AI coding agents — a `/impeccable` skill + 23 design commands, **44 deterministic detector rules**
(anti-generic-design linting that runs with **no LLM/API calls**), and live browser iteration. Multi-provider
(Claude Code · Codex · Cursor · Copilot · …). Reach for it on **real frontend work** — not before.
```bash
npx impeccable install      # installs a skill + hooks + CLI (prompts: project or global ~/.claude) + PRODUCT.md / DESIGN.md
```
- **Standout = the deterministic detector** (a no-API design linter) — the one design check our LLM-guidance tools
  don't do; use it as the **design gate** (the §1 "deterministic → code" layer, applied to UI).
- **Overlap warning:** it overlaps with the `ui-ux-pro-max` plugin (general design guidance) — **pick one**, don't
  run both (two overlapping design systems = drift/bloat). The `design-md-reference` skill is *complementary* — it
  matches a *specific named brand* (different job).
- **Untrusted code (§6):** it installs **hooks that run on your agent workflows** — **review them before enabling.**
