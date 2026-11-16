# 07 · The Docker test stack

**What and why:** the project's tests, builds and checks run in Docker, on a **clean copy of the last commit**, not on
the files in the project folder. That gives four things:

1. **A result always belongs to a known version.** Uncommitted edits can't sneak into a test, and "it passed" means
   "commit abc123 passed".
2. **The computer stays clean.** Toolchains (PHP, Java, Android SDK, Go, Python packages…) live in an image, not on
   the PC. Removing a project removes its tools.
3. **Local runs match CI.** The image matches what GitHub's runners or the live server use, so a local pass means
   something, and almost nothing needs to run on GitHub (where minutes cost money).
4. **Several checks at once.** Each "slot" (`a`, `b`, `c`…) is a separate copy of the stack with its own containers,
   volume and databases, so Claude can run two checks while Codex runs a third, without them touching.

Evidence of every run (log, summary, details) lands in the local-data folder, where the user can open it and the
records can cite it.

## 1. Copy the templates into the project

From `templates/project/`:

```
local/docker-compose.yml        the stack: one runner container (and any services the project needs)
local/runner/Dockerfile         the runner image: Ubuntu 24.04 + Git + the project's toolchain
local/runner/run-checks.sh      runs inside the container: clean clone of the commit, then scripts/check.sh, evidence
scripts/check.sh                the project's own checks (you fill this in)
scripts/local.cmd               the helper for Windows
scripts/local.sh                the helper for macOS / Linux
```

In `scripts/local.cmd` and `scripts/local.sh`, set `PROJECT` to a short lowercase name (letters, digits, dashes):
Docker Compose requires lowercase project names. Set `LOCAL_DIR`'s default to the project's local-data folder.

## 2. Fill in the toolchain and the checks

**Reuse what exists first.** Before writing any check, find what the project already runs:

- `package.json` scripts (`test`, `lint`, `build`), `Makefile`, `composer.json` scripts, `pyproject.toml` / `tox.ini`
  / `pytest.ini`, `build.gradle`, `*.csproj`, `go.mod`, `Cargo.toml`;
- CI files: `.github/workflows/*.yml`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `bitbucket-pipelines.yml`. These say
  exactly which tools, versions and commands the project's CI uses. Copy those versions into the Dockerfile.
- The project's README or CONTRIBUTING notes.

Then:

