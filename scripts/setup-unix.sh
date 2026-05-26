#!/usr/bin/env bash
# ============================================================================
# PicoClaw Portable - Unix First-Run Setup (macOS / Linux)
# ============================================================================
# Downloads the pinned PicoClaw tarball for the host platform, verifies its
# SHA256 against scripts/release.config, extracts the archive, and stages
# the binary under .cache/runtimes/<platform>-<arch>/.
#
# Idempotent: re-running the script is a no-op if the binary is already
# present and matches the manifest.
# ============================================================================

set -euo pipefail

PORTABLE_ROOT="${1:-}"
if [ -z "$PORTABLE_ROOT" ]; then
    echo "Usage: $0 <portable-root> [--force]"
    exit 1
fi
shift || true

FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$SCRIPT_DIR/release.config"

# ---------------------------------------------------------------------------
# Helpers - declared up front so health-check + main flow can use them safely
# ---------------------------------------------------------------------------
step()     { printf '\n[SETUP] %s\n'  "$1"; }
done_msg() { printf '[OK]    %s\n'    "$1"; }
warn()     { printf '[WARN]  %s\n'    "$1" >&2; }
fail()     { printf '[ERROR] %s\n'    "$1" >&2; exit 1; }

read_manifest_value() {
    # $1 = key, $2 = file
    local key="$1" file="$2"
    awk -F= -v k="$key" '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/  { next }
        $1 == k { sub(/^[^=]*=/, ""); print; exit }
    ' "$file"
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        fail "Need sha256sum or shasum to verify downloads."
    fi
}

download_and_verify() {
    # $1 = url, $2 = out_path, $3 = expected sha256 (lowercase hex)
    local url="$1" out="$2" expected="$3"
    local name; name="$(basename "$url")"
    expected="$(printf '%s' "$expected" | tr '[:upper:]' '[:lower:]')"

    if [ -f "$out" ]; then
        local existing; existing="$(sha256_of "$out")"
        if [ "$existing" = "$expected" ]; then
            echo "        $name already cached and verified."
            return 0
        fi
        warn "$name exists but hash mismatch - re-downloading."
        rm -f "$out"
    fi

    echo "        Downloading $name ..."
    echo "        URL: $url"
    if ! curl -fL --progress-bar --retry 3 --connect-timeout 30 --max-time 900 \
            "$url" -o "$out"; then
        rm -f "$out"
        fail "Download failed: $name"
    fi

    [ -s "$out" ] || { rm -f "$out"; fail "Downloaded file is empty: $name"; }

    local actual; actual="$(sha256_of "$out")"
    if [ "$actual" != "$expected" ]; then
        rm -f "$out"
        fail "SHA256 mismatch for $name. expected=$expected actual=$actual"
    fi

    local size_mb
    size_mb="$(awk -v b="$(wc -c <"$out")" 'BEGIN{ printf "%.2f", b/1048576 }')"
    echo "        Downloaded and verified (${size_mb} MB)."
}

extract_tgz() {
    # $1 = archive, $2 = destination
    local archive="$1" dest="$2"
    rm -rf "$dest"
    mkdir -p "$dest"
    tar -xzf "$archive" -C "$dest" || {
        rm -rf "$dest"
        fail "tar extraction failed for $(basename "$archive")"
    }
}

find_picoclaw_binary() {
    # Locate the picoclaw executable somewhere inside the extract directory.
    # Upstream tarballs put picoclaw at the root, but we search recursively
    # in case the layout changes.
    find "$1" -maxdepth 4 -type f -name 'picoclaw' -perm -u+x 2>/dev/null | head -n 1
}

detect_platform() {
    local os arch
    case "$(uname -s)" in
        Linux*)  os=linux ;;
        Darwin*) os=macos ;;
        *) fail "Unsupported OS: $(uname -s)" ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)  arch=x86_64 ;;
        aarch64|arm64) arch=aarch64 ;;
        armv7l)
            if [ "$os" = "linux" ]; then arch=armv7
            else fail "armv7 is only supported on Linux"; fi
            ;;
        armv6l)
            if [ "$os" = "linux" ]; then arch=armv6
            else fail "armv6 is only supported on Linux"; fi
            ;;
        riscv64)
            if [ "$os" = "linux" ]; then arch=riscv64
            else fail "RISC-V is only supported on Linux"; fi
            ;;
        *) fail "Unsupported architecture: $(uname -m)" ;;
    esac
    printf '%s %s\n' "$os" "$arch"
}

