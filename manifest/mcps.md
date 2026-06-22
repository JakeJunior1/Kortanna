# MCP servers manifest

Most MCP servers in this harness **ride on the plugins** above — installing the plugin gives you the MCP, no
separate step. A couple are standalone. **Every key/credential is yours to supply — never reuse anyone else's.**

## Comes with a plugin (no separate install)
| MCP | From plugin | Needs your auth? |
|-----|-------------|------------------|
| context7 | context7 | no |
| semgrep | semgrep | **login required** — optional/skippable, ships **disabled** (hard-blocks edits while enabled-but-logged-out) |
| chrome-devtools | chrome-devtools-mcp | no |
| pinecone | pinecone | **yes** — Pinecone API key |
| sentry | sentry | **yes** — Sentry auth |
| posthog | posthog | **yes** — PostHog auth |
| vercel | vercel | **yes** — Vercel auth |
| neon | neon | **yes** — Neon auth |

The ones marked **yes** prompt for auth / a key on first use (or via their plugin config). Skip the ones you
don't use.

## Standalone (add separately, with your own key)
- **perplexity** — web research MCP. Needs your **own** Perplexity API key. Add it with Claude Code's MCP
  config (`claude mcp add …`, or the MCP settings UI) and paste **your** key — do not commit it.
- **serena** *(optional, recommended)* — semantic code navigation (symbol search, refactors). Add via its MCP
  setup if you want symbol-aware code tools.
- **sequential-thinking** *(optional)* — structured step-by-step reasoning helper.

## How to add a standalone MCP
See the Claude Code MCP docs for the exact `claude mcp add` invocation for each server. Pattern:
```bash
claude mcp add <name> -- <command to launch the server>
# then set its API key/env via your own credentials (never share keys)
```

> Health-check after setup with `claude mcp list`.
