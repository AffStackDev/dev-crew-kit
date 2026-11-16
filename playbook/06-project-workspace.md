# 06 · Set up a project

**What and why:** each project gets its own Git repository with a rulebook for the agents, a status page, a question
list, a decision log and a few record tables. One project at a time, starting with the one the user picked in step 2.
Repeat this step for each further project, now or later.

## 1. Where the code is today

Ask (if step 2 didn't make it clear) and handle the case:

| Case | Do |
|---|---|
| Already a Git repository on this computer | Use it where it is. If it's inside OneDrive/iCloud/Dropbox, recommend moving it to the projects folder (Git and sync tools fight over the same files), and move it only with the user's yes: copy it with its `.git`, check `git status` and `git log` in the new place, and let the user delete the old copy. |
| On GitHub (or another Git host) only | Clone it into the projects folder: `git clone <url>`. If the user isn't signed in to GitHub yet, do step 8's sign-in part first. |
| A plain folder of files | `git init` in place (or in a fresh folder in the projects folder, copying the files), then a first commit: the **baseline**, "as it is on <date>". |
| Only on a server or host (a live website, for example) | Make an empty repository now. Getting the code (and, if wanted, a local copy of the live system) is the matching recipe's job in step 12, with the user's OK for each read from the server. |
| Nothing yet (new project) | `git init` a new folder. |

Set the per-repository identity if the user chose that in step 4.

## 2. Branches

Explain and set up:

- `main` = the version that is released or live. Nobody commits to it directly. It moves only when the user says.
- A **work branch** where the AI's work lands after review, e.g. `work` or `develop` (ask the user's preference; a
  long-running work branch is what the original workflow uses).
- Each Claude Code session works on its own branch off the work branch (the app names them, e.g. `claude/<topic>`),
  each Codex task on `codex/<task>`. They're merged into the work branch after checks.
- Tags mark releases: "what's live is `v1.4.2`" (or the project's own scheme).

If the project has a live version, tag the baseline commit now with that version and the date ("as live on <date>").

## 3. The project's files

Copy from `templates/project/`, merging with anything the project already has (never overwrite an existing
`.gitignore`, `README`, `CLAUDE.md` or `AGENTS.md`: show the user what you'd add, then add it):

```
<project>/
  CLAUDE.md                    the project's rulebook for Claude (fill every <...>)
  AGENTS.md                    the project's adapter for Codex (points to CLAUDE.md for the shared rules)
  docs/STATUS.md               where things stand; "Next session: start here" at the top
  docs/OWNER-QUESTIONS.md      questions only the user can answer
  docs/records/decisions.csv   this project's decisions (D-numbers continue the project's own sequence)
  docs/records/findings.csv    bugs and problems found, with evidence and status
  docs/records/test_execution.csv  every test run that decided something
  docs/issues/                 one note per larger problem (template inside)
  docs/UNIVERSAL-PHASE-VERSIONING-AND-HANDOFF-RULE.md   (if adopted)
  .gitignore  .gitattributes   merged with what's there
```

Fill in `CLAUDE.md` from what you know: what the project is, who it's for, its stack, what's live and how it's
deployed today, the user's project-specific rules from step 2, the folders (repository, local-data folder), and the
branches. Leave the Docker, GitHub and tools sections as "set up in step 7 / 8 / 12" until those steps fill them.
Write "Not checked:" next to anything you didn't verify.

**Decision numbers.** The home base's decisions are `D-001`… for everything that applies everywhere. Each project
keeps its own sequence in its own `decisions.csv`. When a project rule comes from a home-base decision, cite it
("from home D-004") rather than copying the number.

## 4. Records: how to keep them clean

- Append new rows as text. Don't rewrite a whole CSV through a CSV library: it re-quotes rows and creates a giant
  diff. To change one field, parse that one line, change the field, write that line back, and check every row still
  has the same number of fields.
- Before adding a Q-, D- or F-number, read the **highest** number in the whole file (rows aren't always in order) and
  check it isn't already taken on another branch: `git grep -n "^F-042," $(git for-each-ref --format="%(refname)" refs/heads) -- docs/records/findings.csv`.
  Parallel sessions appending to the same records is how duplicate numbers happen.
- Find a question by its text, not only its number, before marking it answered.
- One writer per branch for shared records. By default Claude writes the work branch's records; Codex proposes rows
  through the exchange file (step 11), and Claude assigns the numbers.

## 5. Register it

In `crew-home/WORKSPACES.md`: the project's name, folder, local-data folder (`Dev-local\<project>\`), work branch,
who works there (Claude, Codex), Docker slots (step 7), ports of any local previews, and a one-line description.

## 6. Commit

`git add -A`, then `git commit -m "Project rulebook and records"`. If the project already had commits, do this on the
work branch, not `main`, and show the user the diff first.

## Record

PROGRESS: the project, its path, the case from the table, branches made, baseline tag, files added or merged, the
commit id. Mark step 6 done for this project (list projects still to do).
