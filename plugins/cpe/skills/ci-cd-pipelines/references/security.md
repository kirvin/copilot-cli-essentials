# CI/CD Pipeline Security

## Permission Model

Always declare minimal permissions. GitHub's default is too broad.

```yaml
# Top-level default (restrictive)
permissions:
  contents: read

jobs:
  build:
    permissions:
      contents: read
      packages: write      # Only where needed

  release:
    permissions:
      contents: write      # For creating releases
      id-token: write      # For OIDC token (cloud auth)
```

## Secret Management

**Never hardcode secrets.** Use GitHub Secrets or OIDC for cloud providers.

```yaml
# Good — use secrets
- run: aws s3 sync ./dist s3://${{ secrets.S3_BUCKET }}
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

# Better — use OIDC (no long-lived credentials)
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

## Script Injection Prevention

`pull_request_target` + user-controlled data = script injection risk.

```yaml
# DANGEROUS — don't do this
- run: echo "${{ github.event.pull_request.title }}"

# Safe — use env var
- run: echo "$PR_TITLE"
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
```

## Action Pinning

Pin third-party actions to commit SHA, not a mutable tag.

```yaml
# Mutable tag — supply chain risk
- uses: some-org/some-action@v2

# Pinned SHA — safe
- uses: some-org/some-action@abc1234def5678  # v2.1.0
```

Use `dependabot` to keep pinned SHAs updated automatically:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

## pull_request_target Risks

Only use `pull_request_target` when you need write access from a fork PR. If you do:
- Never checkout the PR's code in the same job as privileged operations
- Use `if: github.event.pull_request.head.repo.full_name == github.repository` to restrict to internal PRs
