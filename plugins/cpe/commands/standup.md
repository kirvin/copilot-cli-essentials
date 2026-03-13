---
description: Generate standup notes from git history, PRs, and issues
argument-hint: "[--since=yesterday|--since=YYYY-MM-DD] [--author=username]"
allowed-tools: Bash, Glob, Grep, Read
---

Generate standup notes summarizing recent work from git history, merged PRs, and open issues.

## Step 1: Determine Time Range

Parse `$ARGUMENTS`:
- `--since=yesterday` — since yesterday (default)
- `--since=YYYY-MM-DD` — since a specific date
- `--author=username` — filter by author (default: current git user)

```bash
SINCE="${SINCE:-yesterday}"
AUTHOR=$(git config user.name 2>/dev/null || echo "")
GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")
```

---

## Step 2: Gather Data

```bash
# Commits by author in time range
git log --since="$SINCE" --author="$AUTHOR" \
  --pretty=format:"%h %s" --no-merges | head -30

# Merged PRs
gh pr list --state merged --author "$GH_USER" \
  --search "merged:>=$SINCE" \
  --json number,title,mergedAt \
  --limit 10 2>/dev/null | jq -r '.[] | "#\(.number) \(.title)"'

# Open PRs awaiting review or in progress
gh pr list --state open --author "$GH_USER" \
  --json number,title,reviewDecision,isDraft \
  --limit 10 2>/dev/null | \
  jq -r '.[] | "#\(.number) \(.title) [\(if .isDraft then "draft" else .reviewDecision // "open" end)]"'

# Recently closed issues
gh issue list --state closed --assignee "$GH_USER" \
  --search "closed:>=$SINCE" \
  --json number,title --limit 10 2>/dev/null | \
  jq -r '.[] | "#\(.number) \(.title)"'

# Open issues assigned to me
gh issue list --state open --assignee "$GH_USER" \
  --json number,title,labels --limit 10 2>/dev/null | \
  jq -r '.[] | "#\(.number) \(.title)"'
```

---

## Step 3: Synthesize Standup

Format output in standard standup structure:

```
## Standup — [DATE]

### Yesterday / Since [DATE]
- [what was completed — commits, merged PRs, closed issues]

### Today
- [open PRs in review, active issues, planned work]

### Blockers
- [anything blocked or waiting on others]
```

Rules:
- Group commits into meaningful work items (don't list every commit)
- Lead with outcomes ("shipped X", "fixed Y") not activity ("worked on X")
- Mention PR numbers for traceability
- If no blockers found, omit that section
- Keep it scannable — bullet points, no prose paragraphs
