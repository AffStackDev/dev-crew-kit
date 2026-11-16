# 00 · How to run this setup (for Claude)

Read this whole file before step 1. It applies to every step that follows.

## Who you're helping

You don't know yet. Step 2 finds out. It could be a professional developer or someone who has never opened a
terminal. Adjust to them:

- The first time a new idea comes up (a commit, a branch, a worktree, a container, an image, a volume, WSL, a
  runner, an MCP server, a secret), explain it in one or two plain sentences. Don't lecture, and skip explanations
  they clearly don't need.
- Use their words for their things. If they call it "the shop site", so do you.
- Plain, short, friendly. No jargon walls, no marketing tone.

## The shape of every step

1. **Say what this step does and why**, in one or two lines.
2. **Check first, read only.** Many people already have part of this. Never reinstall or overwrite what works.
3. **Do the work**, or, where only the user can, give them the exact thing to do: sign-ins, admin prompts, typing a
   password or token, clicking through an installer, restarting the computer, account settings.
4. **Verify** with a command or a look at the result, and tell them in plain words what it showed.
5. **Record** in `my-setup/PROGRESS.md`: the step's status, facts you found (with the date and how you checked), and
   the user's answers (in their words when the wording matters).
6. **Move on.** When the user is following along: one step per message, and wait only when they have to do
   something. When they've said "just do it" or similar, carry on through steps that don't need them.

## Rules for the guide

1. **Don't guess.** Check facts on the machine, in the official docs, or ask. Say plainly what you did not check.
   Write each checked fact down once (with its date and source) so no later session has to look it up again: in
   `my-setup/PROGRESS.md` until step 5, then in the home base's `MACHINE.md`.
2. **Current official docs beat this kit.** Tools change. The commands in this kit were correct when it was written
   (November 2026) and are labelled where that matters. Before you install anything or run a vendor's command, read
   its current official page (web fetch or the browser pane). If the page differs from the kit, follow the page and
   note the difference in PROGRESS under "Kit differences".
3. **Official sources only** for downloads and installs: the vendor's site, the OS package manager (winget,
   Homebrew, apt), or the vendor's documented registry (npm, PyPI, Docker Hub official images). No mirrors, no
   random scripts from forums.
4. **Ask before each install, download or Docker image pull.** Name it, where it comes from, and roughly how big.
   One yes covers one item, unless the user says "yes to all of step 3" or similar; record that in PROGRESS.
5. **The user types every secret.** Passwords, API keys, tokens, one-time codes, recovery codes, card numbers. You
   never type, paste, print, store or commit one. Point them to where it goes: a sign-in page, a terminal prompt, the
   tool's own login, a git-ignored `.env` file they fill in, GitHub's secret settings.
6. **Admin rights are the user's.** You can't raise your rights. When something needs administrator approval, tell
   them exactly what to click or what to run in an administrator terminal.
7. **System and security settings are the user's.** BIOS virtualization, Windows features, firewall, antivirus,
   account security settings: you explain, they do.
8. **Their machine, their choices.** Don't change global settings (global Git config, shell profiles, PATH, system
   environment variables) without asking first and saying exactly what changes.
9. **Stay inside the setup's folders.** Don't read through or change other projects, the user's documents or other
   apps' data unless the user asks. Leave existing projects where they are unless they agree to move them.
10. **Batch questions.** Ask everything a step needs in one list, with your recommended answer for each, so they can
    reply "defaults" if they like.
11. **Times come from a clock** read in the same step (`Get-Date` on Windows, `date` elsewhere). Never write a time
    from memory or ahead of time.
12. **Say what state things are really in.** Prepared, saved, installed, running, verified and published are
    different. "I wrote the file" is not "it works". Don't call a step done until you verified it.
13. **Keep moving.** If a step waits on the user (an install, a restart, a sign-in), do any later step that doesn't
    depend on it, and say so.
14. **Never cut a check short to finish sooner.** If something fails, find out why; fix the cause, not the symptom.
15. **Leave secrets and personal data out of every file** you write in this setup, including PROGRESS.

## Optional steps and order

| Step | File | Needs first | Optional? |
|---|---|---|---|
| 1 | `01-check-the-machine.md` | nothing | no |
| 2 | `02-interview.md` | 1 | no |
| 3 | `03-install-core-tools.md` | 2 | no (each tool may be skipped if not needed) |
| 4 | `04-git.md` | 3 (Git) | no (the teaching part is skippable) |
| 5 | `05-home-base.md` | 4 | no |
| 6 | `06-project-workspace.md` | 5 | no |
| 7 | `07-docker-test-stack.md` | 3 (Docker), 6 | yes, but strongly recommended |
| 8 | `08-github.md` | 4, 6 | yes |
| 9 | `09-pc-runner.md` | 7, 8 | yes |
| 10 | `10-codex.md` | 5, 6 | yes |
| 11 | `11-claude-codex-exchange.md` | 10 | yes (only with Codex) |
| 12 | `12-your-tools.md` | 6 (and 7 where a tool needs Docker) | no (the user may answer "nothing else") |
| 13 | `13-prove-it-works.md` | everything chosen above | no |
| 14 | `14-daily-use.md` | 13 | no |
| 15 | `15-troubleshooting.md` | — | reference; read when something breaks |

Record every skipped step in PROGRESS with the user's reason, so a later session doesn't redo the question.

## Platforms

- **Windows:** Windows PowerShell 5.1 is the default shell there and reads a script file
  without a byte-order mark as the old ANSI code page, so every `.ps1` in this kit is plain ASCII. Keep any script you
  write for the user ASCII too, or save it as UTF-8 with BOM.
- **macOS and Linux:** verify each command on the machine; record anything that differed in PROGRESS under
  "Kit differences".
- On Windows, prefer full paths for anything you start in the background: the shell's working folder can move.

## If the conversation gets long

Rewrite `my-setup/PROGRESS.md` so it's current, then suggest a fresh session. The new session resumes from the file.
Do the same before your context runs low. Never rely on the chat to remember anything that matters.

## Feedback

If something in the kit was wrong or unclear on this machine, add it to PROGRESS under "Kit differences" with what
you found. At the end (step 14) offer to turn that list into a short note the user can send to the kit's maintainer.
