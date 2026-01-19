#!/bin/bash
# iternaut-review.sh - Cross-model reviewer for iterative loop
# Validates PLAN.md against quality gates

# DEPENDENCIES:
# - bash: Shell interpreter
# - claude-code: Claude Code CLI tool
# No external jq needed for this script

set -euo pipefail

PLAN_FILE="${1:-.iter/PLAN.md}"
REVIEWER_MODEL="${ITRNAUT_REVIEWER_MODEL:-opus}"
OUTPUT_FILE="${2:-.iter/review-result.txt}"

if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: PLAN.md not found at $PLAN_FILE"
    exit 1
fi

echo "Reviewing: $PLAN_FILE"

claude-code --model "$REVIEWER_MODEL" << 'EOF'
You are an Iter-Agent Reviewer. Review the implementation PLAN.md against quality gates.

## Quality Gates

### GATE 1: Implementation Guidance
- [ ] Architecture described (components, boundaries, data flow)
- [ ] API specified (agent messages, abstractions)
- [ ] Data model defined (tables, fields, relationships)
- [ ] Tasks broken down (with acceptance criteria)

### GATE 2: Coverage Complete
- [ ] All requirements mapped to tasks
- [ ] Non-goals explicit
- [ ] Risks + mitigations identified
- [ ] Test plan + acceptance criteria

### GATE 3: No Blockers
- [ ] No contradictions
- [ ] All agent responsibilities clear
- [ ] All dependencies explicit

### GATE 4: Actionable
- [ ] Developer can pick any task and start
- [ ] Agent interfaces concrete
- [ ] Milestones sequenced

## Decision Format

SHIP - All gates pass:
```
SHIP

GATE 1: PASS
GATE 2: PASS
GATE 3: PASS
GATE 4: PASS

Plan is complete and actionable.
```

REVISE - Some gates fail:
```
REVISE

GATE 1: FAIL
- <specific issue 1>
- <specific issue 2>

GATE 3: FAIL
- <specific issue>
```

## Output

Read the PLAN.md and output only SHIP or REVISE with specific feedback.
EOF
} --dangerously-skip-permissions > "$OUTPUT_FILE" 2>&1

echo "Review result written to: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
