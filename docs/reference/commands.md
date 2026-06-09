---
layout: default
title: CLI Command Reference
---

# 📖 Command Reference

All CLI commands and options for PicoClaw launcher.

---

## Quick Reference

| Command | Effect | Platforms |
|---------|--------|-----------|
| `launch` | Start interactive chat | Both |
| `--init-config` | Create new configuration | Both |
| `--set-api-key` | Add/update API key | Both |
| `--set-model` | Set default model | Both |
| `--show-config` | Display current config | Both |
| `--help-config` | Show config help | Both |

---

## Configuration Commands

### Initialize Configuration

Creates a new `data/config.json` with default settings.

```bash
# Windows
launch.bat --init-config

# Unix/Linux/macOS
./launch.sh --init-config
```

**Output:**
```
Configuration initialized at data/config.json
Defaults loaded from scripts/config.schema.json
Ready to add API keys
```

**When to use:**
- First time setup
- Reset configuration to defaults
- Migrate from old config

---

### Set API Key

Add or update an API key for a provider.

```bash
# Windows
launch.bat --set-api-key <provider> "<key>"

# Unix/Linux/macOS
./launch.sh --set-api-key <provider> "<key>"
```

**Supported Providers:**
- `openai` - OpenAI API (ChatGPT, GPT-4, etc.)
- `anthropic` - Anthropic API (Claude)
- `deepseek` - DeepSeek API
- `groq` - Groq API (fast inference)
- `gemini` - Google Gemini API
- `huggingface` - HuggingFace API
- `ollama` - Local Ollama instance

**Examples:**

```bash
# OpenAI
launch.bat --set-api-key openai "sk-proj-abc123..."

# Anthropic (Claude)
launch.bat --set-api-key anthropic "sk-ant-..."

# Local Ollama
launch.bat --set-api-key ollama "http://localhost:11434"

# Using env var
$key = $env:OPENAI_API_KEY
launch.bat --set-api-key openai $key
```

**Validation:**
- ✅ Key format validated against schema
- ✅ Helpful hints if format seems wrong
- ✅ Stored in `data/config.json`

---

### Set Default Model

Choose which AI model to use by default.

```bash
# Windows
launch.bat --set-model <model_name>

# Unix/Linux/macOS
./launch.sh --set-model <model_name>
```

**Available Models by Provider:**

**OpenAI:**
```bash
launch.bat --set-model "gpt-4o"            # Flagship model
launch.bat --set-model "gpt-4o-mini"       # Faster & cheaper
launch.bat --set-model "gpt-4-turbo"       # Previous flagship
```

**Anthropic (Claude):**
```bash
launch.bat --set-model "claude-opus-4-1"   # Most capable
launch.bat --set-model "claude-3-5-sonnet" # Balanced
launch.bat --set-model "claude-3-5-haiku"  # Fast & cheap
```

**DeepSeek:**
```bash
launch.bat --set-model "deepseek-v3"
launch.bat --set-model "deepseek-chat"
```

**Groq (Lightning fast):**
```bash
launch.bat --set-model "mixtral-8x7b-32768"
launch.bat --set-model "llama2-70b-4096"
```

**Google Gemini:**
```bash
launch.bat --set-model "gemini-1.5-pro"
launch.bat --set-model "gemini-1.5-flash"
```

**HuggingFace:**
```bash
launch.bat --set-model "meta-llama/Llama-2-7b"
launch.bat --set-model "mistralai/Mistral-7B"
```

**Ollama (Local):**
```bash
launch.bat --set-model "llama2"
launch.bat --set-model "mistral"
launch.bat --set-model "neural-chat"
```

---

### Show Configuration

Display current settings from `data/config.json`.

```bash
# Windows
launch.bat --show-config

# Unix/Linux/macOS
./launch.sh --show-config
```

**Output Example:**
```json
{
  "api_keys": {
    "openai": "sk-proj-***"
  },
  "default_agent": {
    "provider": "openai",
    "model_name": "gpt-4o"
  },
  "temperature": 0.7
}
```

**Use cases:**
- Verify settings are correct
- Check which provider is active
- Debug configuration issues

---

### Configuration Help

Show help text for configuration options.

```bash
# Windows
launch.bat --help-config

# Unix/Linux/macOS
./launch.sh --help-config
```

**Output:**
Detailed help for:
- Supported providers
- Command syntax
- Configuration options
- Troubleshooting

---

## Interactive Commands

### Main Menu

Start interactive chat and access menus:

```bash
launch.bat
# or
./launch.sh
```

