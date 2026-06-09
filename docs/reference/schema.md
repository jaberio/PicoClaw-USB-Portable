---
layout: default
title: Configuration Schema Reference
---

# 📋 Configuration Schema Reference

Technical reference for `scripts/config.schema.json` - the single source of truth.

---

## Schema Overview

The configuration schema serves as the central repository for all PicoClaw settings:

```json
{
  "name": "picoclaw-config",
  "version": "1.0",
  "description": "Central configuration schema for PicoClaw launcher",
  "defaults": { ... },
  "providers": { ... },
  "menu_items": { ... }
}
```

---

## Defaults Section

### Structure

```json
{
  "defaults": {
    "api_keys": {},
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
      "retention_days": 30,
      "auto_cleanup": true
    },
    "gateway": {
      "host": "127.0.0.1",
      "port": 18790,
      "enable_cors": false
    }
  }
}
```

### Fields

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `api_keys` | object | {} | Storage for API keys by provider |
| `default_agent.provider` | string | "openai" | Which provider to use by default |
| `default_agent.model_name` | string | "gpt-4o" | Default model for provider |
| `default_agent.temperature` | number | 0.7 | Model creativity (0-1) |
| `default_agent.max_tokens` | number | 4096 | Max response length |
| `channels` | object | {} | Communication channels config |
| `skills` | array | [] | Enabled skills list |
| `memory.type` | string | "sqlite" | Memory storage type |
| `memory.retention_days` | number | 30 | How long to keep history |
| `gateway.host` | string | "127.0.0.1" | API gateway host |
| `gateway.port` | number | 18790 | API gateway port |

### Usage

When creating new config:
```bash
launch.bat --init-config
# Creates data/config.json with these defaults
```

When checking defaults:
```bash
jq '.defaults' scripts/config.schema.json
```

---

## Providers Section

### Structure

```json
{
  "providers": {
    "<provider_id>": {
      "name": "<Display Name>",
      "keyPrefix": "<Key Pattern>",
      "defaultModels": ["<model1>", "<model2>", ...]
    }
  }
}
```

### Available Providers

#### OpenAI

```json
{
  "openai": {
    "name": "OpenAI",
    "keyPrefix": "sk-proj-",
    "defaultModels": [
      "gpt-4o",
      "gpt-4o-mini",
      "gpt-4-turbo"
    ]
  }
}
```

#### Anthropic (Claude)

```json
{
  "anthropic": {
    "name": "Anthropic",
    "keyPrefix": "sk-ant-",
    "defaultModels": [
      "claude-opus-4-1",
      "claude-3-5-sonnet",
      "claude-3-5-haiku"
    ]
  }
}
```

#### DeepSeek

```json
{
  "deepseek": {
    "name": "DeepSeek",
    "keyPrefix": "sk-",
    "defaultModels": [
      "deepseek-v3",
      "deepseek-chat"
    ]
  }
}
```

#### Groq

```json
{
  "groq": {
    "name": "Groq",
    "keyPrefix": "gsk_",
    "defaultModels": [
      "mixtral-8x7b-32768",
      "llama2-70b-4096"
    ]
  }
}
```

#### Google Gemini

```json
{
  "gemini": {
    "name": "Google Gemini",
    "keyPrefix": "AIza",
    "defaultModels": [
      "gemini-1.5-pro",
      "gemini-1.5-flash"
    ]
  }
}
```

#### HuggingFace

```json
{
  "huggingface": {
    "name": "HuggingFace",
    "keyPrefix": "hf_",
    "defaultModels": [
      "meta-llama/Llama-2-70b-chat-hf",
      "mistralai/Mistral-7B"
    ]
  }
}
```

#### Ollama (Local)

```json
{
  "ollama": {
    "name": "Ollama",
    "keyPrefix": "http://",
    "defaultModels": [
      "llama2",
      "mistral",
      "neural-chat"
    ]
  }
}
```

### Query Providers

View all providers:
```bash
jq '.providers | keys' scripts/config.schema.json
# Output: ["openai", "anthropic", "deepseek", "groq", "gemini", "huggingface", "ollama"]
```

View specific provider:
```bash
jq '.providers.openai' scripts/config.schema.json
```

View models for provider:
```bash
jq '.providers.openai.defaultModels[]' scripts/config.schema.json
```

---

## Menu Items Section

### Structure

```json
{
  "menu_items": {
    "main": [...],
    "configuration": [...],
    "advanced": [...]
  }
}
```

### Menu Item Format

```json
{
  "id": 1,
  "label": "Menu Item Label",
  "hint": "Short description"
}
```

### Main Menu

```json
{
  "main": [
    {
      "id": 1,
      "label": "Start PicoClaw chat",
      "hint": "Interactive agent conversation"
    },
    {
      "id": 2,
      "label": "Onboard / Reconfigure",
      "hint": "Set API keys, choose provider"
    },
    {
      "id": 3,
      "label": "Start gateway",
      "hint": "API mode on 127.0.0.1:18790"
    },
    {
      "id": 4,
      "label": "Configuration",
      "hint": "Quick setup options"
    },
    {
      "id": 5,
      "label": "Advanced options",
      "hint": "Gateway, skills, memory"
    },
    {
      "id": 6,
      "label": "Exit",
      "hint": "Quit launcher"
    }
  ]
}
```

