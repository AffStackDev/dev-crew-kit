#!/usr/bin/env bash
# The project's checks (Dev Crew kit, playbook step 7). Runs inside the runner container, from the repository root of
# a clean copy of the commit being tested. Prints one "PASS <name>" or "FAIL <name>" line per check and exits non-zero
# if anything failed. Optional first argument: the name of one check to run (for example "test").
set -uo pipefail
only="${1:-}"
failures=0
ran=0

run() { # run <name> <command...>
	local name="$1"
	shift
	if [ -n "$only" ] && [ "$only" != "$name" ]; then
		return 0
	fi
	ran=$((ran + 1))
	echo "---- ${name}"
	if "$@"; then
		echo "PASS ${name}"
	else
		echo "FAIL ${name}"
		failures=$((failures + 1))
	fi
}

# Two checks every repository can use: no secret-looking files and no huge files committed.
no_secret_files() {
	local hits
	hits="$(git ls-files | grep -E '(^|/)(\.env(\.[^/]*)?|id_rsa|id_ed25519|[^/]*\.(pem|key|p12|pfx|keystore|jks))$' | grep -vE '\.env\.example$' || true)"
	if [ -n "$hits" ]; then
		echo "tracked files that look like secrets:"
		echo "$hits"
		return 1
	fi
}
no_huge_files() {
	local limit=$((50 * 1024 * 1024)) big=0 f size
	while IFS= read -r f; do
		[ -f "$f" ] || continue
		size=$(wc -c <"$f")
		if [ "$size" -gt "$limit" ]; then
			echo "over 50 MB: $f ($size bytes)"
			big=1
		fi
	done < <(git ls-files)
	[ "$big" -eq 0 ]
}

run no-secret-files no_secret_files
run no-huge-files no_huge_files

# ---- The project's own checks. Copy them from what the project already runs (package.json scripts, Makefile, CI
# workflow files), fastest first. Examples:
# run lint   npm run lint
# run test   npm test
# run build  npm run build
# ----------------------------------------------------------------------------------------------------------------------

if [ -n "$only" ] && [ "$ran" -eq 0 ]; then
	echo "FAIL unknown-check: no check named '${only}' in scripts/check.sh"
	exit 2
fi
echo "checks finished: ${ran} run, ${failures} failed"
[ "$failures" -eq 0 ]
