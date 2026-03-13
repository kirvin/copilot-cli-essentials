---
name: fix-issue
description: Use when the user wants to fetch a GitHub issue and implement a fix for it.
---

Load the systematic debugging skill: `Skill(cpe:systematic-debugging)`

Fetch a GitHub issue, understand the problem, explore the codebase, implement a fix, and verify it.

## Step 1: Parse Intent

Determine from the user's message:
- The issue number to fix (required)
- Whether they want a dry run — analyze and plan the fix without writing any code

## Step 2: Fetch the Issue

```bash
gh issue view <number> --json title,body,labels,assignees,comments
```

Read the full issue body and all comments. Extract:
- What's broken or missing
- Reproduction steps (if given)
- Any constraints or context provided by commenters

## Step 3: Reproduce the Problem

If reproduction steps are available, try to reproduce the issue:
- Run the relevant command or code path
- Check logs for related errors
- Confirm the issue is present before writing any fix

## Step 4: Explore the Codebase

Find the relevant code:
```bash
# Search for keywords from the issue title/body
grep -rn "<keyword>" src/ --include="*.ts" --include="*.js" -l

# Trace entry points
grep -rn "export\|module.exports" src/<relevant-path>/ -l
```

Read the relevant files. Understand what's happening before touching anything.

## Step 5: Implement the Fix

Apply the fix. Follow these principles:
- Minimal change: fix the issue, don't refactor unrelated code
- Match existing style and patterns
- Add a test that reproduces the bug and passes after the fix

If the user requested a dry run, describe the fix you would make and stop here.

## Step 6: Verify

```bash
# Run tests
<test-command>

# If there's a linter
<lint-command>
```

Confirm the issue is resolved. Confirm no regressions.

## Step 7: Report

Summarize:
- Root cause of the issue
- What was changed (files and why)
- How to verify the fix
- Whether the issue can be closed (or needs follow-up)
