# ============================================================================
# PicoClaw Portable - Reset Script (Windows)
# ============================================================================
# Deletes downloaded binaries (and optionally user data) so the next launch
# triggers a clean first-run setup.
#
# Usage:
#   .\scripts\reset-windows.ps1 -Mode soft    # Keep data\ (config, secrets)
#   .\scripts\reset-windows.ps1 -Mode full    # Delete everything including data
# ============================================================================

[CmdletBinding()]
param(
    [ValidateSet('soft', 'full')]
    [string]$Mode = ''
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Get-FolderSizeMB([string]$path) {
    if (-not (Test-Path $path)) { return 0 }
    $sum = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    if ($null -eq $sum) { return 0 }
    return [math]::Round($sum / 1MB, 1)
}

# ---------------------------------------------------------------------------
# Interactive prompt when no mode passed
# ---------------------------------------------------------------------------
if (-not $Mode) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   PicoClaw Portable - Reset"            -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose reset mode:" -ForegroundColor Yellow
    Write-Host "  [1] Soft  - Delete cached binary, KEEP data\ (config, secrets, sessions)"
    Write-Host "  [2] Full  - Delete everything including data\ (fresh start)"
    Write-Host ""
    $pick = Read-Host 'Enter 1 or 2'
    if ($pick -eq '2') { $Mode = 'full' } else { $Mode = 'soft' }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   PicoClaw Portable - Reset ($Mode)"     -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Stop any running PicoClaw process started via this launcher.
Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -ieq 'picoclaw'
} | ForEach-Object {
    try {
        Write-Host "[INFO]  Stopping picoclaw.exe (PID $($_.Id)) ..." -ForegroundColor Yellow
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    } catch {}
}

# ---------------------------------------------------------------------------
# Plan deletions
# ---------------------------------------------------------------------------
$targets = @()

$runtimes = Join-Path $Root '.cache\runtimes'
if (Test-Path $runtimes) { $targets += $runtimes }

if ($Mode -eq 'full') {
    foreach ($p in @('data', '.cache')) {
        $full = Join-Path $Root $p
        if (Test-Path $full) { $targets += $full }
    }
}

Write-Host ""
Write-Host "The following folders will be DELETED:" -ForegroundColor Yellow
foreach ($t in $targets) {
    $sz = Get-FolderSizeMB $t
    Write-Host ("  - {0} ({1} MB)" -f $t, $sz) -ForegroundColor Red
}

if ($Mode -eq 'soft') {
    Write-Host ""
    Write-Host "Your data\ folder is PRESERVED:" -ForegroundColor Green
    Write-Host "  - $Root\data\config.json   (settings, API keys)"
    Write-Host "  - $Root\data\workspace\    (skills, sessions, scratch)"
}

Write-Host ""
$confirm = Read-Host "Type 'yes' to confirm deletion"
if ($confirm -ne 'yes') {
    Write-Host "Cancelled. Nothing deleted." -ForegroundColor Yellow
    exit 0
}

foreach ($t in $targets) {
    if (Test-Path $t) {
        Write-Host "[DEL]   $t ..." -NoNewline
        Remove-Item $t -Recurse -Force
        Write-Host " done" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Reset complete!"                       -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
if ($Mode -eq 'soft') {
    Write-Host "Next: run launch.bat to redownload the binary."
    Write-Host "Your config + workspace under data\ are intact."
} else {
    Write-Host "Next: run launch.bat for a completely fresh start."
    Write-Host "You'll need to onboard and re-enter API keys."
}
