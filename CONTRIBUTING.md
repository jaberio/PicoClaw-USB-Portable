# Contributing

Thanks for your interest in improving the PicoClaw portable launcher.
This wrapper is intentionally small, so most useful contributions are
sharp focused changes rather than big refactors.

## Quick rules

- Keep the wrapper opinion-free about *what* PicoClaw does. We pin a
  release, verify it, set env vars, and get out of the way.
- No new runtime dependencies. The whole point is "binary + scripts".
- Cross-platform parity. Anything you change for Windows should land
  for Unix in the same PR (and vice versa) unless platform-specific.
- Always pin SHA256s. We never download anything we have not hashed.

## What good PRs look like

- **Bumping the release pin.** Update `scripts/release.config` with
  the new `VERSION=` line and the matching `SHA256_*` lines. Verify
  the hashes from the official GitHub release page (see
  [`SECURITY.md`](SECURITY.md) for the verification command). Add a
  short note to `CHANGELOG.md`.
- **Adding a platform.** Add the asset name plus SHA256 to
  `release.config`, extend `detect_platform` in both setup scripts,
  and add an entry to the README support table.
- **Fixing a launcher bug.** Reproduce, fix, add a manual repro to
  the PR description, and run the linters described below.
- **Improving docs.** README typos, FAQ entries, troubleshooting
  guides — all welcome.

## Local development

```cmd
git clone https://github.com/jaberio/PicoClaw-USB-Portable.git
cd PicoClaw-USB-Portable
```

The shell scripts have no build step. Run them in place.

### Lint and parse-check before submitting

```powershell
# Windows: parse all PowerShell files
powershell -NoProfile -ExecutionPolicy Bypass -File .github\scripts\lint.ps1
```

```bash
# Unix: parse all bash scripts
bash -n launch.sh
bash -n scripts/setup-unix.sh
bash -n scripts/reset-unix.sh
```

Optional but recommended:

- [`shellcheck`](https://www.shellcheck.net/) over `*.sh` files.
- [`PSScriptAnalyzer`](https://learn.microsoft.com/powershell/utility-modules/psscriptanalyzer/overview)
  over `*.ps1` files.

### End-to-end smoke test

```cmd
:: Windows
rmdir /s /q .cache 2>nul
launch.bat version
launch.bat status
```

```bash
# macOS / Linux
rm -rf .cache
./launch.sh version
./launch.sh status
```

A clean run downloads the pinned binary, verifies its hash, extracts it,
and prints the version. If anything fails, that's a regression.

## Commit messages

Conventional Commits keeps the changelog easy to generate:

```
feat(setup-windows): add aarch64 fallback for the WoA preview channel
fix(launch): handle paths containing spaces in pass-through args
docs(readme): clarify exFAT compatibility
chore(release): pin v0.2.9
```

## Pull requests

- Open against `main`.
- Fill in the PR template (it's short, three checkboxes).
- Be patient. Reviews come from one maintainer.

## Code of conduct

Be kind. Disagreements about technical decisions are fine; ad hominem,
discrimination, or harassment are not. If something feels off, email
`jaberio@gmail.com`.

## License

By contributing you agree that your contribution is licensed under the
project's [MIT License](LICENSE).
