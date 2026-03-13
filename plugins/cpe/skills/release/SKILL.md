---
name: release
description: Use when the user wants to cut a versioned release with a changelog, tag, and GitHub release.
---

Load the release-management skill: `Skill(cpe:release-management)`

Cut a release: bump version, generate changelog, tag, and publish a GitHub release.

## Step 1: Determine Version

Infer the desired version from the user's message:
- Explicit version number (e.g. `1.2.3`) — use as-is
- `--patch`, `--minor`, or `--major` — bump from latest tag
- No preference specified — default to `--patch`

```bash
# Get current version from latest tag
LATEST=$(git tag --sort=-version:refname | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' | head -1)
echo "Latest tag: $LATEST"

# Get version from package.json if present
[ -f package.json ] && cat package.json | grep '"version"' | head -1
```

Compute the next version based on semver. Show the user the proposed version before proceeding.

---

## Step 2: Confirm Branch & State

```bash
git status --short
git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~10")..HEAD
```

Warn if:
- Working tree is dirty
- Not on `main` or a release branch
- No commits since last tag

---

## Step 3: Generate Changelog

```bash
SINCE=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)
git log ${SINCE}..HEAD --pretty=format:"- %s (%h)" --no-merges
```

Group commits by type (feat, fix, chore, docs, etc.) using conventional commit prefixes. Format:

```
## [VERSION] - YYYY-MM-DD

### Features
- ...

### Bug Fixes
- ...

### Other Changes
- ...
```

If a `CHANGELOG.md` exists, prepend the new section.

---

## Step 4: Version Bump

```bash
# npm projects
[ -f package.json ] && npm version $VERSION --no-git-tag-version

# Other: update version file manually
[ -f VERSION ] && echo "$VERSION" > VERSION
[ -f pyproject.toml ] && sed -i '' "s/^version = .*/version = \"$VERSION\"/" pyproject.toml
```

Stage version file changes:
```bash
git add -A
git commit -m "chore(release): $VERSION"
```

---

## Step 5: Tag & Push

```bash
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin main --tags
```

---

## Step 6: GitHub Release

```bash
gh release create "v$VERSION" \
  --title "v$VERSION" \
  --notes "$CHANGELOG_BODY" \
  --latest
```

For pre-releases, add `--prerelease`.

---

## Dry Run Mode

If the user requested a dry run: compute version, generate changelog, and show what would be created — but don't commit, tag, push, or create the release.

---

## Output

Report:
- Version created: `vX.Y.Z`
- Tag: pushed to remote
- GitHub Release URL (from `gh release view`)
- Next steps (deploy to production if applicable)
