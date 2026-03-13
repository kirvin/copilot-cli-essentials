---
description: Stage and commit changes with a well-formatted conventional commit message
argument-hint: "[message] [--all]"
allowed-tools: Bash, Glob, Grep, Read, Skill, Agent
---

Load the preflight checks skill: `Skill(cpe:preflight-checks)`
Load the writer skill: `Skill(cpe:writer)`

Stage and commit the current changes with a clear, conventional commit message.

## Step 1: Parse Arguments

Parse `$ARGUMENTS`:
- If a message is provided, use it as the commit message basis
- `--all` flag: stage all tracked modified files before committing
- If no arguments, infer the message from the diff

## Step 2: Preflight Checks

Before staging anything, run preflight checks using `Skill(cpe:preflight-checks)` to detect and run linters, formatters, and type checkers. Fix any issues found before proceeding.

## Step 3: Stage Changes

Check `git status` to see what's changed.

If `--all` was passed, stage all tracked modified files:
```bash
git add -u
```

Otherwise, show the user what's staged and unstaged. If nothing is staged, ask which files to include.

## Step 4: Delegate to Haiku

Delegate the actual commit to the `cpe:haiku` agent with these instructions:

```
Review the staged diff and write a conventional commit message.

Run: git diff --cached

Format:
  <type>(<scope>): <subject>

  [optional body — only if the why isn't obvious from the subject]

Types: feat, fix, docs, style, refactor, test, chore, ci, perf, build

Rules:
- Subject: imperative mood, ≤72 chars, no period
- Scope: optional, lowercase (e.g., api, auth, deploy, ci)
- Body: explain WHY, not WHAT; wrap at 72 chars
- No co-author lines unless asked

Then commit:
  git commit -m "<message>"

If the pre-commit hook fails, fix the reported issues and retry. Max 3 attempts.
After success, report: files committed, message used, any hook fixes applied.
```

## Step 5: Verify and Report

After the haiku agent completes:
1. Run `git log --oneline -1` to confirm the commit was created
2. Report the commit hash, message, and files included
