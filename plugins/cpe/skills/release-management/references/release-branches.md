# Release Branches & Hotfixes

## Trunk-Based (Recommended for Most Teams)

All development on `main`. Tags mark releases. No long-lived release branches.

```
main ──●──●──●──●──●──●
           │        │
          v1.0     v1.1
```

**Works best when:** CI is fast and reliable, feature flags control rollout, small-to-medium teams.

**Release process:**
```bash
git tag -a "v1.1.0" -m "Release v1.1.0"
git push origin --tags
gh release create "v1.1.0" --notes "$CHANGELOG"
```

**Hotfix on trunk:**
```bash
git checkout main
# Apply minimal fix
git commit -m "fix: [description]"
git tag -a "v1.1.1"
git push origin main --follow-tags
```

---

## Release Branches (For Parallel Support)

Needed when you must maintain multiple major versions simultaneously.

```
main ──●──●──●──●──●    (v2.x development)
        │
       release/v1.x ──●──●──●    (v1.x maintenance)
```

**Create:**
```bash
git checkout -b release/v1.x v1.0.0
git push origin release/v1.x
```

**Backport a fix:**
```bash
# Merge to main first
git checkout main && git commit -m "fix: ..."

# Cherry-pick to release branch
git checkout release/v1.x
git cherry-pick $COMMIT_SHA
git tag -a "v1.0.1" && git push --follow-tags
```

---

## Hotfix Procedure (Any Branching Model)

A hotfix is a minimal fix to a production issue. Speed matters, but stability matters more.

1. **Branch from the tag, not from a development branch**
   ```bash
   git checkout -b hotfix/v1.1.1 v1.1.0
   ```

2. **Apply the minimum change** — no refactoring, no other fixes bundled in

3. **Test and CI** — even for hotfixes, CI must pass

4. **Tag and release**
   ```bash
   git tag -a "v1.1.1" -m "Hotfix: [description]"
   git push origin hotfix/v1.1.1 --follow-tags
   gh release create "v1.1.1" --notes "Hotfix: [description]"
   ```

5. **Merge back to main** — don't let main diverge from a hotfix
   ```bash
   git checkout main && git merge hotfix/v1.1.1
   git push origin main
   ```
