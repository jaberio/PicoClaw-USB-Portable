# PicoClaw Portable - Command Reference

The portable launcher (`launch.bat` on Windows, `launch.sh` on macOS/Linux)
wraps the official [PicoClaw](https://github.com/sipeed/picoclaw) Go binary,
points `PICOCLAW_HOME` and `PICOCLAW_CONFIG` at the drive's `data/` folder,
and exposes a small interactive menu. Every PicoClaw CLI subcommand is also
reachable directly through the launcher.

---

## Launcher Commands

### Windows (`launch.bat`)

| Command | What it does |
| ------- | ------------ |
| `launch.bat` | Open the interactive menu |
| `launch.bat agent` | Start interactive chat |
| `launch.bat agent -m "Hello"` | One-shot prompt |
| `launch.bat onboard` | Initialize config & workspace |
| `launch.bat gateway` | Start gateway on `127.0.0.1:18790` |
| `launch.bat status` | Print current status |
| `launch.bat version` | Show version info |
| `launch.bat model` | View or switch the default model |
| `launch.bat mcp list` | List configured MCP servers |
| `launch.bat skills list` | List installed skills |
| `launch.bat <any picoclaw subcommand>` | Pass-through (the `picoclaw` prefix is also accepted) |

### macOS / Linux (`launch.sh`)

| Command | What it does |
| ------- | ------------ |
| `./launch.sh` | Open the interactive menu |
| `./launch.sh agent` | Start interactive chat |
| `./launch.sh onboard` | Initialize config & workspace |
| `./launch.sh gateway` | Start gateway on `127.0.0.1:18790` |
| `./launch.sh status` | Print current status |
| `./launch.sh <any picoclaw subcommand>` | Pass-through (`picoclaw` prefix accepted) |

---

## Reset Scripts

Located in `scripts/`. Both prompt for `yes` before deleting anything.

### Windows
```powershell
cd scripts
.\reset-windows.ps1               # interactive menu
.\reset-windows.ps1 -Mode soft    # keep data/ (API keys, sessions, workspace)
.\reset-windows.ps1 -Mode full    # delete everything
```

### macOS / Linux
```bash
cd scripts
bash reset-unix.sh                # interactive
bash reset-unix.sh soft           # keep data/
bash reset-unix.sh full           # delete everything
```

---

## PicoClaw CLI Reference (selected)

These work via the launcher pass-through. Full list: `launch.bat help` or the
[upstream README](https://github.com/sipeed/picoclaw#cli-reference).

### Onboarding & config

```bash
picoclaw onboard           # guided setup
picoclaw status            # show current status
picoclaw version           # show version info
picoclaw model             # view or switch the default model
```

### Agent

```bash
picoclaw agent                          # interactive chat
picoclaw agent -m "summarize TODOs"     # one-shot prompt
```

### Gateway

```bash
picoclaw gateway                        # default 127.0.0.1:18790
PICOCLAW_GATEWAY_HOST=0.0.0.0 picoclaw gateway   # bind publicly (use a tunnel!)
```

### Channels (chat apps)

```bash
picoclaw auth weixin       # connect WeChat account via QR scan
```

PicoClaw supports 19+ channels (Telegram, Discord, WhatsApp, QQ, Slack,
Matrix, DingTalk, Feishu/Lark, LINE, WeCom, VK, IRC, OneBot, MQTT, MaixCam,
Pico, Pico Client, Microsoft Teams webhook, Slack webhook). All are
configured under `channel_list` in `data/config.json`. See the upstream
[Chat Apps guide](https://github.com/sipeed/picoclaw/blob/main/docs/guides/chat-apps.md)
for per-channel setup.

### MCP

```bash
picoclaw mcp list
picoclaw mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /tmp
picoclaw mcp test filesystem
picoclaw mcp edit
picoclaw mcp remove filesystem
```

### Cron / scheduled tasks

```bash
picoclaw cron list
picoclaw cron add ...
picoclaw cron disable <id>
picoclaw cron remove <id>
```

### Skills

```bash
picoclaw skills list
picoclaw skills install <skill-name>
```

### Migration & maintenance

```bash
picoclaw migrate           # upgrade older config formats
picoclaw auth login        # provider OAuth (e.g. GitHub Copilot)
```

---

## Environment Variables PicoClaw Honors

The launcher sets the first three for you. The rest are listed in case you
want to override behavior at the command line.

| Variable | What it does |
| -------- | ------------ |
| `PICOCLAW_HOME` | Base directory for all PicoClaw data (default `~/.picoclaw`). The launcher points this at `data/`. |
| `PICOCLAW_CONFIG` | Full path to `config.json`. The launcher pins this to `data/config.json`. |
| `PICOCLAW_BINARY` | Path to the picoclaw executable. The launcher pins this to the staged binary. |
| `PICOCLAW_GATEWAY_HOST` | Override gateway bind address (default `localhost`). |
| `PICOCLAW_LOG_LEVEL` | `debug`, `info`, `warn` (default), `error`, `fatal`. |
| `PICOCLAW_BUILTIN_SKILLS` | Override the built-in skills directory. |

Many other settings have a corresponding `PICOCLAW_*` env var; see the
upstream [Environment Variables docs](https://docs.picoclaw.io/configuration/environment-variables)
for the full list.

---

## File Locations (Portable)

| File | Path on the drive | Purpose |
| ---- | ----------------- | ------- |
| Binary | `.cache/runtimes/<platform>/picoclaw[.exe]` | Pinned PicoClaw release |
| Binary version | `.cache/runtimes/<platform>/version.txt` | Stamp from `release.config` |
| Setup flag | `.cache/runtimes/<platform>/ready.flag` | First-run completion marker |
| Original archive | `.cache/runtimes/<platform>/picoclaw_*.zip|tar.gz` | Cached for hash-verified reinstalls |
| Config | `data/config.json` | All PicoClaw settings (providers, channels, tools) |
| Security store | `data/.security.yml` | API keys, channel tokens (encrypted) |
| Workspace | `data/workspace/` | Skills, sessions, attachments, scratch |
| Release manifest | `scripts/release.config` | Single source of truth for version + SHA256 |
