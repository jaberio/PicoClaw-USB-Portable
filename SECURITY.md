# Security Policy

This project is a portable launcher wrapper around the upstream PicoClaw
binary. The threat model below covers only the wrapper (download path,
extraction, environment setup); for issues inside PicoClaw itself, please
report to [sipeed/picoclaw](https://github.com/sipeed/picoclaw/security).

## Reporting a vulnerability

- **Email:** `jaberio@gmail.com`
- **GitHub:** open a [private security advisory](https://github.com/jaberio/PicoClaw-USB-Portable/security/advisories/new)

Please **do not** open a public issue for security findings. Aim for an
initial response within 5 business days.

When reporting, include:

1. A short description of the issue and impact.
2. Reproduction steps (commands, config snippets, OS).
3. Affected version (`scripts/release.config` `VERSION=` value).
4. Suggested fix or mitigation if you have one.

## Threat model and guarantees

### What this wrapper protects

- **Host filesystem isolation.** All PicoClaw state lives under `data/`
  on the portable drive via `PICOCLAW_HOME`. The launcher overrides
  `HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME` (and on
  Windows also `APPDATA`/`LOCALAPPDATA`) so child processes cannot
  silently write to the host profile.
- **Supply-chain integrity.** Every binary is downloaded from the
  official `github.com/sipeed/picoclaw/releases` URL and verified
  against a SHA256 hash pinned in `scripts/release.config` *before*
  extraction. A mismatch aborts the install.
- **Reproducible installs.** The release manifest is part of the
  repository. Anyone can audit which release is being shipped at any
  given commit.

### What this wrapper does not protect against

- Malicious or rogue PicoClaw releases. We pin a known-good hash, but
  if the upstream release itself is malicious, this wrapper will happily
  execute it. Review the upstream commit history when bumping versions.
- Local attackers with read access to the USB drive. Files under
  `data/` (especially `.security.yml`) contain credentials. Encrypt
  the drive (BitLocker / FileVault / VeraCrypt).
- Memory or runtime exploits inside the running PicoClaw process.
  Those are upstream concerns.
- Network-level MITM during the first download. We pin SHA256 to make
  this detectable; we do not perform certificate pinning.

## Verifying a release manually

You can independently verify the pinned hashes against the official release:

```powershell
# Windows (PowerShell)
$asset  = 'picoclaw_Windows_x86_64.zip'
$ver    = 'v0.2.8'
$url    = "https://github.com/sipeed/picoclaw/releases/download/$ver/$asset"
Invoke-WebRequest -Uri $url -OutFile $asset
(Get-FileHash -Algorithm SHA256 -Path $asset).Hash.ToLower()
```

```bash
# macOS / Linux
asset=picoclaw_Linux_x86_64.tar.gz
ver=v0.2.8
curl -fL -o "$asset" "https://github.com/sipeed/picoclaw/releases/download/$ver/$asset"
sha256sum "$asset"
```

Compare the resulting hash to the matching `SHA256_*` line in
`scripts/release.config`. They must match exactly.

## Disclosure timeline

- **Day 0** Report received.
- **Day 1–5** Acknowledge and triage.
- **Day 6–30** Develop and release fix. For wrapper bugs we aim for a
  single-day patch release; for upstream issues we coordinate with
  Sipeed.
- **Day 30+** After a fix is shipped, publish a security advisory with
  CVE if applicable, credit the reporter, and add a regression test if
  relevant.
