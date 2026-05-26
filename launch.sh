#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================================
# PicoClaw Agent - Portable Launcher (macOS / Linux)
# ============================================================================
# Terminal:    ./launch.sh
# Finder/macOS: rename to launch.command for double-click launch.
#
# On first run, downloads the official Sipeed tarball (~20 MB) for your
# platform and verifies its SHA256 against scripts/release.config.
#
# All user state (config, secrets, sessions, memory) lives in data/ on the
# portable drive. Nothing is written to your real home directory.
# ============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers (declared first to avoid forward-reference traps under set -e)
# ---------------------------------------------------------------------------
err()  { printf '\033[31m[ERROR]\033[0m %s\n' "$1" >&2; }
warn() { printf '\033[33m[WARN]\033[0m  %s\n' "$1" >&2; }
info() { printf '\033[36m[INFO]\033[0m  %s\n' "$1"; }

abspath() { (cd "$1" && pwd); }

detect_platform() {
    local os arch
    case "$(uname -s)" in
        Linux*)  os=linux ;;
        Darwin*) os=macos ;;
        *) err "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)  arch=x86_64 ;;
        aarch64|arm64) arch=aarch64 ;;
        armv7l)
            if [ "$os" = "linux" ]; then arch=armv7
            else err "armv7 is only supported on Linux"; exit 1; fi
            ;;
        armv6l)
            if [ "$os" = "linux" ]; then arch=armv6
            else err "armv6 is only supported on Linux"; exit 1; fi
            ;;
        riscv64)
            if [ "$os" = "linux" ]; then arch=riscv64
            else err "RISC-V is only supported on Linux"; exit 1; fi
            ;;
        *) err "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    printf '%s %s\n' "$os" "$arch"
}

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
PORTABLE_ROOT="$(abspath "$(dirname "$0")")"
read -r PLATFORM ARCH < <(detect_platform)

CACHE_DIR="$PORTABLE_ROOT/.cache"
RUNTIME_DIR="$CACHE_DIR/runtimes/${PLATFORM}-${ARCH}"
PICOCLAW_BIN="$RUNTIME_DIR/picoclaw"
DATA_DIR="$PORTABLE_ROOT/data"
WORKSPACE_DIR="$DATA_DIR/workspace"
CONFIG_PATH="$DATA_DIR/config.json"

# ---------------------------------------------------------------------------
# First-run / repair setup
# ---------------------------------------------------------------------------
if [ ! -f "$RUNTIME_DIR/ready.flag" ] || [ ! -x "$PICOCLAW_BIN" ]; then
    echo
    echo "============================================"
    echo "    PicoClaw Portable - Setup"
    echo "============================================"
    echo "  Platform: ${PLATFORM}-${ARCH}"
    echo "  Downloading official binary and verifying SHA256."
    echo "============================================"
    echo
    bash "$PORTABLE_ROOT/scripts/setup-unix.sh" "$PORTABLE_ROOT"
fi

# ---------------------------------------------------------------------------
# Make sure the data folder structure exists
# ---------------------------------------------------------------------------
mkdir -p "$DATA_DIR" "$WORKSPACE_DIR"

# ---------------------------------------------------------------------------
# Environment isolation
# PicoClaw natively honors PICOCLAW_HOME and PICOCLAW_CONFIG, so we just
# point them at the drive's data/ folder. Works on every filesystem
# (ext4, APFS, exFAT, FAT32) without symlinks.
# ---------------------------------------------------------------------------
export PATH="$RUNTIME_DIR:$PATH"
export PICOCLAW_HOME="$DATA_DIR"
export PICOCLAW_CONFIG="$CONFIG_PATH"
export PICOCLAW_BINARY="$PICOCLAW_BIN"

# Keep XDG-aware tools (curl, openssl, MCP servers spawned via npx, etc.)
# from leaking into the host home directory.
FAKE_HOME="$CACHE_DIR/unix-home"
mkdir -p "$FAKE_HOME"
export HOME="$FAKE_HOME"
export XDG_CONFIG_HOME="$FAKE_HOME/.config"
export XDG_CACHE_HOME="$FAKE_HOME/.cache"
export XDG_DATA_HOME="$FAKE_HOME/.local/share"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"

