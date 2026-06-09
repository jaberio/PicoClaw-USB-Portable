---
layout: default
title: Troubleshooting & Common Issues
---

# 🔧 Troubleshooting

Common issues and how to solve them.

---

## Configuration Issues

### API Key Not Working

**Problem:** Getting authentication errors when using PicoClaw

**Solutions:**
1. **Verify key is correct:**
   ```bash
   launch.bat --show-config | grep -A 5 api_keys
   ```
   Check for extra spaces or typos

2. **Ensure key is still active:**
   - Log into provider website (OpenAI, Anthropic, etc.)
   - Check key hasn't expired
   - Check key has required permissions

3. **Try reinserting key:**
   ```bash
   launch.bat --set-api-key openai "sk-proj-fresh-copy-of-key"
   ```

4. **Check provider status:**
   - Visit provider's status page
   - Ensure no service outages

---

### Config Not Found

**Problem:** "config.json not found" error

**Solution:**
```bash
# Windows
launch.bat --init-config

# Unix
./launch.sh --init-config
```

This creates `data/config.json` from defaults.

---

### Config File Corrupted

**Problem:** Invalid JSON or syntax errors

**Solution:**
1. **Backup current config:**
   ```bash
   cp data/config.json data/config.json.bak
   ```

2. **Recreate from scratch:**
   ```bash
   rm data/config.json
   launch.bat --init-config
   ```

3. **Restore API keys:**
   ```bash
   launch.bat --set-api-key openai "your-key"
   ```

---

## Model & Provider Issues

### Model Not Found

**Problem:** Error "model not recognized"

**Solution:**
1. **View available models:**
   ```bash
   launch.bat model
   ```

2. **Check provider supports model:**
   ```bash
   launch.bat --show-config | grep -A 2 default_agent
   ```

3. **Switch to working model:**
   ```bash
   launch.bat --set-model "gpt-4o-mini"
   ```

---

### Provider Not Recognized

**Problem:** Can't find provider in list

**Solution:**
1. **Check available providers:**
   ```bash
   launch.bat --set-api-key help
   # or look at config.schema.json
   ```

2. **Verify spelling:**
   ```bash
   launch.bat --set-api-key openai "key"  # Correct
   launch.bat --set-api-key opanai "key"  # Wrong spelling
   ```

3. **Add new provider:**
   - Use an existing provider first
   - Contact support if your provider isn't listed

---

## Setup & Installation Issues

### Download Failed

**Problem:** "Setup failed. Check internet" error

**Solution:**
1. **Check internet connection:**
   ```bash
   ping google.com
   ```

2. **Try again:**
   ```bash
   launch.bat
   # Will retry download automatically
   ```

3. **Manual download:**
   - Check `scripts/release.config` for download URL
   - Download manually to `.cache/` folder

---

### Permission Denied (Unix/Linux)

**Problem:** "Permission denied" when running launch.sh

**Solution:**
```bash
# Make script executable
chmod +x launch.sh
chmod +x scripts/config-helper.sh

# Then run
./launch.sh
```

---

## Runtime Issues

### Hanging/Frozen

**Problem:** PicoClaw appears to hang

**Solution:**
1. **Wait longer:**
   - First startup may take longer
   - LLM responses take time depending on complexity

2. **Check internet:**
   ```bash
   ping api.openai.com
   ```

3. **Stop and restart:**
   - Press `Ctrl+C` to stop
   - Restart: `launch.bat`

4. **View logs:**
   - Check `data/logs/` for error details

---

### Out of Memory

**Problem:** "Out of memory" or "killed" errors

**Solution:**
1. **Use smaller model:**
   ```bash
   launch.bat --set-model "gpt-4o-mini"
   launch.bat --set-model "claude-3-5-haiku"
   ```

2. **Use local model:**
   ```bash
   launch.bat --set-api-key ollama "http://localhost:11434"
   launch.bat --set-model "llama2"
   ```

3. **Increase system memory:**
   - Close other applications
   - Increase swap space (if on Linux)

