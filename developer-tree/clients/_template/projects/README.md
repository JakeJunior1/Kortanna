# projects/

One folder per client project. To add one: copy `~/Developer/projects/_template/` here under a
lowercase-hyphen name, fill its `CLAUDE.md` + `CONTEXT.md`, then add **one routing row** to this
client's `CLAUDE.md` pointing at the new project's `CLAUDE.md` (VAN-CLIEF-RULES.md §4 "add a workspace").

Each project keeps the standard shape: root = main-branch checkout, gitignored `branches/<task>/`
worktrees, `planning/` + `memory/`. Never cross-reference one client's projects from another client.
