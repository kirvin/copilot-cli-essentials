---
description: Create a pull request with an auto-generated description
argument-hint: "[--draft] [--base <branch>]"
allowed-tools: Bash, Glob, Grep, Read, Skill, Agent
---

Load the writer skill: `Skill(cpe:writer)`

Create a pull request for the current branch. Delegates to `cpe:haiku` for speed.

## Step 1: Parse Arguments

Parse `$ARGUMENTS`:
- `--draft`: create a draft PR
- `--base <branch>`: target branch (default: detect from repo default or `main`)

## Step 2: Prerequisite Checks

Before delegating, verify the branch is push-ready:

```bash
# Check there are no uncommitted changes
git status --porcelain

# Confirm upstream is set or push-able
git remote -v
git branch --show-current
```

If there are uncommitted changes, run `/cpe:commit` first.

## Step 3: Delegate to Haiku

Delegate to the `cpe:haiku` agent with these instructions:

```
Create a GitHub pull request for the current branch.

1. Detect base branch:
   - Check if there's a PR template in .github/PULL_REQUEST_TEMPLATE.md
   - Run: git log --oneline HEAD..origin/main 2>/dev/null | wc -l
   - Default base: main (or master if main doesn't exist)

2. Get the diff:
   git log --oneline origin/main...HEAD
   git diff origin/main...HEAD --stat

3. Write the PR title (conventional format, ≤72 chars):
   <type>(<scope>): <description>
   Types: feat, fix, docs, refactor, test, ci, chore, perf

4. Write the PR body:
   ## What
   [What changed — 2-4 bullets]

   ## Why
   [The motivation — business reason, bug context, or design decision]

   ## How to test
   [Step-by-step verification instructions for the reviewer]

   ## Notes
   [Breaking changes, deploy dependencies, follow-up items — omit section if empty]

5. Push if not yet pushed:
   git push -u origin HEAD

6. Create the PR:
   gh pr create \
     --title "<title>" \
     --body "<body>" \
     [--draft if requested] \
     [--base <branch> if specified]

7. Report: PR URL and number.
```

## Step 4: Report

After the haiku agent completes, display the PR URL.
