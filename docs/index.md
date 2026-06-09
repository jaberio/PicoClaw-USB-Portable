---
layout: default
title: PicoClaw Launcher Documentation
---

# 🦞 PicoClaw Portable Launcher

Ultra-efficient AI agent in a single folder. No installation, zero host pollution. Works on Windows, macOS, and Linux.

**[GitHub](https://github.com/jaberio/PicoClaw-USB-Portable) • [Releases](https://github.com/jaberio/PicoClaw-USB-Portable/releases)**

---

## 📖 Quick Navigation

### 🚀 Getting Started
- **[Quick Setup Guide →](guides/quick-start.md)** (30 seconds to configured)
- **[Configuration Guide →](guides/configuration.md)** (API keys, providers, models)

### 💡 Features & Improvements
- **[What's New →](guides/improvements.md)** (New CLI commands, menus, features)
- **[Feature Examples →](guides/examples.md)** (Use cases and scenarios)

### 🏗️ Technical & Architecture
- **[Architecture Overview →](technical/architecture.md)** (DRY design, no hardcoding)
- **[Refactoring Guide →](technical/refactoring.md)** (Before/after code examples)
- **[Delivery Summary →](technical/delivery.md)** (Complete list of improvements)

### 📚 Reference
- **[CLI Commands →](reference/commands.md)** (Full command reference)
- **[Troubleshooting →](guides/troubleshooting.md)** (Common issues & solutions)

---

## ⚡ Quick Start

### Windows

```batch
launch.bat --init-config
launch.bat --set-api-key openai "sk-proj-..."
launch.bat --set-model "gpt-4o"
launch.bat
```

### macOS / Linux

```bash
./launch.sh --init-config
./launch.sh --set-api-key openai "sk-proj-..."
./launch.sh --set-model "gpt-4o"
./launch.sh
```

---

## ✨ Key Features

✅ **30-second Setup** - CLI flags for instant configuration  
✅ **No Hardcoding** - Single source of truth (schema-driven)  
✅ **Easy Configuration** - CLI, interactive menu, or direct helpers  
✅ **Multiple Providers** - OpenAI, Claude, DeepSeek, Groq, and more  
✅ **Cross-Platform** - Windows, macOS, Linux identical behavior  
✅ **Default Commands** - All PicoClaw commands work seamlessly  
✅ **Portable** - USB drive ready, zero host pollution  
✅ **Well Documented** - Comprehensive guides and examples  

---

## 📊 What's Included

```
PicoClaw Launcher 1.1.0
├── launch.bat / launch.sh          Main launchers
├── scripts/
│   ├── config.schema.json          Central configuration
│   ├── config-helper.ps1           Windows config tool
│   ├── config-helper.sh            Unix config tool
│   └── ...setup & utilities
├── data/
│   ├── config.json                 User configuration
│   └── workspace/                  Sessions, memory, skills
└── docs/                           📍 Full documentation
```

---

## 🎯 Common Tasks

### Set up with OpenAI
```bash
launch.bat --set-api-key openai "sk-proj-abc123"
launch.bat --set-model "gpt-4o"
launch.bat  # Start using!
```

### Switch to Claude (Anthropic)
```bash
./launch.sh --set-api-key anthropic "sk-ant-xyz789"
./launch.sh --set-model "claude-opus-4-1"
```

### View Configuration
```bash
launch.bat --show-config
# or via menu: launch.bat → [4] Configuration → [4] View config
```

### Start Gateway (API mode)
```bash
launch.bat
# Select [3] Start gateway
# Runs on 127.0.0.1:18790
```

---

## 🔐 Security

- API keys stored in `data/config.json` (not in git, stays on your drive)
- Environment variable support for CI/CD
- Never hardcoded defaults that might leak
- Full control over what's configured locally

**→ [Security Best Practices](guides/security.md)**

---

## 🤝 Support

- **Issues?** Check [Troubleshooting](guides/troubleshooting.md)
- **Have a question?** See [FAQ](guides/faq.md)
- **Found a bug?** Report on [GitHub Issues](https://github.com/jaberio/PicoClaw-USB-Portable/issues)

---

## 📖 Documentation Structure

| Folder | Content |
|--------|---------|
| `guides/` | User guides, configuration, examples |
| `technical/` | Architecture, design, refactoring docs |
| `reference/` | API reference, commands, schemas |
| `assets/` | Diagrams, images, CSS |

---

## 🚀 Get Started Now

**→ [Read the Quick Start Guide](guides/quick-start.md)**

Or jump into:
- [Configuration (all platforms)](guides/configuration.md)
- [Examples & Use Cases](guides/examples.md)
- [Troubleshooting](guides/troubleshooting.md)

---

**Version:** 1.1.0  
**Status:** ✅ Production Ready  
**License:** MIT  
**Upstream:** [Sipeed PicoClaw](https://github.com/sipeed/picoclaw)

Last updated: June 9, 2026
