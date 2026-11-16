# Read-only check of a finished Dev Crew setup (playbook step 13). Windows PowerShell 5.1 or later; ASCII only.
# Prints PASS / WARN / FAIL lines. Never prints secret values, emails or tokens; changes nothing.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File check-setup.ps1 -HomeBase <crew-home> [-Project <p1>,<p2>]
param(
	[Parameter(Mandatory = $true)][string]$HomeBase,
	[string[]]$Project = @()
)

$script:fails = 0
$script:warns = 0
function Pass([string]$m) { Write-Host "PASS  $m" }
function Warn([string]$m) { Write-Host "WARN  $m"; $script:warns++ }
function Fail([string]$m) { Write-Host "FAIL  $m"; $script:fails++ }
function Has([string]$exe) { [bool](Get-Command $exe -ErrorAction SilentlyContinue) }

Write-Host "== Tools"
if (Has 'git') { Pass "git: $(& git --version)" } else { Fail 'git not found' }
if (Has 'gh') {
	& gh auth status *> $null
	if ($LASTEXITCODE -eq 0) { Pass 'GitHub CLI signed in' } else { Warn 'GitHub CLI installed but not signed in (fine if GitHub was skipped)' }
}
else { Warn 'GitHub CLI not found (fine if GitHub was skipped)' }
if (Has 'docker') {
	$srv = & docker version --format '{{.Server.Version}}' 2>$null
	if ($LASTEXITCODE -eq 0 -and $srv) { Pass "Docker engine answering ($srv)" } else { Fail 'Docker installed but the engine is not answering' }
	& docker compose version *> $null
	if ($LASTEXITCODE -eq 0) { Pass 'Docker Compose present' } else { Fail 'Docker Compose not found' }
}
else { Warn 'Docker not found (fine only if the test stack was skipped)' }
$maxJobs = [Environment]::GetEnvironmentVariable('CREW_MAX_JOBS', 'User')
if (-not $maxJobs) { $maxJobs = $env:CREW_MAX_JOBS }
if ($maxJobs) { Pass "CREW_MAX_JOBS = $maxJobs" } else { Warn 'CREW_MAX_JOBS not set (the helpers default to 4)' }
$wslconfig = Join-Path $env:USERPROFILE '.wslconfig'
if (Test-Path -LiteralPath $wslconfig) {
	$lim = Get-Content -LiteralPath $wslconfig | Where-Object { $_ -match '^\s*(memory|processors)\s*=' }
	if ($lim) { Pass ".wslconfig limits Docker: $(($lim | ForEach-Object { $_.Trim() }) -join ', ')" } else { Warn '.wslconfig has no memory/processors lines' }
}
else { Warn 'no .wslconfig: Docker may take up to half the RAM and every processor thread' }

Write-Host "== Home base: $HomeBase"
if (-not (Test-Path -LiteralPath $HomeBase)) { Fail 'home base folder not found' }
else {
	foreach ($f in 'CLAUDE.md', 'AGENTS.md', 'MACHINE.md', 'WORKSPACES.md', 'CREW-STATUS.md', 'TOOLS.md', 'OWNER-QUESTIONS.md', 'records\decisions.csv') {
		if (Test-Path -LiteralPath (Join-Path $HomeBase $f)) { Pass "has $f" } else { Fail "missing $f" }
	}
	& git -C $HomeBase rev-parse --git-dir *> $null
	if ($LASTEXITCODE -eq 0) {
		$n = & git -C $HomeBase rev-list --count HEAD 2>$null
		if ($n) { Pass "home base is a Git repository with $n commit(s)" } else { Fail 'home base is a Git repository with no commits' }
		$dirty = @(& git -C $HomeBase status --porcelain)
		if ($dirty.Count -gt 0) { Warn "home base has $($dirty.Count) uncommitted change(s)" } else { Pass 'home base committed' }
	}
	else { Fail 'home base is not a Git repository' }
	$dec = Join-Path $HomeBase 'records\decisions.csv'
	if (Test-Path -LiteralPath $dec) {
		$rows = @(Get-Content -LiteralPath $dec | Select-Object -Skip 1 | Where-Object { $_.Trim() }).Count
		if ($rows -gt 0) { Pass "decisions.csv has $rows decision(s)" } else { Warn 'decisions.csv has no decisions yet (step 5 records the step 2 answers)' }
	}
}

Write-Host "== Global rule files"
$claudeMd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
if (Test-Path -LiteralPath $claudeMd) {
	$size = (Get-Item -LiteralPath $claudeMd).Length
	if ($size -le 8192) { Pass "~/.claude/CLAUDE.md exists ($size bytes)" } else { Warn "~/.claude/CLAUDE.md is $size bytes; keep it under ~8 KB (move detail into lessons)" }
	$text = Get-Content -LiteralPath $claudeMd -Raw -Encoding UTF8
	if ($text -match [regex]::Escape((Split-Path -Leaf $HomeBase))) { Pass '~/.claude/CLAUDE.md names the home base' } else { Warn '~/.claude/CLAUDE.md does not mention the home base folder' }
	$mirror = Join-Path $HomeBase 'mirrors\claude-global-CLAUDE.md'
	if (Test-Path -LiteralPath $mirror) {
		if ((Get-FileHash -LiteralPath $mirror).Hash -eq (Get-FileHash -LiteralPath $claudeMd).Hash) { Pass 'mirror of ~/.claude/CLAUDE.md is current' } else { Warn 'mirror of ~/.claude/CLAUDE.md differs: copy and commit it' }
	}
	else { Warn 'no mirror of ~/.claude/CLAUDE.md in the home base' }
}
else { Fail '~/.claude/CLAUDE.md not found' }

