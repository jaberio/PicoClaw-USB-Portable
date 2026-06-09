---
layout: default
title: Examples & Use Cases
---

# 💡 Examples & Use Cases

Real-world scenarios and how to use PicoClaw launcher.

---

## Scenario 1: First-Time User with OpenAI

You just got the portable launcher and want to start chatting with ChatGPT.

### Setup (2 minutes)
```bash
# Windows
launch.bat --init-config
launch.bat --set-api-key openai "sk-proj-your-key-from-openai"
launch.bat --set-model "gpt-4o"

# Unix
./launch.sh --init-config
./launch.sh --set-api-key openai "sk-proj-your-key-from-openai"
./launch.sh --set-model "gpt-4o"
```

### Run
```bash
launch.bat
# Select [1] Start PicoClaw chat
```

### Use
```
You: Tell me a joke
PicoClaw: Why did the AI go to school?
         To improve its training data! 😄
```

---

## Scenario 2: Team Member Switching to Claude

Your team prefers Anthropic's Claude model for complex reasoning tasks.

### Switch Provider (20 seconds)
```bash
# Windows
launch.bat --set-api-key anthropic "sk-ant-your-anthropic-key"
launch.bat --set-model "claude-opus-4-1"

# Unix
./launch.sh --set-api-key anthropic "sk-ant-your-anthropic-key"
./launch.sh --set-model "claude-opus-4-1"
```

### Verify
```bash
launch.bat --show-config
# Check provider is now "anthropic"
# Check model is "claude-opus-4-1"
```

### Use
```bash
launch.bat agent -m "Analyze this complex architecture..."
# Claude processes your architecture question
```

---

## Scenario 3: Cost Optimization - Using Multiple Models

You want to use cheaper models for simple tasks, expensive models only when needed.

### Setup All Providers
```bash
# Setup OpenAI
launch.bat --set-api-key openai "sk-proj-..."

# Setup DeepSeek (cheaper alternative)
launch.bat --set-api-key deepseek "sk-..."

# Setup Groq (free fast inference)
launch.bat --set-api-key groq "gsk_..."
```

### Task-Based Switching
```bash
# Simple task → Use cheap model
launch.bat --set-model "gpt-4o-mini"
launch.bat agent -m "Is this spam?"

# Complex task → Use expensive model
launch.bat --set-model "gpt-4o"
launch.bat agent -m "Design a scalable architecture..."

# Fast task → Use free model
launch.bat --set-model "mixtral-8x7b-32768"  # Groq
launch.bat agent -m "Format this JSON"
```

---

## Scenario 4: Portable USB Drive Setup

You want PicoClaw on a USB drive, ready to use on any computer.

### On First Computer
```bash
# Extract to USB drive
cd /Volumes/USB-Drive/PicoClaw  # or E:\PicoClaw on Windows

# Setup once
launch.bat --init-config
launch.bat --set-api-key openai "sk-proj-..."
launch.bat --set-model "gpt-4o"
```

### On Second Computer
```bash
# Plug in USB, it "just works"
cd /mnt/usb/PicoClaw
launch.sh
# All configuration preserved!
```

**Benefits:**
- ✅ Same setup everywhere
- ✅ No system pollution
- ✅ API keys travel with you (keep USB encrypted!)
- ✅ Works on Windows, macOS, Linux

---

## Scenario 5: CI/CD Automation

Automatically run AI tasks in your deployment pipeline.

### Setup Script
```bash
#!/bin/bash
# setup-picoclaw.sh

cd PicoClaw-USB-Portable

# Initialize
./launch.sh --init-config

# Set API key from environment variable
./launch.sh --set-api-key openai "$OPENAI_API_KEY"

# Set cheap model for speed
./launch.sh --set-model "gpt-4o-mini"

echo "✓ PicoClaw configured"
```

### Usage in Pipeline
```bash
#!/bin/bash
# Generate-Release-Notes.sh

# Use PicoClaw to generate release notes from commit log
./launch.sh agent -m "$(cat COMMITS.log | head -20)

Generate a concise, user-friendly release note summary from these commits.
Focus on user-facing changes, not implementation details."
```

### GitHub Actions Example
```yaml
name: Generate Release Notes
on:
  push:
    tags:
      - 'v*'

jobs:
  release-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup PicoClaw
        run: |
          ./scripts/setup.sh
          ./launch.sh --init-config
          ./launch.sh --set-api-key openai "${{ secrets.OPENAI_API_KEY }}"
      - name: Generate Notes
        run: ./launch.sh agent -m "..." > RELEASE_NOTES.md
      - name: Publish
        uses: actions/upload-artifact@v3
        with:
          name: release-notes
          path: RELEASE_NOTES.md
```

