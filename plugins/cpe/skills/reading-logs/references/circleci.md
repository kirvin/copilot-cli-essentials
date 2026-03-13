# CircleCI Log Investigation

## Fetching Logs

CircleCI exposes logs via API and the `circleci` CLI.

```bash
# CLI — list recent pipelines for current branch
circleci pipeline list --branch $(git branch --show-current) 2>/dev/null | head -20

# Get recent workflow runs via API (requires CIRCLE_TOKEN env var)
BRANCH=$(git branch --show-current)
REPO_SLUG=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')

curl -s "https://circleci.com/api/v2/project/gh/${REPO_SLUG}/pipeline?branch=${BRANCH}" \
  -H "Circle-Token: ${CIRCLE_TOKEN}" \
  | jq -r '.items[] | "\(.id) \(.state) \(.created_at)"' | head -10

# Get workflows for a pipeline
curl -s "https://circleci.com/api/v2/pipeline/$PIPELINE_ID/workflow" \
  -H "Circle-Token: ${CIRCLE_TOKEN}" \
  | jq -r '.items[] | "\(.id) \(.status) \(.name)"'

# Get jobs for a workflow
curl -s "https://circleci.com/api/v2/workflow/$WORKFLOW_ID/job" \
  -H "Circle-Token: ${CIRCLE_TOKEN}" \
  | jq -r '.items[] | "\(.job_number) \(.status) \(.name)"'

# Get log output for a specific job step
curl -s "https://circleci.com/api/v2/project/gh/${REPO_SLUG}/job/${JOB_NUMBER}/artifacts" \
  -H "Circle-Token: ${CIRCLE_TOKEN}" \
  | jq -r '.items[].url'
```

## Common Error Patterns

| Pattern | Meaning | Where to look |
|---------|---------|---------------|
| `exit code: 1` / `exit status 1` | Command failed | Output of the step above |
| `OOMKilled` | Out of memory | Increase `resource_class`, check for memory leaks |
| `Too long with no output` | 10-min no-output timeout | Add progress output or increase `no_output_timeout` |
| `Exited with code exit status 137` | OOM kill (137 = 128+9) | Increase executor size |
| `Error: Cannot find module` | npm/node dependency missing | Check `npm ci` / `npm install` step ran |
| `CIRCLE_TOKEN` / auth errors | API token not set or expired | Check project env vars in CircleCI settings |
| `No space left on device` | Disk full on executor | Clean build artifacts, use smaller `resource_class` |
| `docker: Error response from daemon` | Docker layer issue | Check `setup_remote_docker` is configured |

## Config File Investigation

```bash
# Read the CircleCI config
cat .circleci/config.yml

# Find the failing job definition
grep -A 30 "^  $JOB_NAME:" .circleci/config.yml

# Find orb versions (may be outdated)
grep -A 5 "^orbs:" .circleci/config.yml

# Check for resource_class settings
grep "resource_class" .circleci/config.yml
```

## Filtering Local Artifacts

If CircleCI artifacts are downloaded locally:

```bash
# Find CircleCI output files
find . -name "*.xml" -path "*/test-results/*" 2>/dev/null | head -10
find . -name "*.log" -path "*circleci*" 2>/dev/null | head -10

# Parse JUnit XML for test failures
grep -A 5 'failure\|error' test-results/*.xml 2>/dev/null | head -40
```

## Debugging via Config Validation

```bash
# Validate config locally before pushing
circleci config validate .circleci/config.yml 2>/dev/null

# Process config (expand orbs, check substitution)
circleci config process .circleci/config.yml 2>/dev/null | head -100
```

## Common Config Issues

```yaml
# Missing no_output_timeout on slow steps
- run:
    name: Run integration tests
    no_output_timeout: 20m    # Add this if tests take > 10 min
    command: npm run test:integration

# Missing setup_remote_docker for Docker builds
- setup_remote_docker:
    version: docker24
    docker_layer_caching: true

# resource_class too small for workload
jobs:
  build:
    resource_class: large    # medium → large → xlarge
```

## Re-running Workflows

```bash
# Re-run failed jobs only via API
curl -X POST "https://circleci.com/api/v2/workflow/$WORKFLOW_ID/rerun" \
  -H "Circle-Token: ${CIRCLE_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"from_failed": true}'

# Re-run from beginning
curl -X POST "https://circleci.com/api/v2/workflow/$WORKFLOW_ID/rerun" \
  -H "Circle-Token: ${CIRCLE_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{}'
```
