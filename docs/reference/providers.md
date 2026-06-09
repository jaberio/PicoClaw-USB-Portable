---
layout: default
title: AI Provider Reference
---

# 🔌 Provider Reference

Detailed information about all supported AI providers.

---

## Provider Compatibility Matrix

| Provider | Status | Best For | Key Format | Free Tier | Gateway |
|----------|--------|----------|-----------|-----------|---------|
| OpenAI (ChatGPT) | ✅ Active | General purpose | `sk-proj-*` | ⭐⭐⭐ | ✅ |
| Anthropic (Claude) | ✅ Active | Analysis, writing | `sk-ant-*` | ⭐⭐ | ✅ |
| DeepSeek | ✅ Active | Cost efficiency | `sk-*` | ⭐⭐⭐ | ✅ |
| Groq | ✅ Active | Speed | `gsk_*` | ⭐⭐⭐ | ✅ |
| Google Gemini | ✅ Active | Multimodal | `AIza*` | ⭐⭐⭐ | ✅ |
| HuggingFace | ✅ Active | Research | `hf_*` | ⭐⭐ | ✅ |
| Ollama (Local) | ✅ Active | Privacy | `http://localhost` | ✅ Free | ✅ |

---

## OpenAI

**Website:** https://platform.openai.com

### Getting an API Key

1. Visit https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Copy the key (starts with `sk-proj-`)
4. Keep it safe!

### Setting Up

```bash
launch.bat --set-api-key openai "sk-proj-abc123..."
launch.bat --set-model "gpt-4o"
launch.bat
```

### Recommended Models

| Model | Speed | Intelligence | Cost | Best For |
|-------|-------|--------------|------|----------|
| gpt-4o | ⚡⚡ | ⭐⭐⭐⭐⭐ | $$ | Complex tasks, coding |
| gpt-4o-mini | ⚡⚡⚡ | ⭐⭐⭐⭐ | $ | Quick answers, budget |
| gpt-4-turbo | ⚡ | ⭐⭐⭐⭐ | $$$ | Extended context |

### Pricing

- **gpt-4o:** $0.005/1K input, $0.015/1K output tokens
- **gpt-4o-mini:** $0.00015/1K input, $0.0006/1K output tokens
- **Free tier:** $5 credit (expires after 3 months)

### Documentation

- **API Docs:** https://platform.openai.com/docs/api-reference
- **Pricing:** https://openai.com/pricing
- **Status:** https://status.openai.com

---

## Anthropic (Claude)

**Website:** https://anthropic.com

### Getting an API Key

1. Visit https://console.anthropic.com
2. Sign up or log in
3. Click "Create Key" in API keys section
4. Copy the key (starts with `sk-ant-`)

### Setting Up

```bash
launch.bat --set-api-key anthropic "sk-ant-abc123..."
launch.bat --set-model "claude-opus-4-1"
launch.bat
```

### Recommended Models

| Model | Speed | Intelligence | Cost | Best For |
|-------|-------|--------------|------|----------|
| claude-opus-4-1 | ⚡ | ⭐⭐⭐⭐⭐ | $$$ | Complex analysis |
| claude-3-5-sonnet | ⚡⚡ | ⭐⭐⭐⭐ | $$ | Balanced choice |
| claude-3-5-haiku | ⚡⚡⚡ | ⭐⭐⭐ | $ | Quick tasks |

### Pricing

- **Opus 4.1:** $3/1M input, $15/1M output tokens
- **Sonnet 3.5:** $3/1M input, $15/1M output tokens
- **Haiku 3.5:** $0.80/1M input, $4/1M output tokens
- **Free tier:** Available with limited usage

### Features

- ✅ 200K context window
- ✅ Strong at reasoning
- ✅ Excellent at analysis
- ✅ Good for long documents

### Documentation

- **API Docs:** https://docs.anthropic.com
- **Pricing:** https://www.anthropic.com/pricing
- **Models:** https://docs.anthropic.com/claude/reference/getting-started-with-the-api

---

## DeepSeek

**Website:** https://deepseek.com

### Getting an API Key

