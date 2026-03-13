---
name: branching-strategy
description: Git branching patterns — trunk-based development, feature branches, naming conventions, PR workflow, and merge strategies. Use when establishing team branching standards or deciding how to structure a complex change.
---

# Branching Strategy

**Core principle:** A branching strategy is a communication protocol. It tells the team what's ready to ship, what's in progress, and what's stable. Choose the simplest strategy that meets your deployment and team needs.

## Choosing a Strategy

| Team size | Release cadence | Recommended strategy |
|-----------|-----------------|---------------------|
| Small (1–5) | Continuous | Trunk-based |
| Medium (5–20) | Weekly/bi-weekly | Trunk-based + feature flags |
| Large (20+) | Multiple release trains | Release branches |
| OSS / multi-version | Long-term support | GitFlow-lite |

**Default: trunk-based development.** Most teams that use GitFlow don't need to. Long-lived branches cause merge conflicts, stale context, and delayed integration.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Branch naming, PR conventions | **Conventions** | `references/conventions.md` |
| Trunk-based workflow details | **Trunk-based** | `references/trunk-based.md` |
| Release branches, GitFlow | **Release Branching** | `references/release-branches.md` |

---

## Core Principles

### Branches are temporary

The goal of a branch is to be merged. Long-lived branches accumulate drift and increase merge conflict risk. If a branch lives more than a few days, consider breaking it into smaller pieces.

### Main must always be deployable

Nothing merges to `main` without passing CI. No exceptions. If main is broken, fixing it is the team's top priority — no other work until it's green.

### Small PRs, fast reviews

A PR that changes 50 lines gets reviewed in minutes. A PR that changes 500 lines gets rubber-stamped or stalls. Break large changes into a sequence of small, reviewable pieces.

### Protect the integration point

`main` (or `develop` in GitFlow) is where integration happens. Protect it:
- Require CI to pass before merge
- Require at least one reviewer
- Don't allow force pushes
- Enable required status checks
