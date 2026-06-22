# CLAUDE.md — ~/Developer Global Brain (Layer 0)

You are an agent working under `~/Developer/`, a machine-wide dev environment. This is the **global
brain**: it orients you across every project/client and routes you to the right one. When setting up or
structuring anything new, apply the **Van Clief / ICM methodology** from the guide (see Routing) — don't
invent a scheme.

> Loose files at the dev root: `CLAUDE.md` (this — auto-loads), `CONTEXT.md` (working detail), `memory/`
> (thin cross-project state). **Each project/client owns its OWN `CLAUDE.md`/`CONTEXT.md`/`memory/` — this
> brain routes, it does not duplicate.**

## Workspace Map
```
~/Developer/
├── CLAUDE.md, CONTEXT.md, memory/  — this global brain (cross-project only)
├── guide-setup/      — THE methodology guide → van-clief/VAN-CLIEF-RULES.md
├── projects/         — personal projects (each = a git repo; root = main checkout, gitignored branches/ worktrees)
│   ├── <your-project>/   — replace with your real projects
│   └── _template/    — copy to start a new project
└── clients/          — one folder per client
    ├── <your-client>/    — (projects/ · research/ · brand-assets/)
    └── _template/    — copy to start a new client
```
Use this tree to locate files directly — don't Glob/LS the root to discover structure.

## Routing
| Situation | Go to |
|-----------|-------|
| Work in a personal project | `projects/<name>/CLAUDE.md` |
| Work for a client | `clients/<name>/CLAUDE.md` (+ their `projects/`) |
| Start a NEW project / client | copy `projects/_template/` or `clients/_template/`; apply `guide-setup/van-clief/VAN-CLIEF-RULES.md`; stamp from `…/van-clief/templates/` |
| Planning/orchestrator session (you're rooted here) | `guide-setup/van-clief/VAN-CLIEF-RULES.md` §9 "Multi-session orchestration" — your role, the per-task loop, the guardrails |
| Session start (planner) | `memory/primer.md` (current state) → `memory/lessons.md` (how to work here) — `memory/decisions.md` on demand |

## Conventions
- **Naming:** lowercase, hyphens, no spaces (`brand-assets/`, not `Brand Assets`).
- Each project/client is self-contained: its own `CLAUDE.md` + `CONTEXT.md` + `memory/`.
- Project root = the main-branch checkout (production); `branches/<task>/` = gitignored per-task worktrees (kept
  inside the project, off the dev root). Code reaches main only via merge.
- The brain routes, never duplicates project detail. Secrets gitignored per project.
- Read `CONTEXT.md` for load tables + the session-orchestration convention.
- **No Current State section here.** This brain is read concurrently by many planner sessions; current state lives
  in the memory layer (`memory/primer.md`), which the Routing table already points to. A status block here would be
  redundant (one-fact-one-location) and a drift hazard (VAN-CLIEF §4).