$codexAgents = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
$codexOverride = Join-Path $env:USERPROFILE '.codex\AGENTS.override.md'
if (Test-Path -LiteralPath $codexAgents) {
	$size = (Get-Item -LiteralPath $codexAgents).Length
	if ($size -le 20480) { Pass "~/.codex/AGENTS.md exists ($size bytes)" } else { Warn "~/.codex/AGENTS.md is $size bytes; keep it under ~20 KB (Codex stops at 32 KiB for global + project)" }
	$last = Get-Content -LiteralPath $codexAgents -Encoding UTF8 | Where-Object { $_.Trim() } | Select-Object -Last 1
	if ($last -match '^END OF GLOBAL AGENTS\.md') { Pass "Codex global file ends with its END line: $last" } else { Warn 'Codex global file does not end with its END line (the loading check looks for it)' }
	$mirror = Join-Path $HomeBase 'mirrors\codex-global-AGENTS.md'
	if (Test-Path -LiteralPath $mirror) {
		if ((Get-FileHash -LiteralPath $mirror).Hash -eq (Get-FileHash -LiteralPath $codexAgents).Hash) { Pass 'mirror of ~/.codex/AGENTS.md is current' } else { Warn 'mirror of ~/.codex/AGENTS.md differs: copy and commit it' }
	}
	else { Warn 'no mirror of ~/.codex/AGENTS.md in the home base' }
}
else { Write-Host 'INFO  no ~/.codex/AGENTS.md (fine if Codex was skipped)' }
if ((Test-Path -LiteralPath $codexOverride) -and ((Get-Item -LiteralPath $codexOverride).Length -gt 0)) {
	Fail '~/.codex/AGENTS.override.md is not empty: Codex uses it INSTEAD of AGENTS.md'
}

foreach ($p in $Project) {
	Write-Host "== Project: $p"
	if (-not (Test-Path -LiteralPath $p)) { Fail 'project folder not found'; continue }
	foreach ($f in 'CLAUDE.md', 'docs\STATUS.md', 'docs\OWNER-QUESTIONS.md', 'docs\records\decisions.csv', 'docs\records\findings.csv', 'docs\records\test_execution.csv', '.gitattributes', '.gitignore') {
		if (Test-Path -LiteralPath (Join-Path $p $f)) { Pass "has $f" } else { Fail "missing $f" }
	}
	if (Test-Path -LiteralPath (Join-Path $p 'AGENTS.md')) { Pass 'has AGENTS.md' } else { Warn 'no AGENTS.md (fine if Codex is not used)' }
	$compose = Join-Path $p 'local\docker-compose.yml'
	if (Test-Path -LiteralPath $compose) {
		$c = Get-Content -LiteralPath $compose -Raw
		if ($c -match 'mem_limit') { Pass 'test stack compose file caps memory (mem_limit)' } else { Fail 'test stack compose file has no mem_limit' }
		if ((Test-Path -LiteralPath (Join-Path $p 'scripts\local.cmd')) -or (Test-Path -LiteralPath (Join-Path $p 'scripts\local.sh'))) { Pass 'has the local test helper' } else { Fail 'no scripts\local.cmd or scripts/local.sh' }
	}
	else { Warn 'no local\docker-compose.yml (fine only if the test stack was skipped)' }
	& git -C $p rev-parse --git-dir *> $null
	if ($LASTEXITCODE -ne 0) { Fail 'not a Git repository'; continue }
	$mail = & git -C $p config user.email 2>$null
	if (-not $mail) { Fail 'no Git email set for this repository (local or global)' }
	elseif ($mail -match 'users\.noreply\.github\.com$') { Pass 'Git email is a GitHub noreply address' }
	else { Warn 'Git email is an own address: it becomes public if this repository is ever made public' }
	$secretish = @(& git -C $p ls-files | Where-Object { $_ -match '(^|/)(\.env(\.[^/]*)?|id_rsa|id_ed25519|[^/]*\.(pem|key|p12|pfx|keystore|jks|sql|dump))$' -and $_ -notmatch '\.env\.example$' })
	if ($secretish.Count -gt 0) { Fail "tracked files that look like secrets or data: $($secretish -join ', ')" } else { Pass 'no secret-looking files tracked' }
	$origin = & git -C $p remote get-url origin 2>$null
	if ($origin) {
		if ($origin -match '://[^/@]+:[^/@]+@') { Fail 'the origin URL contains a credential: remove it (gh auth setup-git handles sign-in)' } else { Pass 'origin remote set, no credential in the URL' }
	}
	else { Write-Host 'INFO  no origin remote (local only)' }
	$branch = & git -C $p rev-parse --abbrev-ref HEAD 2>$null
	if ($branch -eq 'main') { Warn 'the checkout is on main: work happens on the work branch' } else { Pass "checkout on branch $branch" }
}

Write-Host ""
Write-Host "Result: $script:fails FAIL, $script:warns WARN"
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
