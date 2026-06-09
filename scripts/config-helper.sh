#!/usr/bin/env bash
# ============================================================================
# PicoClaw Configuration Helper Script
# ============================================================================
# Usage:
#   ./config-helper.sh --set-key "provider" "openai"
#   ./config-helper.sh --set-api-key "openai" "sk-..."
#   ./config-helper.sh --set-model "gpt-4o"
#   ./config-helper.sh --show-config
#   ./config-helper.sh --init-config
# ============================================================================

set -euo pipefail

# Helpers
err()  { printf '\033[31m[ERROR]\033[0m %s\n' "$1" >&2; }
warn() { printf '\033[33m[WARN]\033[0m  %s\n' "$1" >&2; }
info() { printf '\033[36m[INFO]\033[0m  %s\n' "$1"; }
ok()   { printf '\033[32m[✓]\033[0m %s\n' "$1"; }

ROOT="${1:-.}"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_PATH="$ROOT/data/config.json"
SCHEMA_PATH="$SCRIPT_DIR/config.schema.json"
DATA_DIR="$ROOT/data"

# Load schema and extract defaults
load_schema() {
    if [ ! -f "$SCHEMA_PATH" ]; then
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        jq . "$SCHEMA_PATH" 2>/dev/null
    else
        return 1
    fi
}

# Check for required tools
require_tool() {
    if ! command -v "$1" &> /dev/null; then
        err "Required tool not found: $1"
        err "Please install $1 to use config helper"
        exit 1
    fi
}

show_help() {
    cat <<EOF
PicoClaw Configuration Helper
==============================

Usage: ./config-helper.sh [OPTIONS]

Options:
  --init-config              Initialize config.json from template
  --show-config              Display current configuration
  --set-api-key <provider> <key>  Set API key for provider
  --set-model <model_name>   Set default model
  --set-key <key> <value>    Set arbitrary config value
  --help                     Show this help message

Examples:
  ./config-helper.sh --init-config
  ./config-helper.sh --set-api-key openai "sk-proj-xyz123"
  ./config-helper.sh --set-model "gpt-4o-mini"
  ./config-helper.sh --show-config
EOF
}

ensure_data_dir() {
    mkdir -p "$DATA_DIR"
}

init_config() {
    ensure_data_dir
    
    if [ -f "$CONFIG_PATH" ]; then
        read -r -p "config.json already exists. Overwrite? (y/n): " response
        if [ "$response" != "y" ]; then
            warn "Cancelled."
            return
        fi
    fi
    
    if command -v jq &> /dev/null; then
        # Extract defaults from schema and create config
        SCHEMA=$(load_schema)
        if [ -n "$SCHEMA" ]; then
            echo "$SCHEMA" | jq '.defaults' > "$CONFIG_PATH"
            ok "Created config.json from schema defaults"
        else
            err "Could not load schema"
            return 1
        fi
    else
        # Fallback: create minimal config without jq
        cat > "$CONFIG_PATH" <<'EOJ'
{
  "api_keys": {},
  "default_agent": {
    "provider": "openai",
    "model_name": "gpt-4o",
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "channels": {},
  "skills": [],
  "memory": {
    "type": "sqlite",
    "retention_days": 30
  },
  "gateway": {
    "host": "127.0.0.1",
    "port": 18790
  }
}
EOJ
        ok "Created minimal config.json"
    fi
    
    info "Next: Run 'picoclaw onboard' or set API keys with --set-api-key"
}

show_current_config() {
    if [ ! -f "$CONFIG_PATH" ]; then
        warn "config.json not found. Run: ./config-helper.sh --init-config"
        return
    fi
    
    echo ""
    echo "=== Current Configuration ==="
    if command -v jq &> /dev/null; then
        jq . "$CONFIG_PATH"
    else
        cat "$CONFIG_PATH"
    fi
    echo ""
}

set_api_key() {
    local provider="$1"
    local key_value="$2"
    
    if [ ! -f "$CONFIG_PATH" ]; then
        warn "config.json not found. Run: ./config-helper.sh --init-config"
        return
    fi
    
    if command -v jq &> /dev/null; then
        jq ".api_keys.$provider = \"$key_value\"" "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
        ok "API key set for provider: $provider"
    else
        err "jq not found. Cannot update config without jq."
        err "Install jq or edit config.json manually."
        exit 1
    fi
}

set_default_model() {
    local model_name="$1"
    
    if [ ! -f "$CONFIG_PATH" ]; then
        warn "config.json not found. Run: ./config-helper.sh --init-config"
        return
    fi
    
    if command -v jq &> /dev/null; then
        jq ".default_agent.model_name = \"$model_name\"" "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
        ok "Default model set to: $model_name"
    else
        err "jq not found. Cannot update config without jq."
        err "Install jq or edit config.json manually."
        exit 1
    fi
}

set_config_key() {
    local key="$1"
    local value="$2"
    
    if [ ! -f "$CONFIG_PATH" ]; then
        warn "config.json not found. Run: ./config-helper.sh --init-config"
        return
    fi
    
    if command -v jq &> /dev/null; then
        jq ".$key = \"$value\"" "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
        ok "Set $key = $value"
    else
        err "jq not found. Cannot update config without jq."
        exit 1
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "${1:-}" in
    --init-config)
        init_config
        ;;
    --show-config)
        show_current_config
        ;;
    --set-api-key)
        if [ $# -lt 3 ]; then
            err "Usage: ./config-helper.sh --set-api-key <provider> <key>"
            exit 1
        fi
        set_api_key "$2" "$3"
        ;;
    --set-model)
        if [ $# -lt 2 ]; then
            err "Usage: ./config-helper.sh --set-model <model_name>"
            exit 1
        fi
        set_default_model "$2"
        ;;
    --set-key)
        if [ $# -lt 3 ]; then
            err "Usage: ./config-helper.sh --set-key <key> <value>"
            exit 1
        fi
        set_config_key "$2" "$3"
        ;;
    --help|-h|help)
        show_help
        ;;
    *)
        err "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
