# Branch Naming & PR Conventions

## Branch Naming

```
<type>/<description>
<type>/<issue-id>-<description>
```

| Type | Use for | Example |
|------|---------|---------|
| `feat/` | New features | `feat/user-avatars` |
| `fix/` | Bug fixes | `fix/login-timeout` |
| `chore/` | Maintenance, tooling | `chore/update-dependencies` |
| `docs/` | Documentation only | `docs/api-authentication` |
| `refactor/` | Refactoring (no behavior change) | `refactor/auth-service` |
| `hotfix/` | Emergency production fix | `hotfix/v1.2.1-payment-crash` |
| `release/` | Release branches | `release/v2.0` |

**Rules:**
- Lowercase, kebab-case
- No personal names (`feat/kelly-auth` → `feat/auth-service`)
- Include issue ID when it exists (`fix/GH-234-session-expiry`)
- Keep descriptions concise (3–5 words)

## PR Title Convention

Follow Conventional Commits format:

```
<type>(<scope>): <subject>
```

- `feat(auth): add OAuth2 login flow`
- `fix(upload): handle files larger than 100MB`
- `chore(deps): upgrade React to v19`

**Subject rules:**
- Imperative mood ("add", "fix", "remove" — not "added", "fixes")
- No trailing period
- 72 characters max

## PR Description Template

```markdown
## Summary
<!-- What changed and why. Not how. -->

## Testing
<!-- How to verify this works -->
- [ ] Unit tests pass
- [ ] Manually tested: [describe scenario]

## Screenshots
<!-- If UI changes -->

## Related
<!-- Issues, PRs, docs -->
Closes #123
```

## Commit Message Style

```
<type>(<scope>): <subject>

<body — the why, 72 char wrap>

<footer — breaking changes, issue refs>
```

Breaking change footer:
```
feat!: remove deprecated auth endpoint

BREAKING CHANGE: The /api/v1/auth endpoint has been removed.
Use /api/v2/auth instead. See migration guide in docs/.
```
