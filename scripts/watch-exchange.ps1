# Wakes an agent when a Claude <-> Codex exchange file changes (Dev Crew kit, playbook step 11). ASCII only, so
# Windows PowerShell 5.1 reads it correctly. Run it in the background; it exits as soon as the file changes in any
# way (not on a particular marker line), prints the top entry's heading and whether it is from the other side, and
# must be started again after every wake. Exit codes: 0 changed, 1 timed out, 2 file missing.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File watch-exchange.ps1 -File <exchange.md> -Me Claude
param(
	[Parameter(Mandatory = $true)][string]$File,
	[string]$Me = 'Claude',
	[int]$IntervalSeconds = 20,
	[int]$TimeoutMinutes = 240
)

if (-not (Test-Path -LiteralPath $File)) { Write-Host "watch: file not found: $File"; exit 2 }

function Get-TopEntry {
	# Exchange files are UTF-8; read them as UTF-8 whatever the console's code page is.
	Get-Content -LiteralPath $File -Encoding UTF8 | Where-Object { $_ -match '^## Entry ' } | Select-Object -First 1
}
function Get-Hash { (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash }

$startHash = Get-Hash
$startTop = Get-TopEntry
Write-Host "watch: watching $File"
Write-Host "watch: top entry at start: $startTop"
$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$mePattern = '\|\s*' + [regex]::Escape($Me) + '\b'

while ((Get-Date) -lt $deadline) {
	Start-Sleep -Seconds $IntervalSeconds
	try { $hash = Get-Hash } catch { continue }   # the file may be mid-write; try again next round
	if ($hash -eq $startHash) { continue }
	Start-Sleep -Seconds 3                         # let the writer finish
	$top = Get-TopEntry
	$stamp = Get-Date
	Write-Host ("watch: CHANGED at {0} local ({1} UTC)" -f $stamp.ToString('yyyy-MM-dd HH:mm:ss'), $stamp.ToUniversalTime().ToString('HH:mm:ss'))
	Write-Host "watch: top entry now: $top"
	if ($top -eq $startTop) { Write-Host 'watch: no new entry heading at the top; read the file to see what changed' }
	elseif ($top -match $mePattern) { Write-Host "watch: the new top entry is from $Me" }
	else { Write-Host 'watch: the new top entry is from the other side: read it and answer' }
	exit 0
}
Write-Host "watch: no change in $TimeoutMinutes minutes; start the watcher again if still waiting"
exit 1
