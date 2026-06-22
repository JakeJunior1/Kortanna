# New Project Setup Checklist

> Run this at the planning→execution handoff, after the plan/brief is approved. Code scaffolding is delegated
> to execution agents.

---

## Brief header
Every project brief should carry a header block:
```
# Brief — {{PROJECT_NAME}}
supersedes: {{previous-brief-filename or "none"}}
date: {{YYYY-MM-DD}}
status: draft | approved | complete
```
The `supersedes:` field creates a revision chain so you can trace how scope evolved across planning sessions.

## Steps

### 1. Create the project from the template
```bash
cp -R <dev-root>/projects/_template <dev-root>/projects/{{PROJECT_NAME}}
cd <dev-root>/projects/{{PROJECT_NAME}}        # the repo root = the main-branch checkout
```
The skeleton ships the **core** files (every project): `CLAUDE.md` · `CONTEXT.md` · `.orchestrated` (main
merge-only) · `.gitignore` (ignores `branches/`) · `planning/{todo.md` ⏳ pending `· progress.md` 🔄 in-progress
board`}` · `memory/{primer.md · decisions.md}` (the durable record native distills up into). **Optional** files —
stamp from `van-clief/templates/new-project/` only when the project needs them: `srd.md`/`specs/`, `architecture`,
`roadmap.md`, `planning/research/`, `memory/{lessons,completed-tasks}.md`.

### 2. Initialize git
```bash
git init        # .gitignore already ships with the skeleton (ignores branches/)
```

### 3. Create the remote and set origin
```bash
gh repo create {{PROJECT_NAME}} --private --source=. --remote=origin
```

### 4. Write the project CLAUDE.md
Copy `project-CLAUDE.md.template` to `{{PROJECT_NAME}}/CLAUDE.md` and fill the placeholders from the brief:
`{{PROJECT_NAME}}` · `{{PROJECT_DESCRIPTION}}` · `{{TECH_STACK}}` · `{{VALIDATION_COMMANDS}}`. Then write the
**Project-Specific Rules** section fresh from the brief (not templated).

### 5. Assign credential scope
Give the project's agents only the credentials their role needs (least privilege): code agents → a scoped
git/host token; research agents → a search key; analysis-only agents → no tokens. Keep all secrets in a
gitignored `.env`.

### 6. Initial commit
```bash
git add .
git commit -m "Initial project setup"
touch .git/.review-ready        # one-time: clears the trunk-review gate for the scaffold push
git push -u origin main
```
After this, `main` is **merge-only**: production code lands via PR merge, never direct pushes
(enforced by the pre-push-review-guard + main-protection hooks). The planner still commits
brain docs (`*.md`) to main directly.

---

## What happens next
- The **planning session** owns `planning/todo.md` (the task queue) — it is the sole assigner.
- Dispatch **worker** sessions: root each at the project root, mount `~/Developer/guide-setup` as a
  **read-only** additional folder (role prompt + method — never the whole dev root, which would unseal other
  projects/clients), and assign it an `owner`-matched task — **the planner** moves it `todo.md` → `progress.md` at dispatch (`planning/*.md` is planner-only; workers never edit it). The worker
  works in its own `branches/<task>/` worktree (never on `main`), and reads the project `CLAUDE.md` + `CONTEXT.md`.
- Per-task loop, worker rules, Preview-first: the project `CONTEXT.md` (stamped from `CONTEXT.md.template`) carries the worker-facing summary; the canonical spec is `VAN-CLIEF-RULES.md` §9. (One fact, one location — don't restate the loop here.)
- Workers verify UIs with **Preview** (`mcp__Claude_Preview__*`) first; computer-use only when Preview can't.
- Code scaffolding is handled by worker agents (`/init`, community skills, or the brief's instructions).
