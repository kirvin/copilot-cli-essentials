---
name: audit
description: Use when the user wants a security and dependency audit — checking for vulnerabilities, exposed secrets, and outdated packages.
---

Load the security-scanning skill: `Skill(cpe:security-scanning)`
Load the dependency-management skill: `Skill(cpe:dependency-management)`

Audit the codebase for security vulnerabilities, exposed secrets, and outdated dependencies.

## Mode Selection

Determine from the user's message which checks to run:
- `--deps` — dependency vulnerabilities only
- `--secrets` — secret/credential scanning only
- `--all` or no specific mode — run all checks

---

## Dependency Audit

```bash
# Node.js
[ -f package.json ] && npm audit --json 2>/dev/null | jq '{
  vulnerabilities: .metadata.vulnerabilities,
  critical: .metadata.vulnerabilities.critical,
  high: .metadata.vulnerabilities.high
}'

# Python
[ -f pyproject.toml ] || [ -f requirements.txt ] && \
  pip-audit --format=json 2>/dev/null || \
  safety check --json 2>/dev/null || true

# Go
[ -f go.mod ] && govulncheck ./... 2>/dev/null || true

# GitHub Advisory Database via gh
gh api graphql -f query='{ securityVulnerabilities(first:10,ecosystem:NPM) { nodes { advisory { summary severity } } } }' 2>/dev/null || true
```

Report format:
- Critical and high severity issues listed with CVE, package, version, fix version
- Command to fix: `npm audit fix` / `pip install --upgrade <pkg>`

---

## Secret Scanning

```bash
# Scan working tree for common patterns
grep -rn \
  -e "password\s*=\s*['\"][^'\"]\{8,\}" \
  -e "api[_-]key\s*=\s*['\"][^'\"]\{10,\}" \
  -e "secret\s*=\s*['\"][^'\"]\{8,\}" \
  -e "AKIA[0-9A-Z]\{16\}" \
  -e "ghp_[a-zA-Z0-9]\{36\}" \
  --include="*.env" --include="*.json" --include="*.yaml" --include="*.yml" \
  --exclude-dir=node_modules --exclude-dir=.git \
  . 2>/dev/null | grep -v "example\|sample\|test\|mock\|placeholder" | head -20
```

Also check:
```bash
# .env files committed to git
git ls-files | grep -E '^\.env' | grep -v '\.env\.example'

# Private keys
git ls-files | xargs grep -l "BEGIN.*PRIVATE KEY" 2>/dev/null
```

---

## Outdated Dependencies

```bash
# Node.js
[ -f package.json ] && npm outdated --json 2>/dev/null | \
  jq 'to_entries | map(select(.value.current != .value.latest)) |
  map({package: .key, current: .value.current, latest: .value.latest, type: .value.type})'

# Python
[ -f pyproject.toml ] && pip list --outdated --format=json 2>/dev/null | head -20
```

---

## Output Report

Structure findings by severity:

### Critical / High (act now)
- CVEs with CVSS 7.0 or higher
- Any committed secrets

### Medium (schedule)
- Outdated major versions
- Moderate CVEs

### Low / Info
- Outdated minor/patch versions
- Style recommendations

Include remediation commands for each finding. If nothing is found, confirm the project is clean.
