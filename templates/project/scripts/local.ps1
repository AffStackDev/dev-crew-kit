# Local test helper for this project (Dev Crew kit, playbook step 7). Windows PowerShell 5.1 or later; ASCII only.
# Runs scripts/check.sh in Docker on a clean copy of the current commit (never the files in this folder), in a "slot",
# and writes evidence to the local-data folder. Normally started through scripts\local.cmd.
#
#   local doctor          facts about Docker, Git, the slot and the limits; changes nothing
#   local rebuild         build (or rebuild) the runner image
#   local check [NAME]    run all checks, or the one named check, on HEAD
#   local last            print the newest evidence summary
#   local shell           a shell in the runner image (for looking around; nothing is cloned)
#   local down            remove this slot's containers and network (evidence and work volume stay)
#   local clean           also remove this slot's work volume
#
# Settings (environment variables): SLOT (default a), CREW_MAX_JOBS (default 4), CREW_AGENT (default claude),
# CREW_PROJECT (default: the repository's folder name), LOCAL_DIR (default %USERPROFILE%\Dev-local\<project>).
param(
	[Parameter(Position = 0)][string]$Command = 'help',
	[Parameter(Position = 1)][string]$Name = ''
)

function Stop-Helper([string]$Message, [int]$Code = 2) {
	Write-Host "local: $Message"
	exit $Code
}

$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ComposeFile = Join-Path $Repo 'local\docker-compose.yml'

if ($Command -eq 'help' -or $Command -eq '-h' -or $Command -eq '--help') {
	Get-Content -LiteralPath $PSCommandPath | Select-Object -Skip 1 -First 16 | ForEach-Object { $_ -replace '^# ?', '' }
	exit 0
}

# --- Facts from Git -------------------------------------------------------------------------------------------------
$gitDir = & git -C $Repo rev-parse --path-format=absolute --git-common-dir
if ($LASTEXITCODE -ne 0 -or -not $gitDir) { Stop-Helper 'this folder is not inside a Git repository' }
$gitDir = ([string]$gitDir).Trim()
$commit = & git -C $Repo rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or -not $commit) { Stop-Helper 'no commit yet: commit something first' }
$commit = ([string]$commit).Trim()
$short = $commit.Substring(0, 8)

if ($env:CREW_PROJECT) { $project = $env:CREW_PROJECT } else { $project = Split-Path -Leaf (Split-Path -Parent $gitDir) }
$project = ($project.ToLower() -replace '[^a-z0-9_-]', '-').Trim('-')
if (-not $project) { Stop-Helper 'could not work out a project name; set CREW_PROJECT' }

