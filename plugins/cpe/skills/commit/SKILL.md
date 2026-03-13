---
name: commit
description: Use when the user wants to stage and commit changes with a conventional commit message.
---

Load the preflight checks skill: `Skill(cpe:preflight-checks)`
Load the writer skill: `Skill(cpe:writer)`

Stage and commit the current changes with a clear, conventional commit message.

## Step 1: Parse Intent

Determine from the user's message:
- Whether they provided a specific commit message to use as the basis
- Whether they want all tracked modified files staged (equivalent to `--all`)
- If no message or preference is given, infer the message from the diff

## Step 2: Preflight Checks

Before staging anything, run preflight checks using `Skill(cpe:preflight-checks)` to detect and run linters, formatters, and type checkers. Fix any issues found before proceeding.

## Step 3: Stage Changes

Check `git status` to see what's changed.

If the user wants all tracked modified files staged:
```bash
git add -u
```

Otherwise, show the user what's staged and unstaged. If nothing is staged, ask which files to include.

## Step 4: Write and Execute the Commit

Review the staged diff and write a conventional commit message.

```bash
git diff --cached
```

Format:
```
<type>(<scope>): <subject>

[optional body — only if the why isn't obvious from the subject]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`

Rules:
- Subject: imperative mood, 72 chars or fewer, no period
- Scope: optional, lowercase (e.g., `api`, `auth`, `deploy`, `ci`)
- Body: explain WHY, not WHAT; wrap at 72 chars
- No co-author lines unless the user asks

Then commit:
```bash
git commit -m "<message>"
```

If the pre-commit hook fails, fix the reported issues and retry. Max 3 attempts. After success, report: files committed, message used, any hook fixes applied.

## Step 5: Verify and Report

Run `git log --oneline -1` to confirm the commit was created. Report the commit hash, message, and files included.
