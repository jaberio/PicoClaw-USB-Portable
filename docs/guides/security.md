---
layout: default
title: Security & Best Practices
---

# 🔒 Security & Best Practices

Protecting your API keys and data.

---

## API Key Management

### 📋 Best Practices

✅ **DO:**
- Store keys in `data/config.json` (local only)
- Use `.gitignore` to prevent git commits
- Regenerate keys after exposure
- Use minimal permission keys
- Store backups securely

❌ **DON'T:**
- Hardcode keys in scripts
- Share keys via email or chat
- Commit keys to git
- Use same key for multiple machines
- Leave USB unencrypted with keys

---

### Protecting Your Keys

#### 1. Ensure config.json is in .gitignore

```bash
# Check if configured
grep "config.json" .gitignore

# If not, add it:
echo "data/config.json" >> .gitignore
```

#### 2. Encrypt the USB Drive

**Windows:**
```powershell
# Enable BitLocker on USB drive
Enable-BitLocker -MountPoint "E:" -EncryptionMethod Aes256
```

**macOS:**
```bash
# Encrypt with Finder
# Right-click drive → Encrypt
```

**Linux:**
```bash
# Use LUKS encryption
sudo cryptsetup luksFormat /dev/sdX1
sudo cryptsetup luksOpen /dev/sdX1 usb_encrypted
sudo mkfs.ext4 /dev/mapper/usb_encrypted
```

---

### Regenerating Compromised Keys

If a key is exposed:

```bash
# 1. Revoke at provider
# Log into OpenAI/Anthropic/etc. and delete key

# 2. Generate new key
# Log in to provider, create new key

# 3. Update locally
launch.bat --set-api-key openai "sk-proj-new-key"

# 4. Verify old key doesn't work
# (Provider will reject it)
```

---

## Data Privacy

### What Data PicoClaw Stores

**Locally in `data/config.json`:**
- API keys
- Preferred models
- Channel configurations
- Memory/workspace settings

**NOT stored locally:**
- Chat history (default)
- Session logs (configurable)
- Conversation content

### Environment Variables

Override config with environment variables (no file needed):

```bash
# Windows PowerShell
$env:PICOCLAW_OPENAI_KEY = "sk-..."
$env:PICOCLAW_DEFAULT_MODEL = "gpt-4o"

# Unix/Linux
export PICOCLAW_OPENAI_KEY="sk-..."
export PICOCLAW_DEFAULT_MODEL="gpt-4o"
```

**Benefit:** Keys never touch disk!

---

### Memory & History

**Default:** No history stored  
**Optional:** Enable workspace memory

```bash
# In config.json
{
  "memory": {
    "type": "sqlite",
    "retention_days": 30,
    "auto_cleanup": true
  }
}
```

---

## Network Security

### API Communications

- ✅ All communications use HTTPS
- ✅ TLS 1.2+ encryption
- ✅ Certificate validation enabled
- ✅ No certificate pinning (uses system CA)

### Proxy Support

For corporate firewalls:

```json
{
  "gateway": {
    "http_proxy": "http://proxy.company.com:3128",
    "https_proxy": "http://proxy.company.com:3128",
    "no_proxy": "localhost,127.0.0.1"
  }
}
```

---

### Local Gateway Mode

Run locally without internet:

```bash
launch.bat --gateway-only
# Creates local API at http://127.0.0.1:18790
```

Then connect with:
```bash
launch.bat --set-api-key custom-local "http://127.0.0.1:18790"
```

---

## File Permissions

### Windows

```powershell
# Restrict config.json to current user only
icacls data\config.json /inheritance:r /grant:r "%USERNAME%:F"
```

### Unix/Linux

```bash
# Owner read/write only
chmod 600 data/config.json

# Check permissions
ls -la data/config.json
# Should show: -rw------- user user
```

---

## Backup Security

### Secure Backups

```bash
# Unix: Encrypt backup
tar -czf config.tar.gz data/
gpg --symmetric config.tar.gz
rm config.tar.gz

# Windows: Use BitLocker on backup drive
# Or 7-Zip with AES-256 encryption
```

### Backup Rotation

Keep limited backups:
```bash
# Keep only last 3 backups
ls -t data/backups/config.*.json | tail -n +4 | xargs rm
```

---

## Source Code Security

### Verify Releases

All releases are signed:

```bash
# Check signature (once published with signatures)
gpg --verify picoclaw-1.1.0.sha256.sig
sha256sum -c picoclaw-1.1.0.sha256
```

### Verify Dependencies

The launcher has minimal dependencies:
- `jq` (JSON parsing) - open source
- Bash/PowerShell - system default
- Go runtime - compile checked

---

## Vulnerability Reporting

Found a security issue?

**Do NOT:**
- Post in public issues
- Share details publicly

**Do:**
- Email: security@example.com (or use responsible disclosure)
- Include: Description, steps to reproduce, impact
- Allow 90 days for fix before public disclosure

---

## Configuration Validation

### Schema Validation

All configs validate against `scripts/config.schema.json`:

```bash
# Validate manually
jq --arg schema "$(cat scripts/config.schema.json)" '.' data/config.json
```

### Type Checking

```json
{
  "api_keys": {
    "type": "object"
  },
  "default_agent": {
    "type": "object",
    "properties": {
      "model_name": { "type": "string" },
      "temperature": { "type": "number", "minimum": 0, "maximum": 1 }
    }
  }
}
```

---

## Compliance

### GDPR Compliance

✅ No data collection  
✅ No tracking  
✅ No telemetry  
✅ Local-only operation  
✅ Complete data ownership  

### SOC 2 Compliance

For enterprise deployment, PicoClaw supports:
- Encrypted local storage
- Encrypted backups
- Audit logging
- Access controls
- Network isolation

---

## Security Checklist

Before deployment:

- [ ] API key in `config.json`
- [ ] `.gitignore` prevents commits
- [ ] USB drive encrypted
- [ ] File permissions 600 (Unix)
- [ ] No keys in environment (unless temporary)
- [ ] Backups encrypted
- [ ] Firewall configured
- [ ] No untrusted plugins loaded
- [ ] Latest PicoClaw version
- [ ] Regular key rotation policy

---

## Incident Response

If keys are exposed:

1. **Immediate (0-5 min):**
   - Stop using PicoClaw
   - Revoke exposed keys in provider

2. **Short term (5-30 min):**
   - Generate new keys
   - Update local config
   - Verify new keys work

3. **Follow up (1 hour):**
   - Review logs for unauthorized use
   - Check provider billing for anomalies
   - Update incident log

4. **Long term (1+ day):**
   - Implement better security (encryption, 2FA)
   - Review access controls
   - Implement backup strategy

---

## Additional Resources

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [API Key Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/API_Key_Best_Practices.html)
- [Secrets Management](https://12factor.net/config)

---

**See Also:**
- [Configuration Guide →](../guides/configuration.md)
- [Troubleshooting →](troubleshooting.md)
- [Architecture →](../technical/architecture.md)

---

*Last updated: June 9, 2026*
