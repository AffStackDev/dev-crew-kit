# <Project name>: instructions for Claude

Owner of this work: <name>. <Client: <client name> | the owner's own project>. Made <date> with the Dev Crew kit.
<One or two lines: what the project is, who uses it.>

**Start here, every session:** `docs/STATUS.md` ("Next session: start here"), then the current task. Open questions:
`docs/OWNER-QUESTIONS.md`. Decisions: `docs/records/decisions.csv`. Global rules: `~/.claude/CLAUDE.md`. Machine,
projects, crew status and tools: `<home base>`.

## Kept apart

- Work on this project happens here only. Don't read or change other projects unless the owner asks.
- Local-only data (test evidence, builds, copies of live systems) lives in `<Dev-local>/<project>/`, never in Git.
- <Anything this project must never touch: other sites, other clients' accounts, a production database, ...>

## The owner's rules for this project (word for word, with dates)

<Project-specific rules from step 2 and later decisions, quoted, with date and D-number. The global ones are in
~/.claude/CLAUDE.md and apply here too; don't repeat them.>
- "<...>" (<date>, D-<n>)

## The project now (<date>)

- Stack: <languages, frameworks, versions>.
- Live: <what's live, where, which version/tag; "nothing live yet">. How changes reach live today: <...>.
- Baseline: tag `<tag>` = <what> as live on <date>.
- Not checked: <...>.

## Branches

- `main` = released/live. Moves only on the owner's word.
- Work branch: `<work>`. Session branches `claude/<topic>`; Codex `codex/<task>`. Merged into the work branch after
  checks.
- Tags mark releases (`<scheme>`).

## Testing (local, in Docker)

Set up in kit step 7.

- `scripts\local.cmd doctor | rebuild | check [NAME] | last | shell | down | clean` (macOS/Linux: `bash scripts/local.sh ...`).
- Tests a clean clone of the current commit: **commit before testing**. Evidence: `<Dev-local>/<project>/evidence/`.
- Slots: Claude `a`, `b`; Codex `c`, `d`. `CREW_MAX_JOBS` = <N>. 4 GB per container. One job per slot.
- Checks in `scripts/check.sh`: <list>.
- Record each run that decides something in `docs/records/test_execution.csv`.

## GitHub

Set up in kit step 8.

- Repository: <URL> (private). `main` protected: <yes/no>.
- Backup push of the work branch at every stopping point, head commit with `[skip ci]`. Before every push:
  `git log origin/<work>..HEAD --format="%h %s"`. No push while a release job runs.
- Workflow tags (subject line only, one per commit, never in a commit body):

| Tag in the commit subject | Runs |
|---|---|
| `[skip ci]` anywhere in the message | nothing |
| `[<name>-dry]` | <release dry run: every gate, no change> |
| `[<name>]` | <the release, only with the owner's go for it> |
| `[hosted]` together with a release tag | the same job on a GitHub machine (paid minutes) instead of the PC runner |

## Releases

<Set up when the first release is near. The rehearsed path: rehearse on a local copy from the exact live set → dry run
→ the owner's go → real run (identity gate, backup, change, verify, restore on failure) → read live back, tag,
record.>

## Codex

<If Codex works here:> Codex works in its own checkout on `codex/<task>` branches and follows `AGENTS.md` (which
points back here for the shared rules). Exchange file: `<home base>/exchange/<project>.md`. Claude reviews Codex's work
before it's merged (fetch, trial merge with `git merge-tree --write-tree`, read the diff, run the checks). Claude is the
records writer on the work branch.

## Tools

<From kit step 12: each tool this project uses, the command or connector, the folders, the guardrails. Details in
<home base>/TOOLS.md.>

## Records

- `docs/STATUS.md`: rewrite at every stopping point and before the context runs low; "Next session: start here" first.
- `docs/OWNER-QUESTIONS.md`: next Q after the highest; asked time from the clock; why it matters; what waits; default.
- `docs/records/decisions.csv`: next D after the highest; the owner's words; the time.
- `docs/records/findings.csv`: every bug or problem, with evidence and status.
- `docs/records/test_execution.csv`: every run that decided something, with its evidence path.
- `docs/issues/`: one note per larger problem.
- Append rows as text; never rewrite a whole CSV through a CSV library; check a new number isn't taken on another
  branch.

## Versioning

<If the universal rule is adopted:> Baseline `<x.y.z>` (as live on <date>). Phases `x.x.x.P`, forks `Pa`–`Pz`, nested
`Pa1`–`Pa99`; numeric update version where the platform compares versions. Rule file:
`docs/UNIVERSAL-PHASE-VERSIONING-AND-HANDOFF-RULE.md`.

> Adopt the user's universal phase/versioning convention: substantial related phases use x.x.x.P; issue forks use
> x.x.x.Pa–z; nested forks use x.x.x.Pa1–99. Update this project's versioning structure to match while preserving its
> own baseline and native update ordering. Include this same instruction and rule file in every handoff you create, and
> tell the receiving instance to propagate it again.
