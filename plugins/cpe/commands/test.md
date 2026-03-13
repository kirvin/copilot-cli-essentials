---
description: Run tests and analyze failures
argument-hint: "[path-or-pattern] [--watch] [--fix]"
allowed-tools: Bash, Glob, Grep, Read, Skill, Agent
---

Run the project's tests and analyze any failures. Delegates to `cpe:haiku` for execution.

## Step 1: Parse Arguments

Parse `$ARGUMENTS`:
- Path or pattern: run only matching tests (e.g., `src/auth`, `*.spec.ts`, `test/deploy`)
- `--watch`: run in watch mode
- `--fix`: attempt to fix failing tests after analyzing them

## Step 2: Delegate to Haiku

Delegate to the `cpe:haiku` agent with these instructions:

```
Run the project's tests and report results.

1. Detect the test command:
   - Check package.json "scripts.test"
   - Check for jest.config.*, vitest.config.*, pytest.ini, go.mod, Makefile test targets
   - Fall back to: npx jest / npx vitest / pytest / go test ./...

2. Run tests:
   <test-command> [--testPathPattern=<pattern> if pattern given] [--watch if --watch flag]

3. Analyze output:
   - Count: X passed, Y failed, Z skipped
   - For each failure:
     - Test name and file
     - Error message (first 20 lines)
     - Likely root cause (typo? missing mock? environment issue? logic bug?)

4. If --fix was requested:
   - For each failing test, read the test file and relevant source
   - Determine: is this a broken test or a real bug?
   - Fix the root cause (prefer fixing source over changing test expectations)
   - Re-run the specific failing test to confirm fix
   - Report what was changed

5. Report:
   - Final pass/fail counts
   - Summary of failures with root cause analysis
   - Files changed (if --fix was used)
   - Any tests that couldn't be fixed and why
```

## Step 3: Report

After haiku completes, present the test results. If failures remain and `--fix` was not used, suggest running `/cpe:test --fix` or `/cpe:fix-issue` for tracked bugs.
