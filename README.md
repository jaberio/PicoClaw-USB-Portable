# <p align="center">🦞 PicoClaw Agent — Portable & Cross-Platform</p>

<p align="center">
  <a href="https://github.com/jaberio/PicoClaw-USB-Portable/actions/workflows/ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/jaberio/PicoClaw-USB-Portable/ci.yml?branch=main&style=for-the-badge&label=CI" alt="CI">
  </a>
  <a href="https://github.com/jaberio/PicoClaw-USB-Portable/releases/latest">
    <img src="https://img.shields.io/github/v/release/jaberio/PicoClaw-USB-Portable?style=for-the-badge&color=8A2BE2" alt="Latest release">
  </a>
  <img src="https://img.shields.io/badge/PicoClaw-v0.2.8-22c55e?style=for-the-badge" alt="Pinned PicoClaw version">
  <img src="https://img.shields.io/badge/license-MIT-2563EB?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-059669?style=for-the-badge" alt="Platforms">
  <img src="https://img.shields.io/badge/SHA256-verified-0ea5e9?style=for-the-badge" alt="SHA256 verified">
</p>

---

<p align="center">
  <strong>Run Sipeed's ultra-efficient Go-based AI agent from a single folder or USB drive.</strong><br>
  No global installation. Zero host pollution. Every byte of your config, secrets, sessions, and skills stays inside this folder.
</p>

<p align="center">
  Upstream: <a href="https://github.com/sipeed/picoclaw"><code>sipeed/picoclaw</code></a> · &lt;10 MB RAM · &lt;1 s boot · single static Go binary
</p>

---

## ✨ Why this exists

PicoClaw ships as a single static Go binary, which makes it ideal for true
portability: no Python, no Node, no virtualenv, no package manager. This
wrapper turns the upstream binary into a fully self-contained USB-ready
bundle:

- **One folder, one drive.** Drop it on a USB stick or external SSD, run it on any Windows, macOS, or Linux machine.
- **No host pollution.** `~/.picoclaw/` is redirected to the visible `data/` folder via the official `PICOCLAW_HOME` env var. The wrapper never writes to your real home directory.
- **SHA256-verified downloads.** The pinned release lives in `scripts/release.config`. Every download is checked against its expected hash before extraction.
- **Idempotent setup.** Re-running the launcher only re-downloads when the binary is missing or the manifest version changed.
- **OpenAI-compatible everywhere.** PicoClaw natively supports 30+ LLM providers and 19+ messaging channels through `data/config.json`.

---

## ⚡ Quick Start

### 0. Get the wrapper