### Configuration Menu

```json
{
  "configuration": [
    {
      "id": 1,
      "label": "Initialize configuration",
      "hint": "Create new config from defaults"
    },
    {
      "id": 2,
      "label": "Set API key",
      "hint": "Add or update provider key"
    },
    {
      "id": 3,
      "label": "Set default model",
      "hint": "Choose which model to use"
    },
    {
      "id": 4,
      "label": "View current config",
      "hint": "Show active settings"
    },
    {
      "id": 5,
      "label": "Back to main menu",
      "hint": "Return to main menu"
    }
  ]
}
```

### Advanced Menu

```json
{
  "advanced": [
    {
      "id": 1,
      "label": "Enable gateway mode",
      "hint": "Run API server"
    },
    {
      "id": 2,
      "label": "Configure memory",
      "hint": "History & workspace settings"
    },
    {
      "id": 3,
      "label": "Manage skills",
      "hint": "Enable/disable capabilities"
    },
    ...
  ]
}
```

### Query Menus

View all menu items:
```bash
jq '.menu_items | keys' scripts/config.schema.json
```

View main menu:
```bash
jq '.menu_items.main[]' scripts/config.schema.json
```

View specific menu item:
```bash
jq '.menu_items.main[0]' scripts/config.schema.json
```

---

## Complete Schema Example

```json
{
  "name": "picoclaw-config",
  "version": "1.0",
  "description": "Central configuration schema for PicoClaw launcher",
  
  "defaults": {
    "api_keys": {},
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
      "retention_days": 30,
      "auto_cleanup": true
    },
    "gateway": {
      "host": "127.0.0.1",
      "port": 18790,
      "enable_cors": false
    }
  },
  
  "providers": {
    "openai": {
      "name": "OpenAI",
      "keyPrefix": "sk-proj-",
      "defaultModels": ["gpt-4o", "gpt-4o-mini"]
    },
    "anthropic": {
      "name": "Anthropic",
      "keyPrefix": "sk-ant-",
      "defaultModels": ["claude-opus-4-1"]
    }
  },
  
  "menu_items": {
    "main": [
      { "id": 1, "label": "Start PicoClaw chat", "hint": "..." },
      { "id": 2, "label": "Onboard / Reconfigure", "hint": "..." }
    ]
  }
}
```

---

## How Helpers Use the Schema

### Windows (config-helper.ps1)

```powershell
# Load schema
$schema = Get-Content $SCHEMA_PATH | ConvertFrom-Json

# Get defaults
$DEFAULT_CONFIG = $schema.defaults

# Validate provider
$provider_def = $schema.providers[$Provider]

# Get models
$models = $schema.providers[$Provider].defaultModels
```

### Unix (config-helper.sh)

```bash
# Load schema
load_schema() {
    jq . "$SCHEMA_PATH"
}

# Get defaults
jq '.defaults' "$SCHEMA_PATH"

# Validate provider
jq ".providers.$provider" "$SCHEMA_PATH"

# Get models
jq ".providers.$provider.defaultModels[]" "$SCHEMA_PATH"
```

---

## Benefits of Schema-Driven Approach

✅ **Single Source of Truth**
- Change once, updates everywhere
- No inconsistencies

✅ **Easy Extensibility**
- Add provider: 10 seconds
- Add menu item: 10 seconds
- Add default: 10 seconds

✅ **Consistency**
- Same defaults always applied
- Same providers available everywhere
- Same menus rendered

✅ **Documentation**
- Schema IS the documentation
- Always in sync

✅ **Maintainability**
- Reduced maintenance burden
- Fewer sync points
- Lower technical debt

---

## Adding New Provider

### Step 1: Edit config.schema.json

```json
{
  "providers": {
    "new_provider": {
      "name": "New Provider Name",
      "keyPrefix": "np_",
      "defaultModels": ["model1", "model2"]
    }
  }
}
```

### Step 2: That's it! ✅

The new provider is now:
- Available in `--set-api-key`
- Supported in all launchers
- Validated in helpers
- Documented in schema

---

## Validation

### Check Schema Syntax

```bash
# Windows
Get-Content scripts/config.schema.json | ConvertFrom-Json

# Unix
jq . scripts/config.schema.json
```

### Check Provider Exists

```bash
jq '.providers | has("openai")' scripts/config.schema.json
```

### Check Default Config Valid

```bash
jq '.defaults' scripts/config.schema.json | jq empty
```

---

## Related Files

- **Usage:** [Configuration Guide →](../guides/configuration.md)
- **Commands:** [Command Reference →](commands.md)
- **Providers:** [Provider Reference →](providers.md)
- **Architecture:** [Architecture Docs →](../technical/architecture.md)

---

*Last updated: June 9, 2026*
