# 04 · Git: set it up properly, and the five ideas you'll use

**What and why:** Git keeps every version of the user's work, lets the AI try things on a branch without touching
the working version, and makes backup to GitHub a one-line job. A few settings decided now prevent the classic
problems later: a real email leaking into public history, line-ending noise, paths too long for Windows.

## Part 1: settings

Check what's set: `git config --global --list` (show the user; it's their own config). Then, with their OK:

### Identity: per repository, or global?

Every commit carries a name and an email. They become **public** if a repository is ever made public, including old
commits.

- **Recommended email:** GitHub's private address, which looks like `12345678+username@users.noreply.github.com`.
  The user finds it on GitHub → Settings → Emails, after ticking **Keep my email addresses private**. Also suggest
  ticking **Block command line pushes that expose my email**, which makes GitHub refuse a push that carries their real
  address. If they have no GitHub account yet, set the identity per repository in step 6 and switch to the noreply
  address after step 8.
- **Global or per repository:** if the user wants the same identity everywhere, set it globally:
  `git config --global user.name "<name>"` and `git config --global user.email "<noreply email>"`. If they already
  have a global identity (for example their work email), don't change it: set the identity per repository instead
  (`git -C <repo> config user.name ...`) in steps 5 and 6. Ask which.

### Line endings (Windows)

Windows text files end lines with CRLF, Linux and macOS with LF. Git for Windows usually converts on checkout
(`core.autocrlf=true`, set by its installer). That's fine for most files, but scripts that run inside Linux
containers must stay LF or they break with errors like `bad interpreter: /bin/bash^M`.

Don't change the global setting. Instead, every repository in this setup gets a `.gitattributes` file
(`templates/project/.gitattributes`) that pins it per file type: `*.sh` LF, `*.cmd` / `*.bat` CRLF, and code that runs
on Linux servers LF. That's explicit and travels with the repository.

### Long paths (Windows)

Deep folders (node_modules, game engine projects, nested worktrees) can exceed Windows' old 260-character path limit
and fail with "Filename too long". Ask, then: `git config --global core.longpaths true`. (Windows itself has a
separate long-path setting; that one is a system setting the user changes, not you. Git's setting is usually enough.)

### Default branch name

`git config --global init.defaultBranch main` (ask; it only affects new repositories).

### Signing in to GitHub from Git

Leave it for step 8: `gh auth setup-git` makes Git use the GitHub CLI's sign-in. On Windows, Git for Windows also
ships Git Credential Manager, which works too. No password or token is ever written into a file or a remote URL.

## Part 2: the five ideas (skip if the user knows Git)

Teach with a tiny demo in a throwaway folder (`C:\Users\<you>\Dev-local\git-demo` or `~/Dev-local/git-demo`),
five minutes, then delete the folder. Explain each in a sentence or two as you do it:

1. **Repository and commit.** `git init`, make a file, `git add`, `git commit -m "..."`. A commit is a saved version
   with a message. You can always go back to it.
2. **Branch.** `git switch -c try-something`. A branch is a separate line of work. Changes there don't touch `main`
   until merged. The AI works on branches so `main` always works.
3. **Merge.** Back on `main`, `git merge try-something`. This is the "yes, keep it" moment, and in this setup it
   happens when the user says so.
4. **Worktree.** Each Claude Code session (and each Codex task) gets its own checkout of the same repository in its
   own folder, on its own branch, so two sessions can work at once without stepping on each other.
   Show: `git worktree list`.
5. **Remote and push.** A copy of the repository on GitHub. `git push` sends commits there. Until something is
   pushed, it exists only on this computer. That's step 8.

Also show `git log --oneline` and `git diff`, and mention tags (a name pinned to one commit, used for releases:
"what's live is tag v1.4.2").

## Part 3: the Git rules that go into every rulebook

These are written into the project `CLAUDE.md` template already. Explain them once:

- **Never commit secrets or data:** passwords, keys, tokens, `.env` files, database dumps, customer data, copies of a
  live site. Each repository's `.gitignore` catches the usual file names; the rule still applies to anything else.
- **No direct commits to `main`.** Work happens on a branch (a work branch, and session branches off it). `main` is
  merged on the user's word.
- **No history rewriting** (force push, rebase of pushed commits, `reset --hard` on shared branches) without the
  user's go for that specific action.
- **Commit before testing.** The Docker test stack (step 7) tests a clean copy of the last commit, never uncommitted
  files, so a result always belongs to a known version.
- **Don't use `git stash` for setting work aside.** The stash list is shared by every worktree of a repository, so
  one session can pop another session's changes. Use a temporary commit on your own branch instead.
- **Git is not a backup until it's pushed.** One real case: a power cut corrupted Git's pointer to the current branch
  (the file was left full of zero bytes). The commits were still there and the branch was rebuilt from Git's reflog,
  but only because nothing else was lost. Pushing the work branch at every stopping point (step 8) makes that a
  non-event.

## Record

In PROGRESS: which settings were set (global or per repository), the identity chosen (name, and "GitHub noreply" or
"own address", not the address itself), and whether the demo was done. Mark step 4 done.
