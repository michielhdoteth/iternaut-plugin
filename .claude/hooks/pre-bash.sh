#!/bin/bash
# pre-bash.sh - Pre-bash hook for Iternaut
# Logs command execution

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // "unknown"' 2>/dev/null || echo "unknown")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

echo "[$TIMESTAMP] [AGENT:main] [PHASE:bash] [STATUS:START] $COMMAND | refs:.iter/progress.txt | tags:bash,start" >> .iter/progress.txt 2>/dev/null || true

exit 0
