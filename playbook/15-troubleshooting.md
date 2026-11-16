# 15 · Troubleshooting and known traps

Read this when something breaks, and before writing scripts on Windows. Every item here cost real time once.

## Docker

| Symptom | Cause and fix |
|---|---|
| `failed to connect to the docker API` / `error during connect` | Docker Desktop isn't running (it can stop on its own, after updates or sleep). Start it, wait until `docker version` shows a Server section, then start your stacks again. Containers that exited keep their volumes. |
| Containers exited with code 255 after a restart | Normal after Docker Desktop restarts. Databases without a restart policy need `docker start` (or the helper's next run starts them). |
| The PC runs out of memory | A container without a memory cap. Every service in this kit's compose files has `mem_limit`. Check `docker stats --no-stream`. If Docker as a whole is the problem, lower `.wslconfig` `memory` (Windows) and restart Docker. Restarting a hung Docker Desktop is fine to do; note which containers were running and start them again. |
| `all predefined address pools have been fully subnetted` | Too many Compose networks left up. Take idle slots down (`scripts\local.cmd down`) and reuse existing slots. Don't remove networks other sessions use. |
| Stacks broken after `docker network prune` | Docker 29 also removes the networks of stopped containers. Each stack needs `docker compose up -d --force-recreate` from its own compose file. Avoid network prune on a shared machine. |
| `docker run <image>` downloads something unexpected | It pulls when that exact tag is missing, even if a similar tag is on disk. Use `--pull never` and a tag `docker images` lists when you mean "only what's here". |
| A command quietly installs a Docker feature | Some `docker <plugin>` commands install their backend on first use (e.g. `docker model` pulled a multi-GB image once). Check the feature's setting in Docker Desktop first. |
| MySQL in containers: `io_setup() failed with EAGAIN` | The Docker VM's async-I/O limit is used up by many idle database containers. Take idle slots down, or start the database with `--innodb-use-native-aio=0` in a per-slot override. |
| Disk keeps growing (Windows) | Docker's virtual disk never shrinks by itself. Prune, then compact (step 7, section 5). |
| A test run fails oddly in a slot someone else used | Two runs in one slot share its volume. One job per slot (the helper refuses a busy slot); check `docker ps` right before each run. |
| Files written by a container can't be deleted | Written as root into a shared volume or folder. Run containers as a normal user (the runner template does), or fix ownership from inside a container. |

## Git

| Symptom | Cause and fix |
|---|---|
| `Filename too long` (Windows) | `git config core.longpaths true` (global or in that repository). |
| `bad interpreter: /bin/bash^M` in a container | A shell script was checked out with CRLF. `.gitattributes` pins `*.sh` to LF; after adding it, `git add --renormalize .` and commit. |
| `detected dubious ownership` inside a container | The repository is owned by another user from the container's view. The runner image sets `safe.directory`; for your own containers: `git config --global --add safe.directory <path>`. |
| `git status` inside a container takes 40 seconds | Git over a Windows bind mount is slow. Ask the host for the dirty state and pass it in (the helper does). |
| "Your current branch appears to be broken" after a power cut | The branch's ref file got zeroed. Copy `.git` somewhere safe first. Read the last commit from the last line of `.git/logs/refs/heads/<branch>`, check it with `git cat-file -t <sha>`, delete the empty ref file, `git update-ref refs/heads/<branch> <sha>`, then `git fsck --full`. Then push (that's why backup pushes exist). |
| Someone's changes vanished from a worktree | `git stash` is shared by all worktrees; another session may have popped it. Use temporary commits, not stash. |
| A workflow ran when it shouldn't have | A workflow tag in the commit **body**. Tags only in subject lines; the template's first step re-checks the subject. |
| Duplicate record numbers after a merge | Two sessions appended the same Q/D/F number on different branches. Check every branch before taking a number (step 6, section 4); renumber the later one on merge. |

## Windows shells and scripts

