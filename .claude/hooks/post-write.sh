#!/bin/bash
# post-write.sh - Post-write hook for Iternaut
# Detects phase completion and triggers next phase

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

FILE=$(echo "$INPUT" | jq -r '.tool_input.path // "unknown"' 2>/dev/null || echo "unknown")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Check what was written and update progress
if [[ "$FILE" == *"/PLAN.md"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:synthesis] [STATUS:UPDATE] PLAN.md updated | refs:$FILE | tags:write,done" >> .iter/progress.txt 2>/dev/null || true

    # Check if PLAN is complete enough to trigger review
    if grep -q "## Architecture" "$FILE" 2>/dev/null && grep -q "## Tasks" "$FILE" 2>/dev/null; then
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:review] [STATUS:READY] PLAN ready for review | refs:$FILE | tags:review,ready" >> .iter/progress.txt 2>/dev/null || true
    fi
elif [[ "$FILE" == *"/progress.txt"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:progress] [STATUS:DONE] Progress logged | refs:$FILE | tags:progress" >> .iter/progress.txt 2>/dev/null || true
fi

exit 0
