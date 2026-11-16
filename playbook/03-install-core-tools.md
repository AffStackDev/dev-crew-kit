# 03 · Install the core tools

**What and why:** the few tools everything else stands on. For each one: check if it's there, ask, install from the
official source, verify, record. Skip what's already installed and current.

Before running any install command, read the tool's current official install page (rule 2 in 00). The commands below
were right in November 2026. On Windows, `winget` (built into Windows 10/11) installs from the vendor's own package;
confirm an ID with `winget search <name>` if one fails.

## 1. Git

Needed by: everything.

| OS | Install | Verify |
|---|---|---|
| Windows | Already there if the Code tab opened (Git for Windows). Otherwise `winget install -e --id Git.Git` or git-scm.com/download/win | `git --version` |
| macOS | `xcode-select --install` (Apple's command line tools include Git), or `brew install git` | `git --version` |
| Linux | The distribution's package manager, e.g. `sudo apt install git` | `git --version` |

Git's settings are step 4. Don't change any Git setting here.

## 2. GitHub CLI (`gh`)

Needed by: step 8 (GitHub) and step 9 (runner). Skip if the user said no GitHub.
What it is: GitHub's own command-line tool. It signs in once through the browser and then lets scripts create
repositories, read results and fetch short-lived tokens without anyone typing a password.

| OS | Install | Verify |
|---|---|---|
| Windows | `winget install -e --id GitHub.cli` | `gh --version` |
| macOS | `brew install gh` | `gh --version` |
| Linux | The official package repository from cli.github.com (follow its Linux page) | `gh --version` |

A new terminal may be needed before `gh` is found (PATH refresh). Signing in is step 8.

**GitHub Desktop** (optional, Windows/macOS): a friendly window for seeing commits and branches. Some people like
having it alongside. `winget install -e --id GitHub.GitHubDesktop` or desktop.github.com. Warn: GitHub Desktop
suggests cloning into `Documents\GitHub`, which on many Windows PCs is inside OneDrive. Change the folder to the one
chosen in step 2.

## 3. WSL 2 (Windows only)

Needed by: Docker Desktop on Windows.
What it is: a real Linux kernel running inside Windows. Docker's containers run in it. The user won't usually see it.

Check: `wsl --status` and `wsl -l -v`.

- If WSL isn't installed: the user opens **Terminal (Admin)** or **PowerShell as administrator** and runs
  `wsl --install`, then **restarts the computer**. You can't do this part (admin). While they restart, nothing else
  can happen; write PROGRESS first so the next session resumes cleanly.
- If WSL is there but old: `wsl --update` (may also need admin).
- Docker Desktop brings its own small Linux distribution (`docker-desktop`). A separate Ubuntu is **not** needed for
  this setup. Don't install one unless the user wants it for their own reasons.

## 4. Docker Desktop

Needed by: step 7 (test stack), step 9 (runner) and most tool recipes.
What it is: runs **containers**, small throwaway Linux machines built from **images** (recipes). Tests and builds run
in them, so the user's computer stays clean and every run starts from the same known state.

| OS | Install | Notes |
|---|---|---|
| Windows | `winget install -e --id Docker.DockerDesktop` or docker.com | Use the WSL 2 engine (the default). |
| macOS | docker.com (pick Apple silicon or Intel) or `brew install --cask docker` | |
| Linux | Docker Engine from docs.docker.com's page for the distribution, plus the Compose plugin; or Docker Desktop for Linux | Adding the user to the `docker` group gives that account root-level power over the machine; explain this, and let them choose. |

Then:

1. The user starts Docker Desktop and accepts its terms (their agreement, rule: you don't accept terms for them).
   Docker Desktop's license is free for personal use, education and small businesses; larger companies need a paid
   subscription. Tell them to check docker.com's current terms if they work for a company.
2. Verify: `docker version` (both Client and Server sections answer) and `docker compose version`.
3. Ask, then run the tiny test image: `docker run --rm hello-world` (a few KB from Docker Hub's official images).

### Docker's share of the computer

From the answer to question 21 in step 2.

- **Windows:** WSL 2 (and so Docker) takes up to half the RAM by default and all processor threads. Limit it in
  `C:\Users\<you>\.wslconfig`. If the file exists, show the user its current lines and change only `memory` and
  `processors` with their OK. Example for a 32 GB, 16-thread PC:

  ```ini
  [wsl2]
  memory=16GB
  processors=10
  ```

  To apply: quit Docker Desktop, run `wsl --shutdown`, start Docker Desktop again. Recent Docker Desktop versions can
  do this from the command line (`docker desktop stop`, `docker desktop start`); check `docker desktop --help`. This
  stops every running container, so never do it while a job runs. Verify with `docker info` (it reports CPUs and Total
  Memory).

- **macOS / Docker Desktop for Linux:** Docker Desktop → Settings → Resources. The user sets it; you read it back with
  `docker info`.

The per-job limit (4 GB per container by default) is set in each project's compose file in step 7, not here. A raise
of the total never lifts the per-container limit: one unlimited container can eat everything (a video-encoding
container once took 18 of 20 GB and the PC ran out of memory).

## 5. Runtimes on the computer itself: only what's needed

Most project toolchains (PHP, Java, Android SDK, Go, .NET, Python packages…) go **inside Docker images** in step 7
and step 12, not on the computer. That keeps the PC clean and makes local runs match CI.

Install on the computer only when something on the computer itself needs it:

| Tool | Install when | Windows | macOS |
|---|---|---|---|
| Node.js LTS | The user wants the Codex CLI (installed with npm), or a tool that needs Node on the host | `winget install -e --id OpenJS.NodeJS.LTS` | `brew install node` |
| Python 3 | Scripts the user runs on the host | winget `Python.Python.3.x` (check `winget search Python.Python`) or python.org | `brew install python` |

Note on Windows: a `python` on PATH may belong to another app (Codex ships its own runtime, for example). Check
`where.exe python` before assuming which Python runs.

## 6. Codex

Not here. Codex is step 10, after the home base exists, so its rules can point at it.

## 7. An editor (optional)

The user may already have one. If they want one: VS Code (`winget install -e --id Microsoft.VisualStudioCode`) or any
editor they like. Claude doesn't need it.

## Record

In PROGRESS, "Installed in this setup": each tool, version, how installed, date, and the verify command's result.
Also anything the user did themselves (restart, admin prompt, Docker terms). Mark step 3 done.
