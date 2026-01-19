#!/bin/bash
# subagent-stop.sh - Subagent stop hook for Iternaut
# Logs completion, checks for SHIP/REVISE, triggers next phase

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

AGENT=$(echo "$INPUT" | jq -r '.subagent_name // "unknown"' 2>/dev/null || echo "unknown")
OUTPUT=$(echo "$INPUT" | jq -r '.subagent_output // ""' 2>/dev/null || echo "")
DURATION=$(echo "$INPUT" | jq -r '.duration // "unknown"' 2>/dev/null || echo "unknown")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log subagent completion
echo "[$TIMESTAMP] [AGENT:$AGENT] [PHASE:stop] [STATUS:DONE] Completed in ${DURATION}s | refs:.iter/progress.txt | tags:$AGENT,done" >> .iter/progress.txt 2>/dev/null || true

# Check for completion signals
if echo "$OUTPUT" | grep -qi "COMPLETE"; then
    echo "[$TIMESTAMP] [AGENT:$AGENT] [PHASE:complete] [STATUS:SIGNAL] Sent COMPLETE signal | refs:.iter/progress.txt | tags:complete" >> .iter/progress.txt 2>/dev/null || true
fi

# Check for SHIP/REVISE decisions
if echo "$OUTPUT" | grep -qi "SHIP"; then
    echo "[$TIMESTAMP] [AGENT:$AGENT] [PHASE:decision] [STATUS:SHIP] All quality gates passed | refs:.iter/PLAN.md | tags:ship" >> .iter/progress.txt 2>/dev/null || true

    # Trigger finalization
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:finalize] [STATUS:READY] Ready for finalization | refs:.iter/artifacts/ | tags:finalize,ready" >> .iter/progress.txt 2>/dev/null || true
elif echo "$OUTPUT" | grep -qi "REVISE"; then
    echo "[$TIMESTAMP] [AGENT:$AGENT] [PHASE:decision] [STATUS:REVISE] Quality gates not passed | refs:.iter/review-feedback.md | tags:revise" >> .iter/progress.txt 2>/dev/null || true

    # Increment iteration
    if [ -f ".iter/iteration.txt" ]; then
        ITERATION=$(($(cat .iter/iteration.txt 2>/dev/null || echo "0") + 1))
    else
        ITERATION=1
    fi
    echo "$ITERATION" > .iter/iteration.txt

    # Check max iterations
    MAX_ITERATIONS=${ITRNAUT_MAX_ITERATIONS:-10}
    if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:blocked] [STATUS:BLOCKED] Max iterations ($MAX_ITERATIONS) reached | refs:.iter/progress.txt | tags:blocked,max-iterations" >> .iter/progress.txt 2>/dev/null || true
    else
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:loop] [STATUS:CONTINUE] Iteration $ITERATION/$MAX_ITERATIONS - addressing feedback | refs:.iter/review-feedback.md | tags:loop,iteration-$ITERATION" >> .iter/progress.txt 2>/dev/null || true
    fi
fi

exit 0
