# Jenkins Log Investigation

## Fetching Logs

Jenkins exposes logs via its REST API and optionally the `jenkins-cli.jar`.

```bash
# Jenkins base URL and credentials (set as env vars or ask user)
# JENKINS_URL=https://jenkins.example.com
# JENKINS_USER=username
# JENKINS_TOKEN=api-token

# List recent builds for a job
curl -s "${JENKINS_URL}/job/${JOB_NAME}/api/json?tree=builds[number,result,timestamp,duration]&depth=1" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | jq -r '.builds[] | "\(.number) \(.result // "RUNNING") \(.timestamp)"' | head -10

# Get console log for a specific build
curl -s "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/consoleText" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | tail -200

# Get console log for the last failed build
curl -s "${JENKINS_URL}/job/${JOB_NAME}/lastFailedBuild/consoleText" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | grep -A 20 "ERROR\|FAILED\|Exception\|BUILD FAILURE" | head -100

# For Pipeline jobs — get stage log
curl -s "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/wfapi/describe" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | jq -r '.stages[] | "\(.id) \(.status) \(.name)"'
```

## Common Error Patterns

| Pattern | Meaning | Where to look |
|---------|---------|---------------|
| `BUILD FAILURE` | Maven/Gradle build failed | Lines above for compile/test errors |
| `Hudson.AbortException` | Pipeline step explicitly aborted | `error()` call or timeout |
| `FlowInterruptedException` | Pipeline interrupted (timeout/abort) | Check `timeout` step configuration |
| `java.io.IOException: Cannot run program` | Missing executable on agent | Tool not installed or PATH not set |
| `groovy.lang.MissingMethodException` | Undefined method in Jenkinsfile | Typo or missing plugin |
| `SCM checkout failed` | Git clone/fetch failed | Credentials config, repo access |
| `java.lang.OutOfMemoryError` | JVM heap exhausted | Increase `-Xmx` in Jenkins config |
| `No such DSL method` | Jenkinsfile uses unavailable step | Plugin missing or wrong version |
| `permission denied` | File/command permission issue | Agent user permissions |
| `UNSTABLE` | Tests passed but with warnings/failures | Check test report |

## Jenkinsfile Investigation

```bash
# Read the pipeline definition
cat Jenkinsfile

# Check for multiple Jenkinsfiles
ls Jenkinsfile* 2>/dev/null

# Find stage definitions
grep -n "stage(" Jenkinsfile

# Find sh/bat steps
grep -n "^\s*sh\s\|^\s*bat\s" Jenkinsfile | head -20

# Find credential usage
grep -n "credentials\|withCredentials\|usernamePassword" Jenkinsfile
```

## Filtering Console Output

Jenkins console logs are verbose. Filter aggressively:

```bash
# From a downloaded console log
LOG_FILE=console.txt

# Find build result line
grep -n "Finished: \|BUILD SUCCESS\|BUILD FAILURE\|BUILD UNSTABLE" $LOG_FILE

# Find errors (Maven/Gradle style)
grep -n "\[ERROR\]\|\[FATAL\]\|ERROR:" $LOG_FILE | head -20

# Find test failures
grep -n "Tests run:.*Failures:\|FAILED\|AssertionError" $LOG_FILE | head -20

# Find the first error (root cause)
grep -n "Exception\|Error\|FAILED" $LOG_FILE | head -5
# Then read context around first line number:
sed -n '${LINE_NUM-20},${LINE_NUM+30}p' $LOG_FILE
```

## Plugin & Tool Issues

```bash
# Check shared library references
grep -n "@Library\|library(" Jenkinsfile

# Check tool declarations
grep -n "tools {" -A 5 Jenkinsfile

# Check agent/node configuration
grep -n "agent \|node(" Jenkinsfile | head -10
```

## Pipeline Stage Investigation

For declarative pipelines, get per-stage status:

```bash
# Stage results with timestamps
curl -s "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/wfapi/describe" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | jq -r '.stages[] | "\(.status) \(.durationMillis)ms \(.name)"'

# Log for a specific failing stage
STAGE_ID=$(curl -s "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/wfapi/describe" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | jq -r '.stages[] | select(.status == "FAILED") | .id' | head -1)

curl -s "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/execution/node/${STAGE_ID}/wfapi/log" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  | jq -r '.text' | tail -100
```

## Credentials & Environment

```bash
# Check what environment the build runs in
grep -n "environment {" -A 10 Jenkinsfile

# Check withEnv / withCredentials blocks
grep -n "withEnv\|withCredentials" Jenkinsfile

# Check agent labels (which node runs this)
grep -n "label\|agent {" Jenkinsfile | head -10
```
