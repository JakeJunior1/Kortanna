# Review before push (global)

**Code does not reach a trunk (default branch) unreviewed.** An *independent* review — a separate agent with fresh context, not the same context that wrote the code — runs before the work lands. This is enforced by a `PreToolUse` guard (`~/.claude/hooks/pre-push-review-guard.sh`): a push made while on the default branch is denied until a fresh review gate exists. Feature-branch pushes are not gated — there the PR is the review point.

Don't wait for the hook to remind you. When work is ready to push, **proactively** run the review yourself (the `/ship` command does this end-to-end), the same way you proactively `/wrap` before a compact.

## You judge the depth — light vs full
- **Light** (review the diff → push to trunk): localized, low-risk, clear blast radius — UI tweaks, docs, isolated refactors, a self-contained feature. One independent adversarial reviewer on the diff; fix blockers; push. A small follow-up "harden (review of <sha>)" commit is the audit trail.
- **Full** (feature branch + PR + review on the PR): large or risky — money/correctness-critical surfaces (order execution, risk guardrails/limits, kill-switch, sizing, data-fidelity/indicator math), schema/migrations, auth/secrets, or broad multi-file changes you can't fully cover in one pass. **When unsure, go full.**

## Tooling & escalation
- The independent review can be an **agent-spawned reviewer subagent** — a fresh-context reviewer over the diff that the agent launches itself (via the `Agent`/`Task` tool). Automatic, no human typing; this is the standard in-loop / **light**-path review (what `/ship` runs end-to-end).
- **`/code-review ultra`** (deprecated alias `/ultrareview`) = Anthropic's **billed, multi-agent cloud** review. It is **user-invoked only — an agent cannot launch it.**
- **Escalation is the agent's job:** when a change hits the **full/critical** triggers above (order execution, risk guardrails/limits/sizing/kill-switch, data-fidelity/indicator math, schema/migrations, auth/secrets, broad multi-file), the agent still runs the standard subagent review, then **stops and tells the human to run `/code-review ultra` before merge**, naming which trigger fired. Detect-and-prompt is the agent's; running ultra is the human's.

## Non-negotiables
- The review must be *real*: adversarial, hunting actual defects (correctness, edge cases, security, broken assumptions), reading surrounding code — not a rubber stamp. Address blockers before pushing.
- Never drop the gate (`touch .git/.review-ready`) just to get past the hook without a review having run.
- If the gate blocks a push you believe is a **false positive** (e.g. a hook misfire — a feature-branch push from a worktree misread as a trunk push), **STOP and flag the human in your own session** — state why you think it's wrong and wait for a human to fix the hook or clear it. Do **not** `touch` the gate, retry-to-bypass, or otherwise work around it. (In auto/unattended mode you can't reliably reach an absent human, so surfacing it in your session output *is* the escalation.)
- If the review finds nothing real, say so — don't manufacture issues.
- The hook fails **open** (a script bug never blocks a push); the discipline is yours to keep, the hook is the backstop.
