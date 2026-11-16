#!/usr/bin/env bash
# Wakes an agent when a Claude <-> Codex exchange file changes (Dev Crew kit, playbook step 11), macOS/Linux.
# Run it in the background; it exits as soon as the file changes in any way, prints the top entry's heading and
# whether it is from the other side, and must be started again after every wake.
# Exit codes: 0 changed, 1 timed out, 2 file missing.
#   bash watch-exchange.sh <exchange.md> [Me=Claude] [interval seconds=20] [timeout minutes=240]
set -u
file="${1:?usage: watch-exchange.sh <exchange.md> [Me] [interval] [timeout-minutes]}"
me="${2:-Claude}"
interval="${3:-20}"
timeout_min="${4:-240}"
[ -f "$file" ] || { echo "watch: file not found: $file"; exit 2; }

hash() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file" | cut -d' ' -f1; else shasum -a 256 "$file" | cut -d' ' -f1; fi; }
top() { grep -m1 '^## Entry ' "$file"; }

start_hash="$(hash)"
start_top="$(top)"
echo "watch: watching $file"
echo "watch: top entry at start: $start_top"
deadline=$(( $(date +%s) + timeout_min * 60 ))
while [ "$(date +%s)" -lt "$deadline" ]; do
	sleep "$interval"
	h="$(hash 2>/dev/null)" || continue
	[ "$h" = "$start_hash" ] && continue
	sleep 3
	t="$(top)"
	echo "watch: CHANGED at $(date '+%Y-%m-%d %H:%M:%S') local ($(date -u '+%H:%M:%S') UTC)"
	echo "watch: top entry now: $t"
	if [ "$t" = "$start_top" ]; then echo "watch: no new entry heading at the top; read the file to see what changed"
	elif printf '%s' "$t" | grep -Eq "\|[[:space:]]*${me}([^A-Za-z0-9]|$)"; then echo "watch: the new top entry is from $me"
	else echo "watch: the new top entry is from the other side: read it and answer"; fi
	exit 0
done
echo "watch: no change in $timeout_min minutes; start the watcher again if still waiting"
exit 1
