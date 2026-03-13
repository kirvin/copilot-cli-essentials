# Trunk-Based Development

## How It Works

```
main ──●──●──●──●──●──●──●──●──●
        │     │         │
      feat/a feat/b    feat/c
       (1 day) (2 days) (3 hours)
```

All branches are short-lived (hours to 1–2 days). They merge directly to `main`. `main` is always deployable.

## Workflow

```bash
# 1. Start fresh from main
git checkout main && git pull
git checkout -b feat/my-feature

# 2. Work in small increments
# Commit often, push early (even as WIP)

# 3. Open PR early (as draft)
gh pr create --draft --title "feat: my feature" --body "WIP"

# 4. Get review, iterate
# Mark ready when done
gh pr ready

# 5. Merge (prefer squash for feature branches, merge for release)
gh pr merge --squash
```

## Keeping Branches Fresh

Rebase on main frequently to avoid drift:

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease
```

Force-with-lease is safe — it only forces if no one else pushed to your branch.

## Feature Flags for In-Progress Work

If a feature isn't ready to ship but code needs to merge, use a feature flag:

```javascript
if (featureFlags.isEnabled('new-dashboard')) {
  return <NewDashboard />;
}
return <OldDashboard />;
```

This lets you merge incomplete work without exposing it to users.

## Branch Protection Rules

```yaml
# GitHub branch protection for main
Required status checks:
  - CI / test
  - CI / lint
  - CI / build
Required reviewers: 1
Dismiss stale reviews: true
Require up-to-date branches: true
Restrict force pushes: true
```

## When Trunk-Based Doesn't Work

Don't use trunk-based if:
- You must support multiple released versions simultaneously (use release branches)
- Your CI is slow or flaky (fix CI first)
- Your team has no PR review culture (invest in that first)
