# Read-only report of this computer for the Dev Crew setup (playbook step 1). Windows. Changes nothing. ASCII only.
# Prints a Markdown report to paste into my-setup/PROGRESS.md. It reports whether things are set, never secret values,
# and never prints account names, emails or tokens.
$ErrorActionPreference = 'SilentlyContinue'

function Get-ToolVersion([string]$Exe, [string[]]$ToolArgs) {
	$cmd = Get-Command $Exe -ErrorAction SilentlyContinue
	if (-not $cmd) { return 'not found' }
	$out = & $Exe @ToolArgs 2>$null | Select-Object -First 1
	if (-not $out) { return 'found, no version output' }
	return ([string]$out).Trim()
}
function Row([string]$Item, [string]$Value) { "| $Item | $Value |" }

$now = Get-Date
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$ramGb = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$docs = [Environment]::GetFolderPath('MyDocuments')

"## Machine report ($($now.ToString('yyyy-MM-dd HH:mm')) local, $($now.ToUniversalTime().ToString('HH:mm')) UTC; scripts/check-machine.ps1)"
""
"| Item | Found |"
"|---|---|"
Row 'Operating system' "$($os.Caption) $($os.Version)"
Row 'Processor' "$($cpu.Name.Trim()) ($($cpu.NumberOfCores) cores, $($cpu.NumberOfLogicalProcessors) threads)"
Row 'Memory' "$ramGb GB"
Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
	Row "Disk $($_.DeviceID)" ("{0:N0} GB free of {1:N0} GB" -f ($_.FreeSpace / 1GB), ($_.Size / 1GB))
}
# With Hyper-V/WSL 2 already running, VirtualizationFirmwareEnabled reads False even though virtualization works.
Row 'Virtualization' ("firmware setting: $($cpu.VirtualizationFirmwareEnabled); hypervisor running: $($cs.HypervisorPresent)")
Row 'Documents folder inside OneDrive' ([string]($docs -match 'OneDrive'))
$gh = Join-Path $env:USERPROFILE 'GitHub'
Row 'Folder %USERPROFILE%\GitHub exists' ([string](Test-Path -LiteralPath $gh))

# WSL prints UTF-16 unless WSL_UTF8 is set (newer WSL versions honour it).
$env:WSL_UTF8 = '1'
if (Get-Command wsl -ErrorAction SilentlyContinue) {
	$wslList = (& wsl -l -v 2>$null | Where-Object { $_ -and $_.Trim() } | ForEach-Object { $_.Trim() }) -join '; '
	if (-not $wslList) { $wslList = 'installed; no distributions listed (or WSL not set up yet)' }
	Row 'WSL distributions' $wslList
}
else { Row 'WSL' 'not found' }
$wslconfig = Join-Path $env:USERPROFILE '.wslconfig'
if (Test-Path -LiteralPath $wslconfig) {
	$lines = (Get-Content -LiteralPath $wslconfig | Where-Object { $_ -match '^\s*(memory|processors|swap)\s*=' } | ForEach-Object { $_.Trim() }) -join '; '
	if (-not $lines) { $lines = 'exists, no memory/processors lines' }
	Row '.wslconfig' $lines
}
else { Row '.wslconfig' 'none (WSL 2 defaults: up to half the RAM, all threads)' }

Row 'Git' (Get-ToolVersion 'git' @('--version'))
Row 'GitHub CLI' (Get-ToolVersion 'gh' @('--version'))
Row 'Docker CLI' (Get-ToolVersion 'docker' @('--version'))
Row 'Docker Compose' (Get-ToolVersion 'docker' @('compose', 'version'))
Row 'Node.js' (Get-ToolVersion 'node' @('--version'))
$py = Get-Command python -ErrorAction SilentlyContinue
if ($py) { Row 'Python' ((Get-ToolVersion 'python' @('--version')) + " at $($py.Source)") } else { Row 'Python' 'not found' }
Row 'Codex CLI' (Get-ToolVersion 'codex' @('--version'))
Row 'Claude Code CLI' (Get-ToolVersion 'claude' @('--version'))
Row 'winget' (Get-ToolVersion 'winget' @('--version'))

if (Get-Command docker -ErrorAction SilentlyContinue) {
	$srv = & docker version --format '{{.Server.Version}}' 2>$null
	if ($LASTEXITCODE -eq 0 -and $srv) {
		$info = & docker info --format '{{.NCPU}}|{{.MemTotal}}' 2>$null
		$parts = ([string]$info).Split('|')
		$mem = if ($parts.Count -ge 2) { [math]::Round([double]$parts[1] / 1GB, 1) } else { '?' }
		Row 'Docker engine' "running, engine $srv, $($parts[0]) CPUs, $mem GB for containers"
		$crew = @(& docker ps -q --filter 'label=crew.job=1' 2>$null).Count
		$all = @(& docker ps -q 2>$null).Count
		Row 'Containers running' "$all (crew jobs: $crew)"
	}
	else { Row 'Docker engine' 'NOT answering (Docker Desktop not running, or not installed fully)' }
}
if (Get-Command gh -ErrorAction SilentlyContinue) {
	& gh auth status *> $null
	Row 'GitHub CLI signed in' ([string]($LASTEXITCODE -eq 0))
}
$gname = & git config --global user.name 2>$null
$globalMail = & git config --global user.email 2>$null
$mailKind = if (-not $globalMail) { 'not set' } elseif ($globalMail -match 'users\.noreply\.github\.com$') { 'GitHub noreply address' } else { 'own address (would be public in public repositories)' }
Row 'Git global identity' ("name set: $([bool]$gname); email: $mailKind")
Row 'Git core.autocrlf (global/system)' ([string](& git config core.autocrlf 2>$null))
Row 'Git core.longpaths' ([string](& git config core.longpaths 2>$null))

$claudeMd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
$codexAgents = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
$codexOverride = Join-Path $env:USERPROFILE '.codex\AGENTS.override.md'
$codexConfig = Join-Path $env:USERPROFILE '.codex\config.toml'
Row '~/.claude/CLAUDE.md' ([string](Test-Path -LiteralPath $claudeMd))
Row '~/.codex/AGENTS.md' ([string](Test-Path -LiteralPath $codexAgents))
Row '~/.codex/AGENTS.override.md' ([string](Test-Path -LiteralPath $codexOverride))
Row '~/.codex/config.toml' ([string](Test-Path -LiteralPath $codexConfig))
Row 'CREW_MAX_JOBS' $(if ($env:CREW_MAX_JOBS) { $env:CREW_MAX_JOBS } else { 'not set' })
