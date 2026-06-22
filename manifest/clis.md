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
(they fail open — nothing breaks, but the guardrails won't fire). macOS/Linux have bash already.

## One-time auth
- `gh auth login` (GitHub)
- any MCP/plugin marked "needs your auth" in `mcps.md` / `plugins.md` — with **your own** accounts/keys.
