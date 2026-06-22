# Claude Harness — Setup

A ready-made Claude Code harness: the same methodology, commands, hooks, rules, templates, plugin/MCP set, and
global-brain structure as the setup it was exported from — minus anything personal. The decisions are already
made; you fill in your name and your own keys, and you're running the same way.

**What you get:** the Van Clief / ICM methodology guide, a 3-layer memory model, multi-session orchestration
(planner + workers), guardrail hooks (merge-only main, review-before-push, post-compact resume, etc.),
project/client stamping templates, and a curated plugin/MCP/CLI set.

**What you DON'T get (intentionally scrubbed):** no projects, no client work, no API keys/secrets, no personal
memories or transcripts. Placeholders mark every spot you fill in.

---

## 0. Prerequisites
Install the CLIs in [`manifest/clis.md`](manifest/clis.md) first — **Claude Code, git, gh, node, python3**.
**Windows:** install **Git Bash** or use **WSL** so the bash hooks can run (see clis.md).

## 1. Place the files
> If you already have a `~/.claude/`, **back it up first** (`cp -R ~/.claude ~/.claude.bak`) and *merge* rather
> than overwrite — see step 1c.

**a. The wiring → `~/.claude/`**
Copy the contents of `dot-claude/` into `~/.claude/`:
```bash
mkdir -p ~/.claude
cp -R dot-claude/commands ~/.claude/
cp -R dot-claude/hooks ~/.claude/
cp -R dot-claude/rules ~/.claude/
cp -R dot-claude/skills ~/.claude/
cp -R dot-claude/scheduled-tasks ~/.claude/
cp -R dot-claude/scripts ~/.claude/
```

**b. The dev tree → `~/Developer/`**
```bash
mkdir -p ~/Developer
cp -R developer-tree/CLAUDE.md developer-tree/CONTEXT.md developer-tree/memory ~/Developer/
cp -R developer-tree/projects ~/Developer/        # contains projects/_template
cp -R developer-tree/clients  ~/Developer/         # contains clients/_template
cp -R guide ~/Developer/guide-setup                # the methodology guide
# optional: version the guide locally
( cd ~/Developer/guide-setup && git init -q && git add -A && git commit -qm "import guide" )
```

**c. settings.json (the one file to merge carefully)**
`dot-claude/settings.json` carries the **hooks wiring**, the **`enabledPlugins`** on/off map, and the
**`autoMode`** trust block. If you have **no** existing settings, just copy it:
```bash
cp dot-claude/settings.json ~/.claude/settings.json
```
If you **already** have a `settings.json`, merge these keys into yours instead of overwriting:
`hooks`, `enabledPlugins`, `autoMode` (and `permissions` if you want the same allow-list).

> **⚠️ Security-relevant keys — review these before you copy/merge.** This file was exported from a personal
> setup, so a few keys *relax* the permission system for convenience. **None is required for the harness to
> work** — keep, trim, or drop each to your own comfort (and your agent will likely pause on them, which is correct):
>
> - **`skipDangerousModePermissionPrompt: true`** — suppresses the confirmation Claude Code shows for
>   permission-bypass ("dangerous") mode. Shipped **on**; delete the line to keep the prompt. (`defaultMode` is
>   `"default"`, so the harness never *runs* in bypass mode on its own — this only affects the warning if you opt in.)
> - **`permissions.allow`** — Bash commands that run **without prompting** (`git add`/`commit`, `npm install`,
>   `gh repo:*`, `launchctl load`, version checks, …). Convenient, but `gh repo:*` and `npm install` are
>   non-trivial (repo deletion; arbitrary post-install scripts). Trim it to what *you* want auto-allowed, or set it
>   to `[]` to be prompted for everything.
> - **`autoMode.environment`** — the trust context "auto mode" uses to decide what's safe to do without asking. The
>   shipped lines assert pushes/PRs to your personal GitHub are *routine and trusted* — **rewrite them to your own
>   posture** (and fill the `<YOUR NAME>` / `<YOUR_GITHUB_USERNAME>` placeholders, §2 below).
>
> Everything else — `hooks` (this is what actually activates the guardrails), `env`, and the notification flags —
> is benign and needed. One more to eyeball: `enabledPlugins` + `extraKnownMarketplaces` register **third-party
> plugin sources** (enabling a plugin runs their code), so install only the ones you recognize — see
> [`manifest/plugins.md`](manifest/plugins.md).

## 2. Fill in the placeholders
Search the placed files for `<…>` and replace:
- `~/.claude/settings.json` → `<YOUR NAME>`, `<YOUR_GITHUB_USERNAME>` (in the `autoMode.environment` block).
- `~/Developer/CLAUDE.md` → swap the `<your-project>` / `<your-client>` examples in the Workspace Map +
  Routing table for your real ones (or leave them until you create projects).

## 3. Install plugins
Follow [`manifest/plugins.md`](manifest/plugins.md) — add the marketplaces, install the **core** set, then any
**optional** (account-gated) ones you actually use. `claude plugin list` to verify.

## 4. MCP servers + keys
Follow [`manifest/mcps.md`](manifest/mcps.md). Most come with their plugin. Add standalone ones (e.g.
perplexity) with **your own** API keys. Never paste a key into a file you'll commit. `claude mcp list` to verify.
[`manifest/credentials.md`](manifest/credentials.md) is the one-stop checklist of every value you supply
(placeholders + the optional keys) — Claude Code registers keys via `claude mcp add`/plugin auth, not a `.env`.

## 5. Weekly maintenance task (optional but recommended)
`~/.claude/scheduled-tasks/guide-freshness-check/SKILL.md` is a **report-only** weekly dev-env health check
(external currency + internal drift + `~/.claude` audit). To enable it, ask Claude Code to **create a weekly
scheduled task** that runs the `guide-freshness-check` skill — or just run **`/freshness`** manually when you
want a pulse. (It only writes two report files under `~/Developer`; it never changes anything on its own.)

## 6. Verify it's live
Restart Claude Code, then check:
- **Commands:** `/wrap`, `/groom`, `/ship`, `/freshness` are available.
- **Hooks:** start a session and confirm the guardrails fire (e.g. a commit attempt on `main` in a project
  marked `.orchestrated` is blocked; a `/compact` runs the precompact gate). On Windows, confirm `bash` is on
  PATH or the hooks will silently no-op.
- **Rules:** `~/.claude/rules/karpathy.md` + `review-before-push.md` are present (always-loaded).

## 7. Read the method
Open **`~/Developer/guide-setup/van-clief/VAN-CLIEF-RULES.md`** — the canonical methodology (§1–§9). Point any
agent at `~/Developer/CLAUDE.md` and it routes itself from there. To start a project or client, copy the
matching `_template/` and stamp from `guide-setup/van-clief/templates/`.

---

### Notes
- The hooks/commands/rules live in `~/.claude` and the brain in `~/Developer` — **neither is a git repo**, so
  this wiring is account-/machine-local. The guide repo carries the *method*; this bundle is the *wiring* that
  runs it (see VAN-CLIEF §9, "the method's wiring lives off-repo").
- Everything here is yours to edit. The `memory/` files (`primer`, `decisions`, `lessons`) are starter
  skeletons — `lessons.md` is seeded with reusable operating defaults; make them yours.
