# Plugins manifest

The curated plugin set this harness runs (Claude Code). Plugins install from a **marketplace** with
`claude plugin install <name>@<marketplace>`. Add the non-default marketplaces first.

## 1. Add marketplaces
```bash
claude plugin marketplace add anthropics/claude-plugins-official   # usually already present
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
claude plugin marketplace add HKUDS/CLI-Anything
```

## 2. Core plugins — no account needed, install these
```bash
claude plugin install context7@claude-plugins-official            # live library/API docs (MCP)
claude plugin install chrome-devtools-mcp@claude-plugins-official # browser/devtools control (MCP)
claude plugin install pyright-lsp@claude-plugins-official         # Python language server
claude plugin install typescript-lsp@claude-plugins-official      # TS/JS language server
claude plugin install duckdb-skills@claude-plugins-official       # local SQL/data wrangling
claude plugin install claude-md-management@claude-plugins-official# CLAUDE.md hygiene
claude plugin install mcp-server-dev@claude-plugins-official      # build your own MCP servers
claude plugin install agent-sdk-dev@claude-plugins-official       # build agents on the SDK
claude plugin install hookify@claude-plugins-official             # author hooks from a session
claude plugin install commit-commands@claude-plugins-official     # commit/PR helpers
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill           # frontend/design quality
claude plugin install cli-anything@cli-anything                   # generate agent-drivable CLIs for GUI/SDK-only tools
```

## 3. Optional — need your own account / auth (install only what you use)
```bash
claude plugin install sentry@claude-plugins-official    # error monitoring
claude plugin install pinecone@claude-plugins-official  # vector DB
claude plugin install posthog@claude-plugins-official   # product analytics
claude plugin install vercel@claude-plugins-official     # deploys
claude plugin install neon@claude-plugins-official       # serverless Postgres
claude plugin install semgrep@claude-plugins-official    # SAST security scan (MCP) — see warning below
```

> ⚠️ **Semgrep is OPTIONAL and skippable — nothing in the harness depends on it.** If you install it, **enable it ONLY after you've logged into Semgrep**: its "Guardian" runs a PreToolUse hook that **hard-blocks every edit/Bash while enabled-but-logged-out**, which locks up a fresh session (you can't even fix it from inside — disable the plugin by hand in `settings.json` + restart). It ships **disabled** in `settings.json` for exactly this reason — turn it on deliberately once login is sorted, or just skip it.

> `settings.json` (in `dot-claude/`) already lists these under `enabledPlugins` with the right on/off state —
> so once installed they're enabled. It also **disables** the heavyweight department packs
> (`engineering`/`data`/`design`) by default; turn one on per-project at point-of-need rather than globally.
> Verify with `claude plugin list`.