# ---------------------------------------------------------------------------
# Pass-through mode: ./launch.sh <args>  ->  picoclaw <args>
# Strip an optional leading "picoclaw" so users can paste docs verbatim.
# ---------------------------------------------------------------------------
if [ "${1:-}" = "picoclaw" ] || [ "${1:-}" = "PICOCLAW" ]; then
    shift
fi

if [ "$#" -gt 0 ]; then
    exec "$PICOCLAW_BIN" "$@"
fi

# ---------------------------------------------------------------------------
# ANSI Colors (only emit when stdout is a terminal)
# ---------------------------------------------------------------------------
# Several palette entries below look "unused" to ShellCheck because the
# current menus only use a subset. Keeping the full set means future menu
# items can pick up colors without redeclaring the palette. SC2034 is
# disabled file-wide near the top of the script for that reason.
if [ -t 1 ]; then
    RESET=$'\033[0m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    CYAN=$'\033[36m'
    BCYAN=$'\033[96m'
    BGREEN=$'\033[92m'
    YELLOW=$'\033[33m'
    BYELLOW=$'\033[93m'
    RED=$'\033[31m'
    WHITE=$'\033[37m'
    BWHITE=$'\033[97m'
    GRAY=$'\033[90m'
else
    RESET=''; BOLD=''; DIM=''; CYAN=''; BCYAN=''; BGREEN=''
    YELLOW=''; BYELLOW=''; RED=''; WHITE=''; BWHITE=''; GRAY=''
fi

# ---------------------------------------------------------------------------
# Status detection
# ---------------------------------------------------------------------------
detect_status() {
    SETUP_STATUS="Not configured"
    SETUP_ICON="[x]"
    SETUP_COLOR="$RED"
    PROVIDER_NAME=""
    MODEL_NAME=""
    GATEWAY_STATUS="Stopped"
    GATEWAY_ICON="[ ]"
    GATEWAY_COLOR="$GRAY"

    if [ -f "$CONFIG_PATH" ]; then
        if grep -E -q '"api_keys?"' "$CONFIG_PATH" 2>/dev/null; then
            SETUP_STATUS="Configured"
            SETUP_ICON="[OK]"
            SETUP_COLOR="$BGREEN"
        fi
        MODEL_NAME=$(grep -o '"model_name"[[:space:]]*:[[:space:]]*"[^"]*"' \
            "$CONFIG_PATH" | head -n 1 | \
            sed -E 's/.*"model_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)
        PROVIDER_NAME=$(grep -o '"provider"[[:space:]]*:[[:space:]]*"[^"]*"' \
            "$CONFIG_PATH" | head -n 1 | \
            sed -E 's/.*"provider"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)
    fi

    if "$PICOCLAW_BIN" status >/dev/null 2>&1; then
        GATEWAY_STATUS="Running (127.0.0.1:18790)"
        GATEWAY_ICON="[OK]"
        GATEWAY_COLOR="$BGREEN"
    fi

    PC_VERSION="unknown"
    if [ -f "$RUNTIME_DIR/version.txt" ]; then
        PC_VERSION="$(tr -d '[:space:]' < "$RUNTIME_DIR/version.txt")"
    fi
}

# ---------------------------------------------------------------------------
# Menus
# ---------------------------------------------------------------------------
pause() { read -r -p "Press Enter to continue ..." _; }

edit_config() {
    if [ ! -f "$CONFIG_PATH" ]; then
        warn "No config.json yet - run [2] Onboard first."
        pause
        return
    fi
    "${EDITOR:-vi}" "$CONFIG_PATH"
}

show_menu() {
    detect_status
    clear || true
    cat <<EOF

${BCYAN}----------------------------------------------------------------${RESET}
${BOLD}${BWHITE}                   PICOCLAW PORTABLE LAUNCHER${RESET}
${DIM}${GRAY}               Ultra-efficient AI agent in Go (Sipeed)${RESET}
${BCYAN}----------------------------------------------------------------${RESET}

 ${DIM}Setup${RESET}    ${SETUP_COLOR}${SETUP_ICON}${RESET} ${WHITE}${SETUP_STATUS}${RESET}
EOF
    [ -n "$PROVIDER_NAME" ] && printf ' %sProvider%s %s%s%s\n' "$DIM" "$RESET" "$CYAN" "$PROVIDER_NAME" "$RESET"
    [ -n "$MODEL_NAME"    ] && printf ' %sModel%s    %s%s%s\n' "$DIM" "$RESET" "$WHITE" "$MODEL_NAME" "$RESET"
    cat <<EOF
 ${DIM}Gateway${RESET}  ${GATEWAY_COLOR}${GATEWAY_ICON}${RESET} ${WHITE}${GATEWAY_STATUS}${RESET}
 ${DIM}Binary${RESET}   ${GRAY}${PC_VERSION} (${PLATFORM}-${ARCH})${RESET}
 ${DIM}Data${RESET}     ${GRAY}${DATA_DIR}${RESET}

${BCYAN}----------------------------------------------------------------${RESET}

  ${BYELLOW}[1]${RESET}  ${WHITE}Start PicoClaw chat${RESET}       ${GRAY}(interactive agent)${RESET}
  ${BYELLOW}[2]${RESET}  ${WHITE}Onboard / Reconfigure${RESET}     ${GRAY}(API keys, channels)${RESET}
  ${BYELLOW}[3]${RESET}  ${WHITE}Start gateway${RESET}             ${GRAY}(127.0.0.1:18790)${RESET}
  ${BYELLOW}[4]${RESET}  ${WHITE}Advanced options${RESET}          ${GRAY}-->${RESET}
  ${BYELLOW}[5]${RESET}  ${GRAY}Exit${RESET}

EOF
    read -r -p "${BCYAN}Select option: ${RESET}" choice || return
    case "$choice" in
        1) "$PICOCLAW_BIN" agent || true ;;
        2) "$PICOCLAW_BIN" onboard || true ;;
        3) info "Starting gateway in background ..."
           ( "$PICOCLAW_BIN" gateway & ) ; sleep 2 ;;
        4) show_advanced ;;
        5) printf '\n%sGoodbye.%s\n\n' "$GRAY" "$RESET"; exit 0 ;;
        *) ;;
    esac
    show_menu
}