if ($env:SLOT) { $slot = $env:SLOT.ToLower() } else { $slot = 'a' }
if ($slot -notmatch '^[a-z0-9][a-z0-9_-]*$') { Stop-Helper "SLOT '$slot' is not a valid name (letters, digits, - or _)" }
$maxJobs = 4
if ($env:CREW_MAX_JOBS) { $maxJobs = [int]$env:CREW_MAX_JOBS }
if ($env:CREW_AGENT) { $agent = $env:CREW_AGENT } else { $agent = 'claude' }
if ($env:LOCAL_DIR) { $localDir = $env:LOCAL_DIR } else { $localDir = Join-Path $env:USERPROFILE ('Dev-local\' + $project) }
$evidence = Join-Path $localDir 'evidence'
$composeProject = "$project-$slot"
$image = "$project-runner:local"

# Compose reads these; every command needs them because the file marks them required.
$env:PROJECT = $project
$env:SLOT = $slot
$env:CREW_AGENT = $agent
$env:LOCAL_DIR = $localDir
$env:GIT_DIR_HOST = $gitDir
$env:COMMIT = $commit
if (-not $env:CHECK) { $env:CHECK = 'all' }

function Test-Docker {
	& docker version --format '{{.Server.Version}}' *> $null
	return ($LASTEXITCODE -eq 0)
}
function Get-RunningJobs {
	$ids = @(& docker ps -q --filter 'label=crew.job=1')
	return $ids.Count
}
function Test-SlotBusy {
	$ids = @(& docker ps -q --filter "label=com.docker.compose.project=$composeProject" --filter 'label=crew.job=1')
	return ($ids.Count -gt 0)
}
function Test-Image {
	& docker image inspect $image *> $null
	return ($LASTEXITCODE -eq 0)
}
function Show-Last {
	if (-not (Test-Path -LiteralPath $evidence)) { Write-Host "local: no evidence yet in $evidence"; return }
	$newest = Get-ChildItem -LiteralPath $evidence -Directory | Sort-Object Name | Select-Object -Last 1
	if (-not $newest) { Write-Host "local: no evidence yet in $evidence"; return }
	Write-Host "local: $($newest.FullName)"
	$summary = Join-Path $newest.FullName 'summary.md'
	if (Test-Path -LiteralPath $summary) { Get-Content -LiteralPath $summary -Encoding UTF8 } else { Write-Host 'local: (no summary.md in it)' }
}

switch ($Command) {
	'doctor' {
		$dirty = @(& git -C $Repo status --porcelain)
		Write-Host "Project:          $project (compose project $composeProject, image $image)"
		Write-Host "Repository:       $Repo"
		Write-Host "Git data:         $gitDir"
		Write-Host "HEAD:             $commit"
		if ($dirty.Count -gt 0) { Write-Host "Uncommitted:      $($dirty.Count) changed file(s): NOT included in a check run; commit first" } else { Write-Host 'Uncommitted:      none' }
		Write-Host "Slot:             $slot   (agent: $agent)"
		Write-Host "Evidence folder:  $evidence"
		if (Test-Docker) {
			$ver = & docker version --format '{{.Server.Version}}'
			Write-Host "Docker:           answering (engine $ver)"
			$info = & docker info --format '{{.NCPU}} CPUs, {{.MemTotal}} bytes'
			Write-Host "Docker resources: $info"
			Write-Host "Crew jobs:        $(Get-RunningJobs) running of $maxJobs allowed (CREW_MAX_JOBS)"
			if (Test-SlotBusy) { Write-Host "This slot:        BUSY (a run is in progress)" } else { Write-Host 'This slot:        free' }
			if (Test-Image) { Write-Host "Runner image:     present" } else { Write-Host "Runner image:     not built yet (local rebuild)" }
		}
		else { Write-Host 'Docker:           NOT answering (start Docker Desktop, then wait for "docker version" to show a Server)' }
		exit 0
	}
	'rebuild' {
		if (-not (Test-Docker)) { Stop-Helper 'Docker is not answering; start Docker Desktop first' }
		& docker compose -f $ComposeFile build runner
		exit $LASTEXITCODE
	}
	'check' {
		if (-not (Test-Docker)) { Stop-Helper 'Docker is not answering; start Docker Desktop first' }
		if (-not (Test-Image)) { Stop-Helper "the runner image $image is not built yet: run 'local rebuild' first" }
		if (Test-SlotBusy) { Stop-Helper "slot $slot is busy (a run is in progress); wait for it, or use another slot (SLOT=b)" 3 }
		$running = Get-RunningJobs
		if ($running -ge $maxJobs) { Stop-Helper "$running crew Docker jobs are running and CREW_MAX_JOBS is $maxJobs; wait for one to finish" 3 }
		$dirty = @(& git -C $Repo status --porcelain)
		if ($dirty.Count -gt 0) {
			$env:HOST_DIRTY = '1'
			Write-Host "local: note: $($dirty.Count) uncommitted change(s) are NOT in this run; it tests commit $short"
		}
		else { $env:HOST_DIRTY = '0' }
		if ($Name) { $env:CHECK = $Name } else { $env:CHECK = 'all' }
		New-Item -ItemType Directory -Force -Path $evidence | Out-Null
		Write-Host "local: checking $short in slot $slot ($($env:CHECK))"
		& docker compose -f $ComposeFile run --rm runner
		$rc = $LASTEXITCODE
		Show-Last
		exit $rc
	}
	'last' { Show-Last; exit 0 }
	'shell' {
		if (-not (Test-Image)) { Stop-Helper "the runner image $image is not built yet: run 'local rebuild' first" }
		New-Item -ItemType Directory -Force -Path $evidence | Out-Null
		& docker compose -f $ComposeFile run --rm --entrypoint bash runner
		exit $LASTEXITCODE
	}
	'down' {
		& docker compose -f $ComposeFile down --remove-orphans
		exit $LASTEXITCODE
	}
	'clean' {
		if (Test-SlotBusy) { Stop-Helper "slot $slot is busy; not removing its volume while a run is in progress" 3 }
		& docker compose -f $ComposeFile down --volumes --remove-orphans
		exit $LASTEXITCODE
	}
	default { Stop-Helper "unknown command '$Command' (try: doctor, rebuild, check, last, shell, down, clean)" }
}
