#!/usr/bin/env bash
# Starts a one-job GitHub Actions runner on this computer, in Docker (Dev Crew kit, playbook step 9), macOS/Linux.
# GitHub hands the next waiting job that asks for the label (default crew-pc) to it; the runner exits when that job is
# done and its registration disappears. The registration token comes from the GitHub CLI login and is never printed.
#   scripts/gh-runner.sh          take one job
#   scripts/gh-runner.sh build    build or rebuild the runner image
set -uo pipefail
die() { echo "gh-runner: $1"; exit "${2:-2}"; }
repo="$(cd "$(dirname "$0")/.." && pwd)"
compose_file="$repo/local/gh-runner/docker-compose.yml"
git_dir="$(git -C "$repo" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || die "this folder is not inside a Git repository"
if [ -n "${CREW_PROJECT:-}" ]; then project="$CREW_PROJECT"; else project="$(basename "$(dirname "$git_dir")")"; fi
project="$(printf '%s' "$project" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g; s/^-*//; s/-*$//')"
export PROJECT="$project" LOCAL_DIR="${LOCAL_DIR:-$HOME/Dev-local/$project}"
mkdir -p "$LOCAL_DIR/runner-out"

if [ "${1:-run}" = "build" ]; then
	RUNNER_TOKEN=not-needed-for-a-build RUNNER_REPO=not-needed-for-a-build docker compose -f "$compose_file" build gh-runner
	exit $?
fi

running="$(docker ps -q --filter 'label=crew.job=1' | wc -l | tr -d ' ')"
[ "$running" -ge "${CREW_MAX_JOBS:-4}" ] && die "$running crew Docker jobs are running and CREW_MAX_JOBS is ${CREW_MAX_JOBS:-4}; wait for one to finish" 3

RUNNER_REPO="$(cd "$repo" && gh repo view --json nameWithOwner --jq .nameWithOwner)" || die 'could not read the GitHub repository (is "origin" set, and is the GitHub CLI signed in?)'
export RUNNER_REPO
RUNNER_TOKEN="$(gh api -X POST "repos/$RUNNER_REPO/actions/runners/registration-token" --jq .token)" || die "could not get a registration token (GitHub CLI signed in, with admin rights on the repository?)"
export RUNNER_TOKEN
echo "gh-runner: starting a one-job runner for $RUNNER_REPO"
docker compose -f "$compose_file" run --rm gh-runner
rc=$?
unset RUNNER_TOKEN
exit "$rc"