---

## Scenario 6: Local Development with Ollama

You want to use local models without any API keys or internet.

### Setup
```bash
# 1. Install Ollama locally (ollama.ai)
# 2. Run Ollama
ollama serve

# 3. In another terminal, configure PicoClaw
launch.bat --init-config
launch.bat --set-api-key ollama "http://localhost:11434"
launch.bat --set-model "llama2"

# 4. Use locally
launch.bat agent -m "Explain quantum computing"
```

**Advantages:**
- ✅ No API keys needed
- ✅ No internet required
- ✅ Completely private
- ✅ No per-request costs
- ✅ Full control over data

---

## Scenario 7: Multi-Provider Testing

Test your prompts across different models.

### Compare Results
```bash
#!/bin/bash
# compare-models.sh

PROMPT="Explain quantum computing in 3 sentences"

echo "=== OpenAI GPT-4o ==="
./launch.sh --set-model "gpt-4o"
./launch.sh agent -m "$PROMPT"

echo ""
echo "=== Anthropic Claude ==="
./launch.sh --set-api-key anthropic "sk-ant-..."
./launch.sh --set-model "claude-opus-4-1"
./launch.sh agent -m "$PROMPT"

echo ""
echo "=== DeepSeek ==="
./launch.sh --set-api-key deepseek "sk-..."
./launch.sh --set-model "deepseek-chat"
./launch.sh agent -m "$PROMPT"
```

**Use Cases:**
- Finding best model for your use case
- Comparing model quality
- Testing cost vs quality tradeoffs
- Evaluating new providers

---

## Scenario 8: Interactive Gateway Mode

Run PicoClaw as an API server for external tools.

### Setup Gateway
```bash
launch.bat
# Select [3] Start gateway
# Gateway now running on 127.0.0.1:18790
```

### Use from Other Applications
```bash
# From another terminal
curl -X POST http://127.0.0.1:18790/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, PicoClaw!",
    "provider": "openai",
    "model": "gpt-4o"
  }'
```

**Applications:**
- ✅ Web dashboard integration
- ✅ Mobile app backend
- ✅ IDE plugins
- ✅ Chat applications
- ✅ Custom tools

---

## Scenario 9: Batch Processing

Process many items with PicoClaw in a loop.

### Example: Translate Docs
```bash
#!/bin/bash
# translate-docs.sh

for file in *.md; do
    echo "Translating $file..."
    
    ./launch.sh agent -m "
    Translate this to Spanish, keeping formatting:
    
    $(cat "$file")" > "${file%.md}.es.md"
done

echo "✓ All files translated"
```

---

## Scenario 10: Production Deployment

Deploy PicoClaw with your application.

### Docker Example
```dockerfile
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y curl

# Copy PicoClaw
COPY PicoClaw-USB-Portable /app/picoclaw
WORKDIR /app/picoclaw

# Initialize on startup
RUN ./launch.sh --init-config
RUN ./launch.sh --set-api-key openai "$OPENAI_API_KEY"
RUN ./launch.sh --set-model "gpt-4o-mini"

# Start gateway
EXPOSE 18790
CMD ["./launch.sh", "gateway"]
```

### Kubernetes Example
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: picoclaw
spec:
  replicas: 3
  selector:
    matchLabels:
      app: picoclaw
  template:
    metadata:
      labels:
        app: picoclaw
    spec:
      containers:
      - name: picoclaw
        image: picoclaw:latest
        ports:
        - containerPort: 18790
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: api-keys
              key: openai
```

---

## Quick Reference: Common Commands

```bash
# Setup
./launch.sh --init-config
./launch.sh --set-api-key <provider> "<key>"
./launch.sh --set-model <model>

# Use
./launch.sh                              # Interactive menu
./launch.sh agent                        # Chat mode
./launch.sh agent -m "Quick prompt"      # One-shot
./launch.sh gateway                      # API mode
./launch.sh status                       # Check status

# Configure
./launch.sh --show-config                # View settings
./launch.sh --help-config                # Show help

# With different provider
./launch.sh --set-api-key anthropic "sk-ant-..."
./launch.sh --set-model "claude-opus-4-1"
```

---

**Next Steps:**
- [Quick Start →](quick-start.md)
- [Configuration →](configuration.md)
- [Troubleshooting →](troubleshooting.md)

---

*Last updated: June 9, 2026*
