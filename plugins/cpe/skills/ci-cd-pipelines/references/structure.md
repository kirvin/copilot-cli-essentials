# CI/CD Pipeline Structure

## Workflow Anatomy

```yaml
name: CI                          # Human-readable name

on:
  push:
    branches: [main]
    paths-ignore: ['**.md', 'docs/**']  # Skip docs-only changes
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true        # Cancel stale PR runs

jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 5            # Always set — prevents runaway jobs
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    needs: lint                   # Gate on lint passing
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

## Job Dependency Design

Order jobs by: cost (cheap first), dependency (blocking last).

```
lint ──────────┐
type-check ────┼──► test ──► build ──► deploy
unit-tests ────┘
```

## Trigger Design

| Trigger | Use case |
|---------|----------|
| `push: branches: [main]` | Deploy pipelines |
| `pull_request` | Validation pipelines |
| `workflow_dispatch` | Manual + parameterized runs |
| `schedule` | Dependency audits, nightly tests |
| `release: types: [published]` | Release automation |

## Environment Strategy

Use GitHub Environments for deployment targets:
- Define required reviewers for production
- Set environment-specific secrets
- Track deploy history per environment

```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://app.example.com
```
