# Incident Triage

## Severity Framework

| SEV | Condition | Response time | Update cadence |
|-----|-----------|---------------|----------------|
| SEV1 | Production fully down, data loss/corruption, security breach | Immediate | Every 15 min |
| SEV2 | Major feature broken, significant performance degradation | 15 minutes | Every 30 min |
| SEV3 | Minor feature broken, workaround available | 2 hours | Every hour |
| SEV4 | Cosmetic issue, no user impact | Next business day | As needed |

## First 5 Minutes Checklist

```
[ ] What is broken? (observable symptom, not root cause)
[ ] When did it start? (approximate timestamp)
[ ] Who is affected? (all users? subset? internal only?)
[ ] What changed recently? (deploy, config, dependency)
[ ] Is it getting worse, stable, or recovering?
[ ] Assign severity (SEV1–SEV4)
[ ] Identify incident commander
[ ] Open incident channel / war room
```

## Blast Radius Assessment

Quantify impact to prioritize urgency:

- **Users affected**: All / Percentage / Specific cohort (paid users, mobile users, EU region)
- **Functions affected**: Core workflows / Secondary features / Admin only
- **Data risk**: Potential data loss or corruption? (auto-escalate to SEV1)
- **Revenue impact**: Is checkout/payments affected?

## Initial Communication (SEV1/SEV2)

Send within first 10 minutes:

```
[INCIDENT DECLARED] SEV{N}: {Brief title}

Status: Investigating
Time detected: {HH:MM UTC}
Impact: {who/what is affected}
What we know: {1-2 sentences}
Next update: {HH:MM UTC}

IC: {name}
```

## Escalation Triggers

Escalate severity when:
- Impact expands beyond initial assessment
- Root cause is unknown after 30 minutes
- Mitigation attempts are failing
- Data integrity is at risk
- Security breach is suspected
