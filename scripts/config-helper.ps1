# ============================================================================
# PicoClaw Configuration Helper Script
# ============================================================================
# Usage:
#   .\config-helper.ps1 -SetKey "provider" "openai"
#   .\config-helper.ps1 -SetApiKey "openai" "sk-..."
#   .\config-helper.ps1 -SetModel "gpt-4o"
#   .\config-helper.ps1 -ShowConfig
#   .\config-helper.ps1 -InitConfig
# ============================================================================

param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
    [string]$SetKey = "",
    [string]$SetValue = "",
    [string]$SetApiKey = "",
    [string]$ApiKeyValue = "",
    [string]$SetModel = "",
    [switch]$ShowConfig = $false,
    [switch]$InitConfig = $false,
    [switch]$Help = $false
)

# Load configuration paths and schema
$CONFIG_PATH = Join-Path $Root "data" "config.json"
$SCHEMA_PATH = Join-Path (Split-Path -Parent $PSScriptRoot) "scripts" "config.schema.json"
$DATA_DIR = Join-Path $Root "data"

# Load schema defaults
$schema = @{}
if (Test-Path $SCHEMA_PATH) {
    try {
        $schema = Get-Content $SCHEMA_PATH | ConvertFrom-Json
    } catch {
        Write-Host "Warning: Could not load schema from $SCHEMA_PATH" -ForegroundColor Yellow
    }
}

# Use schema defaults or hardcoded fallback
$DEFAULT_CONFIG = if ($schema.defaults) { $schema.defaults } else {
    @{
        api_keys = @{}
        default_agent = @{
            provider = "openai"
            model_name = "gpt-4o"
            temperature = 0.7
            max_tokens = 4096
        }
        channels = @{}
        skills = @()
        memory = @{
            type = "sqlite"
            retention_days = 30
        }
        gateway = @{
            host = "127.0.0.1"
            port = 18790
        }
    }
}

function Show-Help {
    Write-Host @"
PicoClaw Configuration Helper
==============================

Usage: .\config-helper.ps1 [OPTIONS]

Options:
  -SetKey <key> <value>      Set a top-level config key (e.g., -SetKey "gateway" "host" "0.0.0.0")
  -SetApiKey <provider> <key> Set API key for a provider (e.g., -SetApiKey "openai" "sk-...")
  -SetModel <model_name>      Set default model (e.g., -SetModel "gpt-4o")
  -ShowConfig                 Display current configuration
  -InitConfig                 Initialize config.json from template
  -Help                       Show this help message

Examples:
  .\config-helper.ps1 -InitConfig
  .\config-helper.ps1 -SetApiKey "openai" "sk-proj-xyz123"
  .\config-helper.ps1 -SetModel "gpt-4o-mini"
  .\config-helper.ps1 -ShowConfig
"@
}

function Ensure-DataDir {
    if (-not (Test-Path $DATA_DIR)) {
        New-Item -ItemType Directory -Path $DATA_DIR -Force | Out-Null
        Write-Host "Created data directory: $DATA_DIR" -ForegroundColor Green
    }
}

function Initialize-Config {
    Ensure-DataDir
    
    if (Test-Path $CONFIG_PATH) {
        $response = Read-Host "config.json already exists. Overwrite? (y/n)"
        if ($response -ne "y") {
            Write-Host "Cancelled." -ForegroundColor Yellow
            return
        }
    }
    
    $DEFAULT_CONFIG | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_PATH
    Write-Host "✓ Created config.json from schema defaults" -ForegroundColor Green
    Write-Host "Next: Run 'picoclaw onboard' or set API keys with -SetApiKey" -ForegroundColor Cyan
}

function Show-Current-Config {
    if (-not (Test-Path $CONFIG_PATH)) {
        Write-Host "config.json not found. Run: .\config-helper.ps1 -InitConfig" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n=== Current Configuration ===" -ForegroundColor Cyan
    Get-Content $CONFIG_PATH | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host
    Write-Host ""
}

function Set-ConfigKey {
    param([string]$Key, [string]$Value)
    
    if (-not (Test-Path $CONFIG_PATH)) {
        Write-Host "config.json not found. Run: .\config-helper.ps1 -InitConfig" -ForegroundColor Yellow
        return
    }
    
    try {
        $config = Get-Content $CONFIG_PATH | ConvertFrom-Json
        
        # Handle nested keys if needed
        $keys = $Key -split "\."
        $current = $config
        
        for ($i = 0; $i -lt $keys.Count - 1; $i++) {
            if ($null -eq $current.$($keys[$i])) {
                $current | Add-Member -NotePropertyName $keys[$i] -NotePropertyValue @{} -Force
            }
            $current = $current.$($keys[$i])
        }
        
        $lastKey = $keys[-1]
        $current | Add-Member -NotePropertyName $lastKey -NotePropertyValue $Value -Force
        
        $config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_PATH
        Write-Host "✓ Set $Key = $Value" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error updating config: $_" -ForegroundColor Red
    }
}

function Set-ApiKey {
    param([string]$Provider, [string]$KeyValue)
    
    if (-not (Test-Path $CONFIG_PATH)) {
        Write-Host "config.json not found. Run: .\config-helper.ps1 -InitConfig" -ForegroundColor Yellow
        return
    }
    
    try {
        $config = Get-Content $CONFIG_PATH | ConvertFrom-Json
        
        if ($null -eq $config.api_keys) {
            $config | Add-Member -NotePropertyName "api_keys" -NotePropertyValue @{} -Force
        }
        
        $config.api_keys | Add-Member -NotePropertyName $Provider -NotePropertyValue $KeyValue -Force
        
        $config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_PATH
        Write-Host "✓ API key set for provider: $Provider" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error setting API key: $_" -ForegroundColor Red
    }
}

function Set-DefaultModel {
    param([string]$ModelName)
    
    if (-not (Test-Path $CONFIG_PATH)) {
        Write-Host "config.json not found. Run: .\config-helper.ps1 -InitConfig" -ForegroundColor Yellow
        return
    }
    
    try {
        $config = Get-Content $CONFIG_PATH | ConvertFrom-Json
        
        if ($null -eq $config.default_agent) {
            $config | Add-Member -NotePropertyName "default_agent" -NotePropertyValue @{} -Force
        }
        
        $config.default_agent | Add-Member -NotePropertyName "model_name" -NotePropertyValue $ModelName -Force
        
        $config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_PATH
        Write-Host "✓ Default model set to: $ModelName" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error setting model: $_" -ForegroundColor Red
    }
}

# ============================================================================
# Main
# ============================================================================

if ($Help) {
    Show-Help
} elseif ($InitConfig) {
    Initialize-Config
} elseif ($ShowConfig) {
    Show-Current-Config
} elseif ($SetApiKey -and $ApiKeyValue) {
    Set-ApiKey $SetApiKey $ApiKeyValue
} elseif ($SetModel) {
    Set-DefaultModel $SetModel
} elseif ($SetKey -and $SetValue) {
    Set-ConfigKey $SetKey $SetValue
} else {
    Write-Host "No action specified. Use -Help for usage information." -ForegroundColor Yellow
    Show-Help
}
