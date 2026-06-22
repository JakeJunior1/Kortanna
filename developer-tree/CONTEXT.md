# ~/Developer — CONTEXT.md (working detail)

Operator's manual for working across `~/Developer/`. Pairs with `CLAUDE.md` (the map).

## What to Load
| Task | Load | Skip |
|------|------|------|
| Orient at session start (planner) | `memory/primer.md` (state) + `memory/lessons.md` (how to work here) | everything else |
| Cross-project "why did we decide X" | `memory/decisions.md` | project internals |
| Work a specific project/client | that workspace's `CLAUDE.md` only | other workspaces |
| Set up something new | `guide-setup/van-clief/VAN-CLIEF-RULES.md` + the relevant `_template/` | — |

## Structure conventions
- **projects/** — personal projects. Each is a git repo whose **root = the main-branch checkout** (production),
  with gitignored `<name>/branches/<task>/` worktrees (→ PR), plus `<name>/CLAUDE.md` + `CONTEXT.md` +
  `planning/` (todo + progress) + `memory/`. *(A project with a different shape — e.g. a content workflow —
  follows its own CONTEXT.)*
- **clients/** — one folder per client: `<client>/CLAUDE.md` + `CONTEXT.md` (identity, engagement,
  confidentiality), `<client>/projects/<proj>/` (each a project with main/branches), `<client>/research/`,
  `<client>/brand-assets/`, `<client>/memory/`. **Never cross-reference one client in another.**
- **_template/** in each — copy → rename → fill `CONTEXT.md` → add a routing row in `CLAUDE.md`.

## Session orchestration (planning + workers)
**One planning/orchestrator session per project**, rooted here at the dev root (the session the `.planner`
marker + planner-file-lock hook scope to — it writes only `.md`). It is the sole task-assigner: tasks land in
that workspace's `planning/todo.md` (⏳/🔄/✅) and you dispatch each to a worker session that works in
`projects/<x>/branches/<task>/`. The per-task loop, worker role rules, Preview-first, and the guardrail hooks
are specced in `guide-setup/van-clief/VAN-CLIEF-RULES.md` §9 ("Multi-session orchestration"). **An agent
cannot start new sessions or change another session's model/effort — that wiring stays manual.**

## Session continuity (the workspace is stateful)
- **Session start:** read `CLAUDE.md` + `memory/primer.md` + `memory/lessons.md`.
- **Session end / before away:** update `memory/primer.md`; append cross-project decisions to `decisions.md`.
- **Verify against reality** before trusting the primer.
Project-specific progress lives in each project's own `memory/`, not here.

## Self-improving loop + 3-layer memory
Memory lives in three layers, one fact per layer (VAN-CLIEF §9):
1. **`~/.claude/rules/`** — always-loaded universal principles (`karpathy.md`, `review-before-push.md`). Rarely changes.
2. **`~/Developer/memory/`** — this **global planner** layer: `primer.md` (state) · `decisions.md` (append-only ADRs) · `lessons.md` (how you work, cross-project). Read on planner session start.
3. **per-project `memory/`** — **native auto-memory** (auto-loaded + recall), automatic, project-specific, distilled into a lean in-repo `memory/` by `/wrap`.

**Capture corrections to the right layer:** project-specific → that project's native auto-memory · global/orchestration → `memory/lessons.md` · permanent + universal → graduate into `~/.claude/rules/karpathy.md`. **Trim periodically** (the dream pass) so each stays lean.

## What NOT to Do
- Don't duplicate a project/client's own `CLAUDE.md`/`CONTEXT.md` into the brain — link to it.
- Don't put project-specific detail in the global memory; keep it cross-project + thin.
- No spaces/capitals in folder names (lowercase-hyphen).
- Don't hardcode secrets.
