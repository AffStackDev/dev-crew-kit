#!/usr/bin/env bash
# Read-only report of this computer for the Dev Crew setup (playbook step 1), macOS and Linux. Changes nothing.
# Prints a Markdown report to paste into my-setup/PROGRESS.md. Reports whether things are set, never secret values,
# account names, emails or tokens.
set -u
row() { printf '| %s | %s |\n' "$1" "$2"; }
ver() { if command -v "$1" >/dev/null 2>&1; then "$@" 2>/dev/null | head -n 1; else echo "not found"; fi; }

echo "## Machine report ($(date '+%Y-%m-%d %H:%M') local, $(date -u '+%H:%M') UTC; scripts/check-machine.sh)"
echo
echo "| Item | Found |"
echo "|---|---|"
os="$(uname -s)"
if [ "$os" = "Darwin" ]; then
	row "Operating system" "macOS $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
	row "Processor" "$(sysctl -n machdep.cpu.brand_string 2>/dev/null) ($(sysctl -n hw.physicalcpu 2>/dev/null) cores, $(sysctl -n hw.logicalcpu 2>/dev/null) threads)"
	mem_bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
	row "Memory" "$((mem_bytes / 1024 / 1024 / 1024)) GB"
else
	pretty="$( (. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME") || uname -sr)"
	row "Operating system" "$pretty ($(uname -m))"
	row "Processor" "$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //') ($(nproc 2>/dev/null) threads)"
	mem_kb="$(grep -m1 MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')"
	row "Memory" "$(( ${mem_kb:-0} / 1024 / 1024 )) GB"
	if grep -Eq '(vmx|svm)' /proc/cpuinfo 2>/dev/null; then row "Virtualization" "supported by the processor"; else row "Virtualization" "not reported"; fi
fi
row "Disk (home)" "$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $4 " free of " $2}')"
for d in "$HOME/Library/Mobile Documents" "$HOME/Dropbox" "$HOME/OneDrive"; do
	[ -d "$d" ] && row "Synced folder present" "$d (keep projects out of it)"
done
row "Folder ~/GitHub exists" "$([ -d "$HOME/GitHub" ] && echo yes || echo no)"

row "Git" "$(ver git --version)"
row "GitHub CLI" "$(ver gh --version)"
row "Docker CLI" "$(ver docker --version)"
row "Docker Compose" "$(ver docker compose version)"
row "Node.js" "$(ver node --version)"
row "Python 3" "$(ver python3 --version)"
row "Codex CLI" "$(ver codex --version)"
row "Claude Code CLI" "$(ver claude --version)"
[ "$os" = "Darwin" ] && row "Homebrew" "$(ver brew --version)"

if command -v docker >/dev/null 2>&1; then
	if srv="$(docker version --format '{{.Server.Version}}' 2>/dev/null)" && [ -n "$srv" ]; then
		info="$(docker info --format '{{.NCPU}} CPUs, {{.MemTotal}} bytes for containers' 2>/dev/null)"
		row "Docker engine" "running, engine $srv, $info"
		row "Containers running" "$(docker ps -q | wc -l | tr -d ' ') (crew jobs: $(docker ps -q --filter label=crew.job=1 | wc -l | tr -d ' '))"
		if [ "$os" = "Linux" ]; then
			if id -nG 2>/dev/null | grep -qw docker; then row "User in docker group" "yes (root-level power over this machine)"; else row "User in docker group" "no"; fi
		fi
	else
		row "Docker engine" "NOT answering (not running, or not installed fully)"
	fi
fi
if command -v gh >/dev/null 2>&1; then
	if gh auth status >/dev/null 2>&1; then row "GitHub CLI signed in" "yes"; else row "GitHub CLI signed in" "no"; fi
fi
globalMail="$(git config --global user.email 2>/dev/null)"
if [ -z "$globalMail" ]; then kind="not set"; elif printf '%s' "$globalMail" | grep -q 'users\.noreply\.github\.com$'; then kind="GitHub noreply address"; else kind="own address (would be public in public repositories)"; fi
row "Git global identity" "name set: $([ -n "$(git config --global user.name 2>/dev/null)" ] && echo yes || echo no); email: $kind"
row "~/.claude/CLAUDE.md" "$([ -f "$HOME/.claude/CLAUDE.md" ] && echo yes || echo no)"
row "~/.codex/AGENTS.md" "$([ -f "$HOME/.codex/AGENTS.md" ] && echo yes || echo no)"
row "~/.codex/AGENTS.override.md" "$([ -f "$HOME/.codex/AGENTS.override.md" ] && echo yes || echo no)"
row "~/.codex/config.toml" "$([ -f "$HOME/.codex/config.toml" ] && echo yes || echo no)"
row "CREW_MAX_JOBS" "${CREW_MAX_JOBS:-not set}"
