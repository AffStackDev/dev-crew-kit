# Start here

You'll do four small things yourself. After that, Claude walks you through the rest, one step at a time, and checks
each step on your computer before moving on.

## 1. What you need before you begin

| You need | Why | Notes |
|---|---|---|
| A Windows 10/11, macOS or Linux computer | Everything runs on your machine | Claude checks each step on your machine as it goes. 16 GB of RAM works, 32 GB is comfortable. Keep 40 GB of disk free. |
| A Claude plan that includes Claude Code | Claude does the setup and the daily work | See claude.com/pricing for which plans include it today. |
| The Claude desktop app | Its **Code** tab is where Claude works on your files | Download from **claude.ai/download**, install, sign in. |
| **Windows only:** Git for Windows | The Code tab on Windows needs it | **git-scm.com/download/win**. The installer's default choices are fine. |
| *Optional:* a ChatGPT plan that includes Codex | Only if you want Codex as a second worker | Claude sets it up in step 10. Everything else works with Claude alone. |
| *Optional:* a GitHub account | Off-site backup, review, phone access, releases | Free at github.com. Claude helps you connect it in step 8. You can make the account then. |

## 2. Put this kit on your computer

Put it in a plain folder that **is not synced by OneDrive, iCloud Drive, Dropbox or Google Drive**. Sync tools fight
with Git and Docker over the same files. On Windows, `C:\Users\<you>\Documents` is often inside OneDrive without you
knowing, so use `C:\Users\<you>\GitHub\` instead.

Either:

- **With Git** (in a terminal):

  ```bash
  git clone https://github.com/AffStackDev/dev-crew-kit.git
  ```

- **Or as a ZIP:** on the kit's GitHub page, click **Code**, then **Download ZIP**, and unzip it into
  `C:\Users\<you>\GitHub\` (Mac/Linux: `~/GitHub/`).

## 3. Open it in Claude

Open the Claude desktop app, go to the **Code** tab, and pick the kit's folder as the project folder.
(Using the CLI instead? Open a terminal in the kit's folder and run `claude`.)

## 4. Paste this

```text
Set me up. Follow the Dev Crew playbook in this folder from the start, or resume where we left off. One step at a time, and check each step on my computer before moving on.
```

Claude reads the kit's `CLAUDE.md` by itself and takes it from there. You can stop whenever you like: progress is
saved in `my-setup/PROGRESS.md`, and next time you paste the same line (or just say "continue") and Claude picks up
where you left off.

## What the setup covers, in order

1. Checks your computer (read only) and tells you what's there and what's missing.
2. Asks you one batch of questions: what you work on, how you want the AI to work, what to set up first.
3. Installs the core tools, each with your OK: Git, GitHub CLI, Docker Desktop (and WSL 2 on Windows).
4. Sets up Git properly, and teaches you the five Git ideas you'll actually use (skip it if you know Git).
5. Makes your **home base**: one folder of notes and rules that every session and both AIs read first.
6. Sets up your first project with its own rulebook, status page, question list and decision log.
7. Builds a **Docker test stack** so tests and builds run on a clean copy of your latest commit, not on your files.
8. Connects **GitHub**: private backup, safe pushes that start nothing by accident, releases only on purpose.
9. *(Optional)* A **GitHub runner on your own computer**, so release jobs cost no GitHub minutes.
10. *(Optional)* Installs and configures **Codex** so it follows the same rules and remembers them.
11. *(Optional)* The **Claude ↔ Codex exchange**: how the two hand work back and forth, review each other, and share Docker.
12. **Your other tools:** video editing, game and 3D, mobile SDKs, WordPress, design tools, MCP connectors to your
    websites and services, whatever you use. Claude asks, then wires each one into the workflow and tests it.
13. **Proves it all works** with a real change, end to end.
14. Shows you how a normal day goes, and how to use it from your phone.
15. Troubleshooting, for later.

## How long it takes

The core (steps 1–8) is usually one to two hours, most of it waiting on installs and one restart on Windows. Codex
adds about half an hour. Each extra tool depends on the tool. Nothing has to be done in one sitting.

## No Claude Code yet? Start in a regular Claude chat

If you're stuck before step 3, paste this into a normal chat at claude.ai. It walks you up to the point where you
can paste the line from step 4.

```text
I want to set up the "Dev Crew" local development workflow (Claude Code + Docker + Git + GitHub, optionally Codex). The kit is at https://github.com/AffStackDev/dev-crew-kit. I don't have Claude Code running yet. First ask me which operating system I use. Then walk me through, one step at a time and waiting for me to confirm each one: installing the Claude desktop app from claude.ai/download and signing in; on Windows, installing Git for Windows from git-scm.com; downloading the kit into a folder that is not synced by OneDrive, iCloud, Dropbox or Google Drive (on Windows, C:\Users\<me>\GitHub\); and opening that folder in the desktop app's Code tab. When the Code tab is open on the kit folder, tell me to paste the line from step 4 of START-HERE.md there. Don't go beyond that point.
```