Download the latest release zip from
[Releases](https://github.com/jaberio/PicoClaw-USB-Portable/releases/latest)
and extract it onto your USB drive (or any folder), or clone the repo:

```bash
git clone https://github.com/jaberio/PicoClaw-USB-Portable.git
```

### Windows (10 / 11)

Double-click **`launch.bat`**.
On first run, it downloads ~20 MB (the official Sipeed zip) for your
architecture, verifies its SHA256, extracts `picoclaw.exe`, and opens the
menu.

### macOS & Linux

```bash
chmod +x launch.sh
./launch.sh
```

> 💡 **Finder double-click**: rename `launch.sh` to `launch.command`. macOS opens
> `.command` files in Terminal automatically.

### Pass-through mode

Anything you'd normally type after `picoclaw` works through the launcher:

```bash
./launch.sh agent -m "Hello"
./launch.sh onboard
./launch.sh gateway
./launch.sh status
./launch.sh mcp list
```

---

## ⚙️ How It Works (Under the Hood)

```mermaid
graph TD
    A[User runs launch script] --> B{ready.flag + binary present?}
    B -- No / first run --> C[Read scripts/release.config]
    C --> D[Detect platform + arch]
    D --> E[Download picoclaw_<Platform>_<arch>.zip|tar.gz]
    E --> F[Verify SHA256 against manifest]
    F --> G[Extract and stage picoclaw binary]
    B -- Yes --> H[Set PICOCLAW_HOME = data/]
    G --> H
    H --> I[Set PICOCLAW_CONFIG = data/config.json]
    I --> J[Prepend runtime/ to PATH]
    J --> K[Either pass-through args or open TUI menu]
```

### The isolation design

1. **Native `PICOCLAW_HOME` override.** PicoClaw reads its data directory from `PICOCLAW_HOME` before falling back to `~/.picoclaw/`. The launcher points it straight at the drive's `data/` folder. No symlinks, no junctions — works on NTFS, exFAT, FAT32, ext4, APFS, anything.
2. **Native `PICOCLAW_CONFIG` override.** Same trick for the config file path. Sessions, skills, and the encrypted `.security.yml` all land under `data/`.
3. **`HOME` redirected for shell-outs.** When PicoClaw spawns helper tools (curl, MCP servers via npx), the launcher reroutes `HOME` and the `XDG_*` variables to a private cache so those tools never write to your real profile.
4. **Pinned release.** `scripts/release.config` holds the version *and* SHA256 hash for every supported platform. The setup script refuses to extract any archive whose hash doesn't match.

---

## 📁 Workspace Layout

```yaml
picoclaw-portable/
├── launch.bat                  # Windows interactive launcher
├── launch.sh                   # macOS & Linux interactive launcher
├── scripts/
│   ├── release.config          # Pinned version + SHA256s (single source of truth)
│   ├── setup-windows.ps1       # First-run / repair: download + verify + extract
│   ├── setup-unix.sh           # Same, for macOS/Linux
│   ├── reset-windows.ps1       # Soft / full reset
│   ├── reset-unix.sh           # Same, for macOS/Linux
│   └── COMMANDS.md             # Cheatsheet for every CLI command
├── data/                       # ⚠️ [BACKUP THIS] all your private files
│   ├── config.json             # Providers, channels, tools, gateway, agents
│   ├── .security.yml           # Encrypted secret store (API keys, tokens)
│   ├── workspace/              # Skills, sessions, attachments, scratch
│   └── ...                     # Memory, cron jobs, hooks, evolution state
└── .cache/                     # Sandbox cache, never sync this
    ├── runtimes/
    │   ├── windows-x86_64/     # picoclaw.exe + version.txt + ready.flag
    │   ├── windows-aarch64/
    │   ├── macos-x86_64/
    │   ├── macos-aarch64/
    │   ├── linux-x86_64/
    │   ├── linux-aarch64/
    │   ├── linux-armv7/        # 32-bit ARM (Raspberry Pi Zero, older boards)
    │   ├── linux-armv6/        # ancient ARM
    │   └── linux-riscv64/
    ├── win-appdata/            # Fake %APPDATA% so npm/curl don't leak
    ├── win-localappdata/       # Fake %LOCALAPPDATA% (same reason)
    └── unix-home/              # Fake $HOME for macOS / Linux shell-outs
```

---

## 🗝️ Setup API Keys

Two paths to configure providers:

1. **Interactive wizard:** menu option `[2] Onboard / Reconfigure`, or `./launch.sh onboard`. Adds a model entry under `model_list` and stores the API key in the encrypted security store.
2. **Edit `data/config.json` directly.** PicoClaw uses a `model_list` array where each entry pairs a `model_name` alias with a `provider` and `model`:

   ```json
   {
     "version": 3,
     "model_list": [
       {
         "model_name": "default",
         "provider": "openrouter",
         "model": "anthropic/claude-sonnet-4",
         "api_keys": ["sk-or-v1-..."]
       },
       {
         "model_name": "fast",
         "provider": "groq",
         "model": "llama-3.3-70b-versatile",
         "api_keys": ["gsk_..."]
       }
     ],
     "agents": {
       "defaults": {
         "model_name": "default"
       }
     }
   }
   ```

   API keys placed in plaintext under `model_list[*].api_keys` are
   automatically migrated into `data/.security.yml` (encrypted) on the next
   launch.

> **Provider naming:** PicoClaw treats provider as a free-form string in
> `model_list`. Common values include `openai`, `anthropic`, `gemini`,
> `openrouter`, `zhipu`, `deepseek`, `qwen`, `groq`, `moonshot`, `minimax`,
> `mistral`, `ollama`, `vllm`, `azure`, `bedrock`, `github-copilot`. See the
> [upstream provider list](https://github.com/sipeed/picoclaw#-providers-llm)
> for the full set.

---

## 🔄 Updating the Binary

This wrapper deliberately does **not** call PicoClaw's auto-update path,
because that bypasses SHA256 verification. Instead:

1. Update `scripts/release.config` with the new `VERSION` and the matching
   `SHA256_*` lines from the
   [official release page](https://github.com/sipeed/picoclaw/releases).
2. Run **Advanced -> [4] Update binary** from the launcher menu, or:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts\setup-windows.ps1 -Root . -Force`
   - Unix: `bash scripts/setup-unix.sh . --force`

The `--force` flag skips the early-exit health check and re-downloads even
when `ready.flag` is present. Hash mismatch aborts the install before any
binary is staged.

---

## 🖥️ Supported Platforms

| OS | Arch | Asset | Status |
| -- | ---- | ----- | ------ |
| Windows 10 / 11 | x86_64 | `picoclaw_Windows_x86_64.zip` | ✅ |
| Windows 11 ARM | aarch64 | `picoclaw_Windows_arm64.zip` | ✅ |
| macOS 13+ | Apple Silicon | `picoclaw_Darwin_arm64.tar.gz` | ✅ |
| macOS 13+ | Intel | `picoclaw_Darwin_x86_64.tar.gz` | ✅ |
| Linux | x86_64 | `picoclaw_Linux_x86_64.tar.gz` | ✅ |
| Linux | aarch64 | `picoclaw_Linux_arm64.tar.gz` | ✅ |
| Linux | armv7 (Pi Zero 2W 32-bit) | `picoclaw_Linux_armv7.tar.gz` | ✅ |
| Linux | armv6 (ancient ARM) | `picoclaw_Linux_armv6.tar.gz` | ✅ |
| Linux | RISC-V 64 (LicheeRV) | `picoclaw_Linux_riscv64.tar.gz` | ✅ |

> **Filesystem note:** the launcher uses native `PICOCLAW_HOME` and
> `PICOCLAW_CONFIG` environment variables to point PicoClaw at the
> drive's `data/` folder. This works on every filesystem — NTFS, exFAT,
> FAT32, ext4, APFS — with no symlinks, junctions, or special permissions.

---

## 📦 Footprint

| Component | Size | Notes |
| --------- | ---- | ----- |
| Launchers + scripts | ~30 KB | Pure text |
| PicoClaw archive | ~17–20 MB compressed | One per platform |
| PicoClaw binary | ~50 MB extracted | Single static Go executable |
| User data | starts ~0, grows with skills + sessions | Backup target |

> The Go binary is bigger than NullClaw's Zig binary but still tiny compared
> to anything Python or Node based. Runtime memory at idle is &lt;10 MB,
> startup is sub-second even on cheap RISC-V hardware.

---

## 🔒 Security Advisory

> [!WARNING]
> **Your portable drive contains your identity.**
> `data/config.json` and `data/.security.yml` carry every API key, channel
> token, and skill credential the agent has access to. Anyone with read
> access to the drive owns those credentials.
>
> - Encrypt the drive (BitLocker / FileVault / VeraCrypt).
> - Keep `tools.filter_sensitive_data` enabled (default) so leaked secrets
>   never reach the LLM in tool outputs.
> - For higher-stakes usage, set `gateway.host` to `127.0.0.1` (default) and
>   tunnel inbound traffic through Tailscale, Cloudflare Tunnel, or SSH.
> - PicoClaw is pre-1.0 and the upstream README explicitly warns: don't
>   deploy to production yet.

---

## 🔍 Troubleshooting & FAQ

<details>
<summary><strong>SHA256 mismatch on first download</strong></summary>

This means the asset on disk does not match the hash pinned in
`scripts/release.config`. Either the upstream release was re-rolled, or your
network injected something. Verify the value at
<https://github.com/sipeed/picoclaw/releases> and update `release.config`
before re-running.
</details>

<details>
<summary><strong>Drive uses exFAT or FAT32 — does this still work?</strong></summary>

Yes. The launcher uses PicoClaw's native `PICOCLAW_HOME` env var instead of
filesystem links, so exFAT, FAT32, NTFS, ext4, and APFS all behave
identically. Skills and MCP servers that use absolute paths into the drive
will follow the drive letter / mount point.
</details>

<details>
<summary><strong>macOS: "<i>cannot be opened because the developer cannot be verified</i>"</strong></summary>

The setup script automatically runs `xattr -dr com.apple.quarantine` on the
binary. If Gatekeeper still blocks it, run:

```bash
xattr -dr com.apple.quarantine "$(pwd)"
```

from inside the portable folder, then relaunch.
</details>

<details>
<summary><strong>Gateway shows "Stopped" even though I started it</strong></summary>

The launcher detects gateway state by calling `picoclaw status`. If your
gateway is bound to a non-default port, that probe still works but the menu
label assumes `127.0.0.1:18790`. Use `picoclaw status` from a shell to query
the real address.
</details>

<details>
<summary><strong>The drive runs slowly on USB 2.0</strong></summary>

PicoClaw boots in &lt;1 s; slow drives mostly hurt session log writes and
skill installs. Either upgrade to a USB 3.0+ stick / external SSD, or store
sessions on the host with `PICOCLAW_HOME=/local/path picoclaw agent`.
</details>

---

## 🆚 Comparison vs the Hermes Wrapper

| Aspect | Hermes Portable | PicoClaw Portable |
| ------ | --------------- | ----------------- |
| Runtime | Python + Node + uv + venv (~700 MB) | Single static Go binary |
| First-run download | ~600 MB | ~20 MB |
| Cold-start time | seconds | sub-second |
| Memory at idle | ~200+ MB | &lt;10 MB |
| Source code on drive | yes (cloned) | no (binary only) |
| Verification | none | SHA256 per platform |
| Update path | `git pull` + reinstall | bump `release.config` + `--force` |

Both wrappers share the same project layout, menu UX, and reset flow, so the
muscle memory transfers cleanly between them.

---

## 📝 Credits

- **[PicoClaw](https://github.com/sipeed/picoclaw)** — Tiny, fast, deployable anywhere. Go-based agent by [Sipeed](https://sipeed.com/) and 200+ contributors.
- **[NanoBot](https://github.com/HKUDS/nanobot)** — The architectural inspiration for PicoClaw.
- **[Hermes Portable](../Hermes-USB-Portable/)** — Sibling wrapper this one is patterned after.

This repository is an unofficial portable launcher and is not affiliated with
Sipeed. The PicoClaw name and trademarks belong to their respective owners.

---

## 📜 License

This wrapper is released under the [MIT License](LICENSE). The PicoClaw binary
it downloads is also MIT-licensed by Sipeed; consult the
[upstream LICENSE](https://github.com/sipeed/picoclaw/blob/main/LICENSE) for
its terms.

## 🔐 Security

To report a vulnerability in this wrapper, see [SECURITY.md](SECURITY.md). For
issues inside PicoClaw itself, report upstream at
[sipeed/picoclaw](https://github.com/sipeed/picoclaw/security).

## 🤝 Contributing

PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the development
workflow, and [CHANGELOG.md](CHANGELOG.md) for the release history.
