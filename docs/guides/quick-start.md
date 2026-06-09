---
layout: default
title: Quick Start Guide
---

# ⚡ Quick Start - 30 Seconds to Running

Get PicoClaw configured and running in under 30 seconds.

## Windows

### Step 1: Initialize Config (10 seconds)
```batch
launch.bat --init-config
```

Output:
```
✓ Created config.json from schema defaults
Next: Run 'picoclaw onboard' or set API keys with -SetApiKey
```

### Step 2: Add Your API Key (10 seconds)
Replace `sk-proj-your-key-here` with your actual OpenAI key:

```batch
launch.bat --set-api-key openai "sk-proj-your-key-here"
```

Output:
```
✓ API key set for provider: openai
```

### Step 3: (Optional) Choose a Model (5 seconds)
```batch
launch.bat --set-model "gpt-4o"
```

### Step 4: Start Using PicoClaw!
```batch
launch.bat
```

Select `[1] Start PicoClaw chat` and begin.

---

## macOS / Linux

### Step 1: Initialize Config
```bash
./launch.sh --init-config
```

### Step 2: Add Your API Key
```bash
./launch.sh --set-api-key openai "sk-proj-your-key-here"
```

### Step 3: (Optional) Choose a Model
```bash
./launch.sh --set-model "gpt-4o"
```

### Step 4: Start Using!
```bash
./launch.sh
```

---

## That's It! 🎉

Your PicoClaw is now configured and ready to use.

### Next Steps

- **→ [Full Configuration Guide](configuration.md)** - Setup other providers (Claude, DeepSeek, etc.)
- **→ [Examples](examples.md)** - See what you can do
- **→ [Troubleshooting](troubleshooting.md)** - If something doesn't work

---

## Alternative: Interactive Menu

If you prefer the interactive menu:

```batch
launch.bat
```

Then select:
- `[4] Configuration` → `[1] Initialize config`
- `[4] Configuration` → `[2] Set API key`
- `[4] Configuration` → `[3] Set default model`

---

## Common Providers

### OpenAI / ChatGPT
```bash
launch.bat --set-api-key openai "sk-proj-..."
launch.bat --set-model "gpt-4o"
```

### Anthropic / Claude
```bash
launch.bat --set-api-key anthropic "sk-ant-..."
launch.bat --set-model "claude-opus-4-1"
```

### DeepSeek
```bash
launch.bat --set-api-key deepseek "sk-..."
launch.bat --set-model "deepseek-reasoner"
```

### Groq
```bash
launch.bat --set-api-key groq "gsk_..."
launch.bat --set-model "mixtral-8x7b-32768"
```

---

## Troubleshooting

### "API key not working"
→ See [Troubleshooting Guide](troubleshooting.md#api-key-not-working)

### "Config not found"
→ Run `launch.bat --init-config` first

### "Need to change provider"
→ Use `launch.bat --set-api-key <provider> <key>`

---

**Next:** [Full Configuration Guide →](configuration.md)

---

*Last updated: June 9, 2026*
