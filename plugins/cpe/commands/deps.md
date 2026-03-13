---
description: Audit, check, and upgrade project dependencies
argument-hint: "[--audit|--outdated|--upgrade] [--fix]"
allowed-tools: Bash, Glob, Grep, Read, Skill, Agent
---

Load the dependency management skill: `Skill(cpe:dependency-management)`

Manage project dependencies: audit for vulnerabilities, check for outdated packages, or upgrade safely. Delegates execution to `cpe:haiku`.

## Step 1: Parse Arguments

Parse `$ARGUMENTS`:
- `--audit` (default): check for security vulnerabilities
- `--outdated`: list packages with newer versions available
- `--upgrade`: upgrade dependencies to latest compatible versions
- `--fix`: apply safe fixes automatically (for --audit) or upgrade (for --outdated)

If no mode is given, default to `--audit`.

## Step 2: Delegate to Haiku

Delegate to the `cpe:haiku` agent with these instructions:

```
Manage project dependencies in <mode> mode.

1. Detect package manager:
   - package.json + package-lock.json → npm
   - package.json + yarn.lock → yarn
   - package.json + pnpm-lock.yaml → pnpm
   - pyproject.toml / requirements.txt → pip / poetry / uv
   - go.mod → go
   - Gemfile → bundler
   - Cargo.toml → cargo

2. Run the appropriate command:

   --audit mode:
     npm: npm audit [--fix if --fix passed]
     yarn: yarn audit
     pip: pip-audit (or safety check)
     go: govulncheck ./...
     cargo: cargo audit

   --outdated mode:
     npm: npm outdated
     yarn: yarn outdated
     pip: pip list --outdated
     go: go list -u -m all
     cargo: cargo outdated

   --upgrade mode:
     npm: npx npm-check-updates -u && npm install
     yarn: yarn upgrade-interactive (or yarn upgrade)
     pip: uv pip compile --upgrade / pip install -U
     go: go get -u ./... && go mod tidy
     cargo: cargo update

3. Analyze results:
   - For --audit: list vulnerabilities by severity (Critical/High/Medium/Low), affected packages, CVE IDs
   - For --outdated: list packages with current vs latest version, highlight major version bumps
   - For --upgrade: list what was upgraded, flag any major version bumps that may have breaking changes

4. Report findings and any actions taken.
```

## Step 3: Report

After haiku completes:
- For `--audit`: summarize vulnerabilities found and whether they were auto-fixed
- For `--outdated`: list packages that need attention; recommend which to upgrade
- For `--upgrade`: confirm what was upgraded; suggest running tests to verify no regressions

If critical vulnerabilities were found and not auto-fixed, recommend `/cpe:audit` for a deeper security review.
