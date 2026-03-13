---
name: incident-response
description: Incident management — severity classification, investigation methodology, mitigation patterns, communication templates, and post-mortem framework. Use when responding to production incidents, writing runbooks, or conducting post-incident reviews.
---

# Incident Response

**Core principle:** Restore service first. Understand root cause second. Document everything third.

Speed matters more than perfection during an active incident. A fast rollback that restores service while root cause is still unknown is better than spending 30 minutes debugging while users are down.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Triage, severity levels, initial response | **Triage** | `references/triage.md` |
| Investigation techniques, root cause analysis | **Investigation** | `references/investigation.md` |
| Post-mortem writing, retrospectives | **Post-mortem** | `references/post-mortem.md` |

---

## Core Principles

### Declare early, escalate fast

An undeclared incident is a managed incident without coordination. Declaring early:
- Gets the right people involved
- Creates a shared timeline
- Enables parallel investigation tracks
- Starts the clock for SLA tracking

Better to declare and downgrade than to under-respond to a SEV2.

### Bias for rollback

When a recent deploy correlates with a production issue, roll back first. Investigation is faster when users aren't impacted. You can redeploy with a fix after you understand the root cause.

### Single incident commander

In a multi-person response, one person owns the incident and coordinates. Others investigate and implement mitigations. Without a coordinator, efforts duplicate, signals get lost, and communication breaks down.

### Timeline fidelity

Record timestamps for every decision and action during the incident. Memory degrades under stress. A detailed timeline is essential for root cause analysis and for the post-mortem.

### Blameless post-mortems

Root causes are systemic, not personal. "Human error" is never the root cause — it's a symptom of a system that made the wrong action easy and the right action hard. Post-mortems should generate system improvements, not accountability for individuals.
