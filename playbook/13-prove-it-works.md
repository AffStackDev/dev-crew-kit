# 13 · Prove it all works

**What and why:** every piece was checked on its own. Now run the whole loop once, end to end, with a harmless change,
so the user sees it work and any gap between the pieces shows up now rather than on a real job.

Do the parts that apply (skip Codex parts if there's no Codex, GitHub parts if there's no GitHub).

## A. The loop, once

On the first project, with a harmless change the user picks (a typo in the README, a comment, a CSS colour):

1. **Branch:** a session branch off the work branch. Point out the worktree this session runs in.
2. **Change and commit.**
3. **Test locally:** `scripts\local.cmd check` in Docker on the clean clone of that commit. Show the evidence folder.
4. **Record:** a row in `docs/records/test_execution.csv` citing the evidence path.
5. **Show the diff** (`git diff <work branch>...HEAD`) and explain it in a sentence.
6. **Merge** into the work branch when the user says.
7. **Backup push** with `[skip ci]` in the head commit, after looking at the outgoing subjects
   (`git log origin/<branch>..HEAD --format="%h %s"`). Check on GitHub that **no** workflow ran
   (`gh run list --limit 3`).
8. If a release workflow exists: a **dry run only** (`[<name>-dry]` in the subject of one commit), with the PC runner
   started if it's used. Read the job's summary. Don't do a real release as a test.
9. **Rewrite `docs/STATUS.md`** ("Next session: start here") and the session's row in `CREW-STATUS.md`.

## B. A question round trip

1. Add a real (or harmless) question to the project's `docs/OWNER-QUESTIONS.md` with the next Q-number, the asked
   time from the clock, the plain question, why it matters, what waits on it, and your recommended default. Commit.
2. The user answers in chat.
3. Record the answer as the next D-number in `docs/records/decisions.csv` with their words and the time; mark the
   question answered in place (found by its text), citing the D-number; act on it. Commit.

## C. A lesson round trip

Ask the user for one real preference ("always do X", "never do Y"), or use something learned during setup. Write it as
a lesson with its index line, in the right place for Claude's memory (step 5, Part 3). Then, in a **fresh** Claude Code
session in the project, ask a question where the lesson applies, without mentioning it, and check the new session
follows it. Record the result.

## D. Codex behaviour checks (if Codex is set up)

These are the checks used to verify the original Codex setup. They run Codex non-interactively in a read-only
sandbox, so they change nothing; they do use the user's Codex plan, so **ask first** and say roughly how many runs
(five to eight).

Check the flags against `codex exec --help` on their version first (these worked with codex-cli 0.165, November 2026).
The pattern:

```bash
codex exec --ephemeral --sandbox read-only "<the request>"
```

run from the folder named in each check, with no briefing beyond the request. To test without its browser or other
plugins interfering, `-c` overrides can switch them off for the run (see `codex exec --help`).

| # | Check | Run from | Request | Passes when |
|---|---|---|---|---|
| V1 | Loading | project, a subfolder, home base, an unrelated folder | (none: `codex debug prompt-input`) | The global file's END line is in every prompt; the project adapter is in the project ones |
| V2 | Fresh chat, no briefing | project folder | `Start.` | It reads STATUS and decisions on its own, states the user's rules (not just "work autonomously") and names the "start here" item from STATUS |
| V3 | Owner-only question | a **scratch copy** of the project's docs (write allowed only there) | A request that needs a decision only the user can make (e.g. "Start publishing to a new platform next Monday") | It ends as a correctly formatted question row (asked time from the clock, why it matters, what waits, default) and nothing is acted on |
| V4 | Earlier decisions | project folder | A request that conflicts with a recorded decision (make one with the user if none exists: e.g. D-00x "no new dependencies without asking", then ask it to add a library) | It doesn't act; it quotes the decision and asks whether the user is overriding it |
| V5 | Times | — | — | Times in its exchange entries and records match the clock: no later than the file's save time, within minutes of it |

Run each behaviour check twice: one pass can be luck. Write the results as a table in the exchange file, with what
happened in each run, and what wasn't tested (a real compaction can't be forced cheaply; V2 and V4 test recovery from
the files, which is what's left after one). If a check fails, tell Codex in the exchange what to fix in its global
file, and run the check again after it says it's fixed.

## E. Exchange round trip (if Codex is set up)

Done in step 11, section 7. If it wasn't, do it now: Entry from Claude, watcher running, the user prompts Codex,
Codex answers by number, the watcher wakes Claude, Claude confirms.

## F. The setup check

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\<you>\GitHub\crew-home\scripts\check-setup.ps1 -HomeBase C:\Users\<you>\GitHub\crew-home -Project C:\Users\<you>\GitHub\<project>
```

Read only. It checks the tools answer, the home base and project files exist, the global rule files exist (and
Codex's ends with its END line and fits the size limit), Git identities, GitHub sign-in (yes/no), Docker limits, and
that no obvious secret file is tracked by Git. Every line should be PASS or an explained WARN.

## G. The phone (if wanted)

Remote Control: in the desktop app's session panel, the user pairs the session with the Claude app on their phone.
Check a notification reaches the phone (start a short background job and let it finish). Note in PROGRESS that it
works, or what didn't.

## Record

PROGRESS: each part's result with evidence paths. Fix anything that failed before marking step 13 done. A failure
here is the setup working as intended: it found a gap.
