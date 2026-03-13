# Automating Dependency Updates

## Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  # npm
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
      day: monday
      time: "09:00"
    open-pull-requests-limit: 5
    groups:
      # Batch minor/patch updates together to reduce PR noise
      minor-and-patch:
        update-types:
          - minor
          - patch
    ignore:
      # Review major bumps manually
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]
    labels:
      - dependencies
      - automated

  # GitHub Actions
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      actions:
        patterns: ["*"]
```

## Auto-Merge Strategy

For low-risk updates (patch bumps with passing CI), configure auto-merge:

```yaml
# .github/workflows/auto-merge-dependabot.yml
name: Auto-merge Dependabot PRs

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  pull-requests: write
  contents: write

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - uses: dependabot/fetch-metadata@v2
        id: metadata

      - name: Auto-merge patch updates
        if: steps.metadata.outputs.update-type == 'version-update:semver-patch'
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Reviewing Dependabot PRs

```bash
# List open Dependabot PRs
gh pr list --author "dependabot[bot]" --json number,title,labels

# Review a specific PR
gh pr view 123 --web

# Approve and merge
gh pr review 123 --approve
gh pr merge 123 --squash --auto
```

## Renovate (Alternative to Dependabot)

Renovate offers more granular control, especially for monorepos:

```json
// renovate.json
{
  "extends": ["config:base"],
  "schedule": ["before 9am on Monday"],
  "packageRules": [
    {
      "matchUpdateTypes": ["patch", "minor"],
      "automerge": true,
      "automergeType": "pr",
      "platformAutomerge": true
    },
    {
      "matchUpdateTypes": ["major"],
      "labels": ["major-upgrade"],
      "reviewers": ["team-leads"]
    }
  ]
}
```
