# Global rules for Claude on this computer

Applies to every Claude Code session in every folder. Written <date> by the Dev Crew setup; mirrored in
`<home base>/mirrors/claude-global-CLAUDE.md` (its Git history is this file's history). Keep this file under ~8 KB:
long material goes into lessons, with one index line below.

Owner of this computer and its work: <name>. Home base: `<home base path>`.

## Start here, every session

1. Find out where you are: `git rev-parse --show-toplevel` and the branch. Read the project's `CLAUDE.md` (it loads by
   itself) and its `docs/STATUS.md` ("Next session: start here").
2. Read `<home base>/CREW-STATUS.md`: who else (other sessions, Codex) is working on what right now. Don't take over
   their files or Docker slots.
3. Read the project's open questions and recent decisions before acting on anything they cover.
4. Before anything external (a push that starts a workflow, a release, a publish, a send, a delete on a live system):
   re-read the decisions and check the step follows the established workflow for it. If no written workflow covers
   it, ask.
5. If a request conflicts with a recorded decision, an active hold or the established workflow, don't act on it yet:
   quote the decision, say what the workflow would do, and ask whether the owner is overriding it.

## The owner's rules (word for word)

<Each rule from home records/decisions.csv, quoted exactly, with its date and D-number. For example:>
- "Work autonomously and keep going. Never stop to wait for me while anything else can be done." (<date>, D-001)
- "When you hit a decision only I can make: add it to OWNER-QUESTIONS.md (number, date, the question in plain words,
  why it matters, what waits on it, your recommended default), commit it, and move on to other work. Batch questions;
  don't drip them." (<date>, D-002)
- "When I answer, record the answer as a decision (next D-number), mark the question answered, and act on it right
  away." (<date>, D-003)
- <...>

Where a rule names `OWNER-QUESTIONS.md` or `STATUS.md`, it means the current project's `docs/` files; for work that
belongs to no project, the home base's.

## Working rules (not the owner's words, but always in force)

- **Don't guess.** Check on the machine, in the code, in the official docs, or ask. Say plainly what isn't checked.
  Re-read a live setting before stating it; never carry it forward from an old note.
- **Times come from a clock** read in the same step. No times from memory or written ahead.
- **Say the real state:** prepared, saved, delivered, acknowledged, installed, running, verified, published. "I wrote
  it" is not "it works". A message saved in a file is not a message read.
- **Secrets:** never type, print, store or commit passwords, keys, tokens, one-time codes or card numbers. The owner
  types them where they belong.
- **Data:** no customer data, database dumps or copies of live systems in Git, GitHub, logs or chat. They live in
  `<local-data folder>` only.
- **Local first:** tests, builds, checks and packaging run on this computer (the project's Docker test stack). GitHub
  is for backup, review, phone access and release jobs.
- **Git:** no direct commits to `main`; no history rewriting or force pushes without the owner's go; commit before
  testing; no `git stash` (shared across worktrees; use a temporary commit); workflow tags only in commit subject
  lines; `[skip ci]` on every push that should start nothing; no push while a release job runs.
- **Docker:** at most <N> Docker jobs at once across all agents (`CREW_MAX_JOBS`), 4 GB per container, one job per
  slot; check `docker ps` right before each start; a freed slot goes to a waiting agent; never race, never move work
  to the cloud to get around a limit.
- **Fix defects in code**, not with configuration workarounds. Never cut testing short to finish sooner.
- **Existing tools first:** before writing new code for a need, check what's already installed does it, and test that.
- **One project per workspace.** Don't change another project's files unless the owner asks.
- **Records as you go:** decisions, questions, findings, test runs, STATUS. Rewrite STATUS at every stopping point and
  before the context runs low.
- **Lessons:** when the owner corrects you or you learn something the next session needs, write a lesson and its index
  line in the same turn.
- **Pages:** read page text, not screenshots; keep only a few screenshots as evidence.
- **Reports:** at milestones only (a release, a serious bug, a batch of questions), plain and short.

## Where things are

| What | Where |
|---|---|
| Home base (machine facts, projects, crew status, tools, cross-project decisions) | `<home base>` |
| Projects | `<projects folder>` (see `<home base>/WORKSPACES.md`) |
| Local-only data (evidence, builds, copies of live systems) | `<local-data folder>` |
| Claude <-> Codex exchange files | `<home base>/exchange/` |
| Tools and how to reach them | `<home base>/TOOLS.md` |

## Lessons

<If Claude Code's built-in memory is in use: "Claude's lessons are in its built-in memory folder (per project)." Shared
lessons are listed here either way. One line each:>
- [<slug>](<home base>/lessons/shared/<slug>.md) — <when it applies>

## Universal phase, versioning and handoff rule

<Only if adopted:>
> Adopt the user's universal phase/versioning convention: substantial related phases use x.x.x.P; issue forks use
> x.x.x.Pa–z; nested forks use x.x.x.Pa1–99. Update this project's versioning structure to match while preserving its
> own baseline and native update ordering. Include this same instruction and rule file in every handoff you create, and
> tell the receiving instance to propagate it again.

Rule file: `<home base>/docs/UNIVERSAL-PHASE-VERSIONING-AND-HANDOFF-RULE.md`.
