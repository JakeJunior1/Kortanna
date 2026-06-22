# AI Dev-Env Guide (Van Clief / ICM)

A reusable **dev-environment methodology guide** — the distilled Van Clief / Interpretable Context
Methodology (ICM) for structuring AI-assisted projects. Point an agent at this guide when starting any new
project or build; it reads [`CLAUDE.md`](CLAUDE.md) → [`van-clief/VAN-CLIEF-RULES.md`](van-clief/VAN-CLIEF-RULES.md)
and sets things up accordingly.

> Synthesized from the **Clief Notes** courses (Jake Van Clief / Eduba) and grounded in the ICM/MWP paper
> (arXiv 2603.16021, MIT-licensed), Anthropic's Agent Skills spec, and the Claude Code Remote Control docs.
> The original course material is **not redistributed** here — this is the method, in its own words, with attribution.

## Layout
```
guide-setup/
├── CLAUDE.md              — Layer-0 brain: identity + routing for agents (auto-loads)
├── README.md             — this file
└── van-clief/            — THE GUIDE
    ├── VAN-CLIEF-RULES.md — the canonical methodology (§1–§9)
    ├── templates/        — project stamping kits (new-project · archetypes · execution-workers · mission-brief)
    └── model-capabilities.md — native-capability ledger (§7: check before building custom tooling)
```

## How to use it
1. **Apply the method:** read [`van-clief/VAN-CLIEF-RULES.md`](van-clief/VAN-CLIEF-RULES.md) — the 3-layer
   workspace architecture, folder/naming conventions, `CLAUDE.md`/`CONTEXT.md` structure, multi-session
   orchestration (planner + workers), pre-build planning, and session continuity.
2. **Stamp a new project** from a kit in [`van-clief/templates/`](van-clief/templates/) (generic new-project,
   archetypes — api-service · saas-app · mobile-app · landing-page, execution-workers, mission-brief).

## Credits
Methodology: **Jake Van Clief / Clief Notes (Eduba)** + the ICM/MWP paper (arXiv 2603.16021, MIT). This guide
is an independent implementation/synthesis with attribution; it does not redistribute the source courses.
