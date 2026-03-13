---
name: dependency-management
description: Dependency auditing, upgrades, and maintenance — CVE triage, safe upgrade paths, lockfile hygiene, and automated update strategies. Use when auditing dependencies, planning upgrades, or managing Dependabot PRs.
---

# Dependency Management

**Core principle:** Dependencies are code you didn't write but are responsible for. Keeping them current reduces security risk, technical debt, and compatibility gaps — but upgrades carry their own risk and must be tested.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Auditing for CVEs, assessing risk | **Auditing** | `references/auditing.md` |
| Upgrading dependencies safely | **Upgrades** | `references/upgrades.md` |
| Automating with Dependabot, Renovate | **Automation** | `references/automation.md` |

---

## Core Principles

### Keep dependencies shallow

Every dependency is a liability. Before adding one, ask:
- Can this be implemented with < 50 lines of code?
- Is it actively maintained?
- Does it bring its own transitive dependencies?

### Separate security fixes from feature upgrades

Security patches (patch bumps, CVE fixes) should be fast-tracked and merged immediately. Feature upgrades (minor/major) should go through normal testing and review.

Don't bundle them — it obscures what's a safety fix vs. what's a capability change.

### Test upgrades in isolation

When upgrading a dependency:
1. Upgrade only that dependency
2. Run the full test suite
3. Check for behavioral changes in the changelog
4. Review any deprecated API usage

Upgrading five dependencies at once makes it impossible to identify which one broke something.

### Lockfiles are truth

The lockfile (not `package.json`, not `pyproject.toml`) defines what actually installs. Treat it as source of truth. Review lockfile diffs in PRs — unexplained lockfile changes are a supply chain risk signal.
