# GitHub Actions Log Investigation

## Fetching Logs

```bash
# List recent runs — see what failed
gh run list --limit 20 --json databaseId,name,conclusion,createdAt,headBranch \
  | jq -r '.[] | "\(.databaseId) \(.conclusion // .status) \(.name) (\(.headBranch)) \(.createdAt)"'

# Failed jobs only — fastest, smallest output
gh run view $RUN_ID --log-failed 2>/dev/null

# Step-level summary — which job/step failed without loading full log
gh run view $RUN_ID --json jobs \
  | jq -r '.jobs[] | "\(.name): \(.conclusion)\n" +
    (.steps | map(select(.conclusion == "failure")) | map("  ✗ \(.name)") | join("\n"))'

# Full log — only if --log-failed is insufficient
gh run view $RUN_ID --log 2>/dev/null | grep -A 30 "##\[error\]"
```

## Common Error Patterns

| Pattern in log | Meaning | Where to look |
|----------------|---------|---------------|
| `##[error]` | GitHub-annotated error | Read the line + 10 lines after |
| `Process completed with exit code N` | Step failed | Read the step output above |
| `Error: Resource not accessible by integration` | Missing permissions | Check `permissions:` block in workflow |
| `fatal: repository ... not found` | Checkout failed / bad token | `GITHUB_TOKEN` scope or repo access |
| `npm ERR!` | npm script/install failure | Read `npm-debug.log` section above |
| `ENOENT: no such file or directory` | Missing file or command | Check path and working-directory |
| `::error file=` | Annotation from a step | File + line reference in the annotation |
| `Timeout of Xms exceeded` | Step hit timeout-minutes | Increase timeout or fix slow operation |
| `Cannot connect to the Docker daemon` | Docker not running in runner | Check `services:` or add Docker setup step |

## Filtering Patterns

```bash
# Extract just the failing step output from --log-failed
gh run view $RUN_ID --log-failed 2>/dev/null | grep -v "^##\[group\]\|^##\[endgroup\]" | head -200

# Find all error annotations
gh run view $RUN_ID --log 2>/dev/null | grep "##\[error\]"

# Get step timing to identify slow steps
gh run view $RUN_ID --json jobs \
  | jq -r '.jobs[].steps[] | "\(.completedAt // "running") \(.startedAt) \(.name)"' \
  | head -30
```

## Workflow File Cross-Reference

When a step fails, read the workflow YAML to understand what the step is doing:

```bash
# Find the workflow file
ls .github/workflows/

# Read the relevant job/step
grep -A 20 "name: $STEP_NAME" .github/workflows/$WORKFLOW_FILE
```

## Re-running Failed Jobs

```bash
# Re-run only failed jobs (preserves passing ones)
gh run rerun $RUN_ID --failed

# Re-run entire workflow
gh run rerun $RUN_ID

# Trigger fresh run on current branch
gh workflow run $WORKFLOW_NAME --ref $(git branch --show-current)
```

## Debugging Permissions Errors

```bash
# Check what permissions the workflow declares
grep -A 10 "^permissions:" .github/workflows/$WORKFLOW_FILE
grep -A 5 "permissions:" .github/workflows/$WORKFLOW_FILE | head -20

# Common permission fixes:
# contents: write       — for git push, creating releases
# pull-requests: write  — for PR comments
# id-token: write       — for OIDC cloud auth
# packages: write       — for GHCR pushes
```
