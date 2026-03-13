# CODEOWNERS Configuration

## File Location

GitHub recognizes CODEOWNERS in:
- `CODEOWNERS` (root)
- `.github/CODEOWNERS`
- `docs/CODEOWNERS`

`.github/CODEOWNERS` is recommended — keeps root clean.

## Syntax

```
# Pattern          Owner(s)
*                  @org/platform-team          # Default: everything
/src/auth/         @org/security-team          # Auth module
/src/payments/     @alice @bob                 # Specific users
*.tf               @org/infrastructure-team    # All Terraform files
/docs/             @org/docs-team              # Documentation
/.github/          @org/platform-team          # CI/CD config
/package.json      @org/platform-team          # Dependency changes
/src/api/v2/       @carol                      # New API version

# Specific file
/src/config/production.yml  @org/ops-team @alice
```

**Rules:**
- Last matching pattern wins
- Use teams (`@org/team-name`) not individuals where possible — survives org changes
- Be specific: overly broad patterns mean the wrong team gets notified

## Example CODEOWNERS for a Full-Stack App

```
# Default owners
*                              @org/platform

# Frontend
/src/components/               @org/frontend
/src/pages/                    @org/frontend
*.css *.scss                   @org/design-system

# Backend
/src/api/                      @org/backend
/src/services/                 @org/backend
/src/models/                   @org/backend @org/data

# Infrastructure & CI
/.github/                      @org/platform
/terraform/                    @org/infrastructure
/k8s/                          @org/infrastructure
Dockerfile                     @org/platform @org/infrastructure

# Security-sensitive
/src/auth/                     @org/security @org/backend
/src/crypto/                   @org/security
*.pem *.key                    @org/security

# Documentation
/docs/                         @org/docs @org/platform
README.md                      @org/platform
```

## Branch Protection Integration

In GitHub Settings → Branches → Branch protection:
- Enable "Require review from Code Owners"
- Code owners are automatically added as required reviewers for changed files

## Auditing Current Ownership

```bash
# Show CODEOWNERS file
cat .github/CODEOWNERS 2>/dev/null || cat CODEOWNERS 2>/dev/null

# Find files with no owner (after evaluating CODEOWNERS rules)
# GitHub shows "No owner" in PR changed files tab

# Find most frequently changed files (high-ownership-value targets)
git log --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20
```
