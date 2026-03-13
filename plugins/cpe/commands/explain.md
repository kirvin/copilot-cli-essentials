---
description: Explain a file, function, or concept in detail
argument-hint: "<file-or-function-or-concept>"
allowed-tools: Bash, Glob, Grep, Read
---

Explain what `$ARGUMENTS` does — deeply and precisely, for someone who needs to understand it well enough to change it.

## Step 1: Parse Arguments

`$ARGUMENTS` may be:
- A file path: `src/deploy/rollback.ts`
- A function or class name: `handleRollback`
- A concept or system: `blue-green deployment`, `CODEOWNERS resolution`
- A combination: `the retry logic in src/ci/retry.ts`

## Step 2: Locate and Read

Find the relevant code:

```bash
# Find a file
ls src/**/*rollback* 2>/dev/null

# Find a function/class
grep -rn "function handleRollback\|class Rollback\|handleRollback =" src/ --include="*.ts" --include="*.js" -l
```

Read the file(s). If it's a concept, search for relevant entry points and configuration.

## Step 3: Trace the Context

Understand how this fits into the larger system:
- What calls it? Search for callers.
- What does it call? Trace dependencies.
- What data flows in and out?
- What are the failure modes?

## Step 4: Explain

Structure the explanation:

### What it is
One sentence: what this thing does and why it exists.

### How it works
Step-by-step walkthrough of the logic. Use code snippets for non-obvious parts. Explain the "why" behind decisions that might look strange.

### Data flow
What goes in, what comes out, and what side effects occur.

### Dependencies
Key things it relies on — libraries, services, environment variables, config.

### Gotchas
Edge cases, known issues, non-obvious behavior, things that have caused bugs before.

### How to change it
What to watch out for when modifying this code. What would break if changed carelessly.

Keep the explanation sharp. Don't pad it — if something is obvious, skip it. The goal is the insight that saves someone an hour of reading.
