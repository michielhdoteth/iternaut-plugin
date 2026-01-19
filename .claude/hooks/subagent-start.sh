#!/bin/bash
# subagent-start.sh - Subagent start hook for Iternaut
# Logs when iter-* subagents start

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

AGENT=$(echo "$INPUT" | jq -r '.subagent_name // "unknown"' 2>/dev/null || echo "unknown")
TASK=$(echo "$INPUT" | jq -r '.subagent_task // "unknown"' 2>/dev/null || echo "unknown")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log subagent start
echo "[$TIMESTAMP] [AGENT:$AGENT] [PHASE:start] [STATUS:START] Subagent started | refs:.iter/progress.txt | tags:$AGENT,start" >> .iter/progress.txt 2>/dev/null || true

# Track iteration
if [ -f ".iter/iteration.txt" ]; then
    ITERATION=$(cat .iter/iteration.txt 2>/dev/null || echo "1")
else
    ITERATION=1
fi
echo "[$TIMESTAMP] [AGENT:$AGENT] [PHASE:iteration-$ITERATION] [STATUS:RUNNING] Working on: $TASK | refs:.iter/progress.txt | tags:$AGENT,iteration" >> .iter/progress.txt 2>/dev/null || true

exit 0
