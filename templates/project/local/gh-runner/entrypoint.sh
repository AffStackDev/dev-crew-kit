#!/usr/bin/env bash
# Registers this container with GitHub as a one-job ("ephemeral") runner for the repository, takes exactly one job
# and exits; GitHub removes the registration when the job is done, so nothing stays listening on the computer.
# RUNNER_TOKEN is a short-lived registration token fetched by scripts/gh-runner with the owner's GitHub CLI login.
# It is never printed.
set -euo pipefail
: "${RUNNER_TOKEN:?RUNNER_TOKEN is not set (run this through scripts/gh-runner)}"
: "${RUNNER_REPO:?RUNNER_REPO is not set (run this through scripts/gh-runner)}"
cd /home/runner
if ! ./config.sh --unattended --ephemeral --replace --disableupdate \
	--url "https://github.com/${RUNNER_REPO}" --token "${RUNNER_TOKEN}" \
	--name "${RUNNER_NAME:-crew-pc}" --labels "${RUNNER_LABELS:-crew-pc}" --work _work >/tmp/config.log 2>&1; then
	echo "gh-runner: registration failed:"
	tail -n 6 /tmp/config.log
	exit 1
fi
unset RUNNER_TOKEN
echo "gh-runner: registered as ${RUNNER_NAME:-crew-pc}; waiting for one job"
exec ./run.sh
