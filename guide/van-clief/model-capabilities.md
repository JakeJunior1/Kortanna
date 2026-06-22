# Native capability ledger — Claude / Claude Code

> **Purpose (§7 discipline):** before building ANY custom tooling, check here — if a capability is already
> native, don't rebuild it. Maintained, time-sensitive: a capability snapshot, not eternal truth. **Revisit on
> a schedule** (capabilities ship fast). This is the concrete instance of the §7 "native-capability ledger";
> applying the method elsewhere = keep your own.
>
> **Last verified: 2026-06-17** (against code.claude.com/docs; several items confirmed live this session).

## Agents & orchestration
- **Subagents** (Agent tool) — parallel fan-out, custom agent types, background runs. *Don't build a dispatcher.*
- **Workflows** (deterministic multi-agent scripts: pipeline/parallel/phases) — *don't hand-roll orchestration.*
- **Agent Teams / multi-agent** — native. *Don't build agent-comms plumbing (a custom agent-comms layer is obsolete).*
- **`/loop`** — recurring/self-paced task runner. *Don't build a polling loop.*

## Planning & memory
- **Plan mode** — native planning (ephemeral per session).
- **Auto-memory** — per-project memory dir + index; the model is told to use it. *Don't build a memory store
  for basic persistence.* (Durable on-disk PROJECT state + intent-vs-built roadmap is the one gap → keep that
  in the workspace docs per §8/§9, not a custom DB.)
- **`consolidate-memory`** skill (native, anthropic-skills) — the `*dream` merge/prune pass. *Don't build it.*
- **Context management / auto-compact** — native summarization + compaction. *Don't build context summarizers.*

## Skills — three native surfaces (don't rebuild these) — *verified 2026-06-17, Phase 7*
Skills reach you from **three** distinct Anthropic sources — know which surface a skill is on before you
"build" anything:
1. **`anthropic-agent-skills` marketplace** (open repo `anthropics/skills`, installed into `~/.claude`):
   `doc-coauthoring` · `docx`/`pdf`/`pptx`/`xlsx` · `mcp-builder` · `skill-creator` · `web-artifacts-builder`
   · `webapp-testing` · `claude-api` · `algorithmic-art` · `brand-guidelines` · `canvas-design` ·
   `frontend-design` · `internal-comms` · `slack-gif-creator` · `theme-factory`. **Author standard:**
   `<name>/SKILL.md` (spec + template in the repo) — Anthropic-originated, now open.
2. **App-bundled `anthropic-skills:` namespace** (Desktop/Cowork): re-exposes the doc/builder skills above
   **plus** `brain` · `architecture-review` · `code-review` (+ top-level `/code-review`,`/review`) ·
   `consolidate-memory` · `tech-docs` · `schedule` · `setup-cowork`.