| Trap | What to do |
|---|---|
| PowerShell 5.1 reads a `.ps1` without a byte-order mark as the ANSI code page | Non-ASCII characters (`·`, `→`, curly quotes) break matching and output. Keep scripts ASCII, or save as UTF-8 with BOM. Self-test a watcher's pattern against the real file before starting the loop. |
| PowerShell 5.1 has no `&&`, `||`, `?:`, `??` | Use `; if ($?) { ... }` and `if/else`. |
| `2>&1` on a native program in PowerShell 5.1 | Wraps each stderr line as an error and sets `$?` false even on success. Don't redirect stderr of native programs there. |
| A `foreach` statement can't be redirected | Wrap it: `& { foreach (...) { ... } } *> file`. |
| A one-element array of arrays gets flattened | Write `@( ,@('a','b') )`. |
| Bash heredocs (Git Bash, the Bash tool) turn `\\` into `\` | Windows paths, regexes and PHP namespaces in a heredoc'd script come out wrong (a `\a` became a bell character in a records file once). Write such scripts as files with an editor or the Write tool, then run the file. |
| `cmd /c` treats `>` and `->` in an argument as a redirect | Never pass PHP or SQL inline through `cmd`; put it in a file and run the file. |
| Editing a `.cmd` file while a command started from it is still running | cmd.exe reads the file as it goes; the run ends with a nonsense error. Edit only when nothing from it runs. |
| Git Bash's `sed -i` rewrites CRLF files as LF | Edit CRLF files with a tool that keeps line endings. |
| Python's `Path.write_text` on Windows writes CRLF | Use `newline="\n"` or `write_bytes` for files that must be byte-exact. |
| `python -I` ignores `PYTHONIOENCODING` | Use `python -X utf8 -I ...` when output contains non-ASCII. |
| `python` on PATH isn't the Python you think | Another app may ship its own (Codex does). `where.exe python`. Project tooling runs in Docker anyway. |
| Background runs fail with "path not found" | The shell's working folder moved. Start background runs with full paths. |
| A background command that itself backgrounds work with `&` | Reported as finished at once, and its children can outlive it (and keep starting jobs after you "stopped" it). Never put `&` inside a background run; after stopping a queue, check `ps`/`docker ps` for leftovers. |
| Temp folders made by Python 3.12+ `mkdtemp()` can't be written by containers | Owner-only access lists. Make test folders with a plain `mkdir` under `Dev-local`. |

## Codex

| Symptom | Cause and fix |
|---|---|
| Codex ignores rules from a parent folder's `AGENTS.md` | No `.git` in that parent: Codex only checks the current folder. Put the rule in the global file's routing table. |
| Codex "forgets" rules later in a long chat | Compaction dropped chat-only context. The global file's start routine makes it re-read STATUS and decisions after long tasks; check that's in the file and that the file loaded (END line in `codex debug prompt-input`). |
| Rules didn't change after editing `AGENTS.md` | Open chats keep what they loaded at start. Start a fresh chat or tell it to re-read. |
| The global file is ignored entirely | A non-empty `~/.codex/AGENTS.override.md` replaces it, or the joined files exceed `project_doc_max_bytes` (32 KiB default). |
| "Access is denied" on a project folder from a Codex run | Its Windows sandbox account can't read that folder. Check from the desktop app; record which works. |
| Codex keeps asking the user to confirm what Claude relayed | That's correct behaviour: a rule relayed by another agent isn't the user's own word until confirmed. |

## Claude Code

| Symptom | Cause and fix |
|---|---|
| A new rule isn't followed | Open sessions keep the instructions they started with. Start a fresh session; check the rule is in `~/.claude/CLAUDE.md` or the project's `CLAUDE.md`, not only in a chat. |
| The session waits forever on a long job | Long jobs go in the background (they re-invoke the session when done). Waiting on a log line that never comes is the classic hang: wait for the count of result lines, or the process to exit, not a specific phrase. |
| Too many permission prompts | The user can allow common read-only commands for the project (Claude Code's permission settings). Never allow destructive commands blanket-wide. |
| The browser pane can't open a local page | Use the project's `.claude/launch.json` preview entry and bind to `127.0.0.1`. |

## Records and process

| Trap | What to do |
|---|---|
| A status or setting repeated from an old note was wrong | Re-read live settings before stating them, or say when they were last checked. |
| "Done" turned out to mean "written but not working" | Say the real state: prepared, saved, installed, running, verified, published. |
| A question answered twice, or the answer put on the wrong row | Find questions by their text, not only their number. |
| A rule relayed by the other agent turned out not to be the user's | Confirm relayed rules with the user before recording them as decisions. |
| Something waited hours because nobody was watching a file | Saved isn't delivered. Use the watcher, or tell the user to prompt the other agent. |
