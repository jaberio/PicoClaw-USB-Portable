#!/usr/bin/env bash
# ============================================================================
# PicoClaw Portable - Reset Script (macOS / Linux)
# ============================================================================
# Deletes the cached binary (and optionally user data) so the next launch
# triggers a clean first-run setup.
#
# Usage:
#   bash scripts/reset-unix.sh           # interactive
#   bash scripts/reset-unix.sh soft      # keep data/ (API keys, config, sessions)
#   bash scripts/reset-unix.sh full      # delete everything including data/
# ============================================================================

set -euo pipefail

err()  { printf '\033[31m[ERROR]\033[0m %s\n' "$1" >&2; }
info() { printf '\033[36m[INFO]\033[0m  %s\n' "$1"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-}"

if [ -z "$MODE" ]; then
    cat <<EOF
========================================
   PicoClaw Portable - Reset
========================================

Choose reset mode:
  [1] Soft  - Delete cached binary, KEEP data/ (config, secrets, sessions)
  [2] Full  - Delete everything including data/ (fresh start)

EOF
    read -r -p "Enter 1 or 2: " choice
    case "$choice" in
        2) MODE=full ;;
        *) MODE=soft ;;
    esac
fi

case "$MODE" in
    soft|full) ;;
    *) err "Usage: $0 [soft|full]"; exit 1 ;;
esac

echo "========================================"
echo "   PicoClaw Portable - Reset ($MODE)"
echo "========================================"

# Try to stop any running PicoClaw process started via this drive.
if command -v pkill >/dev/null 2>&1; then
    pkill -x picoclaw 2>/dev/null || true
fi

targets=()
[ -d "$ROOT/.cache/runtimes" ] && targets+=("$ROOT/.cache/runtimes")
if [ "$MODE" = "full" ]; then
    [ -d "$ROOT/data"   ] && targets+=("$ROOT/data")
    [ -d "$ROOT/.cache" ] && targets+=("$ROOT/.cache")
fi

echo
echo "The following folders will be DELETED:"
for t in "${targets[@]}"; do
    sz=$(du -sm "$t" 2>/dev/null | cut -f1 || echo 0)
    printf '  - %s (%s MB)\n' "$t" "$sz"
done

if [ "$MODE" = "soft" ]; then
    echo
    echo "Your data/ folder is PRESERVED:"
    echo "  - $ROOT/data/config.json   (settings, API keys)"
    echo "  - $ROOT/data/workspace/    (skills, sessions, scratch)"
fi

echo
read -r -p "Type 'yes' to confirm deletion: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cancelled. Nothing deleted."
    exit 0
fi

for t in "${targets[@]}"; do
    if [ -d "$t" ]; then
        printf '[DEL]   %s ...' "$t"
        rm -rf "$t"
        printf ' done\n'
    fi
done

echo
echo "========================================"
echo "   Reset complete!"
echo "========================================"
echo
if [ "$MODE" = "soft" ]; then
    echo "Next: run ./launch.sh to redownload the binary."
    echo "Your config + workspace under data/ are intact."
else
    echo "Next: run ./launch.sh for a completely fresh start."
    echo "You'll need to onboard and re-enter API keys."
fi
