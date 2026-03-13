---
name: test
description: Use when the user wants to run tests and analyze failures, optionally fixing them.
---

Run the project's tests and analyze any failures.

## Step 1: Determine Options

Infer from the user's message:
- A specific test path or pattern to run (e.g., `src/auth`, `*.spec.ts`, `test/deploy`) — if none mentioned, run all tests
- Whether to run in watch mode
- Whether to attempt to fix failing tests after analyzing them

## Step 2: Run Tests and Analyze

1. Detect the test command:
   - Check package.json "scripts.test"
   - Check for jest.config.*, vitest.config.*, pytest.ini, go.mod, Makefile test targets
   - Fall back to: npx jest / npx vitest / pytest / go test ./...

2. Run tests:
   ```
   <test-command> [--testPathPattern=<pattern> if pattern given] [--watch if watch mode requested]
   ```

3. Analyze output:
   - Count: X passed, Y failed, Z skipped
   - For each failure:
     - Test name and file
     - Error message (first 20 lines)
     - Likely root cause (typo? missing mock? environment issue? logic bug?)

4. If the user requested fixing failures:
   - For each failing test, read the test file and relevant source
   - Determine: is this a broken test or a real bug?
   - Fix the root cause (prefer fixing source over changing test expectations)
   - Re-run the specific failing test to confirm fix
   - Report what was changed

5. Report:
   - Final pass/fail counts
   - Summary of failures with root cause analysis
   - Files changed (if fixes were applied)
   - Any tests that couldn't be fixed and why

## Step 3: Report

Present the test results. If failures remain and fixing was not requested, suggest running the test skill again with a fix request, or tracking the failures as issues.
