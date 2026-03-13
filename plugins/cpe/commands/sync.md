---
description: Sync fork or branch with upstream — fetch, rebase, resolve conflicts
argument-hint: "[upstream-branch] [--fork]"
allowed-tools: Bash, Glob, Grep, Read
---

Sync the current branch or fork with its upstream, resolving conflicts and keeping history clean.

## Step 1: Detect Context

```bash
# Current state
git status --short
git branch --show-current
git remote -v

# Check if this is a fork (has upstream remote)
git remote | grep -E "^upstream$" && echo "fork detected" || echo "no upstream remote"

# Check divergence
git fetch --all 2>/dev/null
git log --oneline HEAD..origin/main 2>/dev/null | wc -l  # commits behind
git log --oneline origin/main..HEAD 2>/dev/null | wc -l  # commits ahead
```

Parse `$ARGUMENTS`:
- `--fork` — treat as fork, sync from upstream remote
- `upstream-branch` — target branch (default: main)

---

## Step 2: Stash If Dirty

```bash
if [ -n "$(git status --short)" ]; then
  git stash push -m "cpe-sync-stash-$(date +%s)"
  STASHED=true
fi
```

---

## Step 3: Sync

**Fork sync** (has upstream remote):
```bash
git fetch upstream
git rebase upstream/main

# Push to fork's origin
git push origin $(git branch --show-current) --force-with-lease
```

**Branch sync** (feature branch against main):
```bash
git fetch origin
git rebase origin/main

# If rebase conflicts arise, report them and guide resolution
```

**Simple pull** (on main/default branch):
```bash
git pull --rebase origin main
```

---

## Step 4: Handle Conflicts

If rebase encounters conflicts:

```bash
git status --short | grep "^UU\|^AA\|^DD"
```

For each conflicted file:
1. Show the conflict markers and both sides
2. Recommend resolution based on context (keep ours / keep theirs / merge)
3. After user resolves: `git rebase --continue`

---

## Step 5: Restore Stash

```bash
[ "$STASHED" = "true" ] && git stash pop
```

---

## Output

Report:
- Commits pulled from upstream
- Commits rebased onto new base
- Any conflicts resolved
- Final `git log --oneline -5` to confirm clean state
