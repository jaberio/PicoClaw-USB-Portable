# ============================================================================
# PicoClaw Portable - Windows First-Run Setup
# ============================================================================
# Downloads the pinned PicoClaw zip for the host architecture, verifies its
# SHA256 against scripts\release.config, extracts the archive, and stages
# picoclaw.exe under .cache\runtimes\windows-<arch>\.
#
# Idempotent: re-running the script is a no-op if the binary is already
# present and the archive's hash still matches the manifest.
# ============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers - declared first so nothing below relies on undefined functions
# ---------------------------------------------------------------------------
function Write-Step([string]$msg) {
    Write-Host ""
    Write-Host "[SETUP] $msg" -ForegroundColor Cyan
}
function Write-Done([string]$msg) {
    Write-Host "[OK]    $msg" -ForegroundColor Green
}
function Write-Warn([string]$msg) {
    Write-Host "[WARN]  $msg" -ForegroundColor Yellow
}
function Write-Fail([string]$msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

function Read-Manifest([string]$path) {
    if (-not (Test-Path $path)) {
        throw "Manifest not found: $path"
    }
    $map = @{}
    Get-Content $path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $key = $line.Substring(0, $eq).Trim()
        $val = $line.Substring($eq + 1).Trim()
        $map[$key] = $val
    }
    return $map
}

function Get-PicoClawArch {
    # PROCESSOR_ARCHITECTURE is the *current* process arch; PROCESSOR_ARCHITEW6432
    # exposes the host arch when running 32-bit on 64-bit. We only support
    # x86_64 and aarch64 because the upstream releases do not ship 32-bit Windows.
    $hostArch = $env:PROCESSOR_ARCHITEW6432
    if (-not $hostArch) { $hostArch = $env:PROCESSOR_ARCHITECTURE }
    switch ($hostArch.ToUpperInvariant()) {
        'AMD64' { return 'x86_64' }
        'ARM64' { return 'aarch64' }
        default { throw "Unsupported architecture: $hostArch (need AMD64 or ARM64)" }
    }
}

function Get-FileSha256([string]$path) {
    # Prefer Get-FileHash, fall back to certutil for environments where the
    # Microsoft.PowerShell.Utility module is unavailable (AppLocker/WDAC/CLM).
    $cmd = Get-Command Get-FileHash -ErrorAction SilentlyContinue
    if ($cmd) {
        return (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant()
    }

    $output = & certutil.exe -hashfile $path SHA256 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        throw "Could not compute SHA256 for $path (Get-FileHash and certutil both unavailable)."
    }
    foreach ($line in $output) {
        $clean = ($line -replace '\s', '').ToLowerInvariant()
        if ($clean.Length -eq 64 -and $clean -match '^[0-9a-f]+$') {
            return $clean
        }
    }
    throw "certutil returned no usable SHA256 hash for $path."
}

function Save-Download {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$OutFile,
        [Parameter(Mandatory = $true)][string]$ExpectedSha256
    )

    $name = Split-Path $Url -Leaf
    $expected = $ExpectedSha256.ToLowerInvariant()

    if (Test-Path $OutFile) {
        $existing = Get-FileSha256 $OutFile
        if ($existing -eq $expected) {
            Write-Host "        $name already cached and verified."
            return
        }
        Write-Warn "$name exists but hash mismatch - re-downloading."
        Remove-Item $OutFile -Force
    }

    Write-Host "        Downloading $name ..." -ForegroundColor Cyan
    Write-Host "        URL: $Url" -ForegroundColor DarkGray

    if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
        $args = @(
            '-L', '-f',
            '--retry', '3',
            '--connect-timeout', '30',
            '--max-time', '900',
            '-o', $OutFile,
            $Url
        )
        & curl.exe @args
        if ($LASTEXITCODE -ne 0) {
            if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
            throw "curl.exe failed (exit $LASTEXITCODE) downloading $name"
        }
    } else {
        try {
            $ProgressPreference = 'Continue'
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 900
        } catch {
            if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
            throw "Failed to download ${name}: $_"
        }
    }

    if (-not (Test-Path $OutFile)) {
        throw "Download succeeded but file is missing: $OutFile"
    }
    $size = (Get-Item $OutFile).Length
    if ($size -eq 0) {
        Remove-Item $OutFile -Force
        throw "Downloaded file is 0 bytes: $name"
    }

    $actual = Get-FileSha256 $OutFile
    if ($actual -ne $expected) {
        Remove-Item $OutFile -Force
        throw "SHA256 mismatch for ${name}.  expected=$expected  actual=$actual"
    }

    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "        Downloaded and verified ($sizeMB MB)." -ForegroundColor Green
}

