# Dependency Security

## Vulnerability Auditing

### Node.js

```bash
# Built-in audit
npm audit

# JSON output for programmatic use
npm audit --json | jq '.metadata.vulnerabilities'

# Fix automatically (within semver range)
npm audit fix

# Force fix (may break semver — review changes)
npm audit fix --force
```

### Python

```bash
# pip-audit (recommended)
pip-audit

# safety
safety check

# With pyproject.toml
pip-audit --requirement requirements.txt
```

### Go

```bash
govulncheck ./...
```

### GitHub Dependabot

Enable in `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
    groups:
      production-deps:
        dependency-type: production
      dev-deps:
        dependency-type: development
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]  # Review major bumps manually
```

## Severity Triage

| CVSS | Severity | Action |
|------|----------|--------|
| 9.0–10.0 | Critical | Fix before next deploy |
| 7.0–8.9 | High | Fix this sprint |
| 4.0–6.9 | Medium | Schedule next release |
| 0.1–3.9 | Low | Backlog |

Not all critical CVEs are exploitable in your context. Check:
- Is the vulnerable code path reachable?
- Is user input involved?
- Are there mitigating factors (WAF, input validation upstream)?

## Supply Chain Security

### Lockfiles

Always commit lockfiles (`package-lock.json`, `yarn.lock`, `poetry.lock`, `go.sum`). They prevent substitution attacks and ensure reproducible builds.

```bash
# Verify integrity (npm)
npm ci  # Fails if package-lock.json doesn't match

# Verify integrity (Python)
pip install --require-hashes -r requirements.txt
```

### SLSA / Provenance

For published packages or Docker images, consider generating build provenance:

```yaml
- uses: actions/attest-build-provenance@v1
  with:
    subject-path: dist/*.tgz
```

This allows consumers to verify the artifact was built by your CI, not tampered with.
