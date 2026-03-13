---
name: deps
description: Use when the user wants to audit dependencies for vulnerabilities, check for outdated packages, or upgrade dependencies safely.
---

Load the dependency management skill: `Skill(cpe:dependency-management)`

Manage project dependencies: audit for vulnerabilities, check for outdated packages, or upgrade safely.

## Step 1: Determine Mode

Infer the mode from the user's message:
- `--audit` (default): check for security vulnerabilities
- `--outdated`: list packages with newer versions available
- `--upgrade`: upgrade dependencies to latest compatible versions
- `--fix`: apply safe fixes automatically (for `--audit`) or upgrade (for `--outdated`)

If the user's message doesn't specify a mode, default to `--audit`.

## Step 2: Detect Package Manager and Run

Detect the package manager from the project files:
- `package.json` + `package-lock.json` → npm
- `package.json` + `yarn.lock` → yarn
- `package.json` + `pnpm-lock.yaml` → pnpm
- `pyproject.toml` / `requirements.txt` → pip / poetry / uv
- `go.mod` → go
- `Gemfile` → bundler
- `Cargo.toml` → cargo

Run the appropriate command based on mode:

**`--audit` mode:**
```bash
npm audit [--fix if fix was requested]
yarn audit
pip-audit --format=json   # or: safety check --json
govulncheck ./...
cargo audit
```

**`--outdated` mode:**
```bash
npm outdated
yarn outdated
pip list --outdated
go list -u -m all
cargo outdated
```

**`--upgrade` mode:**
```bash
npx npm-check-updates -u && npm install
yarn upgrade
uv pip compile --upgrade   # or: pip install -U
go get -u ./... && go mod tidy
cargo update
```

## Step 3: Analyze Results

- For `--audit`: list vulnerabilities by severity (Critical / High / Medium / Low), affected packages, CVE IDs
- For `--outdated`: list packages with current vs. latest version, highlight major version bumps
- For `--upgrade`: list what was upgraded, flag any major version bumps that may have breaking changes

## Step 4: Report

- For `--audit`: summarize vulnerabilities found and whether they were auto-fixed
- For `--outdated`: list packages that need attention; recommend which to upgrade
- For `--upgrade`: confirm what was upgraded; suggest running tests to verify no regressions

If critical vulnerabilities were found and not auto-fixed, recommend running the full security audit skill for a deeper review.
