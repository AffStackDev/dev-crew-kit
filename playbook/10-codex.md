# 10 · Codex: install it and make it remember (optional)

**What and why:** Codex is OpenAI's coding agent. In this setup it's a second worker: it takes its own tasks on its
own branches, and Claude reviews its work before anything is merged or released (step 11). The hard part isn't
installing it. It's making Codex follow the user's rules and **not forget them** halfway through a day, which is what
happens when rules and state live only in a chat that later gets compacted. The cure is the same as for Claude:
everything that matters is in files that load automatically or that it re-reads at fixed moments.

Skip this step if the user said no to Codex in step 2.

## 1. Install and sign in

Read OpenAI's current Codex docs first (rule 2 in 00); start from developers.openai.com/codex. Options in
November 2026:

- the **Codex desktop app** (Windows and macOS), or
- the **Codex CLI**: `npm install -g @openai/codex` (needs Node.js from step 3), then `codex`.

Many people use both: the app for daily work, the CLI for scripted checks (section 6). The user signs in with their
ChatGPT account in the app or with `codex login`; you don't handle the sign-in. Model, reasoning level and plan are
the user's choices; don't change them.

Verify: the CLI answers `codex --version`. On Windows the desktop app may keep its own copy of the CLI under
`%LOCALAPPDATA%\OpenAI\Codex\bin\`; `where.exe codex` shows what's on PATH.

## 2. How Codex loads its instructions

Checked against OpenAI's docs on 1 November 2026; re-check the current docs ("AGENTS.md" and "config" pages) and note
any change in PROGRESS:

- **Global file:** `AGENTS.md` in Codex's home folder (`CODEX_HOME`, default `~/.codex`, on Windows
  `C:\Users\<you>\.codex`). Loaded first, in every chat, in every folder. If a non-empty `AGENTS.override.md` exists
  there, it is used **instead**. Don't create one.
- **Project files:** then one `AGENTS.md` per folder from the project root down to the working folder, joined in that
  order; later (deeper) files win where they conflict.
- **Project root** = the nearest folder with `.git`. If there isn't one, Codex checks only the current folder. That
  means a folder **without** `.git` doesn't pass its `AGENTS.md` down to subfolders (found in practice: rules in a
  non-Git parent folder never reached chats started in its dated task subfolders). Put anything that must apply
  everywhere into the global file's routing table instead.
- **Size limit:** the joined files stop at `project_doc_max_bytes`, 32 KiB by default. Keep the global file under about
  20 KB so global + project still fit.
- The chain is read when a chat or run **starts**. The docs don't promise it's re-sent after the chat is compacted.
  So the global file tells Codex to re-read its status and decisions files after long tasks and compactions.
- Codex's built-in **memories** feature is optional, off by default, and builds memories in the background from chats
  that have been idle for hours. The docs say required rules belong in `AGENTS.md`, not memories. It doesn't replace
  the files below. Turning it on is the user's choice.

## 3. Codex's global rules (`~/.codex/AGENTS.md`)

1. If the file exists, read it and show the user; plan to merge, not replace.
2. Write it from `templates/codex/global-AGENTS.md`, filled in:
   - **Start here** routine (every chat, resume, compaction, long-task checkpoint): find the working folder's row in
     the routing table; read that project's `docs/STATUS.md`, decisions and questions; read `crew-home/CREW-STATUS.md`;
     read the lessons that fit; before anything external, re-read the decisions and check the step follows the
     established workflow.
   - **Rules in force**: a five-line summary at the top (so a fresh chat can state them), then the user's rules
     **word for word** from the home base's `records/decisions.csv`, each with its date. Where a rule names a file
     (`OWNER-QUESTIONS.md`), say which file that means in a project.
   - **Conflict check**: if a new request conflicts with a recorded decision, a hold or the established workflow,
     don't draft or act yet; quote the decision, say what the workflow would do, and ask whether the user is
     overriding it. (This was the one behaviour check that failed in the original setup until this rule was added: a
     fresh chat read a new request as permission and drafted ten posts that an earlier decision had ruled out.)
   - **Write as you go** table (the same habit as Claude's, step 5 Part 4).
   - **Routing table**: working folder → project adapter → STATUS file → decisions/questions files → who else works
     there.
   - **Local first**, **secrets**, **times from the clock**, **saved vs delivered vs verified**, **ownership**.
   - **Lesson index**: one line per file in `crew-home/lessons/codex/` and `crew-home/lessons/shared/`.
   - The universal rule (if adopted).
   - **Last line:** `END OF GLOBAL AGENTS.md (version <date and time from the clock>)`. If that line shows up in
     Codex's loaded prompt (section 6), the whole file loaded. Update it on every change.
3. Mirror: copy it to `crew-home/mirrors/codex-global-AGENTS.md` and commit, every time it changes.

## 4. The project adapter (`<project>/AGENTS.md`)

Step 6 put one in each project from `templates/project/AGENTS.md`. Check it says:

- read `CLAUDE.md` for the shared rules (both agents follow the same project rules);
- Codex works in its **own checkout or worktree** on `codex/<task>` branches, never in Claude's worktrees or on the
  work branch directly;
- who writes the shared records on the work branch (default: Claude; Codex proposes question and decision rows in the
  exchange file and Claude assigns the numbers), so two agents never take the same number;
- the exchange file's absolute path (step 11) and Codex's Docker slots (step 7).

A pointer like "read CLAUDE.md" is only an instruction. Codex reads it when it follows the instruction, unlike the
global file, which is always loaded. That's why the global file carries the general rules itself.

## 5. Codex's records

- `crew-home/CREW-STATUS.md`: Codex chats get rows there like Claude sessions. A chat updates only its own row.
- Lessons: `crew-home/lessons/codex/<slug>.md` (template `templates/codex/lesson.md`), indexed in the global file.
- Project questions and decisions: in the project's own records (through Claude on the work branch, as above). For
  Codex-only work with no project (say, a folder of content), the folder gets its own `AGENTS.md`, `STATUS.md`,
  `OWNER-QUESTIONS.md` and decisions file from the project templates, and a routing row.

## 6. Check that it loaded

If the CLI has the command (it did in codex-cli 0.165, November 2026; check `codex --help` and `codex debug --help`):

```bash
codex debug prompt-input "loading check only"
```

It prints what Codex would send to the model without calling it, so it's free. Run it from: the project folder, a
subfolder of it, the home base, and an unrelated folder (e.g. Downloads). Search the output for the END line (and the
project adapter's text in the project folders). Save the outputs in `Dev-local\codex-checks\<stamp>\` and record the
result.

If the command doesn't exist in their version, use the behaviour checks in step 13 instead.

## 7. Permissions and sandbox

- Codex asks to trust a folder the first time; trusted folders are listed in `~/.codex/config.toml`. Trust only the
  user's project folders and the home base.
- Codex's Windows sandbox runs commands as a restricted account that may not be able to read some folders. In the
  original setup, a sandboxed test run got "Access is denied" on the project folder while the desktop app could read
  it. If Codex can't read a project, check from the desktop app before changing anything, and record what you find.
- Docker from Codex: it needs to reach Docker Desktop. If its sandbox blocks that, the user decides whether to allow
  it in Codex's settings; don't change Codex's security settings yourself.

## 8. Open chats

Chats that were already open keep their old instructions. Tell the user: start fresh Codex chats, or tell each open
one "re-read your global AGENTS.md and the files it points to". Record which.

## Record

PROGRESS and `crew-home/WORKSPACES.md` (who works where), `crew-home/TOOLS.md` (a Codex card: version, app/CLI,
plan not recorded beyond "user's plan"), the loading check result. Commit the home base. Mark step 10 done.