# ---------------------------------------------------------------------------
# Manifest + platform
# ---------------------------------------------------------------------------
[ -f "$MANIFEST" ] || fail "Manifest not found: $MANIFEST"
VERSION="$(read_manifest_value VERSION "$MANIFEST")"
[ -n "$VERSION" ] || fail "VERSION missing from release.config"

read -r PLATFORM ARCH < <(detect_platform)
ARCH_UPPER="$(printf '%s' "$ARCH" | tr '[:lower:]' '[:upper:]')"
PLATFORM_UPPER="$(printf '%s' "$PLATFORM" | tr '[:lower:]' '[:upper:]')"

ASSET_NAME="$(read_manifest_value "ASSET_${PLATFORM_UPPER}_${ARCH_UPPER}" "$MANIFEST")"
EXPECTED_SHA="$(read_manifest_value "SHA256_${PLATFORM_UPPER}_${ARCH_UPPER}" "$MANIFEST")"
[ -n "$ASSET_NAME"  ] || fail "No asset pinned for ${PLATFORM}-${ARCH} in release.config"
[ -n "$EXPECTED_SHA" ] || fail "No SHA256 pinned for ${PLATFORM}-${ARCH} in release.config"

ASSET_URL="https://github.com/sipeed/picoclaw/releases/download/${VERSION}/${ASSET_NAME}"

CACHE_DIR="$PORTABLE_ROOT/.cache"
RUNTIME_DIR="$CACHE_DIR/runtimes/${PLATFORM}-${ARCH}"
ARCHIVE_PATH="$RUNTIME_DIR/$ASSET_NAME"
EXTRACT_DIR="$RUNTIME_DIR/extract"
BINARY_PATH="$RUNTIME_DIR/picoclaw"
VERSION_FILE="$RUNTIME_DIR/version.txt"
READY_FLAG="$RUNTIME_DIR/ready.flag"

mkdir -p "$RUNTIME_DIR"

# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------
if [ -f "$READY_FLAG" ] && [ "$FORCE" -eq 0 ]; then
    needs_refresh=0
    if [ ! -x "$BINARY_PATH" ]; then
        warn "ready.flag exists but binary is missing - rerunning setup."
        needs_refresh=1
    elif [ -f "$VERSION_FILE" ] && [ "$(tr -d '[:space:]' < "$VERSION_FILE")" != "$VERSION" ]; then
        warn "Installed version differs from manifest - rerunning setup."
        needs_refresh=1
    fi
    if [ "$needs_refresh" -eq 0 ]; then
        done_msg "PicoClaw $VERSION already installed."
        exit 0
    fi
    rm -f "$READY_FLAG"
fi

# ---------------------------------------------------------------------------
# Download + verify
# ---------------------------------------------------------------------------
step "Installing PicoClaw $VERSION (${PLATFORM}-${ARCH}) ..."
download_and_verify "$ASSET_URL" "$ARCHIVE_PATH" "$EXPECTED_SHA"

# ---------------------------------------------------------------------------
# Extract + stage binary
# ---------------------------------------------------------------------------
echo "        Extracting $ASSET_NAME ..."
extract_tgz "$ARCHIVE_PATH" "$EXTRACT_DIR"

src="$(find_picoclaw_binary "$EXTRACT_DIR")"
if [ -z "$src" ]; then
    fail "picoclaw binary not found inside $ASSET_NAME"
fi

cp -f "$src" "$BINARY_PATH"
chmod +x "$BINARY_PATH"

# macOS: strip quarantine so Gatekeeper does not block first launch.
if [ "$PLATFORM" = "macos" ] && command -v xattr >/dev/null 2>&1; then
    xattr -dr com.apple.quarantine "$BINARY_PATH" 2>/dev/null || true
fi

# Toss the extract dir; we only need the staged binary.
rm -rf "$EXTRACT_DIR"

printf '%s' "$VERSION" > "$VERSION_FILE"
: > "$READY_FLAG"

done_msg "PicoClaw $VERSION ready."

echo ""
echo "========================================"
echo "   Setup complete - launching PicoClaw"
echo "========================================"
sleep 1
