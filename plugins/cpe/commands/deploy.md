---
description: Deploy to an environment with pre-flight checks and rollback guidance
argument-hint: "[environment] [--dry-run]"
allowed-tools: Bash, Glob, Grep, Read, Skill
---

Deploy to a target environment with validation, safety checks, and rollback guidance.

## Decision: Environment Target

Parse `$ARGUMENTS` for environment name (default: `staging`). Recognized targets: `staging`, `production`, `prod`, `preview`, `dev`.

For `production` or `prod`, apply the **Production Gate** (see below) before proceeding.

---

## Step 1: Pre-Flight Checks

Load the deployment-strategies skill: `Skill(cpe:deployment-strategies)`

Run checks appropriate to the project:

```bash
# Confirm clean working tree
git status --short

# Confirm branch and latest commit
git log -1 --oneline

# Check for failing CI on current commit (if gh CLI available)
gh run list --branch $(git branch --show-current) --limit 5 2>/dev/null || true

# Detect project type and run build/test
[ -f package.json ] && npm run build --if-present 2>/dev/null
[ -f package.json ] && npm test --if-present 2>/dev/null
[ -f Makefile ] && make test 2>/dev/null || true
```

If any check fails, **stop and report** — do not proceed to deploy.

---

## Step 2: Production Gate (production targets only)

Before deploying to production, confirm:

1. **Branch**: Is this `main` or a release branch? Warn if deploying from a feature branch.
2. **CI status**: All checks green on this commit?
3. **Changelog / tag**: Is there a version tag for this deploy?
4. **Rollback plan**: Identify the previous stable commit or tag:
   ```bash
   git tag --sort=-version:refname | head -5
   git log --oneline -5
   ```

Present a deploy summary and ask for confirmation before executing.

---

## Step 3: Execute Deploy

Detect the project's deploy mechanism and run it:

```bash
# GitHub Actions workflow dispatch
gh workflow run deploy.yml --field environment=$ENVIRONMENT 2>/dev/null

# Makefile target
make deploy-$ENVIRONMENT 2>/dev/null || make deploy 2>/dev/null

# npm script
npm run deploy:$ENVIRONMENT 2>/dev/null || npm run deploy 2>/dev/null

# Shell script
./scripts/deploy.sh $ENVIRONMENT 2>/dev/null
./deploy.sh $ENVIRONMENT 2>/dev/null
```

If no deploy mechanism is detected, output the detected project structure and guide the user on what command to run.

---

## Step 4: Post-Deploy Verification

```bash
# Watch workflow run if dispatched via gh
gh run watch 2>/dev/null || true
```

Report:
- Deploy status (success / failed / running)
- URL if available (preview URL, staging URL)
- Rollback command if deploy failed:
  ```bash
  git revert HEAD --no-edit && git push
  # or
  gh workflow run rollback.yml --field environment=$ENVIRONMENT
  ```

---

## Dry Run Mode

If `--dry-run` in arguments: run all pre-flight checks, print the deploy command that would run, but do not execute it.
