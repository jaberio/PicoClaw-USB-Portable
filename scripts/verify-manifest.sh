#!/usr/bin/env bash
# ============================================================================
# verify-manifest.sh - Confirm every pinned asset still matches its hash
# ============================================================================
# Downloads every asset listed in scripts/release.config, computes its SHA256,
# and compares it to the pinned value. Prints a table and exits non-zero if
# anything drifted.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${1:-$SCRIPT_DIR/release.config}"

if [ ! -f "$MANIFEST" ]; then
    echo "[ERROR] Manifest not found: $MANIFEST" >&2
    exit 2
fi

read_manifest_value() {
    awk -F= -v k="$1" '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/  { next }
        $1 == k { sub(/^[^=]*=/, ""); print; exit }
    ' "$MANIFEST"
}

VERSION="$(read_manifest_value VERSION)"
if [ -z "$VERSION" ]; then
    echo "[ERROR] VERSION missing from release.config" >&2
    exit 2
fi

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        echo "[ERROR] need sha256sum or shasum" >&2
        exit 2
    fi
}

# ASSET_<KEY> + SHA256_<KEY> pairs.
KEYS=$(awk -F= '/^ASSET_/{ sub(/^ASSET_/, "", $1); print $1 }' "$MANIFEST")

if [ -z "$KEYS" ]; then
    echo "[ERROR] No ASSET_/SHA256_ pairs found in manifest." >&2
    exit 2
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bad=0
total=0
printf '\n%-22s %-40s %-10s\n' "PLATFORM" "ASSET" "STATUS"
printf '%-22s %-40s %-10s\n' "--------" "-----" "------"

while IFS= read -r key; do
    [ -z "$key" ] && continue
    asset="$(read_manifest_value "ASSET_$key")"
    expected="$(read_manifest_value "SHA256_$key" | tr '[:upper:]' '[:lower:]')"
    [ -z "$asset" ] && continue
    [ -z "$expected" ] && {
        printf '%-22s %-40s %-10s\n' "${key,,}" "$asset" "NO-HASH"
        bad=$((bad+1))
        total=$((total+1))
        continue
    }
    total=$((total+1))
    out="$TMP/$asset"
    url="https://github.com/sipeed/picoclaw/releases/download/$VERSION/$asset"
    if ! curl -fsSL --retry 3 --connect-timeout 30 --max-time 900 -o "$out" "$url"; then
        printf '%-22s %-40s %-10s\n' "${key,,}" "$asset" "FETCH-FAIL"
        bad=$((bad+1))
        continue
    fi
    actual="$(sha256_of "$out")"
    if [ "$actual" = "$expected" ]; then
        printf '%-22s %-40s %-10s\n' "${key,,}" "$asset" "OK"
    else
        printf '%-22s %-40s %-10s\n' "${key,,}" "$asset" "MISMATCH"
        echo "    expected: $expected"
        echo "    actual:   $actual"
        bad=$((bad+1))
    fi
done <<< "$KEYS"

echo
if [ "$bad" -gt 0 ]; then
    echo "[FAIL] $bad/$total asset(s) drifted from the pinned manifest."
    exit 1
fi

echo "[OK] All $total pinned asset(s) match."