**Main Menu Options:**
```
[1] Start PicoClaw chat          → Interactive AI conversation
[2] Onboard / Reconfigure        → Add API keys, choose provider
[3] Start gateway                → API mode on localhost:18790
[4] Configuration                → Quick setup options
[5] Advanced options             → Gateway, skills, memory
[6] Exit                         → Quit launcher
```

### Configuration Menu (Option [4])

Inside launcher, select option 4 for quick setup:

```
Configuration
  [1] Initialize configuration
  [2] Set API key
  [3] Set default model
  [4] View current config
  [5] Back to main menu
```

---

## Advanced Options

### Set Configuration Path

Use custom config location:

```bash
# Windows (PowerShell)
$env:PICOCLAW_CONFIG = "C:\custom\path\config.json"
launch.bat

# Unix/Linux/macOS (Bash)
export PICOCLAW_CONFIG="/custom/path/config.json"
./launch.sh
```

---

### Environment Variable Overrides

Override config with environment variables:

```bash
# Windows (PowerShell)
$env:PICOCLAW_OPENAI_KEY = "sk-..."
$env:PICOCLAW_DEFAULT_MODEL = "gpt-4o"
$env:PICOCLAW_TEMPERATURE = "0.5"

# Unix/Linux/macOS (Bash)
export PICOCLAW_OPENAI_KEY="sk-..."
export PICOCLAW_DEFAULT_MODEL="gpt-4o"
export PICOCLAW_TEMPERATURE="0.5"
```

**Supported Variables:**
- `PICOCLAW_CONFIG` - Config file path
- `PICOCLAW_<PROVIDER>_KEY` - API key for provider
- `PICOCLAW_DEFAULT_MODEL` - Default model
- `PICOCLAW_TEMPERATURE` - Model temperature (0-1)

---

### Batch/Script Mode

Use in scripts and automation:

```bash
# Initialize fresh config
launch.bat --init-config

# Set API key from env var
launch.bat --set-api-key openai $env:OPENAI_KEY

# Set model
launch.bat --set-model "gpt-4o-mini"

# Verify setup
launch.bat --show-config

# Start chat
launch.bat
```

---

## Examples

### First-Time Setup

```bash
# Step 1: Initialize
launch.bat --init-config

# Step 2: Add API key
launch.bat --set-api-key openai "sk-proj-..."

# Step 3: Choose model
launch.bat --set-model "gpt-4o-mini"

# Step 4: Start chatting
launch.bat
```

### Switch Providers Mid-Session

Inside launcher menu:
1. Select [4] Configuration
2. Select [2] Set API key
3. Select [3] Set default model
4. Select [1] to start chatting

### Use Multiple Providers

```bash
# Set primary provider
launch.bat --set-api-key openai "sk-..."
launch.bat --set-model "gpt-4o"

# Add backup provider
launch.bat --set-api-key anthropic "sk-ant-..."

# Use first provider
launch.bat

# To use Claude later:
# 1. Inside launcher, go to Configuration
# 2. Set API key to claude
# 3. Set model to claude-opus-4-1
```

### Automated CI/CD Setup

```bash
#!/bin/bash
# CI/CD automation script

./launch.sh --init-config
./launch.sh --set-api-key deepseek $DEEPSEEK_API_KEY
./launch.sh --set-model "deepseek-v3"

# Run batch queries
echo "Hello" | ./launch.sh
echo "How are you?" | ./launch.sh
```

---

## Troubleshooting Commands

### Check Configuration File

```bash
# Windows
type data\config.json

# Unix
cat data/config.json
```

### Validate JSON

```bash
# Windows (PowerShell)
Get-Content data\config.json | ConvertFrom-Json

# Unix
jq . data/config.json
```

### Check Schema

```bash
# View available providers
jq '.providers | keys' scripts/config.schema.json

# View available models
jq '.providers.openai.defaultModels' scripts/config.schema.json

# View defaults
jq '.defaults' scripts/config.schema.json
```

---

## Command Summary

**Configuration (First Time):**
```bash
launch.bat --init-config
launch.bat --set-api-key openai "sk-..."
launch.bat --set-model "gpt-4o"
launch.bat --show-config
```

**Usage (Regular):**
```bash
launch.bat              # Start interactive
launch.bat --show-config # Check settings
```

**Maintenance:**
```bash
launch.bat --help-config    # Get help
launch.bat --init-config    # Reset config
```

---

**See Also:**
- [Quick Start Guide →](../guides/quick-start.md)
- [Configuration Guide →](../guides/configuration.md)
- [Provider Reference →](providers.md)
- [Troubleshooting →](../guides/troubleshooting.md)

---

*Last updated: June 9, 2026*
