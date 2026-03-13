# Semantic Versioning

## The Rules (simplified)

```
MAJOR.MINOR.PATCH

MAJOR: breaking changes
MINOR: new features, backward-compatible
PATCH: bug fixes, backward-compatible
```

## What Counts as Breaking?

For a library/SDK:
- Removing or renaming a public function/method/class
- Changing a function signature (adding required params, changing return type)
- Changing behavior that callers depend on
- Removing fields from a response schema

For an API:
- Removing endpoints
- Changing required fields
- Changing response shape in a non-additive way
- Changing authentication requirements

For a CLI tool:
- Removing flags or subcommands
- Changing flag semantics
- Changing output format (if parsed by scripts)

## What Is NOT Breaking?

- Adding optional parameters with defaults
- Adding new fields to response schemas (usually)
- Adding new endpoints or commands
- Performance improvements
- Internal refactors with no behavioral change

## Pre-release Versions

```
1.0.0-alpha.1      # Alpha — unstable API
1.0.0-beta.3       # Beta — feature-complete, may have bugs
1.0.0-rc.1         # Release candidate — ready for final validation
```

Pre-release versions do NOT carry the same stability guarantees. Signal this clearly in release notes.

## Version from Commits

Using conventional commits, determine bump:

| Commit type | Version bump |
|-------------|-------------|
| `feat!:` or `BREAKING CHANGE:` | MAJOR |
| `feat:` | MINOR |
| `fix:`, `perf:`, `refactor:` | PATCH |
| `chore:`, `docs:`, `test:` | No release needed |

## Practical Checklist

Before bumping:
- [ ] CI passing on the release commit
- [ ] All tickets for this milestone closed or deferred
- [ ] Changelog written and reviewed
- [ ] Release branch cut (for major/minor)
- [ ] Migration guide written (for major)
