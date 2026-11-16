#!/usr/bin/env bash
# Runs inside the runner container (Dev Crew kit, playbook step 7).
# Tests a clean copy of $COMMIT made from the repository's Git data (mounted read only at /repo.git), never the files
# in the project folder, then runs scripts/check.sh from that copy. Writes evidence to
# /evidence/<UTC stamp>-<commit>-<check>/: summary.md, log.txt, meta.json.
set -uo pipefail
: "${COMMIT:?COMMIT is not set (run this through scripts/local)}"
CHECK="${CHECK:-all}"
SLOT="${SLOT:-a}"
HOST_DIRTY="${HOST_DIRTY:-0}"
mkdir -p "${HOME:-/work/home}"

short="${COMMIT:0:8}"
start_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
stamp="$(date -u +%Y%m%d-%H%M%S)"
safe_check="$(printf '%s' "$CHECK" | tr -c 'A-Za-z0-9._-' '_')"
out="/evidence/${stamp}-${short}-${safe_check}"
mkdir -p "$out" || { echo "run-checks: cannot write the evidence folder $out"; exit 3; }
log="$out/log.txt"
clone=/work/clone

# A clean copy of the commit. The clone in the slot's volume is reused between runs (fetch, checkout, clean), so a
# run never sees files left by an earlier one. A fresh clone is made if the commit isn't reachable by a fetch.
prepare() {
	if [ -d "$clone/.git" ]; then
		git -C "$clone" fetch --quiet --prune origin '+refs/heads/*:refs/remotes/origin/*' || return 1
	fi
	if [ ! -d "$clone/.git" ] || ! git -C "$clone" cat-file -e "${COMMIT}^{commit}" 2>/dev/null; then
		rm -rf "$clone"
		git clone --quiet --no-checkout /repo.git "$clone" || return 1
	fi
	git -C "$clone" checkout --quiet --force --detach "$COMMIT" || return 1
	git -C "$clone" clean -ffdxq || return 1
}

{
	echo "== run-checks: commit $COMMIT, check '$CHECK', slot $SLOT, started $start_utc"
	echo "== preparing a clean copy of the commit"
} >"$log"

rc=0
if prepare >>"$log" 2>&1; then
	cd "$clone" || exit 3
	if [ ! -f scripts/check.sh ]; then
		echo "run-checks: scripts/check.sh is missing in commit $short" >>"$log"
		rc=2
	else
		echo "== scripts/check.sh ${CHECK}" >>"$log"
		if [ "$CHECK" = "all" ]; then
			bash scripts/check.sh >>"$log" 2>&1
		else
			bash scripts/check.sh "$CHECK" >>"$log" 2>&1
		fi
		rc=$?
	fi
else
	echo "run-checks: could not prepare a clean copy of $COMMIT (is it committed?)" >>"$log"
	rc=2
fi

end_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
if [ "$rc" -eq 0 ]; then result=PASS; else result=FAIL; fi
echo "== finished $end_utc: $result (exit $rc)" >>"$log"

{
	echo "# ${result}: ${CHECK} on ${short}"
	echo
	echo "| | |"
	echo "|---|---|"
	echo "| Result | **${result}** (exit ${rc}) |"
	echo "| Commit | \`${COMMIT}\` |"
	echo "| Check | ${CHECK} |"
	echo "| Slot | ${SLOT} |"
	echo "| Started (UTC) | ${start_utc} |"
	echo "| Finished (UTC) | ${end_utc} |"
	if [ "$HOST_DIRTY" = "1" ]; then
		echo "| Project folder | had uncommitted changes; they are NOT in this run |"
	else
		echo "| Project folder | clean (no uncommitted changes) |"
	fi
	echo
	echo "Result lines:"
	echo
	echo '```'
	grep -E '^(PASS|FAIL|SKIP) ' "$log" || echo "(no PASS/FAIL lines printed by scripts/check.sh)"
	echo '```'
	echo
	echo "Last lines of log.txt:"
	echo
	echo '```'
	tail -n 15 "$log"
	echo '```'
} >"$out/summary.md"

cat >"$out/meta.json" <<EOF
{"commit": "${COMMIT}", "check": "${CHECK}", "slot": "${SLOT}", "result": "${result}", "exit_code": ${rc}, "started_utc": "${start_utc}", "finished_utc": "${end_utc}", "host_dirty": ${HOST_DIRTY}}
EOF

echo "${result} ${CHECK} on ${short} (slot ${SLOT}); evidence: $(basename "$out")"
exit "$rc"
