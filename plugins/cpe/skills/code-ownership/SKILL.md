---
name: code-ownership
description: CODEOWNERS setup, review assignment, team structure in GitHub, and PR review standards. Use when establishing ownership boundaries, configuring CODEOWNERS, or improving PR review quality.
---

# Code Ownership

**Core principle:** Every piece of production code has an owner — a person or team responsible for its quality, reliability, and evolution. Unclear ownership leads to deferred maintenance, missed reviews, and orphaned systems.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| CODEOWNERS syntax, GitHub configuration | **CODEOWNERS** | `references/codeowners.md` |
| PR review quality, review standards | **Review Standards** | `references/review-standards.md` |

---

## Core Principles

### Ownership is responsibility, not gatekeeping

A code owner is accountable for the quality of their area — not a blocker for other teams making changes. The goal is visibility and accountability, not bureaucracy.

### Broad ownership doesn't work

"The backend team owns the backend" means nobody owns it. Effective ownership is:
- Specific enough to be meaningful (module or service level)
- Small enough to be manageable (1–5 people per area)
- Documented and discoverable (CODEOWNERS + team wiki)

### Rotate ownership intentionally

Tribal knowledge is a risk. When only one person understands a system, you have a bus factor of 1. Rotate ownership deliberately to spread knowledge.

### Review what you own

Code owners should review changes to their areas with genuine attention. A rubber-stamp approval is worse than no review — it implies the change was validated when it wasn't.
