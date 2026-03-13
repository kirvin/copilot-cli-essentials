# Upgrading Dependencies Safely

## Upgrade Strategy by Risk Level

| Change type | Risk | Process |
|-------------|------|---------|
| Patch bump (1.0.X) | Low | Merge quickly, full test |
| Minor bump (1.X.0) | Medium | Test suite + changelog review |
| Major bump (X.0.0) | High | Staged migration, dedicated branch |
| Replacing a dependency | Very High | Feature-flagged, parallel testing |

## Patch/Minor Upgrades

```bash
# Node.js — update to latest within semver range
npm update

# Update a single package to latest
npm install package-name@latest

# See what would change
npm outdated
```

Review the package's changelog for the version range before merging. Look for:
- Deprecation notices (plan migration, don't be caught off-guard)
- Behavior changes (even in patch releases, bugs get "fixed" in ways that break callers)
- New required configuration

## Major Upgrades

Create a dedicated branch for major upgrades:

```bash
git checkout -b upgrade/react-19
npm install react@19 react-dom@19
```

Steps:
1. Read the migration guide (every major version has one)
2. Update code to remove deprecated API usage
3. Run full test suite
4. Fix type errors (TypeScript projects)
5. Manual smoke test of key user flows
6. Merge as a dedicated PR with the migration documented

## Finding Breaking Changes

```bash
# Check changelog between versions
npm view package-name@">=1.0.0 <2.0.0" --json | jq '."dist-tags"'

# Or check GitHub releases
gh release list --repo owner/package-name --limit 20
```

## Regression Testing Checklist

Before merging a major upgrade:
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] No new TypeScript errors
- [ ] No new ESLint/linting errors
- [ ] Key user flows work in development
- [ ] Bundle size hasn't grown significantly (frontend projects)
- [ ] Performance benchmarks haven't regressed (if applicable)
