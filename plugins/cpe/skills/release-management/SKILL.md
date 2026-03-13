---
name: release-management
description: Release strategy, semantic versioning, changelog authoring, and GitHub release mechanics. Use when planning a release, deciding version bumps, writing changelogs, or managing release branches.
---

# Release Management

**Core principle:** A release is a promise to your users. The version number communicates the scope of change. The changelog explains what changed and why. Both must be accurate.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Deciding version numbers, semver rules | **Versioning** | `references/versioning.md` |
| Writing changelogs, commit conventions | **Changelog** | `references/changelog.md` |
| Release branches, hotfixes, branching | **Branching** | `references/release-branches.md` |

---

## Core Principles

### Semver is a contract

- **Major (X.0.0)**: Breaking change — users must update their code
- **Minor (1.X.0)**: New capability — backward-compatible additions
- **Patch (1.1.X)**: Bug fix — backward-compatible corrections

When in doubt: if a consumer of your API/library would need to change their code to keep working, it's a major bump.

### Release from a known-good state

Never release from:
- A dirty working tree
- A branch without passing CI
- A commit with unresolved review feedback

The release commit should be the one CI validated, not a new one created just before tagging.

### Changelogs are for users, not for git

A changelog is not a git log. It's a curated summary of what changed, written for the person who will consume your software. Group by impact, not by type.

Good: "Fixed crash when uploading files larger than 100MB"
Bad: "fix(upload): handle buffer overflow in multipart processor"

### Every release is reversible

Before cutting any release, identify:
1. The rollback tag/commit
2. The rollback procedure (revert + re-tag or deploy previous artifact)
3. Who owns the rollback decision