1. Visit https://platform.deepseek.com
2. Sign up and verify
3. Create API key
4. Copy key (format: `sk-*`)

### Setting Up

```bash
launch.bat --set-api-key deepseek "sk-abc123..."
launch.bat --set-model "deepseek-v3"
launch.bat
```

### Recommended Models

| Model | Speed | Intelligence | Cost | Best For |
|-------|-------|--------------|------|----------|
| deepseek-v3 | ⚡⚡ | ⭐⭐⭐⭐⭐ | $ | Excellent value |
| deepseek-chat | ⚡⚡⚡ | ⭐⭐⭐ | $ | Quick responses |

### Pricing

- **Very affordable** - 50-80% cheaper than OpenAI
- **deepseek-v3:** $0.27/1M input, $1.1/1M output tokens
- **No free tier** - But extremely cheap

### Features

- ✅ Excellent reasoning
- ✅ Very cost-effective
- ✅ Strong coding ability
- ✅ Good long-context support

### Documentation

- **API Docs:** https://api-docs.deepseek.com
- **Pricing:** https://platform.deepseek.com/pricing

---

## Groq

**Website:** https://groq.com

### Getting an API Key

1. Visit https://console.groq.com
2. Sign up
3. Copy API key from dashboard
4. Key format: `gsk_*`

### Setting Up

```bash
launch.bat --set-api-key groq "gsk_abc123..."
launch.bat --set-model "mixtral-8x7b-32768"
launch.bat
```

### Recommended Models

| Model | Speed | Intelligence | Cost | Best For |
|-------|-------|--------------|------|----------|
| mixtral-8x7b-32768 | ⚡⚡⚡⚡ | ⭐⭐⭐ | $ | Speed priority |
| llama2-70b-4096 | ⚡⚡⚡ | ⭐⭐⭐⭐ | $ | Balanced |

### Pricing

- **Ultra-fast inference** - Optimized for speed
- **Free tier:** 30 requests/min
- **Paid:** Pay-per-token pricing

### Features

- ✅ Lightning-fast responses
- ✅ Great for real-time applications
- ✅ Generous free tier
- ✅ Excellent value

### Documentation

- **API Docs:** https://console.groq.com/docs
- **Pricing:** https://groq.com/pricing

---

## Google Gemini

**Website:** https://ai.google.dev

### Getting an API Key

1. Visit https://makersuite.google.com/app/apikey
2. Click "Create API key"
3. Copy the key (format: `AIza*`)
4. Paste into PicoClaw

### Setting Up

```bash
launch.bat --set-api-key gemini "AIzaXXXXXXXXXXXXXX..."
launch.bat --set-model "gemini-1.5-pro"
launch.bat
```

### Recommended Models

| Model | Speed | Intelligence | Cost | Best For |
|-------|-------|--------------|------|----------|
| gemini-1.5-pro | ⚡⚡ | ⭐⭐⭐⭐⭐ | $ | Multimodal, long context |
| gemini-1.5-flash | ⚡⚡⚡ | ⭐⭐⭐⭐ | $ | Fast responses |

### Pricing

- **Free tier:** 60 requests/minute (very generous!)
- **Paid:** $0.075/1M input, $0.3/1M output (Gemini 1.5 Pro)
- **Free trial:** Full features, no card needed

### Features

- ✅ Free tier is very generous
- ✅ Multimodal support (images, video)
- ✅ 1M token context window
- ✅ Great for prototyping

### Documentation

- **API Docs:** https://ai.google.dev/docs
- **Pricing:** https://ai.google.dev/pricing
- **Free Trial:** https://makersuite.google.com

---

## HuggingFace

**Website:** https://huggingface.co

### Getting an API Key

1. Visit https://huggingface.co/settings/tokens
2. Click "New token"
3. Create token (format: `hf_*`)
4. Copy token

### Setting Up

```bash
launch.bat --set-api-key huggingface "hf_abc123..."
launch.bat --set-model "meta-llama/Llama-2-7b-chat-hf"
launch.bat
```

### Popular Models

