---
description: Workspace groom — assess drift, refresh stale context/docs, enforce backlog hygiene, log the pass. The periodic whole-workspace complement to /wrap.
---

Run a grooming pass on the CURRENT workspace (cwd / `git rev-parse --show-toplevel`) so its **documented state
matches reality**. Follow the Van Clief layer chain — read what each layer points to, don't assume a fixed path:
CLAUDE.md (L0) → CONTEXT.md (L1) → `planning/` (roadmap · decisions · todo) + `memory/`.

## 1. Pulse first (read-only) — assess drift
Before changing anything, take a fast health read:
- Read the workspace CLAUDE.md / CONTEXT.md / planning docs + the memory index.
- For each tracked area, compare **documented state vs filesystem reality** (file mtimes, recent git activity,
  tasks marked open vs actually done).
- Score **drift** = how far the docs lag reality: **0** clean · **1–7** minor (fix now) · **8–14** moderate
  (docs likely misleading the model) · **15+** critical (sessions acting on stale context).
- Present a short dashboard (area · status · days-stale · drift score) and which areas are due.
- **Wait for confirmation before editing.** If drift is 0, say so and stop — don't manufacture work.

## 2. Groom active state
Walk the current docs/status: close what's done (outcome + date), update what changed, flag what's now wrong.
**Surgical** — touch only what genuinely drifted (same discipline as `/wrap`). Convert relative dates to absolute
`YYYY-MM-DD`. Honor the repo's conventions (append-only decision records, "one fact one location").

## 3. Groom memory + the self-improving loop
The *dream pass* — keep memory lean and let lessons compound (Van Clief §9). **(Per-session distillation — native
capture → the project's in-repo `memory/` — is `/wrap`'s job; `/groom` is the periodic cross-layer consolidation
+ upward graduation, not the per-session capture.)**
- **Consolidate:** re-read the memory layers — per-project **native auto-memory** (capture) + the project's
  **in-repo `memory/`** (`primer`/`decisions`/`lessons` + the `rule-candidates`/`improvements-queue` backlog, harvested below) · global `~/Developer/memory/` ·
  `~/.claude/rules/` — and **merge duplicates, resolve contradictions, prune stale entries, refresh the
  index.** Memory bloats like a Current State block — trim it.
- **Graduate lessons — copy up *and* delete down:** when a lesson has proven universal (holds in every
  project/tool), promote it into the higher layer (`~/.claude/rules/karpathy.md`, or a project `CLAUDE.md`)
  **and remove it from the lower layer.** Leaving the duplicate behind is what causes drift — one fact, one location.
- **Harvest the proposal backlog `/wrap` fed, then graduate (suggest, never auto-create):** read
  `memory/rule-candidates.md` (proposed rules) + `memory/improvements-queue.md` (proposed
  skills/subagents/abstractions) — the per-session candidates `/wrap` queued — plus the global-brain copies
  (`~/Developer/memory/`). For each that's **proven out** (recurred enough to be worth it), graduate it: a
  rule → `~/.claude/rules/karpathy.md` (or a rule file); a *procedure* → a **skill** (`skill-creator` /
  `writing-skills`); a recurring *role* → a **subagent-type** (`~/.claude/agents/<name>.md`). **De-dupe across
  the project + global copies before graduating, and clear the entry from BOTH** (one-fact-one-location).
  Also surface any NEW candidate not yet queued. Name what each covers; **the operator approves before anything is
  authored** — no auto-generated, unreviewed rules/skills/agents.
- **Unattended run = report only:** flag graduation candidates, skill candidates, and bloat as findings; never
  apply them without the operator (same rule as the system audit below).

## 4. Groom the backlog
Enforce time-based hygiene: **review-by** = High 7d / Med 14d / Low 30d; **staleness** = 2× review-by → archive
with a note. Items past review-by → surface "decide or kill." **Graduation is explicit:** ask which backlog
items are ready to become active **TASKS** (bounded) or **PROJECTS** (complex) — never graduate silently. Items
may move backward too (active → backlog → deferred).

## 5. Groom directories + system
- **Project/client dirs:** flag orphans or anything new since last groom → archive or reclassify (archive > delete).
- **System layer (`~/.claude` config audit):** sanity-check the hand-authored config — hooks parse (`bash -n`) and
  their referenced files exist + are executable; commands and rules aren't broken or stale; `settings.json` is valid
  JSON; no orphaned/duplicate entries or dead references. Flag what's wrong — in an **unattended run, report only,
  don't auto-fix.** (A DEEP `.claude/` audit — classify duplicate/diverged/stale/promote-to-global with per-item
  approval — remains its own dedicated pass.)
- **Third-party tooling currency:** list enabled plugins whose marketplace source is non-`anthropics`
  (`claude plugin marketplace list`) — their upstream re-pull/drift status is **owned by `/freshness` §2**
  (don't duplicate the check here). Surface a pointer to run `/freshness` if it's overdue, and flag any
  newly-installed third-party plugin so freshness's drift check covers it.

## 6. Log the groom
Append a short summary to the workspace's decisions/log per its convention: date · areas reviewed · drift
before→0 · changes · graduated lessons & backlog items · proposed skills · archived items · next-due. Reset the
mental drift score to 0.

---
**Principles:** archive > delete (you can't un-delete) · every file earns its place (explain it in 5s or it
moves) · if it's not current, it's harmful · clean as you go. **Safety:** report first; get approval before any
destructive move; process lowest-risk first; never batch-delete without per-item confirmation.

*(Procedure salvaged from a prior framework's groom/pulse + drift model, generalized to the Van Clief layers and
stripped of that framework's machinery. Companion to `/wrap` — wrap = save one repo before compact; groom =
periodic whole-workspace hygiene.)*