1. **Dockerfile:** add the toolchain lines under the marked spot, with versions pinned to match CI or the live server
   (e.g. `php8.3-cli`, `openjdk-17-jdk-headless`, `nodejs` from NodeSource at the CI's major version, `golang-1.22`).
   The matching recipe in `recipes/` has a starting point for common stacks. Ask before the first build (it
   downloads the base image and packages: say roughly how big).
2. **scripts/check.sh:** the checks in order, fastest first (lint, unit tests, build, then slower ones). Each prints
   one clear line per result. Exit non-zero if anything fails. Optional: accept a check name as `$1` to run just one.
3. **Services** (database, cache, search, a mail catcher): add them to `local/docker-compose.yml` as extra services
   with a `mem_limit` each. **One database server per slot**, never shared between slots: two test runs on one
   database server can block each other (seen in practice: lock names built from a shared table prefix made two
   parallel test sites wait on each other).
4. **No ports published** unless the user needs to open something in a browser. A test stack doesn't need to be
   reachable from the PC; it runs everything inside.

## 3. Run it

```powershell
scripts\local.cmd doctor       # Docker, Git, folders, slot and job-limit facts; changes nothing
scripts\local.cmd rebuild      # build the runner image (first time, or after editing the Dockerfile)
scripts\local.cmd check        # run scripts/check.sh on a clean clone of HEAD, in slot a
scripts\local.cmd last         # print the newest evidence summary
```

macOS/Linux: the same with `bash scripts/local.sh <command>`.

A second check at the same time: `set SLOT=b` (PowerShell: `$env:SLOT="b"`; bash: `SLOT=b bash scripts/local.sh check`).

Show the user the evidence folder in `Dev-local\<project>\evidence\<UTC stamp>-<commit>-<check>\`: `summary.md`
(pass/fail and the totals), `log.txt` (everything), `meta.json` (commit, slot, times, whether the project folder had
uncommitted changes at the time).

Long runs: start them in the background (Claude Code's background commands re-invoke Claude when they finish), and
keep working meanwhile. Don't sit in a loop polling.

## 4. Limits: the helper enforces them

The helper refuses to start when it would break a limit, instead of relying on anyone's memory:

| Limit | Default | Set by |
|---|---|---|
| Memory per container | 4 GB (`mem_limit` and `memswap_limit` in the compose file) | Raise only with the user's OK, per service that needs it. Never remove it. |
| Docker jobs at once, across all projects and agents | From step 2 (e.g. 4) | The `CREW_MAX_JOBS` environment variable (user-level: `setx CREW_MAX_JOBS 4` on Windows, a line in the shell profile on Mac/Linux; ask first). The helper counts running containers labelled `crew.job=1`. |
| One job per slot | always | The helper refuses a slot whose runner is already running. Two runs in one slot share its work volume and break each other. |
| Docker's total share of the PC | From step 3 | `.wslconfig` (Windows) or Docker Desktop's Resources (Mac). |

Slots are free names. Convention, recorded in `crew-home/WORKSPACES.md`: Claude uses `a` and `b`, Codex `c` and `d`,
side sessions get named slots (`e`, `f`, …) in their brief. Always check `docker ps` right before starting a run, not
only at the start of a batch.

When Codex is part of the crew (step 11), sharing follows the user's split from step 2: each agent stays within its
share; when one is idle the other may use more; a slot that frees up goes to whichever agent is waiting; nobody races
for slots, stops the other's job, or moves work to the cloud to get around the limit. Slower is fine.

## 5. Keep the disk in check

- The helper's `down` removes a slot's containers (evidence stays). `scripts\local.cmd clean` removes the slot's work
  volume too.
- `docker builder prune -f` clears the build cache. `docker image prune` removes dangling images.
- Don't run `docker system prune -a` or `docker network prune` on a shared machine without looking first: Docker 29
  removes the networks of *stopped* containers too, which breaks every stopped stack until it's recreated.
- **Windows:** Docker keeps everything in one virtual disk file (`%LOCALAPPDATA%\Docker\wsl\disk\docker_data.vhdx`),
  and it never shrinks by itself after files inside it are deleted. Giving the space back is a system step the user
  does as administrator: quit Docker Desktop, `wsl --shutdown`, then in an admin prompt run `diskpart` and
  `select vdisk file="<path>"`, `attach vdisk readonly`, `compact vdisk`, `detach vdisk`, `exit`. Check the current
  Docker docs first; newer versions may offer this in Settings.
- **Three generations rule** for builds and test sites: keep the last known good version, the version being worked
  on, and the newest. Everything older can go. Evidence folders that records cite are kept (zip them if they grow).

## 6. Local previews in the desktop app (optional)

If the project has something to look at in a browser (a website, a web app, docs), add it to the project's
`.claude/launch.json` so Claude can start it and look at it in the app's browser pane. Template:
`templates/project/.claude/launch.json`. Bind to `127.0.0.1`, not `0.0.0.0`, so it's only reachable from this PC.

## 7. Copies of live systems

A local copy of a live website, store or database is the most useful test bed there is, and the most sensitive: it
holds real customer data. Rules:

- Each copy needs the user's OK. It lives in `Dev-local\<project>\` only: never in Git, GitHub, a workflow artifact or
  a synced folder.
- The copy can't reach the internet or send mail (block outbound calls, catch mail into files), and scheduled jobs are
  off, so nothing in it can charge a card, email a customer or call a live API.
- Count what's in it (numbers only, no personal details) and tell the user before copying.

`recipes/wordpress-woocommerce.md` is a complete worked example (the one this kit's workflow grew up on). Other
platforms follow the same pattern.

## Record

PROGRESS and the project's `CLAUDE.md` ("Testing" section): the helper commands, the slots, the limits, the image's
toolchain and versions, the first run's result and evidence path. Add a row to `docs/records/test_execution.csv` for
that first run. Register the slots in `crew-home/WORKSPACES.md`. Commit. Mark step 7 done.
