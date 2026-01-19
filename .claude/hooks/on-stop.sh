#!/bin/bash
# on-stop.sh - Stop hook for Iternaut
# Summarizes session, detects if workflow is complete

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log session end
echo "[$TIMESTAMP] [AGENT:main] [PHASE:session] [STATUS:STOP] Session ended" >> .iter/progress.txt 2>/dev/null || true

# Check workflow status
if [ -f ".iter/PLAN.md" ]; then
    # Count completed phases
    RESEARCH_DONE=$(grep -c "STATUS:COMPLETE.*researcher" .iter/progress.txt 2>/dev/null || echo "0")
    ARCH_DONE=$(grep -c "STATUS:COMPLETE.*architecture" .iter/progress.txt 2>/dev/null || echo "0")
    PLAN_DONE=$(grep -c "STATUS:COMPLETE.*planning" .iter/progress.txt 2>/dev/null || echo "0")
    REVIEW_DONE=$(grep -c "STATUS:COMPLETE.*review" .iter/progress.txt 2>/dev/null || echo "0")
    COMPLETE_DONE=$(grep -c "STATUS:COMPLETE.*complete" .iter/progress.txt 2>/dev/null || echo "0")

    echo "[$TIMESTAMP] [AGENT:main] [PHASE:status] [STATUS:UPDATE] Workflow status: Research=$RESEARCH_DONE Architecture=$ARCH_DONE Planning=$PLAN_DONE Review=$REVIEW_DONE Complete=$COMPLETE_DONE | refs:.iter/progress.txt | tags:status" >> .iter/progress.txt 2>/dev/null || true

    # Check for SHIP signal
    if grep -qi "ALL GATES PASSED.*SHIP" .iter/progress.txt 2>/dev/null; then
        echo "[$TIMESTAMP] [AGENT:main] [PHASE:ship] [STATUS:COMPLETE] WORKFLOW COMPLETE - SHIP | refs:.iter/PLAN.md | tags:ship,complete" >> .iter/progress.txt 2>/dev/null || true
        echo ""
        echo "=========================================="
        echo "  ITERNAUT WORKFLOW COMPLETE - SHIP!"
        echo "=========================================="
        echo "  Plan: .iter/PLAN.md"
        echo "  Progress: .iter/progress.txt"
        echo "  Artifacts: .iter/artifacts/"
        echo "=========================================="
    fi
fi

# Append session summary
echo "" >> .iter/progress.txt
echo "--- Session Summary ---" >> .iter/progress.txt
echo "Ended: $TIMESTAMP" >> .iter/progress.txt
echo "Lines in progress.txt: $(wc -l < .iter/progress.txt 2>/dev/null || echo 0)" >> .iter/progress.txt
echo "" >> .iter/progress.txt

exit 0
