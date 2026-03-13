# Dependency Auditing

## Running Audits

```bash
# Node.js — built-in
npm audit
npm audit --json  # Machine-readable output

# Node.js — Snyk (more context)
npx snyk test

# Python
pip-audit                           # Recommended
safety check                        # Alternative
pip-audit --requirement requirements.txt

# Go
govulncheck ./...

# Ruby
bundle audit check --update

# Rust
cargo audit
```

## Interpreting Results

For each vulnerability, assess:

1. **Is the vulnerable function called?** A CVE in a parsing library doesn't matter if you don't parse user input with it.

2. **Is user input the source?** A vulnerability in a build tool that never touches production data may be lower priority than its CVSS score suggests.

3. **Is there a fix available?** If yes, patch it. If no, assess workarounds (disable the feature, add input validation upstream).

## CVE Triage Workflow

```bash
# Get full details on a specific vulnerability
npm audit --json | jq '.vulnerabilities["package-name"]'

# Check if the vulnerability path is reachable
# Find where the vulnerable package is imported
grep -r "require\|import" --include="*.js" --include="*.ts" . | grep "vulnerable-package"
```

For each high/critical CVE:
- [ ] Is the vulnerable code reachable in production?
- [ ] Can an attacker control the inputs?
- [ ] Is there a patch available?
- [ ] What's the upgrade path?

## Generating a Dependency Report

```bash
# Node.js — full dependency tree
npm list --depth=2

# Direct dependencies only with versions
cat package.json | jq '.dependencies, .devDependencies'

# Count transitive dependencies
npm list --all 2>/dev/null | wc -l
```

## GitHub Security Advisories

```bash
# Enable Dependabot alerts via gh CLI
gh api -X PUT repos/:owner/:repo/vulnerability-alerts

# List current alerts
gh api repos/:owner/:repo/dependabot/alerts \
  --jq '.[] | "\(.severity) \(.security_advisory.summary)"'
```
