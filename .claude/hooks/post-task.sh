#!/bin/bash
# post-task.sh - Post-task hook for Iternaut
# Detects subagent completion and triggers next phase

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

AGENT=$(echo "$INPUT" | jq -r '.tool_input.name // "unknown"' 2>/dev/null || echo "unknown")
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // ""' 2>/dev/null || echo "")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log subagent completion
echo "[$TIMESTAMP] [AGENT:main] [PHASE:subagent] [STATUS:DONE] $AGENT completed | refs:.iter/progress.txt | tags:subagent,done" >> .iter/progress.txt 2>/dev/null || true

# Check for specific subagent completions and trigger next phases
if [[ "$AGENT" == *"iter-researcher"* ]]; then
    # Check if all researchers are done
    RESEARCHER_COUNT=$(grep -c "STATUS:DONE.*\[AGENT:researcher\]" .iter/progress.txt 2>/dev/null || echo "0")
    if [ "$RESEARCHER_COUNT" -ge 3 ]; then
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:research] [STATUS:COMPLETE] All researchers done ($RESEARCHER_COUNT) | refs:.iter/research-*.md | tags:research,complete" >> .iter/progress.txt 2>/dev/null || true
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:architecture] [STATUS:READY] Ready for architecture design | refs:.iter/PLAN.md | tags:architecture,ready" >> .iter/progress.txt 2>/dev/null || true
    fi
elif [[ "$AGENT" == *"iter-architect"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:architecture] [STATUS:COMPLETE] Architecture complete | refs:.iter/PLAN.md | tags:architecture,complete" >> .iter/progress.txt 2>/dev/null || true
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:planning] [STATUS:READY] Ready for task breakdown | refs:.iter/PLAN.md#Tasks | tags:planning,ready" >> .iter/progress.txt 2>/dev/null || true
elif [[ "$AGENT" == *"iter-planner"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:planning] [STATUS:COMPLETE] Tasks defined | refs:.iter/PLAN.md#Tasks | tags:planning,complete" >> .iter/progress.txt 2>/dev/null || true
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:review] [STATUS:READY] Ready for quality gate review | refs:.iter/PLAN.md#DONECHECKLIST | tags:review,ready" >> .iter/progress.txt 2>/dev/null || true
elif [[ "$AGENT" == *"iter-reviewer"* ]]; then
    # Check if review passed
    if echo "$OUTPUT" | grep -qi "SHIP"; then
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:review] [STATUS:COMPLETE] ALL GATES PASSED - SHIP | refs:.iter/PLAN.md#DONECHECKLIST | tags:review,ship" >> .iter/progress.txt 2>/dev/null || true
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:complete] [STATUS:COMPLETE] Iternaut workflow complete | refs:.iter/PLAN.md | tags:complete" >> .iter/progress.txt 2>/dev/null || true
    else
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:review] [STATUS:REVISE] Review requested revisions | refs:.iter/review-feedback.md | tags:review,revise" >> .iter/progress.txt 2>/dev/null || true
    fi
elif [[ "$AGENT" == *"iter-coder"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:implementation] [STATUS:DONE] Task implemented | refs:src/ | tags:implementation,done" >> .iter/progress.txt 2>/dev/null || true
elif [[ "$AGENT" == *"iter-tester"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:testing] [STATUS:DONE] Tests written | refs:tests/ | tags:testing,done" >> .iter/progress.txt 2>/dev/null || true
elif [[ "$AGENT" == *"iter-security-auditor"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:security] [STATUS:DONE] Security scan complete | refs:.iter/artifacts/security-scan.md | tags:security,done" >> .iter/progress.txt 2>/dev/null || true
fi

exit 0
