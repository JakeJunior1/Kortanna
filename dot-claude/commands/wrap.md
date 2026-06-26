---
description: Pre-compact save — update this repo's docs + memories, commit, push, and clear the compact gate so /compact can proceed.
---

You are about to compact. Do a COMPLETE, intelligent save of the CURRENT repository so the next session resumes as if nothing was lost. Operate only on the current repo (cwd / `git rev-parse --show-toplevel`).

Do this:

1. **Review the session.** Skim what we actually did and what's still in flight. Identify anything now out of date or unrecorded.

2. **Update docs that drifted — only the ones that genuinely changed.** The relevant `CONTEXT.md`(s), `planning/` (roadmap, decisions, srd), `README`, status notes. Leave accurate docs untouched. Follow this repo's own conventions (append-only decision records, archive-before-overwrite, "one fact one location", dates as absolute `YYYY-MM-DD`, etc.). **In an orchestrated project a *worker* session's `/wrap` must NOT touch the planning board (`planning/todo.md`/`progress.md`) — that's the planner's (single-writer, hook-enforced): wrap your memory + non-board docs + commit only; the planner moves `progress→completed-tasks` at merge.**

3. **Update memory — capture, then distill to the durable record.** First refresh the project's **native auto-memory** (the auto-loaded index + entries) with current state, key decisions, and exact next-up tasks — absolute dates, update the index. Then, **if the project keeps an in-repo `memory/` as its durable record** (`primer.md` · `decisions.md` · `lessons.md`), **distill** this session's durable, worth-keeping captures up into it — the in-repo record is the version-controlled subset that travels with the repo (VAN-CLIEF §9: native = capture, in-repo = durable; `/groom` later consolidates across layers). Promote the durable bits; don't copy raw native notes wholesale. If the repo has no memory system, skip this step.

   **Planner sessions also wrap the global brain.** If you're a planning/orchestrator session managing projects from `~/Developer`, additionally distill any **generalizable** orchestration wisdom from this session into the global **`~/Developer/memory/`** (`primer` · `lessons` · `decisions`) — only what helps across **any** project (how you orchestrate; a reusable pattern; a corrected approach), **never** project-specific state (that stays in the managed project's own `memory/`); thin organizing pointers are fine — keep it lean and hand-curated. `~/Developer` is **not a git repo** → this is a file save, not a commit (the precompact gate fails open there — VAN-CLIEF §9).

   **Queue what compounds — capture the candidate, never author it (karpathy §5).** If a **correction recurred** this session (the same mistake/guidance hit more than once) or a **procedure/role kept repeating**, append a ONE-LINE dated candidate (**creating the file if absent**) — a behavioral rule → `memory/rule-candidates.md`, a skill/subagent/abstraction → `memory/improvements-queue.md` (planner sessions also append to the global-brain `~/Developer/memory/` copies). Don't write the rule/skill itself — just queue it; `/groom` later reviews + (on your approval) graduates it. Skip silently when nothing recurred.

4. **Commit + push** everything above (follow the repo's branch convention — this repo commits to its working branch).

5. **Clear the compact gate** so `/compact` can proceed next. The gate is per-session + worktree-safe
   (the legacy path keeps an already-running older guard happy; it harmlessly no-ops in a worktree):
   ```bash
   touch "$(git rev-parse --absolute-git-dir 2>/dev/null)/.precompact-ready-${CLAUDE_CODE_SESSION_ID:-shared}"
   touch "$(git rev-parse --show-toplevel 2>/dev/null)/.git/.precompact-ready" 2>/dev/null || true
   ```

6. **Report** a one-screen summary of what you saved, then end with exactly: **"Saved — you can run /compact now."**

Be thorough but surgical: capture precisely what a fresh session needs to continue seamlessly, nothing more. Do NOT compact yourself — that's the user's next step.
