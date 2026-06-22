# CLAUDE.md — AI Dev-Env Guide (Global)

You are an agent working inside this repo. **This is a reusable dev-environment methodology guide:**
the distilled Van Clief / Interpretable Context Methodology (ICM) for structuring AI-assisted projects.
When the user asks you to set up, structure, or scaffold a new project, build, or workspace — **apply the
methodology defined here.** Do not reinvent a folder/context scheme; this *is* the scheme.

> This file lives at the repo root and auto-loads whenever cwd is inside the repo. It is the map (Layer 0),
> not the territory — the method itself is in `van-clief/VAN-CLIEF-RULES.md`. Declarative, model-agnostic.
> It is a **stable reference** read concurrently by many sessions, so it carries no mutable Current State
> block (§4).

## What this is
A reference the user points agents at when starting work. The single source of truth for the method is
**`van-clief/VAN-CLIEF-RULES.md`** (§1–§9: the 3-layer workspace architecture, folder/naming conventions,
CLAUDE.md / CONTEXT.md structure, do's & don'ts, pre-build planning, session continuity). Everything else
is templates / stamping kits.

## Workspace Map
```
guide-setup/
├── CLAUDE.md                 — this file (Layer 0: identity + routing)
├── README.md                 — human-facing orientation
├── van-clief/                — THE GUIDE
│   ├── VAN-CLIEF-RULES.md    — canonical methodology (§1–§9). Read this to apply the method.
│   ├── templates/            — project STAMPING KITS (new-project · archetypes · execution-workers · mission-brief)
│   └── model-capabilities.md — native-capability ledger (§7: check before building custom tooling)
```
Use this tree to locate files directly — do not Glob/LS from the root to discover structure.

## Routing
| Situation | Read |
|-----------|------|
| Apply the method / set up or structure a new project, build, or workspace | `van-clief/VAN-CLIEF-RULES.md` |
| Stamp a new project from a template (code / content / archetype) | `van-clief/templates/` |
| "What's already native?" (before building custom tooling) | `van-clief/model-capabilities.md` |

## Conventions
- **The guide is the method.** Apply `VAN-CLIEF-RULES.md`; don't invent a parallel scheme.
- **One fact, one location.** Don't duplicate a rule; link to its home.
- **Model-agnostic, declarative.** Plain language; this file carries no behavioral prompt syntax.

## Avoid
- Duplicating `VAN-CLIEF-RULES.md` content into other files instead of linking it.
- Treating this guide as project-specific — it's the *global* method, applied per project.
