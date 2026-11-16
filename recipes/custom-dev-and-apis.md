# Custom development, web apps, APIs, databases, client work

## What it's for in this workflow

Any language, any framework: the project's toolchain lives in its Docker runner image, its tests run on a clean copy
of each commit, its services (database, cache, queue) run per slot, and releases go out through a rehearsed job.

## Way in

The project's own tooling, in Docker: the language's package manager, test runner, linter and build. Deploy targets
through their official CLIs (cloud providers, Vercel, Netlify, Fly, container registries, SSH).

## Install

In `local/runner/Dockerfile`, at the versions the project's CI or production uses. Starting points (verify versions):

| Stack | Image lines |
|---|---|
| Node | NodeSource or the official `node:<major>` image as base; `corepack enable` for pnpm/yarn |
| Python | `python3`, `python3-venv`; or the official `python:<version>` image; `pip install -r requirements.txt` / `uv` / Poetry |
| PHP | `ondrej/php` packages at the exact version; Composer |
| Java / Kotlin | Eclipse Temurin JDK; Gradle/Maven wrappers from the repository |
| .NET | Microsoft's `mcr.microsoft.com/dotnet/sdk:<version>` image as base |
| Go | the official `golang:<version>` image as base |
| Rust | the official `rust:<version>` image as base |
| Ruby | the official `ruby:<version>` image; Bundler |

Using a language's official image as the base instead of Ubuntu is fine: keep the runner user, Git and
`run-checks.sh` from the template.

Services in the compose file, each with a memory cap, one set per slot: Postgres, MySQL/MariaDB, Redis, a mail
catcher (e.g. Mailpit), an S3-compatible store (MinIO), whatever the app uses. Seed them from fixtures in the
repository, never from a production dump unless the user approves a sanitized copy.

## Sign-in and secrets

- `.env.example` in Git (names only), `.env` git-ignored and filled in by the user.
- Separate keys for development, staging and production. Agents use development keys; production keys only exist in
  the deploy job's secrets.
- For each client, separate accounts and keys; never reuse one client's credentials for another.

## Client work

- One repository per client project, and one local-data folder per client. Never mix two clients' code, data or
  notes in one workspace.
- The client's decisions go in that project's decisions file, quoted, with the date and who said it.
- Client data on the PC (a copy of their database) needs their permission as well as the user's, and is deleted when
  the work is done.
- Repositories that belong to the client may live in the client's GitHub organization; workflows and secrets there
  follow the client's rules.

## Guardrails worth setting

- Database migrations: rehearsed on a copy, reversible, never run on production without the go.
- Dependencies: no new runtime dependency without asking (licence, maintenance, size); lockfiles committed.
- Public APIs: breaking changes need a version bump and the user's OK.

## Prove it

The project's full check suite green in Docker on a clean clone; the app starts in a slot and answers its health
endpoint; a preview opens in the browser pane (`.claude/launch.json`).

## Checks to add

Format/lint, type check, unit tests, integration tests against the slot's services, build, a container image build if
it ships as one, a dependency vulnerability scan (the language's audit tool) and a secret scan before any push to a
public repository.

## Traps

- Tests that pass only because of state left by an earlier run: each run gets fresh databases.
- Time zones: servers often run on UTC while the business doesn't; test date boundaries.
- Windows line endings in scripts copied into containers: `.gitattributes` pins them.
