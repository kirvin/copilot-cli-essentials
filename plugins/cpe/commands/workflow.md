---
description: Debug, fix, or optimize a GitHub Actions workflow
argument-hint: "[workflow-name|run-id] [--fix]"
allowed-tools: Bash, Glob, Grep, Read, Skill
---

Diagnose and fix GitHub Actions workflow failures or performance issues.

Load the ci-cd-pipelines skill: `Skill(cpe:ci-cd-pipelines)`

## Step 1: Identify Target

Parse `$ARGUMENTS`:
- Run ID (numeric) — inspect that specific run
- Workflow name — find latest failing run for that workflow
- No argument — show all recent failures and prompt

```bash
# List recent workflow runs with status
gh run list --limit 20 --json name,status,conclusion,headBranch,databaseId,createdAt \
  | jq -r '.[] | "\(.databaseId) \(.conclusion // .status) \(.name) (\(.headBranch))"'
```

---

## Step 2: Fetch Failure Details

```bash
# Get run details
gh run view $RUN_ID --log-failed 2>/dev/null | head -200

# Or full log for the failed job
gh run view $RUN_ID --log 2>/dev/null | grep -A 30 "Error\|FAIL\|failed\|exit code"
```

Read the workflow YAML to understand structure:
```bash
ls .github/workflows/
cat .github/workflows/$WORKFLOW_FILE
```

---

## Step 3: Diagnose Root Cause

Apply systematic debugging. Common failure categories:

| Category | Symptoms | Diagnosis |
|----------|----------|-----------|
| Dependency install | `npm ci` / `pip install` errors | Cache invalidation, lockfile mismatch |
| Test failures | Test output in logs | Read test output, identify specific failure |
| Lint/format | ESLint, prettier, ruff errors | Run locally to reproduce |
| Build errors | Compile/bundle failures | Missing env vars, version mismatches |
| Permission errors | 403, permission denied | Token scopes, GITHUB_TOKEN permissions |
| Timeout | Step exceeded time limit | Slow test, infinite loop, missing cache |
| Flaky | Intermittent failures | Race conditions, external API, timing |

---

## Step 4: Fix Mode (`--fix`)

If `--fix` flag present, apply the fix directly:

1. Read the workflow file
2. Apply targeted fix (don't rewrite the whole workflow)
3. Show diff before writing
4. Commit: `fix(ci): [description of fix]`

Common fixes to apply:
- Add/restore cache steps for node_modules, pip, cargo
- Pin action versions that are floating (`@main` → `@v3`)
- Add `continue-on-error: false` where needed
- Fix permissions blocks (`permissions: contents: write`)
- Add timeout-minutes to slow steps

---

## Step 5: Re-run or Validate

```bash
# Re-run failed jobs only
gh run rerun $RUN_ID --failed

# Or trigger fresh run on current branch
gh workflow run $WORKFLOW_NAME
```

---

## Output

- Root cause summary (1-2 sentences)
- Fix applied or recommended (with file:line reference)
- Whether workflow was re-triggered
