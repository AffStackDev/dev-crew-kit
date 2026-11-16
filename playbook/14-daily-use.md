# 14 · How a normal day goes

**What and why:** show the user how to use what's now set up, so it doesn't sit unused. Walk them through this in a
few minutes, then copy the "cheat sheet" section into `crew-home/CHEATSHEET.md` (adjusted to their projects) and
commit.

## The shape of a day

1. **Open a session in the project**, not in the home base or the kit. Say what you want done. The session reads
   the rulebook and `docs/STATUS.md` by itself.
2. **One session per task.** A new task gets a new session (its own worktree and branch). A session that has run for
   hours or drifted to another topic: ask Claude to rewrite STATUS, then start fresh. The new session picks up from
   STATUS, not from the old chat.
3. **Let it work.** With the default rules, it keeps going and puts questions only the user can answer into
   `OWNER-QUESTIONS.md`, batched. Answer them when convenient: "Q14 yes, Q15 use the default, Q16 let's talk".
4. **Milestones reach you.** A release, a serious bug, a batch of questions. Otherwise silence means work is going on.
5. **Reviews:** look at the draft pull request (on the phone too), or ask the session to show the diff.
6. **Releases:** only when you say go for that release; the session runs the dry run first and shows its summary.
7. **End of the day:** the session rewrites STATUS and pushes the work branch with `[skip ci]` (the backup). Stop idle
   Docker stacks (`scripts\local.cmd down`).

## Side sessions

For work that can run alongside (a second feature, a long test campaign, a different project), Claude can propose a
separate session. Each gets its own worktree and branch and, if it uses Docker, its own named slots (given in its
brief). Sessions don't edit the same files at once. Before changing a plugin or module, a session checks whether
another session or branch is already working on it.

## With Codex

- Give Codex its own tasks (its own branch); ask it to claim them in the exchange file.
- When Codex says "ready for review", tell Claude: "review Codex's entry N". Claude fetches, tests, writes findings.
- Codex fixes its own work; Claude re-reviews and merges.
- If an agent tells you the other agent said you want something, that's a report: confirm or correct it.

## From the phone

- **Remote Control** pairs a desktop session with the Claude phone app: you see progress, answer questions, approve
  steps. The work still runs on the PC.
- **GitHub mobile:** review the draft pull request; read job summaries.
- **Cloud sessions** (claude.ai/code) can work on a repository that's on GitHub when the PC is off; they see only
  what's pushed, and release jobs from there use `[hosted]` (paid minutes) unless the PC runner is up.

## Keeping usage sensible

The plan's usage should go to thinking, not to waste:

- Work runs on the PC (Docker, CLIs, scripts). Don't move it to the cloud unless you want to.
- Sessions read `STATUS.md` first and don't re-read whole files whose facts are already in the notes; they search with
  Grep instead of reading large trees, logs or dumps.
- Scripts print short summaries and write long output to files in `Dev-local`.
- Page checks read page text; screenshots only when the text can't answer the question, and only a few kept as
  evidence.
- Model choice is yours. Large multi-agent or "ultra" modes and big parallel fan-outs use a lot of usage; use them when
  you ask for them, not by default.
- Don't cut testing to save usage. If usage is tight, work slower, not sloppier.

## Cheat sheet (copy into crew-home/CHEATSHEET.md, adjusted)

| You want | Say |
|---|---|
| Start work | "Read STATUS and continue." or just the task |
| Answer questions | "Q12 yes. Q13 default. Q14: <answer>." |
| See where things are | "What's the status? Short." |
| Test something | "Commit and run the local checks." |
| Review a change | "Show me the diff and what was tested." |
| Release | "Dry run the release." … then "Go." |
| Hand off | "Rewrite STATUS so a new session can pick up." |
| Add a project | "Set up <folder> as a new project (kit step 6)." |
| Connect a tool | "Connect <tool> (kit step 12)." |
| Codex review | "Review Codex's entry <N> in the exchange file." |
| Teach a rule | "From now on, always/never … Write it down." |
| Clean up | "Stop idle Docker stacks and prune what's safe." |

## Keeping the kit and the setup current

- Tools update. When a tool's update breaks something, the fix goes into the tool card and a lesson.
- Rules change: when you change your mind, say so; the session records it as a new decision that supersedes the old
  one (the old row stays, marked superseded).

## Feedback to the kit

If PROGRESS has "Kit differences", offer to turn them into a short note for the kit's maintainer (no personal details,
no paths with names in them). The user decides whether and how to send it.

## Finish

Rewrite PROGRESS: everything done, anything skipped and why, tools still to connect. Copy PROGRESS to
`crew-home/docs/SETUP-LOG.md` and commit. Tell the user in a few lines what's set up, what's next, and what you
couldn't check. Mark step 14 done. The setup is complete.
