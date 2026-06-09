---
layout: default
title: Configuration Guide
---

# ⚙️ Configuration Guide

Complete guide to configuring PicoClaw with all supported providers and options.

---

## Quick Setup (All Platforms)

### 1. Initialize Config

**Windows:**
```powershell
cd scripts
.\config-helper.ps1 -InitConfig
```

**macOS / Linux:**
```bash
cd scripts
./config-helper.sh --init-config
```

This creates `data/config.json` from template with all common providers pre-configured.

---

## Set API Keys

### OpenAI / ChatGPT

**Windows:**
```powershell
.\config-helper.ps1 -SetApiKey "openai" "sk-proj-your-key-here"
```

**Unix:**
```bash
./config-helper.sh --set-api-key openai "sk-proj-your-key-here"
```

### Anthropic / Claude

**Windows:**
```powershell
.\config-helper.ps1 -SetApiKey "anthropic" "sk-ant-your-key-here"
```

**Unix:**
```bash
./config-helper.sh --set-api-key anthropic "sk-ant-your-key-here"
```

### DeepSeek

**Windows:**
```powershell
.\config-helper.ps1 -SetApiKey "deepseek" "sk-your-key-here"
```

**Unix:**
```bash
./config-helper.sh --set-api-key deepseek "sk-your-key-here"
```

### Groq

**Windows:**
```powershell
.\config-helper.ps1 -SetApiKey "groq" "gsk_your-key-here"
```

**Unix:**
```bash
./config-helper.sh --set-api-key groq "gsk_your-key-here"
```

### Other Providers (Gemini, HuggingFace, Ollama)

Replace `provider` and `key` with your values:

**Windows:**
```powershell
.\config-helper.ps1 -SetApiKey "gemini" "AIza..."
.\config-helper.ps1 -SetApiKey "huggingface" "hf_..."
.\config-helper.ps1 -SetApiKey "ollama" "http://localhost:11434"
```

**Unix:**
```bash
./config-helper.sh --set-api-key gemini "AIza..."
./config-helper.sh --set-api-key huggingface "hf_..."
./config-helper.sh --set-api-key ollama "http://localhost:11434"
```

---

## Set Default Model

After adding API keys, choose which model PicoClaw uses by default:

**Windows:**
```powershell
.\config-helper.ps1 -SetModel "gpt-4o"
```

**Unix:**
```bash
./config-helper.sh --set-model "gpt-4o"
```

### Common Models

| Provider | Model | Tier | Speed | Cost |
|----------|-------|------|-------|------|
| OpenAI | `gpt-4o` | Latest | Fast | $ |
| OpenAI | `gpt-4o-mini` | Latest | Very Fast | ¢ |
| Anthropic | `claude-opus-4-1` | Latest | Slow | $$ |
| Anthropic | `claude-3-5-sonnet` | Fast | Fast | $ |
| Anthropic | `claude-3-5-haiku` | Fast | Very Fast | ¢ |
| DeepSeek | `deepseek-reasoner` | Latest | Slow | $ |
| DeepSeek | `deepseek-chat` | Latest | Fast | ¢ |
| Groq | `mixtral-8x7b-32768` | Fast | Very Fast | Free |
| Ollama | `llama2` | Local | Depends | Free |

---

## View Current Configuration

**Windows:**
```powershell
.\config-helper.ps1 -ShowConfig
```

**Unix:**
```bash
./config-helper.sh --show-config
```

Output shows your current setup with all configured providers and settings.

---

## Via Interactive Menu

Alternative to command-line:

1. Run launcher: `launch.bat` or `./launch.sh`
2. Select `[4] Configuration`
3. Choose option:
   - `[1] Initialize config` - Create from template
   - `[2] Set API key` - Add/update key interactively
   - `[3] Set default model` - Choose model interactively
   - `[4] View config` - Display current settings

---

## Manual Configuration

Edit directly in your text editor:

**Windows:**
```powershell
notepad ..\data\config.json
```

**Unix:**
```bash
$EDITOR ../data/config.json
```

### Configuration Structure

