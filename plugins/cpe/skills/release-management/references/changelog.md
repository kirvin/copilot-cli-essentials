# Writing Changelogs

## Structure

```markdown
## [1.2.0] - 2026-03-12

### Breaking Changes
- Removed `legacyAuth()` — use `authenticate()` instead (#234)

### New Features
- Added dark mode support (#201)
- File uploads now support drag-and-drop (#189)

### Bug Fixes
- Fixed crash when session expires during file upload (#245)
- Resolved timezone offset error in date picker (#241)

### Performance
- Dashboard loads 40% faster with query caching (#238)
```

## Writing Guidelines

**Lead with the user impact, not the technical change.**

| Instead of... | Write... |
|---------------|----------|
| "fix(auth): handle null session token" | "Fixed login failure when session expires" |
| "feat(upload): add multipart support" | "Files larger than 100MB can now be uploaded" |
| "refactor: extract service layer" | (omit — no user impact) |

**Include context for breaking changes.** Don't just say what changed — say why and how to migrate:

```markdown
### Breaking Changes
- `createUser(name, email)` now requires a third `role` parameter.
  **Migration:** Add `role: 'member'` as the third argument to maintain existing behavior.
```

**Link to issues/PRs.** Every entry should have a reference so users can find details.

## Automating from Commits

If using conventional commits:

```bash
# Generate raw material
git log v1.1.0..HEAD --pretty=format:"- %s (%h)" --no-merges | grep -E "^- (feat|fix|perf|BREAKING)"
```

Then rewrite each entry in plain language before publishing. Never publish raw commit messages as a changelog.

## Keep a CHANGELOG.md

Keep `CHANGELOG.md` in the repo root. New releases prepend to the top.

```
CHANGELOG.md
[unreleased]       ← Work in progress
[1.2.0] 2026-03-12
[1.1.3] 2026-02-01
...
```
