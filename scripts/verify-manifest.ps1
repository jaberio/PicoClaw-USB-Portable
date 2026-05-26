# ============================================================================
# verify-manifest.ps1 - Confirm every pinned asset still matches its hash
# ============================================================================
# Downloads every asset listed in scripts\release.config, computes its SHA256,
# and compares it to the pinned value. Prints a table and returns a non-zero
# exit code if anything drifted.
#
# Used in CI (.github/workflows/ci.yml). Safe to run locally too:
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-manifest.ps1
# ============================================================================

[CmdletBinding()]
param(
    [string]$Manifest,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

if (-not $Manifest) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (-not $scriptDir) { $scriptDir = (Get-Location).Path }
    $Manifest = Join-Path $scriptDir 'release.config'
}

if (-not (Test-Path $Manifest)) {
    Write-Error "Manifest not found: $Manifest"
    exit 2
}

# ---------------------------------------------------------------------------
# Parse the manifest into a hashtable.
# ---------------------------------------------------------------------------
$kv = @{}
Get-Content $Manifest | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    $eq = $line.IndexOf('=')
    if ($eq -lt 1) { return }
    $kv[$line.Substring(0, $eq).Trim()] = $line.Substring($eq + 1).Trim()
}

$version = $kv['VERSION']
if (-not $version) {
    Write-Error 'VERSION missing from release.config'
    exit 2
}

# Discover every (asset, sha256) pair by matching ASSET_<KEY> with SHA256_<KEY>.
$pairs = @()
foreach ($key in $kv.Keys) {
    if ($key -like 'ASSET_*') {
        $suffix = $key.Substring('ASSET_'.Length)
        $shaKey = "SHA256_$suffix"
        if ($kv.ContainsKey($shaKey)) {
            $pairs += [pscustomobject]@{
                Platform = $suffix.ToLowerInvariant()
                Asset    = $kv[$key]
                Expected = $kv[$shaKey].ToLowerInvariant()
            }
        }
    }
}

if (-not $pairs) {
    Write-Error 'No ASSET_/SHA256_ pairs found in manifest.'
    exit 2
}

# ---------------------------------------------------------------------------
# Cross-platform SHA256 helper (matches setup-windows.ps1 fallback chain).
# ---------------------------------------------------------------------------
function Get-FileSha256([string]$path) {
    $cmd = Get-Command Get-FileHash -ErrorAction SilentlyContinue
    if ($cmd) {
        return (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant()
    }
    $output = & certutil.exe -hashfile $path SHA256 2>$null
    foreach ($line in $output) {
        $clean = ($line -replace '\s', '').ToLowerInvariant()
        if ($clean.Length -eq 64 -and $clean -match '^[0-9a-f]+$') { return $clean }
    }
    throw "No SHA256 utility available."
}

$tmp = New-Item -ItemType Directory -Force -Path (Join-Path $env:TEMP "picoclaw-verify-$([System.Guid]::NewGuid().Guid.Substring(0,8))")
$results = @()
$bad = 0

try {
    foreach ($p in $pairs) {
        $url = "https://github.com/sipeed/picoclaw/releases/download/$version/$($p.Asset)"
        $out = Join-Path $tmp $p.Asset
        if (-not $Quiet) {
            Write-Host ("[FETCH] {0}" -f $p.Asset) -ForegroundColor Cyan
        }
        try {
            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                & curl.exe -fsSL --retry 3 --connect-timeout 30 --max-time 900 -o $out $url
                if ($LASTEXITCODE -ne 0) { throw "curl exit $LASTEXITCODE" }
            } else {
                Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 900
            }
            $actual = Get-FileSha256 $out
        } catch {
            $results += [pscustomobject]@{
                Platform = $p.Platform
                Asset    = $p.Asset
                Status   = 'FETCH-FAIL'
                Expected = $p.Expected
                Actual   = $_.Exception.Message
            }
            $bad++
            continue
        }
        $status = if ($actual -eq $p.Expected) { 'OK' } else { 'MISMATCH' }
        if ($status -ne 'OK') { $bad++ }
        $results += [pscustomobject]@{
            Platform = $p.Platform
            Asset    = $p.Asset
            Status   = $status
            Expected = $p.Expected
            Actual   = $actual
        }
    }
} finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
$results | Format-Table -AutoSize Platform, Asset, Status

if ($bad -gt 0) {
    Write-Host ("[FAIL] {0}/{1} asset(s) drifted from the pinned manifest." -f $bad, $results.Count) -ForegroundColor Red
    exit 1
}

Write-Host ("[OK] All {0} pinned asset(s) match." -f $results.Count) -ForegroundColor Green
exit 0
