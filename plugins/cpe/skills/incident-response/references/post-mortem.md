# Post-Mortem Framework

## When to Write One

- All SEV1 incidents
- All SEV2 incidents
- SEV3 incidents with > 1hr resolution time or repeat occurrences
- Any incident that reveals a systemic gap

Write within 48 hours while details are fresh.

## Post-Mortem Template

```markdown
# Post-Mortem: [Incident Title]

**Date:** YYYY-MM-DD
**Severity:** SEV{N}
**Duration:** X hours Y minutes
**Impact:** [brief impact summary]

---

## Summary

[2–3 sentence overview: what happened, blast radius, how it was resolved]

---

## Timeline

| Time (UTC) | Event |
|------------|-------|
| HH:MM | Incident detected by [monitoring/user report] |
| HH:MM | SEV{N} declared, IC assigned |
| HH:MM | [investigation action] |
| HH:MM | Root cause identified: [brief] |
| HH:MM | Mitigation applied: [what was done] |
| HH:MM | Service restored |
| HH:MM | Incident resolved |

---

## Root Cause

[Specific technical cause. Not "human error." Not "deployment." The actual mechanism.]

Example: "A database index was dropped during the migration but the queries in the new code assumed it existed, causing full table scans that exceeded connection pool limits under production load."

---

## Contributing Factors

[Conditions that made the incident possible or made it worse]

- [factor 1]
- [factor 2]

---

## Impact

- Users affected: [N users / X% of traffic]
- Duration: [X minutes of full degradation, Y minutes of partial]
- Data: [any data loss, corruption, or exposure]

---

## What Went Well

[Things that helped contain or resolve the incident faster]

- [detection was fast because...]
- [rollback procedure was clear]

---

## What Went Poorly

[Things that made the incident worse or harder to resolve]

- [detection was slow because no alert for X]
- [rollback took longer than expected because...]

---

## Action Items

| Action | Owner | Due date | Issue |
|--------|-------|----------|-------|
| Add alert for [condition] | @person | YYYY-MM-DD | #123 |
| Write runbook for [scenario] | @person | YYYY-MM-DD | #124 |
| [fix the root cause] | @person | YYYY-MM-DD | #125 |

```

## Writing Guidelines

**Root cause:** Name the specific technical mechanism. "Human error" means the system allowed a dangerous action without sufficient safeguards — that's the real root cause.

**Action items must be specific and assigned.** "Improve monitoring" is not an action item. "Add alert for DB connection pool saturation > 80% for 2 minutes (#456)" is.

**Blameless means systemic.** Phrases like "engineer forgot to..." should be replaced with "the process didn't require..." or "there was no automated check for..."

## Publishing & Follow-Through

1. Share draft with responders for accuracy review
2. Publish to internal incident channel / docs
3. Track action items to completion in your issue tracker
4. Reference at next team retro
5. Link from the incident ticket for future reference
