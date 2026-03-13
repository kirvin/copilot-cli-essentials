# Incident Investigation

## Hypothesis-Driven Investigation

Form 1–3 hypotheses immediately based on what changed recently. Test each in 5–10 minutes. If none confirm, form new hypotheses.

Avoid: open-ended exploration without a hypothesis. It wastes time.

## Common Investigation Checklist

```bash
# 1. What changed recently?
git log --oneline --since="4 hours ago"
git log --oneline -10

# 2. Recent deploys
gh run list --limit 10 --json name,conclusion,createdAt,headSha \
  | jq -r '.[] | "\(.createdAt) \(.conclusion) \(.name)"' 2>/dev/null

# 3. Recent merged PRs
gh pr list --state merged --limit 5 --json number,title,mergedAt \
  | jq -r '.[] | "\(.mergedAt) #\(.number) \(.title)"' 2>/dev/null

# 4. Config changes
git diff HEAD~5 -- "*.env*" "*.yaml" "*.yml" "*.json" "*.toml" 2>/dev/null \
  | grep "^[+-]" | grep -v "^---\|^+++" | head -30

# 5. Error patterns in logs (if available locally)
find . -name "*.log" -newer /tmp -not -path "*/node_modules/*" 2>/dev/null \
  | xargs grep -l "ERROR\|FATAL\|panic\|Exception" 2>/dev/null | head -5
```

## Narrowing the Blast Radius

Questions to ask:
- When exactly did it start? (correlate with deploys/config changes)
- Is it all users or a subset? (region, user tier, browser, device)
- Is it all requests or a specific endpoint/flow?
- Is it 100% failure or intermittent?
- Did anything change in infrastructure? (scaling event, node failure, DB failover)

## Common Root Cause Categories

| Category | Signals | Mitigation |
|----------|---------|-----------|
| Bad deploy | Correlated with release timing | Rollback |
| Config change | Env var / feature flag change | Revert config |
| Database | Slow queries, connection errors | Scale, index, or failover |
| Dependency failure | External service errors | Circuit breaker, fallback |
| Traffic spike | Latency increase, 429/503 errors | Scale up, rate limit |
| Certificate expiry | TLS errors, 495/496 status | Renew cert |
| Disk/memory | OOM kills, disk full errors | Scale storage, fix leak |
| Data corruption | Unexpected results, constraint violations | Stop writes, assess scope |

## Rollback Decision Matrix

Roll back when:
- Incident correlates with a recent deploy (< 2 hours)
- Root cause is unknown after 15 minutes of investigation
- The fix would take > 30 minutes to code and test

Don't roll back when:
- The deploy is > 6 hours old (likely not the cause)
- Rollback would cause a worse data migration issue
- The issue is infrastructure-side (rolling back code won't help)
