# This computer: checked facts

Every fact here says when and how it was checked. Anything not checked says so. Re-check before relying on an old
fact for anything that matters, and update the line (keep the old date in the history via Git).

## Hardware and system

| Item | Fact | Checked |
|---|---|---|
| Operating system | <e.g. Windows 11 Home 10.0.26xxx> | <date>, scripts/check-machine |
| Processor | <model, cores / threads> | <date>, scripts/check-machine |
| Memory | <GB> | <date>, scripts/check-machine |
| Disk | <drive: free GB> | <date>, scripts/check-machine |
| Virtualization | <on / off> | <date>, scripts/check-machine |
| Documents folder | <inside OneDrive: yes/no> | <date>, scripts/check-machine |

## Tools

| Tool | Version | Installed how / where | Checked |
|---|---|---|---|
| Git | | | |
| GitHub CLI | | signed in: yes/no | |
| Docker Desktop / Engine | | | |
| Docker Compose | | | |
| WSL | | | |
| Node.js | | | |
| Python | | which one is on PATH | |
| Codex (app / CLI) | | | |
| Claude Code | | desktop app / CLI | |

## Docker's limits

| Limit | Value | Where set | Checked |
|---|---|---|---|
| Total memory for Docker | | `.wslconfig` / Docker Desktop Resources | `docker info`, <date> |
| Processors for Docker | | | |
| Docker jobs at once (`CREW_MAX_JOBS`) | | user environment variable | |
| Memory per container | 4 GB | each compose file | |

## Folders

| What | Path |
|---|---|
| Projects | |
| Home base | |
| Local-only data | |

## Not checked

- <anything relevant that hasn't been verified, and how to check it>
