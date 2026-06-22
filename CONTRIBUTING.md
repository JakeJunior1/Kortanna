# Contributing to Kortanna

Thanks for taking a look. Kortanna is a **config + methodology bundle**, not a runtime app — it's the
Van Clief / ICM guide plus the Claude Code wiring (commands, hooks, rules, templates, `settings.json`).
So "contributing" mostly means improving docs, the method, the templates, or the guardrail hooks.

## Ways to help
- **Fix or clarify the method** — `guide/van-clief/VAN-CLIEF-RULES.md` is the canonical source. One fact, one
  location: improve it in place rather than duplicating a rule elsewhere.
- **Harden a hook** — the bash guardrails in `dot-claude/hooks/`. They must stay **fail-open** (a bug in a hook
  must never block a user's edit/commit/push) and must resolve the repo from `CLAUDE_PROJECT_DIR`/`PWD`, not
  assume a fixed path. Test on macOS/Linux *and* note Windows (Git Bash / WSL) behavior.
- **Improve a template** — the stamping kits in `guide/van-clief/templates/` and the `developer-tree/_template`s.
- **Docs** — `README.md`, `SETUP.md`, the `manifest/`.

## Ground rules
- **Keep it declarative and model-agnostic.** The guide is plain-language method, not vendor-specific prompt syntax.
- **No secrets, ever.** No API keys, tokens, personal paths, or private project/client names in any committed
  file. Credentials are always the user's to supply — see [`manifest/credentials.md`](manifest/credentials.md).
- **Surgical changes.** Touch only what your change needs; match the surrounding style; don't refactor things
  that aren't broken.
- **Conventional-ish commits** are appreciated (`fix:`, `feat:`, `docs:`), but a clear plain-English subject is fine.

## PR process
1. Fork, branch, make a focused change.
2. If you touched a hook, confirm it still fails open (rename a dependency / feed it junk input — it must not
   hard-block) and say how you tested it in the PR.
3. Open a PR describing **what** changed and **why**, with a usage example if relevant.

By submitting a PR you agree your contribution is released under the project's [MIT License](LICENSE).
