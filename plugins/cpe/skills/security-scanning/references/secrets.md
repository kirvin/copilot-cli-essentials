# Secret Detection & Management

## Common Secret Patterns

Patterns to grep for in code reviews and audits:

```bash
# AWS
AKIA[0-9A-Z]{16}                    # AWS Access Key ID
[0-9a-zA-Z/+]{40}                   # AWS Secret Access Key (near AKIA)

# GitHub
ghp_[a-zA-Z0-9]{36}                 # Personal access token
github_pat_[a-zA-Z0-9_]{82}         # Fine-grained PAT
ghs_[a-zA-Z0-9]{36}                 # GitHub Actions token

# OpenAI / Anthropic
sk-[a-zA-Z0-9]{48}                  # OpenAI API key
sk-ant-[a-zA-Z0-9\-_]{90}+          # Anthropic API key

# Generic patterns
password\s*[:=]\s*['"][^'"]{6,}     # Hardcoded passwords
api[_-]?key\s*[:=]\s*['"][^'"]{10,} # API keys
token\s*[:=]\s*['"][a-zA-Z0-9]{20,} # Generic tokens
```

## What to Do When You Find a Secret

1. **Do not include the secret value in issue descriptions or comments**
2. Rotate immediately — assume it's compromised
3. Check git history for how long it's been exposed:
   ```bash
   git log --all -p -- path/to/file | grep -A1 "secret_name"
   ```
4. Revoke the old credential in the issuing service
5. Add the pattern to `.gitignore` / pre-commit hooks
6. Use GitHub Secret Scanning alerts to catch future occurrences

## Prevention

### .env pattern

```bash
# .gitignore
.env
.env.local
.env.*.local

# Keep in repo
.env.example   # Template with placeholder values
```

### Pre-commit hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

### GitHub Secret Scanning

Enable in repo Settings → Security → Secret scanning. GitHub will alert on 100+ secret patterns automatically and can block pushes.

```yaml
# Enable push protection (blocks commits containing secrets)
# Settings → Security → Secret scanning → Push protection → Enable
```

## Rotating a Compromised Secret

1. Generate new credential in the issuing service
2. Update in GitHub Secrets: `Settings → Secrets and variables → Actions`
3. Re-run any workflows that use it
4. Verify old credential is revoked
5. Document the rotation in an incident ticket
