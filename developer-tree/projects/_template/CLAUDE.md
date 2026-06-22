# CLAUDE.md — <Project Name>

<One sentence: what this project is + who it's for.> Home base: `projects/<project>/` (the repo root = the main-branch checkout).

> Auto-loads when an agent works in this project. Apply the method in
> `~/Developer/guide-setup/van-clief/VAN-CLIEF-RULES.md`; stamp from `…/van-clief/templates/`.

## Workspace Map
```
<project>/                       — THE git repo (this folder = the main-branch checkout)
├── CLAUDE.md      — this file · CONTEXT.md — working detail (load tables, process, do-nots)
├── planning/      — todo.md (task queue · planner-owned) · progress.md (rollup)
├── memory/        — primer.md (state) · decisions.md (append-only)
├── .orchestrated  — marker: main is merge-only (activates the main-protection hook)
├── <code>         — production code; reaches main ONLY via PR merge
└── branches/<task>/ — gitignored per-task worktrees; work happens here
```

## Stack · Routing · Commands
- **Stack:** <language / framework / db / deploy>
- **Routing:** <task → where to work>
- **Commands:** <dev · test · build · lint>

## Conventions
- Spec before code; one fact, one location; lowercase-hyphen naming.
- Secrets in `.env` (gitignored). Never hardcode.

## Current State
<done · in progress · next>

## Avoid
- <project non-negotiables>
