# Credentials & placeholders you supply

A single checklist of every value **you** fill in — names and keys. **Bring your own; never reuse anyone
else's, and never paste a key into a file you'll commit.**

> **Why there's no `.env` here.** Kortanna is Claude Code config, not an app with a dotenv loader. Keys are
> registered through Claude Code itself — `claude mcp add …`, a plugin's auth prompt, or `settings.json` — **not**
> by sourcing a `.env` file. This page is the *index* of what to supply; the `how` lives in `mcps.md` / `plugins.md`.

## Identity placeholders (not secrets — just fill in)
| Placeholder | Where | What to put |
|-------------|-------|-------------|
| `<YOUR NAME>` | `~/.claude/settings.json` → `autoMode.environment` | your name |
| `<YOUR_GITHUB_USERNAME>` | `~/.claude/settings.json` → `autoMode.environment` | your GitHub handle |
| `<your-project>` / `<your-client>` | `~/Developer/CLAUDE.md` (map + routing) | your real names, or leave the examples until you create one |

Search the placed files for `<…>` to find them all (see [`SETUP.md`](../SETUP.md) §2).

## One-time auth (no key stored in any file)
| Service | How | Needed for |
|---------|-----|-----------|
| **GitHub** | `gh auth login` | PR create/merge + the `/ship` review flow |

## Optional API keys — only for the optional MCPs/plugins you actually enable
None of these are required to use the harness. Add each through its plugin's auth prompt or `claude mcp add`
(see [`mcps.md`](mcps.md) / [`plugins.md`](plugins.md)).

| Credential | For | Required? |
|------------|-----|-----------|
| Perplexity API key | `perplexity` standalone MCP (web research) | optional |
| Pinecone API key | `pinecone` (vector DB) | optional |
| Sentry auth | `sentry` (error monitoring) | optional |
| PostHog auth | `posthog` (product analytics) | optional |
| Vercel auth | `vercel` (deploys) | optional |
| Neon auth | `neon` (serverless Postgres) | optional |
| Semgrep login | `semgrep` (SAST) | **optional + skippable** — ships disabled; enable only *after* login (see `plugins.md`) |

Skip any you don't use. `claude mcp list` / `claude plugin list` to verify what's wired.
