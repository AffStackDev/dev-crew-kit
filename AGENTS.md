# Dev Crew setup kit: note for Codex

This folder is a setup kit. It is meant to be run by **Claude Code**, which walks the user through the whole setup
(see `CLAUDE.md` and `playbook/`). The Codex part of the setup is `playbook/10-codex.md` and
`playbook/11-claude-codex-exchange.md`; Claude does it with the user, and the files it installs for you are
`templates/codex/global-AGENTS.md` (your global `AGENTS.md`) and `templates/project/AGENTS.md` (per project).

If the user opened this folder in Codex first:

1. Tell them the guided setup runs in Claude Code (the Code tab of the Claude desktop app, or the `claude` CLI) and
   point them to `START-HERE.md`.
2. If they want you to do the setup instead, you may follow `playbook/` yourself. Read `playbook/00-guide-rules.md`
   first and apply it as written; where a step says "Claude", it means whichever agent is guiding. Keep progress in
   `my-setup/PROGRESS.md` exactly as the playbook describes, so Claude can take over later.
3. Don't edit the kit's own files unless the user asks you to change the kit.

Rules that apply either way: don't guess (check or ask); the user types every password, token, key and one-time code;
ask before each install or download; change nothing outside the folders this setup creates unless the user asks.
