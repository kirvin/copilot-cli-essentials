#!/usr/bin/env bash
# sessionStart hook — logs session metadata for audit trail
# Input: JSON via stdin with fields: timestamp, cwd, source, initialPrompt
# Output: Ignored by Copilot CLI (cannot inject context into conversation)

set -euo pipefail

LOG_DIR="${HOME}/.copilot/logs"
LOG_FILE="${LOG_DIR}/sessions.log"

# Read input JSON from stdin
INPUT=$(cat)

# Parse fields using basic shell (no jq dependency assumed)
TIMESTAMP=$(echo "$INPUT" | grep -o '"timestamp":[0-9]*' | grep -o '[0-9]*' || echo "")
SOURCE=$(echo "$INPUT" | grep -o '"source":"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "unknown")
CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "")

# Use cwd from input or fall back to process cwd
WORK_DIR="${CWD:-$(pwd)}"
PROJECT=$(basename "$WORK_DIR")
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Append session log entry
echo "${DATE} source=${SOURCE} project=${PROJECT} cwd=${WORK_DIR}" >> "$LOG_FILE"

exit 0
