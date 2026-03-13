---
name: deployment-strategies
description: Deployment patterns — blue/green, canary, rolling, feature flags, and database migration strategies. Use when planning a risky deploy, designing a deployment pipeline, or managing database changes alongside code deployments.
---

# Deployment Strategies

**Core principle:** The goal of a deployment strategy is to get new code to production safely with minimal user impact and fast rollback capability.

## Choosing a Strategy

| Strategy | Risk tolerance | Rollback speed | Complexity |
|----------|----------------|----------------|------------|
| All-at-once | High | Slow (re-deploy) | Low |
| Rolling | Medium | Medium | Low |
| Blue/Green | Low | Instant | Medium |
| Canary | Very low | Instant | High |
| Feature flags | Very low | Instant | Medium |

**Default for most teams:** Rolling deploy with feature flags for high-risk changes.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Blue/green, canary, rolling patterns | **Patterns** | `references/patterns.md` |
| Feature flags implementation | **Feature Flags** | `references/feature-flags.md` |
| Database migrations with zero downtime | **DB Migrations** | `references/db-migrations.md` |

---

## Core Principles

### Decouple deploy from release

Deploying code and releasing features to users are separate decisions. A feature flag lets you deploy on Tuesday and release on Thursday without another deploy.

### Test in production (safely)

Staging environments don't capture production-scale behavior. Canary releases and feature flags let you test with real production traffic at controlled scope.

### Databases change slower than code

Never tie a code deploy to a database migration that can't be rolled back. Use the expand-contract pattern: deploy the schema change first (backward-compatible), then deploy the code, then remove the old schema.

### Every deploy needs a rollback plan

Before deploying anything, identify: what command do we run if this breaks? How long will rollback take? If rollback takes more than 5 minutes or requires complex steps, simplify the deploy.
