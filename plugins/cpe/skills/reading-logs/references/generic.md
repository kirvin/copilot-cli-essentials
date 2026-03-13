# Generic Log Investigation

Use this when the CI system is unknown, when working with application logs rather than pipeline logs, or when multiple systems are involved.

## Detection First

```bash
# Identify CI system(s) in use
[ -d ".github/workflows" ]       && echo "GitHub Actions: load references/github-actions.md"
[ -f ".circleci/config.yml" ]    && echo "CircleCI: load references/circleci.md"
[ -f "Jenkinsfile" ]             && echo "Jenkins: load references/jenkins.md"

# Identify log files present
find . -name "*.log" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -20
find . -name "*.out" -o -name "test-results" -o -name "reports" 2>/dev/null | grep -v node_modules | head -10
```

If a CI-specific config file is found, load that reference instead of this one.

## Universal Log Filtering

```bash
# Find errors in any log file
grep -rn "ERROR\|FATAL\|CRITICAL\|Exception\|Traceback\|panic:" \
  --include="*.log" --include="*.out" \
  --exclude-dir=node_modules . 2>/dev/null | head -30

# First error (root cause) vs. last error (often symptom)
grep -n "ERROR\|FATAL" $LOG_FILE | head -3    # Start here

# Context around a specific line
sed -n '$((LINE-10)),$((LINE+30))p' $LOG_FILE

# Time-windowed filter (if log has ISO timestamps)
grep "2026-03-12T1[4-6]:" $LOG_FILE | grep -E "ERROR|WARN" | head -30

# Count error frequency (find most common errors)
grep "ERROR" $LOG_FILE | sort | uniq -c | sort -rn | head -10
```

## Structured Log Parsing (JSON logs)

Many modern apps emit JSON logs:

```bash
# Parse JSON log lines — find errors
cat app.log | jq -r 'select(.level == "error" or .level == "fatal") | "\(.timestamp) \(.message)"' 2>/dev/null | head -20

# Extract error with context fields
cat app.log | jq 'select(.level == "error")' 2>/dev/null | head -5

# Find errors in a time window
cat app.log | jq 'select(.level == "error" and (.timestamp > "2026-03-12T14:00:00"))' 2>/dev/null | head -10
```

## Test Result Parsing

```bash
# JUnit XML (Maven, Jest, pytest, etc.)
find . -name "*.xml" -path "*/test*" 2>/dev/null | head -5
grep -h '<failure\|<error' test-results/*.xml 2>/dev/null | sed 's/<[^>]*>//g' | head -20

# Jest/Vitest text output
grep -A 5 "✕\|FAIL\|● " test-output.log 2>/dev/null | head -40

# pytest output
grep -A 10 "FAILED\|AssertionError\|E  " pytest-output.log 2>/dev/null | head -40
```

## Common Root Cause Categories

| Error type | Typical cause | Investigate |
|------------|---------------|-------------|
| Missing file/command | Path issue, missing install step | Check working directory, tool installation |
| Connection refused | Service not started, wrong port | Check service startup, port config |
| Permission denied | Wrong user, missing chmod | Check file permissions, user context |
| Out of memory | Memory leak, too-small executor | Profile memory, increase resource limits |
| Timeout | Slow test, external dep, hang | Add timeouts, mock slow deps, find infinite loops |
| Auth failure | Expired/missing credentials | Check secret rotation, env var presence |
| Dependency missing | Install step failed or cached wrong | Clear cache, re-run install |
| Flaky test | Race condition, timing, external state | Run in isolation, add retries, fix state cleanup |

## Asking for More Context

If logs aren't available locally, ask the user to provide:
- The CI system URL and job/build number
- A copy of the console output (even partial)
- The relevant config file (Jenkinsfile, `.circleci/config.yml`, workflow YAML)
- Whether this is a first-time failure or a regression
