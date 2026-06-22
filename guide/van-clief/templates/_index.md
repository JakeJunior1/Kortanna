# Templates — project stamping kits

The guide's reusable **stamping kits**, sanitized from a recovered real-world production implementation. Use these when starting or scaffolding a new project — the repo's `CLAUDE.md` routes here for
"stamp a new project from a template." Model-agnostic, path-agnostic; fill the placeholders.

## What's here
- **`new-project/`** — the generic new-project kit: `project-CLAUDE.md.template` (the project L0 to fill) +
  `CONTEXT.md.template` (the in-workspace dispatcher), `planning/todo.md.template` + `progress.md.template`
  (the orchestration queue + rollup), `.orchestrated.template` (merge-only-main marker), `.gitignore.template`
  (ignores `branches/`), `setup-checklist.md` (root=main / git / remote / credential-scope handoff).
- **Archetype kits** — each ships a `plan.json` (sequenced task DAG) + `checklist.md` (deliverables):
  - `api-service/` · `saas-app/` · `mobile-app/` · `landing-page/`
- **`execution-workers/`** — reusable role-prompts for dispatched workers (base, frontend, backend, general,
  content-creator, market-research, research, code-reviewer, funnel-builder). `base.md` carries the **6-tier
  tool-selection tree** (SDK → MCP/CLI → CLI-wrapper → Preview → browser-automation → Computer-Use) + a model-agnostic clause +
  a JSON result contract — the shared spine the others build on.
- **`mission-brief.md`** — a generic mission/brief template with a `supersedes:` revision chain.

## Relationship to the live `_template/` skeletons
`~/Developer/projects/_template/` and `clients/_template/` are the minimal copy-me skeletons (the project
root = the main-branch checkout: `CLAUDE.md`/`CONTEXT.md`/`planning/`/`memory/` + gitignored `branches/`).
**These** kits are the richer, archetype-specific reference you stamp *into* a new project once you know its shape. Note: there's a rich `new-project/` kit but **no `new-client/` kit** — clients stamp **lean-only** from `clients/_template/` (add a client kit later if the need arises). The lean skeletons are *materialized instances* of the kit + VAN-CLIEF §9 (the canonical loop) — keep them in sync, don't fork.

> Provenance: sanitized from `a prior private repo` (`templates/`), 2026-06-17 — implementation-specific paths
> (custom paths, agent-comms, DB, RAG/secrets specifics) stripped.
