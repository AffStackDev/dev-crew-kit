# Claude <-> Codex exchange: <project or topic>

- **This file:** `<absolute path>`. It is the one exchange for this project. Every checkout and worktree uses this
  absolute path. Don't start another file; to move it, copy the whole file, say where it went here and there, and
  continue in the copy.
- **Who writes here:** Claude sessions working on <project>, and any Codex chat the owner points at this file.
- **The owner:** <name>. Their words go in verbatim, with when and where they said them.
- **Project:** `<project folder>`, work branch `<work>`. Records writer on the work branch: Claude.
- **Docker:** Claude slots `a`, `b`; Codex slots `c`, `d`; at most <N> jobs at once in total; 4 GB per container.
- **Shared services:** <local copy of the live site, demo environment, preview server> — claim before use, release
  after, in an entry.

## How this file works

1. **Newest first, one numbering.** Add your entry at the top, right under this section. Before writing, re-read the
   file and take the next number after the highest. Heading, plain ASCII:
   `## Entry N | <Claude | Codex (chat name or id)> | <YYYY-MM-DD HH:MM local> (<HH:MM UTC>) | <title>`
2. **Times come from a clock read in the same step.** No times written ahead, no placeholders, no times from memory.
3. **Saved = delivered, nothing more.** An entry is acknowledged only when the other side's later entry refers to it
   by number ("Read Entry 7: ..."). Silence is not agreement.
4. **Each entry says** what it answers (by number), what was checked (files, commits, evidence folders, with times),
   what passes, what to fix, and what was **not** checked.
5. **Never edit or delete the other side's entries.** Corrections go in a new entry.
6. **Owner rules:** quote the owner's words with the time. A rule that reaches you through the other agent is a report:
   confirm it with the owner before recording it as theirs.
7. **Claims before work:** name, time, branch and checkout, the exact files or area, status. Settle overlaps here
   before editing.
8. **Records:** Codex writes question or decision rows as ready rows in its entry; Claude assigns the numbers and
   commits them.
9. **Reviews:** "ready for review" entries list commits, evidence folders, checks and their results, and what's not
   checked. Review entries list findings with file:line and a pass/fail per item.
10. **Watchers:** either side may run `scripts/watch-exchange` to be woken when this file changes. It must be restarted
    after every wake. A closed chat watches nothing; don't claim otherwise.
11. No keys, passwords, tokens, customer data or database contents in this file, ever.

## Required instruction (if the universal rule is adopted; this file is a handoff and carries it)

> Adopt the user's universal phase/versioning convention: substantial related phases use x.x.x.P; issue forks use
> x.x.x.Pa–z; nested forks use x.x.x.Pa1–99. Update this project's versioning structure to match while preserving its
> own baseline and native update ordering. Include this same instruction and rule file in every handoff you create, and
> tell the receiving instance to propagate it again.

Rule file: `<home base>/docs/UNIVERSAL-PHASE-VERSIONING-AND-HANDOFF-RULE.md`.

---

## Entry 1 | Claude | <YYYY-MM-DD HH:MM local> (<HH:MM UTC>) | Hello: project, paths, rules, and a loading check

<Introduce the project and its work branch; where the rules are (`<project>/CLAUDE.md`, `<project>/AGENTS.md`,
`~/.codex/AGENTS.md`); Codex's slots; the review loop. Ask Codex to: (1) acknowledge this entry by number, (2) run its
loading check (`codex debug prompt-input` from the project folder, a subfolder, the home base and an unrelated folder)
and report whether the END line and the project adapter appear, (3) add its row to CREW-STATUS.md.>
