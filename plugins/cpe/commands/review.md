---
description: Comprehensive code review of the current branch using the code-reviewer agent
argument-hint: "[--base <branch>] [--fix-all]"
allowed-tools: Bash, Glob, Grep, Read, Skill, Agent
---

Run a thorough code review of changes on the current branch, then present findings and offer to fix issues.

## Step 1: Parse Arguments

Parse `$ARGUMENTS`:
- `--base <branch>`: compare against this branch (default: `main`)
- `--fix-all`: after the review, automatically fix all Critical and Important issues

## Step 2: Confirm Scope

```bash
git branch --show-current
git log --oneline origin/main...HEAD
git diff origin/main...HEAD --stat
```

Show the user what will be reviewed (files changed, commits in scope).

## Step 3: Dispatch Code Reviewer

Invoke the `cpe:code-reviewer` agent:

```
Review all changes on the current branch vs <base-branch>.

Focus areas:
- Correctness: logic errors, edge cases, off-by-ones
- Security: injection, secrets exposure, auth bypasses, insecure defaults
- CI/CD: pipeline correctness, deployment risks, environment assumptions
- Error handling: silent failures, uncaught exceptions, missing retries
- Test coverage: missing tests for changed behavior, test quality
- Style: consistency with existing patterns

Load relevant skills based on what's changed:
- Skill(cpe:security-scanning) if security-sensitive code changed
- Skill(cpe:ci-cd-pipelines) if pipeline files changed
- Skill(cpe:writing-tests) if test coverage is a concern

Output format:
## Review Summary
[Overall assessment in 1-2 sentences]

## Issues
### Critical
[Must fix before merge]

### Important
[Should fix — meaningful risk or quality impact]

### Suggestions
[Optional improvements]

## Verdict
[ ] Approved — ready to merge
[ ] Approved with minor fixes
[ ] Changes requested — address Critical/Important issues first
```

## Step 4: Post-Review

After the review completes:

1. Present the findings clearly
2. If `--fix-all` was passed, implement all Critical and Important fixes, then re-run the review to confirm resolution
3. If `--fix-all` was not passed, ask the user which issues to address

When all requested fixes are done, confirm with a final `git diff --stat` and offer to commit.
