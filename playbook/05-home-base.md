# 05 · The home base, and Claude's global rules

**What and why:** one small folder of notes that every session (and Codex, if it joins) reads first: the machine's
facts, the list of projects, who is working on what, the tools, and the user's decisions. Chats get long, get
compacted and get closed; these files don't. Anything that matters is written here or in a project's records when
it happens, never left only in a chat.

## Part 1: the folder

Default path: `C:\Users\<you>\GitHub\crew-home` (Mac/Linux `~/GitHub/crew-home`), next to the projects, outside any
synced folder. Use the folders chosen in step 2.

1. Create it and `git init` it. If the user chose a per-repository identity in step 4, set it here
   (`git config user.name` / `user.email` inside the folder).
2. Copy the templates from `templates/home/` into it, keeping the structure:

   ```
   crew-home/
     CLAUDE.md                what this folder is and how sessions use it
     AGENTS.md                the same for Codex
     MACHINE.md               checked facts about this computer, with dates
     WORKSPACES.md            every project: folder, local-data folder, Docker slots, ports, who works there
     CREW-STATUS.md           one row per active session or Codex chat: what it's doing and owns right now
     TOOLS.md                 every tool and how the agents reach it (filled in step 12)
     OWNER-QUESTIONS.md       questions only the user can answer that belong to no single project
     records/decisions.csv    the user's decisions that apply everywhere (D-001, D-002, ...)
     exchange/                Claude <-> Codex exchange files (step 11)
     lessons/                 lessons learned, one file each (see Part 3)
     mirrors/                 copies of the global rule files, for their history (Part 2)
     docs/UNIVERSAL-PHASE-VERSIONING-AND-HANDOFF-RULE.md   (if adopted in step 2)
     scripts/                 watch-exchange.ps1 / .sh, check-setup.ps1 (copied from the kit's scripts/)
     .gitignore  .gitattributes
   ```

3. Fill them in from PROGRESS:
   - `MACHINE.md`: the step 1 report and everything installed in step 3, each with date and source. Add a line
     "Not checked:" for anything you didn't verify.
   - `records/decisions.csv`: one row per answer from step 2's section C and the other choices that apply everywhere
     (Docker limits, folders, GitHub yes/no, Codex yes/no, the versioning rule). `D-001` onward. Quote the user's
     words in `owner_words`; date and time from step 2's record.
   - `WORKSPACES.md`: the projects named in step 2 (filled properly in step 6).
   - `CREW-STATUS.md`: a row for this setup session.
4. The local-data folder from step 2 (`C:\Users\<you>\Dev-local\`): create it. It holds test evidence, builds and
   any copy of a live system, per project. It is never inside a Git repository and never synced to the cloud. Add a
   `README.txt` there saying exactly that.
5. First commit: `git add -A` then `git commit -m "Home base"`. Show the user `git log --oneline` and explain that
   this folder's history is now kept.

The home base is local. It may get a private GitHub backup in step 8 like any repository (the user decides). It
never holds secrets or customer data.

## Part 2: Claude's global rules (`~/.claude/CLAUDE.md`)

Claude Code reads `CLAUDE.md` files automatically: the user-level one at `~/.claude/CLAUDE.md`
(`C:\Users\<you>\.claude\CLAUDE.md`) in every session in every folder, then the project's own `CLAUDE.md`. Check the
current Claude Code docs for the exact loading order before relying on details.

1. If `~/.claude/CLAUDE.md` already exists, read it, show it to the user, and plan to **add** a section rather than
   replace it. Show the exact change before saving.
2. Otherwise write it from `templates/user-claude/CLAUDE.md`, filled in with:
   - the path of the home base;
   - the user's rules in force, **word for word** from `records/decisions.csv`, each with its date and D-number;
   - the working rules that aren't the user's words (times from the clock, saved vs verified, secrets, etc.);
   - the "start here" routine every session follows.
3. Keep it short: under about 8 KB. Long material goes into lessons (Part 3), with one index line here.
4. Mirror: copy it to `crew-home/mirrors/claude-global-CLAUDE.md` and commit, every time it changes. The home base's
   Git history is then the history of the global rules.
5. Tell the user: this file now applies to **every** Claude Code session on this computer, in every folder. Sessions
   already open keep their old instructions until restarted.

## Part 3: memory and lessons

Two kinds of memory, both files:

- **Records** (status, questions, decisions, findings, test runs): what is true and what was decided. Per project in
  the project's `docs/`, cross-project in the home base. Steps 6 and 10 cover them.
- **Lessons**: what an agent learned the hard way and must not relearn. "PowerShell 5.1 reads BOM-less scripts as
  ANSI." "The user wants screenshots of every UI change." One small file per lesson, with an index line.

Where Claude's lessons go:

- **If your Claude Code has a built-in memory folder** (your own instructions mention a memory directory you write
  to, with an index file), use it for Claude's lessons. Tell the user where it is and that it's per project. Don't
  duplicate those lessons into the home base.
- **If it doesn't**, keep Claude's lessons in `crew-home/lessons/claude/<slug>.md` using
  `templates/home/lessons/LESSON-TEMPLATE.md`, and add one index line per lesson to `~/.claude/CLAUDE.md` under
  "Lessons", so they load in every session.

Codex's lessons go in `crew-home/lessons/codex/` (step 10). A lesson that applies to both agents goes in
`crew-home/lessons/shared/` and both global rule files index it.

What deserves a lesson: a correction from the user, a mistake that cost real time, a fact about this machine or a tool
that isn't obvious and will come up again. What doesn't: what the code or Git history already says, one-off task
details, status (that's what STATUS is for).

## Part 4: the records habit (explain it to the user once)

| When | Write |
|---|---|
| The user answers a question or gives a rule | A decision row (next D-number) with their words and the time; mark the question answered; act on it |
| A decision only the user can make | A question row in OWNER-QUESTIONS (next Q-number, asked time, plain question, why it matters, what waits, recommended default), batched; then keep working on other things |
| A step finishes, before anything external, at each stopping point, before saying "done", before the context runs low | Rewrite the project's `docs/STATUS.md` ("Next session: start here" first), and your row in `crew-home/CREW-STATUS.md` |
| The user corrects you, or you learn something the next session needs | A lesson and its index line, in the same turn |
| A long task ends, or the chat was compacted | Re-read STATUS and the decisions before the next action |

Silence is never consent: an unanswered question waits; its default is a recommendation, not an approval.

## Record

PROGRESS: the home base path, the files made, the commit id, the global CLAUDE.md change (new or added to), where
Claude's lessons live. Mark step 5 done.
