---
name: execute
description: Use when the user wants to execute an implementation plan from the plans folder, dispatching parallel agents to complete task groups.
---

Load the executing plans skill: `Skill(cpe:executing-plans)`

Find and execute an implementation plan, dispatching sub-agents to complete task groups in parallel.

## Step 1: Find the Plan

Determine from the user's message which plan to execute:
- If a file path was given, use it directly
- If a number was given, find `plans/0N-*.md` or a similarly numbered plan
- If nothing was specified, list available plans and ask the user to choose
- Determine whether isolated worktree execution was requested (appropriate for large, multi-file plans)

```bash
ls plans/*.md 2>/dev/null || ls .claude/plans/*.md 2>/dev/null || echo "No plans found"
```

## Step 2: Review the Plan

Read the plan file and identify:
- Task groups (by subsystem or `##` heading)
- Dependencies between groups (sequential vs. parallel)
- Any ambiguities that need clarification before starting

If anything is unclear, ask before proceeding.

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
3. Dispatch a code-reviewer agent to review the full diff

## Step 5: Commit and Clean Up

Stage and commit plan-related changes. If using a worktree, merge back to main and remove it. Mark the plan file as COMPLETED by adding `<!-- COMPLETED -->` to the top.
