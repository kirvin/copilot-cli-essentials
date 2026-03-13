# CI/CD Caching

## Cache Strategy

Caching is the single highest-ROI optimization for most pipelines. A cold `npm ci` takes 30–90s. A cached one takes 3–5s.

## Node.js

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'        # Auto-caches based on package-lock.json hash

- run: npm ci          # Uses cache automatically
```

For yarn:
```yaml
- uses: actions/setup-node@v4
  with:
    cache: 'yarn'
- run: yarn install --frozen-lockfile
```

## Python

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'

- run: pip install -e '.[dev]'
```

## Go

```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
    cache: true          # Caches module download cache
```

## Build Artifacts Between Jobs

```yaml
jobs:
  build:
    steps:
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
          retention-days: 1

  deploy:
    needs: build
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
```

## Cache Invalidation

Cache keys should include:
1. OS (runner)
2. Language version
3. Lockfile hash

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

The `restore-keys` fallback allows partial cache hits when the lockfile changes.

## What NOT to Cache

- Build outputs that include secrets or env-specific values
- Caches larger than ~500MB (overhead outweighs benefit)
- Anything that must be fresh every run (e.g., security scan results)
