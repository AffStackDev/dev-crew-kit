# Home base: instructions for Claude

This folder is the home base of <name>'s development setup: the facts and records every session and agent reads
first. It holds no project code, no secrets and no customer data. Made <date> with the Dev Crew kit.

## What's here

| File | What | Who writes it |
|---|---|---|
| `MACHINE.md` | Checked facts about this computer, each with its date and how it was checked | Any session, when it checks something new |
| `WORKSPACES.md` | Every project: folder, local-data folder, branches, Docker slots, ports, who works there | The session that sets a project up or changes these |
| `CREW-STATUS.md` | One row per active session or Codex chat | Each agent updates only its own row |
| `TOOLS.md` | Every tool: how it's reached, guardrails, who drives it | The session that connects or changes a tool |
| `OWNER-QUESTIONS.md` | Questions for the owner that belong to no single project | Claude |
| `records/decisions.csv` | The owner's decisions that apply everywhere | Claude |
| `exchange/` | Claude <-> Codex exchange files, one per project or topic | Both, append only, newest entry first |
| `lessons/` | Lessons, one file each: `claude/`, `codex/`, `shared/` | The agent that learned it |
| `mirrors/` | Copies of `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`, for their history | Whoever changes a global file |
| `docs/` | The universal rule file (if adopted), the setup log | — |
| `scripts/` | `watch-exchange`, `check-setup` | — |

## Rules for this folder

- Re-read a file immediately before writing it; other agents may have changed it. Preserve their entries.
- Commit at stopping points (`git add -A`, a short message). If Git reports a lock (`index.lock`), another agent is
  committing: wait a few seconds and try again; never delete the lock while a Git process runs.
- Decision numbers here are `D-001`… and apply everywhere. Projects keep their own sequences.
- Nothing here is pushed anywhere unless the owner chose a private GitHub backup for it (see `WORKSPACES.md`).
- The owner's global rules for Claude are in `~/.claude/CLAUDE.md`; this file only explains the folder.
