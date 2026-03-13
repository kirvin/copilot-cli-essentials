---
description: Incident response — triage, investigate, mitigate, and document
argument-hint: "[describe the incident or paste error]"
allowed-tools: Bash, Glob, Grep, Read, Skill
---

Guide incident response from detection through mitigation and post-mortem.

Load the incident-response skill: `Skill(cpe:incident-response)`

## Phase 1: Triage

**Assess severity immediately.** Parse `$ARGUMENTS` for incident description.

| Severity | Criteria | Response |
|----------|----------|----------|
| SEV1 | Production down, data loss risk, security breach | Immediate — all hands |
| SEV2 | Degraded production, partial outage | Urgent — on-call response |
| SEV3 | Minor degradation, workaround available | Scheduled — next business hours |
| SEV4 | Cosmetic, low-impact | Normal sprint cycle |

Ask the user to confirm severity if not clear from description.

---

## Phase 2: Immediate Investigation

```bash
# Recent deployments (what changed?)
git log --oneline -10
git log --since="2 hours ago" --oneline

# Recent workflow runs
gh run list --limit 10 --json name,conclusion,createdAt,headSha \
  | jq -r '.[] | "\(.createdAt) \(.conclusion) \(.name)"' 2>/dev/null || true

# Recent merged PRs
gh pr list --state merged --limit 5 --json number,title,mergedAt \
  | jq -r '.[] | "\(.mergedAt) #\(.number) \(.title)"' 2>/dev/null || true

# Check for error patterns in recent logs (if log files present)
find . -name "*.log" -newer /tmp -not -path "*/node_modules/*" 2>/dev/null | head -5
```

Guide the user to check:
1. **What changed recently?** (deploys, config changes, dependency updates)
2. **What's the blast radius?** (which users/services affected)
3. **Is it still happening?** (ongoing vs. transient)

---

## Phase 3: Mitigation Options

Present options based on investigation findings:

**Rollback deploy:**
```bash
# Find previous stable deploy
git log --oneline -5
git revert HEAD --no-edit
git push

# Or revert to specific commit
git revert $COMMIT_SHA --no-edit && git push

# Trigger rollback workflow if exists
gh workflow run rollback.yml 2>/dev/null || true
```

**Feature flag / kill switch:**
```bash
# Check for feature flag config
find . -name "flags*" -o -name "features*" 2>/dev/null | grep -v node_modules | head -5
```

**Hotfix path:**
```bash
git checkout -b hotfix/$INCIDENT_NAME
# [apply minimal fix]
gh pr create --title "hotfix: $DESCRIPTION" --base main --draft
```

---

## Phase 4: Communication Template

Generate an incident communication based on severity:

```
**[SEV{N}] Incident: [brief title]**

Status: Investigating / Mitigating / Resolved

Impact: [what's affected, how many users]
Started: [time]
Last update: [time]

What we know: [current understanding]
What we're doing: [mitigation steps in progress]

Next update: [time]
```

---

## Phase 5: Post-Incident

After mitigation, create a follow-up issue:

```bash
gh issue create \
  --title "Post-mortem: [incident title]" \
  --body "## Timeline\n\n## Root Cause\n\n## Impact\n\n## Remediation\n\n## Action Items\n" \
  --label "incident,post-mortem"
```

Provide a post-mortem template populated with the incident details gathered during investigation.
