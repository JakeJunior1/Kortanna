---
name: guide-freshness-check
description: Weekly dev-env maintenance (REPORT-ONLY): external currency + internal drift pulse + ~/.claude audit → one combined report in ~/Developer.
---

Run the weekly DEV-ENV MAINTENANCE pass. **STRICTLY REPORT-ONLY** — your only writes are the two output files below; do NOT edit any docs, do NOT install/update/enable/disable any plugin or MCP, do NOT apply any fix. Detect + recommend only; the operator and a follow-up agent review and apply.

Do all three checks, then write ONE combined report:

(A) EXTERNAL currency — follow `~/.claude/commands/freshness.md` exactly: referenced github repos in the guide's library-reference.md via `gh api` (drop reserved paths like topics/; detect 404 by exit code); `claude plugin marketplace update` then `claude plugin list`; `claude mcp list` core MCP health (context7 · semgrep · pinecone · chrome-devtools · serena · sequential-thinking) — IGNORE the dept-pack `plugin:engineering|data|design:*` stubs. Guide root = `$HOME/Developer/guide-setup`.

(B) INTERNAL drift — do `~/.claude/commands/groom.md` STEP 1 ONLY (the read-only "pulse"): compare documented state vs reality for the guide repo and the global brain (`$HOME/Developer/CLAUDE.md` + `CONTEXT.md` + `memory/`); score drift. Do NOT do groom's editing steps 2–5.

(C) ~/.claude AUDIT — groom step 4's system-layer check: hooks parse (`bash -n`) + their referenced files exist; commands/rules not broken or stale; `settings.json` valid JSON; no orphans.

OUTPUT (the only things you write):
- Overwrite `$HOME/Developer/_dev-env-health.md` — three sections (External / Internal drift / ~/.claude), each listing ONLY what needs action as `{what · where (file:line) · recommended fix}`; if a section is clean, say "✅ current". Keep it short.
- Append one dated line to `$HOME/Developer/_dev-env-health-log.md`: `YYYY-MM-DD · maintenance · <one-line verdict per section>`.

Then summarize the report in your final message. Nothing else.