---

## Platform-Specific Issues

### Windows: Path Too Long

**Problem:** "The system cannot find the path specified"

**Solution:**
1. **Extract to shorter path:**
   - Instead of: `C:\Users\YourName\AppData\Local\...`
   - Use: `C:\PicoClaw` or `D:\PicoClaw`

2. **Enable long paths (Windows 10/11):**
   ```powershell
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
     -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
   ```

---

### macOS: Quarantine Error

**Problem:** "cannot be opened because it is from an unidentified developer"

**Solution:**
```bash
xattr -d com.apple.quarantine ./launch.sh
chmod +x launch.sh
./launch.sh
```

---

### Linux: Library Not Found

**Problem:** "error while loading shared libraries"

**Solution:**
```bash
# Install required libraries
sudo apt-get install libssl-dev libffi-dev

# Or use Ollama for local models (no dependencies)
./launch.sh --set-api-key ollama "http://localhost:11434"
```

---

## Performance Issues

### Slow Responses

**Problem:** Taking a long time to get answers

**Solutions:**
1. **Use faster model:**
   ```bash
   launch.bat --set-model "gpt-4o-mini"  # Faster than gpt-4o
   launch.bat --set-model "claude-3-5-haiku"  # Faster than Opus
   ```

2. **Check provider latency:**
   - Some providers are slower during peak hours
   - Try different provider

3. **Use local model:**
   ```bash
   launch.bat --set-api-key ollama "..."
   ```

---

## Configuration Storage Issues

### Config Lost After Restart

**Problem:** Configuration resets after restart

**Solution:**
1. **Check file exists:**
   ```bash
   ls data/config.json  # Unix
   dir data\config.json  # Windows
   ```

2. **Check permissions:**
   ```bash
   # Unix
   chmod 644 data/config.json
   ```

3. **Backup config:**
   ```bash
   cp data/config.json data/config.json.bak
   ```

---

## Security Issues

### API Key Exposed

**Problem:** API key accidentally shared or committed to git

**Solution:**
1. **Immediately revoke key:**
   - Log into provider (OpenAI, etc.)
   - Delete/revoke the exposed key
   - Generate new key

2. **Generate new config:**
   ```bash
   rm data/config.json
   launch.bat --init-config
   launch.bat --set-api-key openai "new-key"
   ```

3. **Check git history:**
   - Review what was pushed
   - Contact provider if leaked through git

---

## Getting More Help

### Check Logs
```bash
cat data/logs/picoclaw.log  # Unix
type data\logs\picoclaw.log  # Windows
```

### Validate Configuration
```bash
launch.bat --show-config
```

### Run Diagnostics
```bash
launch.bat status
launch.bat version
```

### Report Issues
- **GitHub Issues:** https://github.com/jaberio/PicoClaw-USB-Portable/issues
- **Include:** Error message, command run, OS/platform, steps to reproduce

---

## FAQ

**Q: Can I use PicoClaw without internet?**  
A: Yes! Use Ollama for local models: `launch.bat --set-api-key ollama "http://localhost:11434"`

**Q: How do I switch providers?**  
A: Use `launch.bat --set-api-key <provider> <key>` then `launch.bat --set-model <model>`

**Q: Is my API key secure?**  
A: Keys are stored locally in `data/config.json`. Add to `.gitignore` and keep USB encrypted.

**Q: Can I use this on a USB drive?**  
A: Yes! That's the whole point. Just copy the entire folder to USB.

**Q: Does it work on [specific OS/distro]?**  
A: Windows, macOS, Linux, Raspberry Pi all supported.

**Q: How do I uninstall?**  
A: Just delete the folder. There's no system installation.

---

**Need more help?**
- [Configuration Guide →](../guides/configuration.md)
- [Examples →](../guides/examples.md)
- [GitHub Issues →](https://github.com/jaberio/PicoClaw-USB-Portable/issues)

---

*Last updated: June 9, 2026*
