# Security Policy

## What Kortanna is (and the trust model)
Kortanna is **configuration and documentation** — a methodology guide plus Claude Code wiring (bash hooks,
slash-commands, rules, templates, `settings.json`). It ships **no secrets** and **no runtime service**.

The guardrail **hooks are a discipline backstop, not a security boundary.** By design they **fail open** — a
bug in a hook (or a missing dependency like `jq`/`bash`) must never block your work, which also means they do
**not** sandbox or contain anything. They reduce footguns (e.g. an accidental commit to `main`, a push before
review); they are not an isolation mechanism. **Real isolation is your OS and Claude Code's own permission
model**, not these scripts. Treat any hook as bypassable and advisory.

## Reporting a vulnerability
Please report privately — **do not open a public issue** for a security problem.
- Use **GitHub Security Advisories**: the repo's **Security** tab → **"Report a vulnerability."**

A useful report includes a description, the affected file (path + line range), how to reproduce against the
latest `main`, and what the impact is. There is **no bug bounty** — this is a personal open-source project.
Reporters are credited unless they ask otherwise.

## In scope
- A committed file that **leaks a secret, token, or private path** (there should be none — if you find one, report it).
- A hook, template, or command that could be coerced into **executing attacker-controlled input** or that
  instructs an agent to take a destructive/unsafe action without surfacing it.
- A template or doc that steers users into an **insecure default** (e.g. committing keys).

## Out of scope
- "A guardrail hook can be bypassed / disabled" — they're advisory and fail open **by design** (see above).
- Prompt injection against *your own* agent, or the consequences of permissions you grant Claude Code.
- Third-party plugins/MCPs the manifest points to — those are the upstream projects' responsibility; you supply
  and review your own keys (see [`manifest/credentials.md`](manifest/credentials.md)).
