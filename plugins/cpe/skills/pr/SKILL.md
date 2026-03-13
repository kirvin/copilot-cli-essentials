---
name: pr
description: Use when the user wants to create a pull request with an auto-generated description for the current branch.
---

Load the writer skill: `Skill(cpe:writer)`

Create a pull request for the current branch with a well-written, auto-generated description.

## Step 1: Determine Options

Infer from the user's message:
- Whether to create a draft PR
- The target base branch (default: detect from repo default or `main`)

## Step 2: Prerequisite Checks

Before creating the PR, verify the branch is push-ready:

```bash
# Check there are no uncommitted changes
git status --porcelain

# Confirm upstream is set or push-able
git remote -v
git branch --show-current
```

If there are uncommitted changes, ask the user to commit them first before proceeding.

## Step 3: Create the Pull Request

1. Detect base branch:
   - Check if there's a PR template in .github/PULL_REQUEST_TEMPLATE.md
   - Run: `git log --oneline HEAD..origin/main 2>/dev/null | wc -l`
   - Default base: main (or master if main doesn't exist)

2. Get the diff:
   ```bash
   git log --oneline origin/main...HEAD
   git diff origin/main...HEAD --stat
   ```

3. Write the PR title in conventional format (≤72 chars):
   ```
   <type>(<scope>): <description>
   ```
   Types: feat, fix, docs, refactor, test, ci, chore, perf

4. Write the PR body:
   ```
   ## What
   [What changed — 2-4 bullets]

   ## Why
   [The motivation — business reason, bug context, or design decision]

   ## How to test
   [Step-by-step verification instructions for the reviewer]

   ## Notes
   [Breaking changes, deploy dependencies, follow-up items — omit section if empty]
   ```

5. Push if not yet pushed:
   ```bash
   git push -u origin HEAD
   ```

6. Create the PR:
   ```bash
   gh pr create \
     --title "<title>" \
     --body "<body>" \
     [--draft if requested] \
     [--base <branch> if specified]
   ```

## Step 4: Report

Display the PR URL and number to the user.
