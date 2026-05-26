# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-05-26

### Added
- First public release of the PicoClaw portable launcher.
- Cross-platform launcher (`launch.bat`, `launch.sh`) with an
  interactive menu, advanced submenu, and pass-through CLI mode.
- Pinned release manifest (`scripts/release.config`) covering Windows
  x86_64 and aarch64, macOS Intel and Apple Silicon, and Linux
  x86_64 / aarch64 / armv7 / armv6 / riscv64.
- SHA256-verified downloads with `Get-FileHash` plus `certutil`
  fallback on Windows, and `sha256sum` plus `shasum -a 256` fallback
  on Unix.
- Self-healing setup that re-downloads when the binary is missing or
  the manifest version drifts.
- Soft and full reset scripts (`scripts/reset-windows.ps1`,
  `scripts/reset-unix.sh`) with `yes` confirmation gates.
- `PICOCLAW_HOME` / `PICOCLAW_CONFIG` env-var redirect so `data/`
  works on every filesystem (NTFS, exFAT, FAT32, ext4, APFS) without
  symlinks or junctions.
- Verification utility (`scripts/verify-manifest.ps1` and
  `scripts/verify-manifest.sh`) that re-downloads every pinned asset
  and re-checks the hash.
- GitHub Actions CI that lint-parses all scripts and runs the
  manifest verifier on every pull request.
- Issue and pull request templates, plus a private security advisory
  flow documented in `SECURITY.md`.
- LICENSE (MIT), CONTRIBUTING, CODE_OF_CONDUCT, SECURITY policies.

### Notes
- Pinned PicoClaw release: `v0.2.8` (commit
  [`6e1fab8`](https://github.com/sipeed/picoclaw/commit/6e1fab80)).

[1.0.0]: https://github.com/jaberio/PicoClaw-USB-Portable/releases/tag/v1.0.0
