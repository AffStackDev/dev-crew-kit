# Starts a one-job GitHub Actions runner on this computer, in Docker (Dev Crew kit, playbook step 9). ASCII only.
# GitHub hands the next waiting job that asks for the label (default crew-pc) to it; the runner exits when that job is
# done and its registration disappears. Jobs that run here use no GitHub minutes. The registration token comes from
# the GitHub CLI login on this computer (needs admin rights on the repository) and is never printed.
#   scripts\gh-runner.cmd          take one job
#   scripts\gh-runner.cmd build    build or rebuild the runner image
# Settings: RUNNER_LABELS / RUNNER_NAME (default crew-pc), CREW_MAX_JOBS (default 4), CREW_PROJECT, LOCAL_DIR.
param([Parameter(Position = 0)][string]$Command = 'run')

function Stop-Helper([string]$Message, [int]$Code = 2) { Write-Host "gh-runner: $Message"; exit $Code }

$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ComposeFile = Join-Path $Repo 'local\gh-runner\docker-compose.yml'

$gitDir = & git -C $Repo rev-parse --path-format=absolute --git-common-dir
if ($LASTEXITCODE -ne 0 -or -not $gitDir) { Stop-Helper 'this folder is not inside a Git repository' }
if ($env:CREW_PROJECT) { $project = $env:CREW_PROJECT } else { $project = Split-Path -Leaf (Split-Path -Parent ([string]$gitDir).Trim()) }
$project = ($project.ToLower() -replace '[^a-z0-9_-]', '-').Trim('-')
if ($env:LOCAL_DIR) { $localDir = $env:LOCAL_DIR } else { $localDir = Join-Path $env:USERPROFILE ('Dev-local\' + $project) }
New-Item -ItemType Directory -Force -Path (Join-Path $localDir 'runner-out') | Out-Null
$env:PROJECT = $project
$env:LOCAL_DIR = $localDir

if ($Command -eq 'build') {
	$env:RUNNER_TOKEN = 'not-needed-for-a-build'
	$env:RUNNER_REPO = 'not-needed-for-a-build'
	& docker compose -f $ComposeFile build gh-runner
	exit $LASTEXITCODE
}
if ($Command -ne 'run') { Stop-Helper "unknown command '$Command' (use no argument to take one job, or 'build')" }

$maxJobs = 4
if ($env:CREW_MAX_JOBS) { $maxJobs = [int]$env:CREW_MAX_JOBS }
$running = @(& docker ps -q --filter 'label=crew.job=1').Count
if ($running -ge $maxJobs) { Stop-Helper "$running crew Docker jobs are running and CREW_MAX_JOBS is $maxJobs; wait for one to finish" 3 }

Push-Location $Repo
$repoName = & gh repo view --json nameWithOwner --jq .nameWithOwner
$ok = ($LASTEXITCODE -eq 0)
Pop-Location
if (-not $ok -or -not $repoName) { Stop-Helper 'could not read the GitHub repository (is "origin" set, and is the GitHub CLI signed in?)' }
$env:RUNNER_REPO = ([string]$repoName).Trim()

$token = & gh api -X POST "repos/$($env:RUNNER_REPO)/actions/runners/registration-token" --jq .token
if ($LASTEXITCODE -ne 0 -or -not $token) { Stop-Helper 'could not get a registration token (is the GitHub CLI signed in, with admin rights on the repository?)' }
$env:RUNNER_TOKEN = ([string]$token).Trim()
Write-Host "gh-runner: starting a one-job runner for $($env:RUNNER_REPO)"
& docker compose -f $ComposeFile run --rm gh-runner
$rc = $LASTEXITCODE
$env:RUNNER_TOKEN = ''
exit $rc
