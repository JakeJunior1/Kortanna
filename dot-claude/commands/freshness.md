---
description: Upstream-currency check (REPORT-ONLY) — referenced repos (dead/archived/renamed), plugin/marketplace drift, MCP health. On-demand; the weekly cadence is the combined dev-env-maintenance routine. The external complement to /groom (internal drift).
---

Run a FRESHNESS check: is the **external** world the guide depends on still current? This is the upstream-currency complement to `/groom` (internal doc/dead-item drift). Be thorough but fast, and **tolerate individual failures** — one rate-limited API call or dead host must not abort the run.

**Operate from the guide repo regardless of cwd** (this may fire from a cron in any session):
```bash
GUIDE="$HOME/Developer/guide-setup"
```

## 1. Referenced repos — dead / archived / renamed
- If you keep a repo registry/watchlist (a `*.md` of `github.com/<owner>/<repo>` entries), currency-check those repos; otherwise skip this sub-step.
- **First drop github reserved paths** (not repos): `topics/ sponsors/ features/ marketplace/ settings/ orgs/ collections/ trending/ apps/`.
- Detect each repo's state by **exit code** — a 404 exits non-zero but still prints error JSON, so don't infer from stdout:
  ```bash
  if out=$(gh api "repos/$r" --jq '.full_name + "|" + (.archived|tostring)' 2>/dev/null); then
    full=${out%|*}; arch=${out#*|}   # arch=true → ⚠️ ARCHIVED · full≠$r → 🔁 RENAMED→$full · else ✓ live
  else echo "❌ GONE/404: $r"; fi      # non-zero exit = gone
  ```
  (GitHub redirects renamed repos, so a 🔁 link still resolves but its canonical name has drifted — worth updating.)
- Non-github URLs (skillsmp.com, agentskills.io, modelcontextprotocol.io, …): `curl -sS -o /dev/null -w '%{http_code}' -L --max-time 15 <url>` → flag non-2xx/3xx as ⚠️ unreachable.
- Report a compact table of **only the non-✓ rows**, plus a count (`N checked, M need attention`).

## 2. Plugins / marketplaces — refresh, inventory, upstream drift
- `claude plugin marketplace update` — refresh all marketplace catalogs to latest.
- `claude plugin list` — inventory installed plugins (version · scope · enabled/disabled).
- `claude plugin marketplace list` — maps each marketplace → its **source repo** (`owner/repo`). **This is the registry** — no hand-maintained list; the CLI tracks the source, so it never goes stale.
- **Upstream drift — third-party plugins (the "re-pull?" check).** First-party marketplaces (owner `anthropics/*` — `claude-plugins-official`, `anthropic-agent-skills`, `knowledge-work-plugins`) are kept current by the `marketplace update` above. For every **enabled** plugin whose marketplace source is **non-`anthropics`** (e.g. `cli-anything`→`HKUDS/CLI-Anything`, `ui-ux-pro-max`→`nextlevelbuilder/ui-ux-pro-max-skill`, plus any superpowers/voltagent/planning-with-files/hydradb ones), compare the **installed version** (`plugin list`) against the **upstream latest** and flag drift:
  - **semver** (e.g. `2.5.0`): `gh api repos/<owner>/<repo>/releases/latest --jq .tag_name` (fall back to newest `tags/` if no releases) → installed behind upstream? flag.
  - **commit-pin** (e.g. `bf3cc39e2edb`): `gh api repos/<owner>/<repo>/commits/HEAD --jq '.sha[0:12]'` vs the installed short-sha → differ? flag. (Tolerate a missing/renamed default branch — don't abort.)
  - Report each drifted plugin as `{plugin · installed → upstream · recommend `claude plugin update <plugin>` (restart to apply)}`.
- Flag any `unknown`-version plugin for a manual look. **(Still REPORT-ONLY — recommend the `update`, never run it.)**

## 3. MCP health
- `claude mcp list` — report each server's state: ✓ connected / ✗ failed / ! needs-auth.
- **Focus on the intentional core** (context7 · semgrep · pinecone · chrome-devtools · serena · sequential-thinking): alarm only if one of these FLIPS to ✗ failed.
- The `plugin:engineering|data|design:*` **dept-pack connector stubs are known noise** (mostly ✗/!) when those packs are disabled — don't alarm on them. NOTE: `claude mcp list` shows CLI/plugin MCPs only; **app-level desktop connectors** (your connected apps) won't appear here.

## 4. Report (REPORT-ONLY) → log
- **REPORT-ONLY — never act.** Your ONLY writes are the log + report. Never edit guide docs, never install / update / enable / disable a plugin or MCP, never apply a fix — **even in auto/unattended mode.** Detect and recommend; a separate review-and-apply pass (with the operator) makes the changes.
- **Actionable findings:** for each stale item give `{what · where (file:line) · recommended fix}` so a follow-up agent can execute it after the operator eyeballs it. If clean: "✅ everything current."
- **Log:** append one dated line to `~/Developer/_dev-env-health-log.md` — `YYYY-MM-DD · freshness · N repos / M plugins / K MCPs · <one-line verdict>`.
- **Standalone vs weekly:** on-demand, report findings in-session + log. The **weekly cadence** is the combined **dev-env-maintenance** scheduled task (`scheduled-tasks` MCP, `~/.claude/scheduled-tasks/`, survives restarts / runs on next launch if missed) — it runs this check + `/groom`'s read-only pulse + the `~/.claude` audit, writing ONE combined report to `~/Developer/_dev-env-health.md`. Manage: `mcp__scheduled-tasks__list_scheduled_tasks` → `update_scheduled_task`. (NB: `CronCreate` is session-only here, not used.)

Keep it surgical: this checks currency and reports. It does not edit the guide's content or touch any plugin/MCP on its own.