3. **Cowork department packs** (`knowledge-work-plugins`, **app-level only** — live under
   `~/Library/Application Support/Claude/.../cowork_plugins/`, managed via the Cowork app `/plugins` UI,
   **NOT** `settings.json`): `engineering` · `data` · `product-management` · `design` · `marketing` ·
   `finance` · `legal` · `sales` · `operations` · `productivity` · `customer-support` · `enterprise-search`
   · `bio-research` · `human-resources` · `cowork-plugin-management`. Each bundles skills + commands +
   connectors + sub-agents for a job function, and is **built to be customized** to your tools/terms/process
   (`cowork-plugin-management` is the tool for that). *App-level by default (so Phase 6's `~/.claude` audit
   correctly didn't touch them) — but **mirrorable into `~/.claude`** so they work in the CLI/Claude Code too:
   `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install <pack>@knowledge-work-plugins`.
   We mirrored `engineering`/`data`/`design` 2026-06-18, then **disabled all three globally 2026-06-20** —
   their connector stubs were per-session noise and `disabledMcpServers` (global *and* per-project) can't
   separate a pack's connectors from its skills, so the clean lever was the `enabledPlugins` toggle;
   **re-enable a pack per-project** at point-of-need.* (Full Phase-7 inventory + decisions: the auto-memory ledger.)
**Standing note:** as of 2026-06-17 every plugin/pack on this machine reads `usageCount: 0` (dormant
library). Native-first discipline = *invoke the existing surface on demand*, don't add always-on weight.

## Hooks — powerful, but with hard limits
- Events: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse(+Failure), PermissionRequest, FileChanged,
  InstructionsLoaded, PreCompact, Notification, Stop. Can hard-block (exit 2) **in every permission mode.**
- Input fields: `session_id`, `transcript_path`, `cwd`, `permission_mode`, `effort.level`, + event-specific
  (`prompt`, `tool_name`/`tool_input`, `file_path`, etc.).
- **Surfaces:** hooks run in BOTH the terminal CLI and the **Claude Desktop app** (proven 2026-06-17 — the
  precompact/post-compact hooks fired in a desktop session). The docs read CLI-centric but understate desktop.
- ⛔ **Hooks do NOT receive context-window / token usage.** A "context-meter hook" is **not buildable.** Context
  fill is exposed only to the **statusline** (`context_window.used_percentage`) — and the statusline is a
  **terminal-only status bar** that does NOT run in the Desktop app (which shows fill via its own usage ring).
  So a statusline→file→hook bridge is moot for a desktop user. **Verdict (2026-06-17): context-meter dropped** —
  keep §7's context-fill brackets as a behavioral principle, no custom mechanism.

## Permissions & auto-mode
- **Classifier "auto" mode** — a server-side model reviews each action; natively blocks `curl|bash`, prod
  deploys, force-push to default, mass cloud delete, IAM changes, data exfiltration, unauthorized persistence
  (cron/ssh/shell-profile), irreversible local destruction, **self-modification of `.claude` config**, and more.
  Config: top-level `autoMode` in settings.json — `environment` / `allow` / `soft_deny` / `hard_deny` (prose
  arrays; `$defaults` keeps built-ins). *In auto mode `permissions.deny` is enforced but largely redundant with
  the classifier; `permissions.allow` is mostly inert (broad rules dropped).* *Don't build a custom command
  guard for the things the classifier already covers — a PreToolUse hook is only needed for bypass-mode coverage
  or landmines the classifier can't know.*
- **bypassPermissions** — no classifier, deny ignored; only `ask` rules + `rm -rf /`|`~` circuit-breaker + hooks fire.
- **sandbox** — native (`sandbox.enabled`).

## Tools / integrations
- **MCP** — native client + a registry/connectors. *Don't build MCP bridges that duplicate official servers.*
- **computer-use** + **claude-in-chrome** — native desktop/browser control. *Don't build a computer-use agent.*
- **WebSearch / WebFetch** — native. **Semgrep** (security scan), **context7** (live library docs) — via plugins.
- **statusline** — receives full context/cost/rate-limit data; updates each turn. **CLI-only** (terminal status
  bar); does NOT run in the Desktop app. *Desktop equivalent = the usage ring by the model picker.*

## Scheduling
- **`/schedule`** (cloud routines, cron) + **ScheduleWakeup** + **`/loop`**. *Don't build a cron manager
  (a custom build is obsolete).*

---
## Verified-this-session deltas (2026-06-17)
- Hooks are blind to context fill → context-meter is statusline-only, user-facing (not a hook).
- auto-mode classifier defaults are extensive → custom deny-lists are mostly redundant for auto-mode users.
- `brain`/`tech-docs`/`architecture-review`/`skill-creator`/`consolidate-memory` are native → no porting needed.
- `groom`/`pulse`/`audit-claude` were provided by a prior framework (now retired) → groom rebuilt as `/groom`; a deep
  `.claude` audit remains a candidate skill (audit taxonomy recoverable from git history).
