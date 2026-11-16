# 01 · Check the machine (read only)

**What and why:** see what this computer already has, so nothing gets reinstalled and nothing is assumed. Nothing is
changed in this step.

## Do

Windows (PowerShell):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-machine.ps1
```

macOS / Linux:

```bash
bash scripts/check-machine.sh
```

The script only reads. It prints a Markdown report: operating system, processor, memory, free disk, virtualization,
WSL, the versions of Git, GitHub CLI, Docker, Node, Python, Codex and Claude's CLI if present, whether Docker is
running, Docker's memory and processor limits, whether the user's Documents folder is inside OneDrive, and whether
GitHub CLI is signed in (yes/no only, no account details).

`-ExecutionPolicy Bypass` applies to that one run only; it doesn't change the computer's policy. If the user's
organisation blocks it, run the commands from the script by hand instead (it is short and commented).

## Read the result for the user

Tell them in plain words, five to ten lines:

| Finding | What it means |
|---|---|
| Memory under 16 GB | Workable for small projects; Docker gets a smaller share; run one Docker job at a time. |
| 16 GB | Fine. Docker gets about 8 GB; two or three Docker jobs at once. |
| 32 GB or more | Comfortable. Docker can get 16–20 GB; four or five jobs at once. |
| Free disk under 40 GB | Ask what can be cleaned before installing Docker. Docker's images and test sites grow to tens of GB over months. |
| Virtualization off (Windows) | Docker Desktop and WSL 2 need it. It's switched on in the computer's BIOS/UEFI settings: the user does it (rule 7). Explain how to find the setting for their computer's maker; don't guess the menu names. |
| WSL missing or version 1 (Windows) | Installed in step 3. |
| Documents inside OneDrive (Windows) | Normal, but projects must not go there. The setup uses `C:\Users\<you>\GitHub\` instead. |
| A tool already installed | Note its version; step 3 skips it unless it's too old for the current official requirements. |
| Docker installed but not running | Start Docker Desktop and run `docker version` again before step 3 decides anything. |
| An existing `.wslconfig` (Windows) | Someone already limited Docker's memory or processors. Keep it; step 3 asks before changing it. |

Also check, and record:

- **Is there already a Claude or Codex setup?** Look for `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
  `~/.codex/config.toml`. If they exist, read them (they're the user's own files) and tell the user: this setup will
  *add to* them in steps 5 and 10, and show every change before saving. Never replace them wholesale.
- **Existing projects.** If the user mentioned a project folder, check whether it's a Git repository
  (`git -C <folder> rev-parse --show-toplevel`) and whether it's inside a synced folder. Don't move anything yet.

## Record

In `my-setup/PROGRESS.md`, under "Machine facts", paste the report and add the date and time (from the clock) and
"checked with scripts/check-machine". Mark step 1 done. These facts move to the home base's `MACHINE.md` in step 5.
