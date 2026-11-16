# 09 · A GitHub runner on this computer (optional)

**What and why:** a GitHub Actions job normally runs on GitHub's machines and costs minutes. A **self-hosted runner**
is a program on the user's own computer that takes jobs instead. This kit's version runs in a Docker container that
registers for **exactly one job**, runs it, and exits; GitHub then removes the registration, so nothing stays
listening on the PC.

Use it for jobs that only GitHub can start (they need a secret, or the user triggers them from a phone) but that
should run here: release jobs, read-only checks of a live system, copying data from a server into the local-data
folder. The job's files and any copy of live data stay on the PC; nothing goes into GitHub's logs or artifacts unless
the workflow puts it there.

Skip this step if the user has no release jobs yet. Come back when the first one is near.

## Safety first

- **Private repositories only.** On a public repository, anyone who opens a pull request from a fork could get their
  code run on this computer. GitHub's own docs recommend self-hosted runners only with private repositories. The
  template workflows also only trigger on pushes to the user's own branches, never on `pull_request`.
- The runner starts only when someone runs the helper. A job waits (queued) until then.
- The registration token is fetched from the GitHub CLI login (step 8) at start, is short-lived, and is never printed.
- Secrets reach the job only while it runs, and the template keeps them in a memory-only folder that disappears with
  the container.

## 1. Copy the templates

From `templates/project/`:

```
local/gh-runner/Dockerfile          GitHub's official runner image + the tools the jobs need
local/gh-runner/docker-compose.yml  one-job runner; memory-only folders for keys and temp files; 4 GB cap
local/gh-runner/entrypoint.sh       registers (ephemeral), takes one job, exits
scripts/gh-runner.cmd / .sh         fetches the token with gh, starts the container
```

Set the runner's label (default `crew-pc`) and add only the tools the project's jobs use to the Dockerfile. Mount only
the local-data folders a job needs to write.

## 2. Build and try

Ask first: the runner image is GitHub's official `ghcr.io/actions/actions-runner` (a few hundred MB plus tools).

```powershell
scripts\gh-runner.cmd build
scripts\gh-runner.cmd
```

The second command waits for one job. To test it end to end, push a commit whose subject carries the template
workflow's dry-run tag (`[release-example-dry]`), with the runner started. Watch it on GitHub (`gh run watch` or the
Actions tab): the job lands on `crew-pc`, runs, and the container exits. Check that the registration is gone
afterwards: `gh api repos/<owner>/<repo>/actions/runners --jq ".total_count"` should be 0.

## 3. The workflow side

The template's job picks its machine like this:

```yaml
runs-on: ${{ contains(github.event.head_commit.message, '[hosted]') && 'ubuntu-24.04' || fromJSON('["self-hosted","crew-pc"]') }}
```

So: this computer by default; a GitHub machine (paid minutes) only when the commit message also carries `[hosted]`,
for phone sessions when the PC is off.

Steps that only a GitHub machine needs (installing a language, for example) get
`if: runner.environment == 'github-hosted'`, because the PC runner's image already has them.

## 4. Counting it

The runner is a Docker job. It counts toward `CREW_MAX_JOBS` (it carries the `crew.job=1` label) and gets the same
4 GB cap. Start it, push, and let it finish before starting other heavy runs if the machine is busy.

## Record

PROGRESS and the project's `CLAUDE.md` (GitHub section): the label, the helper commands, which workflows use it, the
first test run's id and result. Commit (`[skip ci]`). Mark step 9 done.