function Expand-PicoClawZip {
    param(
        [Parameter(Mandatory = $true)][string]$Archive,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (Test-Path $Destination) {
        Remove-Item $Destination -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null

    # Prefer Expand-Archive when the cmdlet is available; fall back to tar.exe
    # (built into Windows 10/11) for restricted shells where the
    # Microsoft.PowerShell.Archive module is missing.
    $expand = Get-Command Expand-Archive -ErrorAction SilentlyContinue
    if ($expand) {
        Expand-Archive -Path $Archive -DestinationPath $Destination -Force
        return
    }

    $tar = "$env:WINDIR\System32\tar.exe"
    if (Test-Path $tar) {
        & $tar -xf $Archive -C $Destination
        if ($LASTEXITCODE -ne 0) {
            throw "tar.exe failed (exit $LASTEXITCODE) extracting $Archive"
        }
        return
    }

    throw "No archive extractor available (Expand-Archive and tar.exe both missing)."
}

function Find-PicoClawBinary([string]$Dir) {
    $candidates = Get-ChildItem -Path $Dir -Filter 'picoclaw.exe' -Recurse -File -ErrorAction SilentlyContinue
    if ($candidates) {
        return $candidates[0].FullName
    }
    return $null
}

# ---------------------------------------------------------------------------
# Paths & manifest
# ---------------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Manifest  = Read-Manifest (Join-Path $ScriptDir 'release.config')

$Version = $Manifest['VERSION']
if (-not $Version) { throw "VERSION missing from release.config" }

$Arch        = Get-PicoClawArch
$ArchUpper   = $Arch.ToUpperInvariant()
$AssetName   = $Manifest["ASSET_WINDOWS_$ArchUpper"]
$ExpectedSha = $Manifest["SHA256_WINDOWS_$ArchUpper"]
if (-not $AssetName)   { throw "No asset name pinned for windows-$Arch in release.config" }
if (-not $ExpectedSha) { throw "No SHA256 pinned for windows-$Arch in release.config" }

$AssetUrl    = "https://github.com/sipeed/picoclaw/releases/download/$Version/$AssetName"

$CacheDir    = Join-Path $Root  '.cache'
$RuntimeDir  = Join-Path $CacheDir "runtimes\windows-$Arch"
$ArchivePath = Join-Path $RuntimeDir $AssetName
$ExtractDir  = Join-Path $RuntimeDir 'extract'
$BinaryPath  = Join-Path $RuntimeDir 'picoclaw.exe'
$VersionFile = Join-Path $RuntimeDir 'version.txt'
$ReadyFlag   = Join-Path $RuntimeDir 'ready.flag'

New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

# ---------------------------------------------------------------------------
# Health check - if the ready flag is stale, redo setup
# ---------------------------------------------------------------------------
if ((Test-Path $ReadyFlag) -and -not $Force) {
    $needsRefresh = $false
    if (-not (Test-Path $BinaryPath)) {
        Write-Warn "ready.flag exists but binary is missing - rerunning setup."
        $needsRefresh = $true
    } elseif ((Test-Path $VersionFile) -and ((Get-Content $VersionFile -Raw).Trim() -ne $Version)) {
        Write-Warn "Installed version differs from manifest - rerunning setup."
        $needsRefresh = $true
    }
    if (-not $needsRefresh) {
        Write-Done "PicoClaw $Version already installed."
        exit 0
    }
    Remove-Item $ReadyFlag -Force -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# Download + verify
# ---------------------------------------------------------------------------
Write-Step "Installing PicoClaw $Version (windows-$Arch) ..."
Save-Download -Url $AssetUrl -OutFile $ArchivePath -ExpectedSha256 $ExpectedSha

# ---------------------------------------------------------------------------
# Extract + stage binary
# ---------------------------------------------------------------------------
Write-Host "        Extracting $AssetName ..." -ForegroundColor Cyan
Expand-PicoClawZip -Archive $ArchivePath -Destination $ExtractDir

$src = Find-PicoClawBinary $ExtractDir
if (-not $src) {
    throw "picoclaw.exe not found inside $AssetName"
}

Copy-Item -Path $src -Destination $BinaryPath -Force

# Strip extra files from the runtime dir; keep only the essentials.
Remove-Item $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue

Set-Content -Path $VersionFile -Value $Version -NoNewline -Encoding ASCII
New-Item -ItemType File -Path $ReadyFlag -Force | Out-Null

Write-Done "PicoClaw $Version ready."

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Setup complete - launching PicoClaw" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Start-Sleep -Seconds 1
