#!/bin/bash
# pre-task.sh - Pre-task hook for Iternaut
# Logs subagent launch

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

AGENT=$(echo "$INPUT" | jq -r '.tool_input.name // "unknown"' 2>/dev/null || echo "unknown")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log subagent launch
echo "[$TIMESTAMP] [AGENT:main] [PHASE:subagent] [STATUS:START] Launching $AGENT | refs:.iter/progress.txt | tags:subagent,start" >> .iter/progress.txt 2>/dev/null || true

exit 0
