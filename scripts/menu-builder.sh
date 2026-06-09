# ============================================================================
# PicoClaw Launcher Utilities - Shared Menu Builder
# ============================================================================
# This script provides reusable functions for building and rendering menus
# across different platforms (Windows, macOS, Linux)
# ============================================================================

# Source this file in launcher scripts:
# Unix: source ./menu-builder.sh
# Windows: This is a reference for the patterns to follow

# Menu rendering patterns to avoid repetition
# Unix implementations follow below; Windows uses similar logic in .bat

render_menu_header() {
    local title="$1"
    local color_code="${2:-36}"  # Default: cyan
    
    printf '\033[%dm%s\033[0m\n' "$color_code" "----------------------------------------------------------------"
    printf '\033[1m\033[97m%s\033[0m\n' "$title"
    printf '\033[%dm%s\033[0m\n' "$color_code" "----------------------------------------------------------------"
    printf '\n'
}

render_menu_items() {
    local -a items=("$@")
    
    for item in "${items[@]}"; do
        # Expect format: "ID|LABEL|HINT|COLOR"
        IFS='|' read -r id label hint color <<< "$item"
        
        if [ -z "$color" ]; then
            color="93"  # Yellow by default
        fi
        
        printf '  \033[%dm[%d]\033[0m  \033[97m%-30s\033[0m \033[90m%s\033[0m\n' \
            "$color" "$id" "$label" "$hint"
    done
    
    printf '\n'
}

render_status_line() {
    local label="$1"
    local status="$2"
    local icon="$3"
    local color="${4:-90}"
    
    printf ' \033[2m%s\033[0m %s%s\033[0m \033[97m%s\033[0m\n' \
        "$label" "$(printf '\033[%dm' "$color")" "$icon" "$status"
}

# Status detection helpers
check_config_status() {
    local config_path="$1"
    
    if [ ! -f "$config_path" ]; then
        echo "Not configured"
        return 1
    fi
    
    if grep -qE '"api_keys?"|"api_key"' "$config_path" 2>/dev/null; then
        echo "Configured"
        return 0
    fi
    
    echo "Partial setup"
    return 1
}

extract_config_value() {
    local config_path="$1"
    local key_path="$2"
    
    if ! command -v jq &> /dev/null; then
        # Fallback to grep for simple keys
        grep -o "\"$key_path\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$config_path" | \
            sed -E "s/.*\"$key_path\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\1/" || true
        return
    fi
    
    jq -r ".$key_path // empty" "$config_path" 2>/dev/null || true
}

# Generic command execution wrapper
run_picoclaw_cmd() {
    local binary="$1"
    shift
    
    if [ ! -x "$binary" ]; then
        printf '\033[31m[ERROR]\033[0m Binary not found: %s\n' "$binary" >&2
        return 1
    fi
    
    "$binary" "$@"
}

# Conditional editor selection
get_editor() {
    if [ -n "${EDITOR:-}" ]; then
        echo "$EDITOR"
    elif command -v nano &> /dev/null; then
        echo "nano"
    elif command -v vi &> /dev/null; then
        echo "vi"
    else
        echo "cat"  # Fallback: view-only
    fi
}

# Common menu action: run binary command and pause
run_and_pause() {
    local binary="$1"
    shift
    
    run_picoclaw_cmd "$binary" "$@" || true
    pause
}
