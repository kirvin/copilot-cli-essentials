---
name: ci-cd-pipelines
description: GitHub Actions best practices — workflow structure, caching, security hardening, matrix builds, and reusable workflows. Use when designing, debugging, or optimizing CI/CD pipelines.
---

# CI/CD Pipelines

**Core principle:** A CI/CD pipeline is production infrastructure. It should be fast, secure, deterministic, and easy to debug when it fails.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Workflow structure, triggers, job design | **Structure** | `references/structure.md` |
| Caching dependencies, build artifacts | **Caching** | `references/caching.md` |
| Secrets, permissions, supply chain | **Security** | `references/security.md` |
| Matrix builds, parallelism, environments | **Scaling** | `references/scaling.md` |

---

## Core Principles

### Fast feedback loops

Developers context-switch when CI takes too long. Target: < 5 min for unit tests, < 15 min for full suite.

- Run cheap checks first (lint, type-check, unit tests)
- Parallelize independent jobs
- Cache aggressively — dependency install is usually the slowest step
- Use `paths` filters to skip unnecessary runs

### Determinism over convenience

Flaky pipelines destroy trust. Every non-deterministic element is a bug waiting to happen.

- Pin action versions to a commit SHA, not a floating tag
- Use lockfiles (`package-lock.json`, `poetry.lock`, `go.sum`)
- Seed randomness in tests explicitly
- Avoid `sleep` — use condition polling or wait steps

### Minimal permissions

Workflows run with elevated access. Apply least-privilege at every level.

```yaml
permissions:
  contents: read  # Start here. Add only what's needed.
```

Never use `permissions: write-all` or omit the `permissions` block on workflows that handle PRs.

### Fail fast, fail clearly

A failing pipeline should tell you exactly what's wrong in < 30 seconds of log reading.

- Use `::error::` annotations for critical failures
- Group output with `::group::` / `::endgroup::`
- Exit immediately on error (`set -euo pipefail` in bash steps)
- Use `if: failure()` steps to capture and upload artifacts on failure

---

## Common Patterns

### Dependency caching (Node)

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

- run: npm ci
```

### Reusable workflow call

```yaml
jobs:
  test:
    uses: ./.github/workflows/test.yml
    with:
      environment: staging
    secrets: inherit
```

### Matrix build

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    node: ['18', '20']
  fail-fast: false
```

### Conditional deploy

```yaml
- name: Deploy to production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: ./scripts/deploy.sh production
```
