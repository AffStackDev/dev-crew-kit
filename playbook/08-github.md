# 08 · Connect GitHub

**What and why:** GitHub is the off-site copy of the work, the place to review changes (also from a phone), and, when
the user wants it, the trigger for release jobs that need secrets. It is **not** where tests run: the PC does that
(step 7). Principle, in the original workflow owner's words: "git is only there so if I want to work from my phone or
tell you to push an update to the site you can".

## 1. The account (the user's)

- No account yet: the user makes one at github.com. They choose the username and password and handle the email
  confirmation. You don't create accounts for them.
- Recommend: two-factor authentication on (Settings → Password and authentication), and the email privacy settings
  from step 4 (Keep my email addresses private; Block command line pushes that expose my email).
- If step 4 set a temporary per-repository email, switch the repositories to the noreply address now.

## 2. Sign in the GitHub CLI (the user does it)

Ask the user to run this in a terminal themselves and follow the prompts (GitHub.com → HTTPS → sign in with a web
browser). It shows a one-time code they enter in the browser. You don't handle the code.

```bash
gh auth login
```

Then you verify, and connect Git to it:

```bash
gh auth status
gh auth setup-git
```

`gh auth status` prints the account name and scopes. Don't paste token values anywhere; `gh` keeps the token in the
system's credential store.

## 3. A private repository per project

For each project the user wants on GitHub (and the home base, if they want that backed up too):

```bash
gh repo create <name> --private --source . --remote origin --description "<one line>"
git push -u origin <work branch>
git push origin main
```

**Private** unless the user explicitly wants a public project. Before anything is ever made public, scan the whole
history for secrets (a scanner such as gitleaks, run in Docker, with the user's OK to pull the image), and check the
commit emails (`git log --format="%ae" | sort -u`). Deleting a file doesn't remove it from history.

Ask whether to protect `main` on GitHub (Settings → Rules → a ruleset that requires a pull request for `main`). It's
an account setting: the user clicks it, or says yes and you run the matching `gh api` call and show the result.

## 4. What GitHub runs, and how to make sure it runs nothing by accident

Every push can start GitHub Actions workflows, and hosted minutes cost money or count against a limit. The original
workflow once burned about 3,000 minutes in two days running tests on GitHub that the PC could run. Rules:

- **Tests, builds, linting, packaging run on the PC** (step 7). Workflows that run them on GitHub are manual-start
  only (`on: workflow_dispatch`), for when the PC is off or the user is on their phone.
- **Backup pushes start nothing.** The head commit of a backup push carries `[skip ci]` in its message (GitHub skips
  push-triggered workflows for it). Push the work branch at every stopping point; that's the backup.
- **Release jobs run only on purpose.** A release workflow starts only when the commit's **subject line** (the first
  line of the message) carries its tag, for example `[deploy-dry]` or `[deploy]`. One tag per commit. Never write a
  workflow tag in a commit body: GitHub's `contains()` check sees the whole message, so a body that merely quotes a tag
  ("next: run [deploy]") starts the job. The template workflow checks the subject line again in its first step and
  refuses when the tag is only in the body.
- **Before every push,** look at what's going out:

  ```bash
  git log origin/<branch>..HEAD --format="%h %s"
  ```

  Every commit that should start nothing carries `[skip ci]`; at most one carries a release tag, in its subject.
- **Never push while a release job is still running** for that branch.

Write the tags this project uses into its `CLAUDE.md` as a table (`templates/project/CLAUDE.md` has the table).

## 5. Release workflows (when a release is near, not before)

Build the release path when the project first needs it. The pattern, from the original workflow:

1. **Rehearse first** on a local copy of the live system, from the exact versions live runs (step 7, section 7).
2. **Dry run** (`[<name>-dry]`): every gate and check, no change.
3. **Real run** (`[<name>]`) only with the user's go for that release.
4. Inside the job: confirm the target is the right one (identity gate), back up first, change, verify, and restore
   automatically on failure. Write a summary the user can read on their phone.

Template: `templates/project/.github/workflows/release-example.yml`. It runs on the PC runner by default (step 9),
or on a GitHub machine when the subject also carries `[hosted]`. Give each release workflow **its own concurrency
group**: if three workflows share one group, the newest waiting run can cancel another unseen.

Pin third-party actions to a full commit SHA, not a tag (`uses: actions/checkout@<sha> # v4`), so a changed tag can't
change what runs with the project's secrets. Look the SHA up with `gh api repos/actions/checkout/git/ref/tags/<tag>`.

## 6. Secrets

- Secrets for workflows (deploy keys, API tokens) go into GitHub's encrypted secrets, set by the **user**:
  `gh secret set <NAME>` (it prompts; they paste) or the repository's Settings → Secrets and variables → Actions.
- Never in a file in the repository, a workflow file, a commit message, a log line or a job summary. Jobs mask
  registered secrets in logs; don't rely on that alone.
- An SSH deploy key: generate it on the PC (`ssh-keygen -t ed25519`), the user adds the public half on the server
  (their account) and the private half as a GitHub secret, then delete the private file from the PC if nothing else
  needs it. Pin the server's host key in the workflow (check its fingerprint once, record it) so the job refuses an
  impostor server.
- In a job, write a key only to a memory-only folder (the PC runner template mounts one) and never print it.

## 7. Reviews and the phone

- A **draft pull request** from the work branch into `main` gives the user one place to see everything that's
  changed, from the GitHub mobile app too. Merge to `main` happens on the user's word.
- Claude can also be reached from the phone through the desktop app's Remote Control (step 14), and the user can
  start cloud sessions on a repository that's on GitHub; those run on Anthropic's machines, not the PC, and see only
  what's pushed.

## Record

PROGRESS and the project's `CLAUDE.md`: the GitHub account name (not tokens), each repository's URL and visibility,
whether `main` is protected, the tag table, the backup-push rule. Commit with `[skip ci]` and push: that's the first
backup push. Mark step 8 done.
