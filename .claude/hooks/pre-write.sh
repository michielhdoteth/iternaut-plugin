#!/bin/bash
# pre-write.sh - Pre-write hook for Iternaut
# Logs file modifications to progress

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

FILE=$(echo "$INPUT" | jq -r '.tool_input.path // "unknown"' 2>/dev/null || echo "unknown")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log the write operation
echo "[$TIMESTAMP] [AGENT:main] [PHASE:write] [STATUS:START] Writing to $FILE | refs:$FILE | tags:write,start" >> .iter/progress.txt 2>/dev/null || true

exit 0
