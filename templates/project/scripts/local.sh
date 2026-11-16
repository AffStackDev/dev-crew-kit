#!/usr/bin/env bash
# Local test helper for this project (Dev Crew kit, playbook step 7), for macOS and Linux.
# Runs scripts/check.sh in Docker on a clean copy of the current commit (never the files in this folder), in a "slot",
# and writes evidence to the local-data folder.
#
#   local.sh doctor          facts about Docker, Git, the slot and the limits; changes nothing
#   local.sh rebuild         build (or rebuild) the runner image
#   local.sh check [NAME]    run all checks, or the one named check, on HEAD
#   local.sh last            print the newest evidence summary
#   local.sh shell           a shell in the runner image (for looking around; nothing is cloned)
#   local.sh down            remove this slot's containers and network (evidence and work volume stay)
#   local.sh clean           also remove this slot's work volume
#
# Settings (environment variables): SLOT (default a), CREW_MAX_JOBS (default 4), CREW_AGENT (default claude),
# CREW_PROJECT (default: the repository's folder name), LOCAL_DIR (default ~/Dev-local/<project>).
set -uo pipefail

cmd="${1:-help}"
name="${2:-}"
die() { echo "local: $1"; exit "${2:-2}"; }

repo="$(cd "$(dirname "$0")/.." && pwd)"
compose_file="$repo/local/docker-compose.yml"

if [ "$cmd" = "help" ] || [ "$cmd" = "-h" ] || [ "$cmd" = "--help" ]; then
	sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
	exit 0
fi

git_dir="$(git -C "$repo" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || die "this folder is not inside a Git repository"
commit="$(git -C "$repo" rev-parse HEAD 2>/dev/null)" || die "no commit yet: commit something first"
short="${commit:0:8}"

if [ -n "${CREW_PROJECT:-}" ]; then project="$CREW_PROJECT"; else project="$(basename "$(dirname "$git_dir")")"; fi
project="$(printf '%s' "$project" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g; s/^-*//; s/-*$//')"
[ -n "$project" ] || die "could not work out a project name; set CREW_PROJECT"

slot="$(printf '%s' "${SLOT:-a}" | tr '[:upper:]' '[:lower:]')"
printf '%s' "$slot" | grep -Eq '^[a-z0-9][a-z0-9_-]*$' || die "SLOT '$slot' is not a valid name (letters, digits, - or _)"
max_jobs="${CREW_MAX_JOBS:-4}"
agent="${CREW_AGENT:-claude}"
local_dir="${LOCAL_DIR:-$HOME/Dev-local/$project}"
evidence="$local_dir/evidence"
compose_project="$project-$slot"
image="$project-runner:local"

export PROJECT="$project" SLOT="$slot" CREW_AGENT="$agent" LOCAL_DIR="$local_dir" GIT_DIR_HOST="$git_dir" COMMIT="$commit"
export CHECK="${CHECK:-all}"

# On Linux, run the container as this user so it can write the evidence folder (Docker Desktop on macOS maps it).
user_args=()
if [ "$(uname -s)" = "Linux" ]; then user_args=(--user "$(id -u):$(id -g)"); fi

docker_ok() { docker version --format '{{.Server.Version}}' >/dev/null 2>&1; }
running_jobs() { docker ps -q --filter 'label=crew.job=1' | wc -l | tr -d ' '; }
slot_busy() { [ -n "$(docker ps -q --filter "label=com.docker.compose.project=$compose_project" --filter 'label=crew.job=1')" ]; }
image_ok() { docker image inspect "$image" >/dev/null 2>&1; }
show_last() {
	local newest
	newest="$(ls -1d "$evidence"/*/ 2>/dev/null | sort | tail -n 1)"
	if [ -z "$newest" ]; then echo "local: no evidence yet in $evidence"; return; fi
	echo "local: $newest"
	if [ -f "$newest/summary.md" ]; then cat "$newest/summary.md"; else echo "local: (no summary.md in it)"; fi
}

case "$cmd" in
doctor)
	dirty="$(git -C "$repo" status --porcelain | wc -l | tr -d ' ')"
	echo "Project:          $project (compose project $compose_project, image $image)"
	echo "Repository:       $repo"
	echo "Git data:         $git_dir"
	echo "HEAD:             $commit"
	if [ "$dirty" -gt 0 ]; then echo "Uncommitted:      $dirty changed file(s): NOT included in a check run; commit first"; else echo "Uncommitted:      none"; fi
	echo "Slot:             $slot   (agent: $agent)"
	echo "Evidence folder:  $evidence"
	if docker_ok; then
		echo "Docker:           answering (engine $(docker version --format '{{.Server.Version}}'))"
		echo "Docker resources: $(docker info --format '{{.NCPU}} CPUs, {{.MemTotal}} bytes')"
		echo "Crew jobs:        $(running_jobs) running of $max_jobs allowed (CREW_MAX_JOBS)"
		if slot_busy; then echo "This slot:        BUSY (a run is in progress)"; else echo "This slot:        free"; fi
		if image_ok; then echo "Runner image:     present"; else echo "Runner image:     not built yet (local.sh rebuild)"; fi
	else
		echo "Docker:           NOT answering (start Docker, then wait for 'docker version' to show a Server)"
	fi
	;;
rebuild)
	docker_ok || die "Docker is not answering; start it first"
	docker compose -f "$compose_file" build runner
	;;
check)
	docker_ok || die "Docker is not answering; start it first"
	image_ok || die "the runner image $image is not built yet: run 'local.sh rebuild' first"
	slot_busy && die "slot $slot is busy (a run is in progress); wait for it, or use another slot (SLOT=b)" 3
	running="$(running_jobs)"
	[ "$running" -ge "$max_jobs" ] && die "$running crew Docker jobs are running and CREW_MAX_JOBS is $max_jobs; wait for one to finish" 3
	dirty="$(git -C "$repo" status --porcelain | wc -l | tr -d ' ')"
	if [ "$dirty" -gt 0 ]; then
		export HOST_DIRTY=1
		echo "local: note: $dirty uncommitted change(s) are NOT in this run; it tests commit $short"
	else
		export HOST_DIRTY=0
	fi
	if [ -n "$name" ]; then export CHECK="$name"; else export CHECK=all; fi
	mkdir -p "$evidence"
	echo "local: checking $short in slot $slot ($CHECK)"
	docker compose -f "$compose_file" run --rm ${user_args[@]+"${user_args[@]}"} runner
	rc=$?
	show_last
	exit "$rc"
	;;
last) show_last ;;
shell)
	image_ok || die "the runner image $image is not built yet: run 'local.sh rebuild' first"
	mkdir -p "$evidence"
	docker compose -f "$compose_file" run --rm ${user_args[@]+"${user_args[@]}"} --entrypoint bash runner
	;;
down) docker compose -f "$compose_file" down --remove-orphans ;;
clean)
	slot_busy && die "slot $slot is busy; not removing its volume while a run is in progress" 3
	docker compose -f "$compose_file" down --volumes --remove-orphans
	;;
*) die "unknown command '$cmd' (try: doctor, rebuild, check, last, shell, down, clean)" ;;
esac