show_advanced() {
    clear || true
    cat <<EOF

${BCYAN}----------------------------------------------------------------${RESET}
${BOLD}${BWHITE}                       Advanced Options${RESET}
${BCYAN}----------------------------------------------------------------${RESET}

  ${BYELLOW}[1]${RESET}  ${WHITE}Show status${RESET}             ${GRAY}- check provider/channels${RESET}
  ${BYELLOW}[2]${RESET}  ${WHITE}Switch model${RESET}            ${GRAY}- picoclaw model${RESET}
  ${BYELLOW}[3]${RESET}  ${WHITE}Edit config.json${RESET}        ${GRAY}- open in \$EDITOR${RESET}
  ${BYELLOW}[4]${RESET}  ${WHITE}Update binary${RESET}           ${GRAY}- bump to manifest version${RESET}
  ${BYELLOW}[5]${RESET}  ${WHITE}List MCP servers${RESET}        ${GRAY}- picoclaw mcp list${RESET}
  ${BYELLOW}[6]${RESET}  ${WHITE}List skills${RESET}             ${GRAY}- picoclaw skills list${RESET}
  ${BYELLOW}[7]${RESET}  ${GRAY}Back to main menu${RESET}

EOF
    read -r -p "${BCYAN}Select option: ${RESET}" choice || return
    case "$choice" in
        1) "$PICOCLAW_BIN" status || true; pause ;;
        2) "$PICOCLAW_BIN" model || true; pause ;;
        3) edit_config ;;
        4) info "Refreshing binary against scripts/release.config ..."
           bash "$PORTABLE_ROOT/scripts/setup-unix.sh" "$PORTABLE_ROOT" --force
           pause ;;
        5) "$PICOCLAW_BIN" mcp list || true; pause ;;
        6) "$PICOCLAW_BIN" skills list || true; pause ;;
        7) return ;;
        *) show_advanced ;;
    esac
    show_advanced
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
show_menu
