---
description: Execute an implementation plan from the plans folder
argument-hint: "[plan-file-or-number] [--worktree]"
allowed-tools: Bash, Glob, Grep, Read, Skill, Agent
---

Load the executing plans skill: `Skill(cpe:executing-plans)`

Find and execute an implementation plan, dispatching sub-agents to complete task groups in parallel.

## Step 1: Find the Plan

Parse `$ARGUMENTS`:
- If a file path is given, use it directly
- If a number is given, find `plans/0N-*.md` or similar numbered plan
- If empty, list available plans in `plans/` and ask the user to choose
- `--worktree` flag: create a git worktree for isolated execution (use for large, multi-file plans)

```bash
ls plans/*.md 2>/dev/null || ls .claude/plans/*.md 2>/dev/null || echo "No plans found"
```

## Step 2: Review the Plan

Read the plan file and identify:
- Task groups (by subsystem or `##` heading)
- Dependencies between groups (sequential vs parallel)
- Any ambiguities that need clarification before starting

If anything is unclear, ask before proceeding using `AskUserQuestion`.

## Step 3: Execute

Follow the executing-plans skill:
1. Group related tasks by subsystem
2. Dispatch parallel agents for independent groups
3. Run dependent groups sequentially
4. Track progress with Task tools

## Step 4: Verify

After all agents complete:
1. Run the project's test suite to confirm nothing broke
2. Manually verify the key deliverables from the plan
3. Dispatch `cpe:code-reviewer` agent to review the full diff

## Step 5: Commit and Clean Up

Stage and commit plan-related changes. If using a worktree, merge back to main and remove it. Mark the plan file as COMPLETED (add `<!-- COMPLETED -->` to the top).