```json
{
  "api_keys": {
    "openai": "sk-proj-...",
    "anthropic": "sk-ant-...",
    "deepseek": "sk-...",
    "groq": "gsk_...",
    "gemini": "AIza..."
  },
  "default_agent": {
    "provider": "openai",
    "model_name": "gpt-4o",
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "channels": {},
  "skills": [],
  "memory": {
    "type": "sqlite",
    "retention_days": 30
  },
  "gateway": {
    "host": "127.0.0.1",
    "port": 18790
  }
}
```

---

## Environment Variables (Optional)

Override API keys using environment variables (useful for CI/CD):

**Unix / macOS:**
```bash
export PICOCLAW_OPENAI_KEY="sk-proj-..."
export PICOCLAW_ANTHROPIC_KEY="sk-ant-..."
./launch.sh agent
```

**Windows PowerShell:**
```powershell
$env:PICOCLAW_OPENAI_KEY="sk-proj-..."
$env:PICOCLAW_ANTHROPIC_KEY="sk-ant-..."
.\launch.bat
```

---

## Switch Providers

### From OpenAI to Claude

```bash
# Windows
launch.bat --set-api-key anthropic "sk-ant-..."
launch.bat --set-model "claude-opus-4-1"

# Unix
./launch.sh --set-api-key anthropic "sk-ant-..."
./launch.sh --set-model "claude-opus-4-1"
```

### From Claude to DeepSeek

```bash
# Windows
launch.bat --set-api-key deepseek "sk-..."
launch.bat --set-model "deepseek-reasoner"

# Unix
./launch.sh --set-api-key deepseek "sk-..."
./launch.sh --set-model "deepseek-reasoner"
```

---

## Configuration Templates

### Minimal Setup (OpenAI only)
```json
{
  "api_keys": {
    "openai": "sk-proj-..."
  },
  "default_agent": {
    "provider": "openai",
    "model_name": "gpt-4o"
  }
}
```

### Multi-Provider Setup
```json
{
  "api_keys": {
    "openai": "sk-proj-...",
    "anthropic": "sk-ant-...",
    "deepseek": "sk-...",
    "groq": "gsk_..."
  },
  "default_agent": {
    "provider": "openai",
    "model_name": "gpt-4o"
  }
}
```

### Advanced Setup
```json
{
  "api_keys": { ... },
  "default_agent": {
    "provider": "openai",
    "model_name": "gpt-4o",
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "channels": {
    "telegram": { "enabled": true, "token": "..." }
  },
  "skills": ["skill1", "skill2"],
  "memory": {
    "type": "sqlite",
    "retention_days": 30
  },
  "gateway": {
    "host": "0.0.0.0",
    "port": 18790
  }
}
```

---

## Supported Providers

PicoClaw supports 30+ LLM providers through OpenAI-compatible APIs:

- ✅ OpenAI (GPT-4, GPT-4o)
- ✅ Anthropic (Claude)
- ✅ DeepSeek
- ✅ Groq
- ✅ Google Gemini
- ✅ HuggingFace
- ✅ Ollama (local)
- ✅ And 23+ more...

[Full provider list →](../reference/providers.md)

---

## Troubleshooting

### API key not working
- Verify key is correct (watch for extra spaces)
- Ensure key hasn't expired
- Check provider supports the model you selected

### Config not found
Run `launch.bat --init-config` first

### Need to add multiple keys
```bash
launch.bat --set-api-key openai "sk-..."
launch.bat --set-api-key anthropic "sk-ant-..."
launch.bat --set-api-key deepseek "sk-..."
```

### Model not available
Run `launch.bat model` to see available models for your provider

---

## Security Best Practices

✅ Store config.json in `data/` (outside git)  
✅ Add `data/config.json` to `.gitignore`  
✅ Use environment variables for CI/CD  
✅ Never commit API keys to git  
✅ Keep USB drive encrypted if using portable setup  
✅ Rotate keys regularly  

---

**Next:** [Examples & Use Cases →](examples.md)

---

*Last updated: June 9, 2026*