| Model | Speed | Intelligence | Cost | Best For |
|-------|-------|--------------|------|----------|
| meta-llama/Llama-2-70b-chat | ⚡⚡ | ⭐⭐⭐⭐ | $ | Open source, no restrictions |
| mistralai/Mistral-7B | ⚡⚡⚡ | ⭐⭐⭐ | $ | Fast, efficient |
| tiiuae/falcon-7b | ⚡⚡⚡ | ⭐⭐⭐ | $ | Lightweight |

### Pricing

- **Free tier:** Limited inference API calls
- **Pro ($9/mo):** Unlimited inference API
- **Cost per API:** Very affordable

### Features

- ✅ 1000+ open source models
- ✅ No model-specific licensing
- ✅ Research-friendly
- ✅ Community-driven

### Documentation

- **API Docs:** https://huggingface.co/docs/api-inference
- **Model Hub:** https://huggingface.co/models
- **Pricing:** https://huggingface.co/pricing

---

## Ollama (Local)

**Website:** https://ollama.ai

### Getting Started

1. Download Ollama from https://ollama.ai
2. Install (Mac, Windows, Linux)
3. Run: `ollama serve`
4. In another terminal: `ollama pull llama2`

### Setting Up PicoClaw

```bash
launch.bat --set-api-key ollama "http://localhost:11434"
launch.bat --set-model "llama2"
launch.bat
```

### Available Models

```bash
ollama pull llama2              # 4 GB - General purpose
ollama pull mistral             # 4 GB - Fast
ollama pull neural-chat         # 4 GB - Conversational
ollama pull orca-mini           # 2 GB - Lightweight
ollama pull dolphin-phi          # 3 GB - Fast & capable
```

### Pricing

- **Free!** - 100% open source
- No API costs, ever
- No privacy concerns (runs locally)
- Works offline

### Features

- ✅ Completely free
- ✅ 100% privacy (local)
- ✅ No internet required
- ✅ Fast after download
- ✅ Works on any hardware (CPU or GPU)

### System Requirements

- **Mac:** Apple Silicon (M1+) or Intel
- **Windows:** WSL2 + WSLg or native Windows
- **Linux:** Any modern distribution
- **Minimum RAM:** 8GB (16GB recommended)
- **Disk:** 5-50GB per model

### Documentation

- **Install:** https://github.com/ollama/ollama
- **Models:** https://ollama.ai/library
- **API:** https://github.com/ollama/ollama/blob/main/API.md

---

## Cost Comparison

### Example: 1000 API calls, 200 tokens input, 500 tokens output

| Provider | Cost |
|----------|------|
| 🎯 **DeepSeek** | ~$0.90 |
| **Groq** | ~$1.00 (free tier) |
| **OpenAI (mini)** | ~$0.30 |
| **Google Gemini** | Free (free tier) |
| **Ollama** | Free (local) |
| **OpenAI (GPT-4o)** | ~$10.00 |
| **Anthropic** | ~$6.00 |

---

## Best Choices By Use Case

### 💰 Most Budget-Friendly
**Recommendation:** DeepSeek or Ollama
- DeepSeek: Cheapest cloud option
- Ollama: Free, fully local

### ⚡ Fastest Responses
**Recommendation:** Groq
- 10-100x faster than other providers
- Great for real-time applications

### 🧠 Most Intelligent
**Recommendation:** OpenAI GPT-4o or Anthropic Claude
- Best for complex reasoning
- Top quality output

### 🔒 Most Private
**Recommendation:** Ollama
- Runs locally on your machine
- No data leaves your computer
- Works offline

### 🎓 Best for Learning
**Recommendation:** Ollama or HuggingFace
- Open source models
- Full transparency
- Good for research

### 🎯 Best Overall Value
**Recommendation:** DeepSeek or Google Gemini
- Excellent quality for price
- Reliable performance
- Good free tiers

---

**See Also:**
- [Configuration Guide →](../guides/configuration.md)
- [Quick Start →](../guides/quick-start.md)
- [Examples →](../guides/examples.md)
- [Commands →](commands.md)

---

*Last updated: June 9, 2026*
