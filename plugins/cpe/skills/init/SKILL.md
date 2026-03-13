---
name: init
description: Use when the user wants to initialize or audit GitHub repository best practices — branch protection, CODEOWNERS, PR templates, Dependabot, and CI/CD foundations.
---

Load the code ownership skill: `Skill(cpe:code-ownership)`
Load the CI/CD pipelines skill: `Skill(cpe:ci-cd-pipelines)`

Set up or audit GitHub repository best practices: branch protection, CODEOWNERS, PR templates, Dependabot, and CI/CD foundations.

## Step 1: Determine Mode

Infer from the user's message:
- `--audit` (default): report what's missing or misconfigured without making changes
- `--fix`: create or update missing configurations

If the user's message doesn't specify, default to `--audit` and show what would be set up.

## Step 2: Detect Repository Context

```bash
# Get repo info
gh repo view --json name,defaultBranch,visibility,isPrivate

# Check what already exists
ls .github/ 2>/dev/null
gh api repos/{owner}/{repo}/branches/main/protection 2>/dev/null || echo "No branch protection"
gh api repos/{owner}/{repo}/contents/.github/CODEOWNERS 2>/dev/null || echo "No CODEOWNERS"
```

## Step 3: Audit Checklist

Check each item and report status (present / missing / misconfigured):

### Branch Protection (main/master)
```bash
gh api repos/{owner}/{repo}/branches/{default}/protection
```
Expected: require PR reviews, require status checks, no force push, no deletion.

### CODEOWNERS
Check for `.github/CODEOWNERS` or `CODEOWNERS` at repo root. Validate syntax (paths exist, teams/users are real).

### PR Template
Check for `.github/PULL_REQUEST_TEMPLATE.md` or `.github/pull_request_template/` directory.

### Dependabot
Check for `.github/dependabot.yml`. Validate it covers the project's package ecosystems.

### CI/CD Foundation
- GitHub Actions: `.github/workflows/` with at least one workflow
- CircleCI: `.circleci/config.yml`
- Jenkins: `Jenkinsfile`

Check that a CI pipeline runs on PRs.

### Issue Templates
Check for `.github/ISSUE_TEMPLATE/` with at least a bug report template.

### Repository Settings
```bash
gh api repos/{owner}/{repo} | jq '{has_issues, has_wiki, delete_branch_on_merge, allow_squash_merge}'
```
Recommended: issues enabled, delete branch on merge enabled.

## Step 4: Create Missing Configurations (--fix only)

For each missing item, create a sensible default:

**CODEOWNERS** (if missing):
```
# Global owners — review required on all changes
* @<org>/<team>

# CI/CD ownership
.github/workflows/ @<org>/platform-team
.circleci/ @<org>/platform-team
```

**PR Template** (if missing):
```markdown
## What
<!-- What changed and why -->

## How to test
<!-- Steps to verify this works -->

## Notes
<!-- Breaking changes, follow-ups, deploy dependencies -->
```

**Dependabot** (if missing, detect ecosystems first):
```yaml
version: 2
updates:
  - package-ecosystem: "npm"  # or pip, gomod, etc.
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

**Branch Protection** (via gh api):
```bash
gh api repos/{owner}/{repo}/branches/{default}/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

## Step 5: Report

Present a structured summary:

```
GitHub Repository Best Practices — <repo-name>

Branch Protection    present / missing / misconfigured
CODEOWNERS          present / missing
PR Template         present / missing
Dependabot          present / missing ecosystem
CI/CD Pipeline      present / missing
Issue Templates     present / missing
```

If `--fix` was used, report each file created or setting changed.
