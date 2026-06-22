---
description: Review-then-ship — run an independent (separate-agent) review of the unpushed work, then push small/low-risk diffs to the trunk or open a branch+PR for large/risky ones. Satisfies the pre-push review gate.
---

You are shipping the current repo's unpushed work **through an independent review** — never straight to the trunk unreviewed. Operate only on the current repo (`git rev-parse --show-toplevel`).

## 1. Scope the unpushed work
- `git status` and `git log @{u}..HEAD --oneline` (fallback `git log origin/<default>..HEAD`). If nothing is unpushed, say so and stop.
- Read the actual diff: `git diff @{u}..HEAD` (or `git log -p`). You decide the path from what it contains.

## 2. Decide LIGHT vs FULL — and say which, and why
**FULL** (feature branch + PR + review on the PR) if the diff is **large or risky**:
- touches money/correctness-critical surfaces — order execution, risk guardrails/limits, kill-switch, position sizing, data-fidelity (feed/resample/indicator math that drives decisions), auth/secrets;
- schema changes / migrations;
- broad or cross-cutting (many files, large LOC, or hard to fully review in one pass);
- you are not confident a single reviewer covers the blast radius.

**LIGHT** (review the diff, then push to trunk) otherwise — localized, low-risk, clear blast radius (UI tweaks, docs, isolated refactors, a self-contained feature). When unsure, go FULL.

## 3a. LIGHT path
1. Spawn an **independent review agent** (Agent tool) on the unpushed diff. Prompt it adversarially: real defects only (correctness, edge cases, security, broken assumptions) with file:line, failure scenario, and severity — no style nits, no praise. Give it the commit range and tell it to read surrounding files, not just the patch.
2. Address every **blocker/should-fix** it finds (commit the fixes; a tiny follow-up "harden (review of <sha>)" commit is good — it leaves an audit trail). Re-review if the fixes were substantive.
3. Drop the gate and push:
   ```bash
   touch "$(git rev-parse --show-toplevel)/.git/.review-ready" && git push
   ```
   The pre-push guard consumes the gate and auto-approves the push to trunk.
4. Report: path taken, what the review caught, what you fixed, the pushed SHA(s).

## 3b. FULL path
1. Get the work onto a **feature branch** (don't push it to trunk). If the commits are sitting on the default branch locally:
   ```bash
   git branch <feature-name> && git reset --hard @{u}   # move commits to the branch, restore trunk to upstream
   git checkout <feature-name>
   ```
   (If already on a feature branch, skip this.)
2. `git push -u origin <feature-name>` (feature-branch pushes are not gated).
3. Open the PR: `gh pr create --fill` (refine title/body as needed).
4. Run the review (one strong reviewer for a moderate change; multiple adversarial dimensions + a verify pass for a big/risky one — or tell the operator they can run `/code-review ultra <PR#>` for the heavyweight cloud review). **Post the findings on the PR** (`gh pr review` / `gh pr comment`) so the review lives with the change.
5. Report: branch, PR URL, review summary, and that it's ready for the operator to merge after addressing.

## Rules
- The gate (`$REPO/.git/.review-ready`) is **only** dropped after a real review actually ran and blockers are resolved — never as a rubber stamp to get past the hook.
- If the review finds nothing real, say so explicitly (that's a valid outcome) — don't invent issues.
- Keep it surgical. This command reviews and ships; it does not refactor or expand scope.
