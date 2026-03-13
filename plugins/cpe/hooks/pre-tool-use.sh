#!/usr/bin/env bash
# preToolUse hook — blocks destructive operations without confirmation
# Input: JSON via stdin with fields: timestamp, cwd, toolName, toolArgs
# Output: JSON with permissionDecision (allow/deny/ask) — only "deny" is currently acted on

set -euo pipefail

# Read input JSON from stdin
INPUT=$(cat)

TOOL=$(echo "$INPUT" | grep -o '"toolName":"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "")
ARGS=$(echo "$INPUT" | grep -o '"toolArgs":"[^"]*"' | sed 's/"toolArgs":"//;s/"$//' || echo "")

# Only inspect bash/shell tool calls
if [[ "$TOOL" != "bash" ]]; then
    exit 0
fi

# Patterns that should be blocked — destructive and irreversible
BLOCKED_PATTERNS=(
    "git push --force[^-]"        # Force push (not force-with-lease)
    "git push -f[^-]"             # Force push shorthand
    "git push -f$"                # Force push at end of command
    "rm -rf /"                    # Root deletion
    "rm -rf \*"                   # Glob deletion from root
    ":refs/tags/"                 # Tag deletion via push
    "git reset --hard HEAD~[2-9]" # Hard reset more than 1 commit back
    "DROP TABLE"                  # SQL table drops
    "DROP DATABASE"               # SQL database drops
    "TRUNCATE TABLE"              # SQL truncation
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$ARGS" | grep -qE "$pattern"; then
        printf '{"permissionDecision":"deny","permissionDecisionReason":"Destructive operation blocked by cpe safety hook. Confirm intent explicitly and re-run if intentional."}\n'
        exit 0
    fi
done

# Force-with-lease is safe — explicitly allow
# (prevents blocking git push --force-with-lease)

exit 0
