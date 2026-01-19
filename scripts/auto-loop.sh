#!/bin/bash
# auto-loop.sh - Automatic continuous loop with hook automation
# Runs continuously until SHIP signal - no manual intervention needed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"
STATE_DIR="${ITRNAUT_STATE_DIR:-.iternaut}"
MAX_ITERATIONS="${ITRNAUT_MAX_ITERATIONS:-10}"
WORKER_MODEL="${ITRNAUT_WORKER_MODEL:-sonnet}"
REVIEWER_MODEL="${ITRNAUT_REVIEWER_MODEL:-opus}"
REVIEWER_ENABLED="${ITRNAUT_REVIEWER_ENABLED:-true}"
SLEEP_BETWEEN="${ITRNAUT_SLEEP_BETWEEN:-2}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log() { echo -e "${BLUE}[AUTO]${NC} $*"; }
warn() { echo -e "${YELLOW}[AUTO]${NC} $*"; }
error() { echo -e "${RED}[AUTO]${NC} $*" >&2; }
success() { echo -e "${GREEN}[AUTO]${NC} $*"; }
phase() { echo -e "${CYAN}[AUTO]${NC} $*"; }

check_ship() {
    if [ -f "$STATE_DIR/progress.txt" ] && grep -qi "ALL GATES PASSED.*SHIP\|WORKFLOW COMPLETE.*SHIP\|<promise>COMPLETE</promise>" "$STATE_DIR/progress.txt" 2>/dev/null; then
        return 0
    fi
    return 1
}

check_completion() {
    if [ -f "$STATE_DIR/.complete" ]; then
        return 0
    fi
    return 1
}

init_state() {
    mkdir -p "$STATE_DIR"

    cat > "$STATE_DIR/progress.txt" << 'EOF'
# Iternaut Auto-Loop Progress Log
# All subagents append to this file
# Format: [TIMESTAMP] [AGENT:<name>] [PHASE:<phase>] [STATUS:<STATUS>] <summary> | refs:<file> | tags:<tags>

EOF
    echo "Auto-loop started: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$STATE_DIR/progress.txt"
    echo "Worker model: $WORKER_MODEL" >> "$STATE_DIR/progress.txt"
    if [ "$REVIEWER_ENABLED" = "true" ]; then
        echo "Reviewer model: $REVIEWER_MODEL" >> "$STATE_DIR/progress.txt"
    fi
    echo "" >> "$STATE_DIR/progress.txt"

    echo "0" > "$STATE_DIR/iteration.txt"
}

run_continuous() {
    local iteration=0
    local last_phase=""

    while [ $iteration -lt $MAX_ITERATIONS ]; do
        iteration=$((iteration + 1))
        echo "$iteration" > "$STATE_DIR/iteration.txt"

        echo ""
        phase "╔════════════════════════════════════════════════════════╗"
        phase "║  AUTO-LOOP ITERATION $iteration / $MAX_ITERATIONS               ║"
        phase "╚════════════════════════════════════════════════════════╝"

        log_iteration "=== Iteration $iteration ==="

        # Read current phase from state
        local phase_file="$STATE_DIR/current-phase.txt"
        if [ -f "$phase_file" ]; then
            last_phase=$(cat "$phase_file")
        fi

        # Execute based on current phase
        execute_phase "$iteration"

        # Check for completion
        if check_ship || check_completion; then
            success "SHIP signal detected!"
            break
        fi

        # Small delay between iterations
        sleep $SLEEP_BETWEEN
    done

    if [ $iteration -ge $MAX_ITERATIONS ]; then
        error "Max iterations reached"
        log_iteration "STOPPED: Max iterations ($MAX_ITERATIONS)"
    fi
}

execute_phase() {
    local iteration=$1

    # Determine what phase we're in
    local phase_file="$STATE_DIR/current-phase.txt"
    local current_phase="boot"

    if [ -f "$phase_file" ]; then
        current_phase=$(cat "$phase_file")
    fi

    # Execute appropriate phase
    case "$current_phase" in
        boot)
            phase "▶ PHASE: BOOT"
            echo "boot" > "$STATE_DIR/current-phase.txt"
            run_boot_phase
            ;;
        research)
            phase "▶ PHASE: RESEARCH"
            echo "research" > "$STATE_DIR/current-phase.txt"
            run_research_phase
            ;;
        architecture)
            phase "▶ PHASE: ARCHITECTURE"
            echo "architecture" > "$STATE_DIR/current-phase.txt"
            run_architecture_phase
            ;;
        planning)
            phase "▶ PHASE: PLANNING"
            echo "planning" > "$STATE_DIR/current-phase.txt"
            run_planning_phase
            ;;
        review)
            phase "▶ PHASE: REVIEW"
            echo "review" > "$STATE_DIR/current-phase.txt"
            run_review_phase
            ;;
        implementation)
            phase "▶ PHASE: IMPLEMENTATION"
            echo "implementation" > "$STATE_DIR/current-phase.txt"
            run_implementation_phase
            ;;
        complete)
            success "Workflow complete!"
            return 0
            ;;
        *)
            phase "▶ PHASE: $current_phase"
            run_custom_phase "$current_phase"
            ;;
    esac
}

run_boot_phase() {
    log "Reading PRD and extracting requirements..."

    local prd_content=$(cat .claude/PRD.md 2>/dev/null || echo "No PRD found")

    echo "$prd_content" > "$STATE_DIR/prd.md"

    log_iteration "PHASE:boot STATUS:START Extracted requirements from PRD"

    echo "research" > "$STATE_DIR/current-phase.txt"
}

run_research_phase() {
    log "Running parallel researchers..."

    # Launch researcher subagents
    claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions << 'EOF' 2>/dev/null || true
You are iter-researcher. Research technical architecture for the project.

Task: Research technical architecture, patterns, and risks.

Output: Write findings to .iter/research.md

Log progress to .iter/progress.txt
EOF

    log_iteration "PHASE:research STATUS:DONE Research complete"

    echo "architecture" > "$STATE_DIR/current-phase.txt"
}

run_architecture_phase() {
    log "Designing architecture..."

    claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions << 'EOF' 2>/dev/null || true
You are iter-architect. Design the system architecture.

Task: Create architecture section in PLAN.md with:
- Components and responsibilities
- Data flow
- API design
- Data model

Output: Write to .iter/PLAN.md

Log progress to .iter/progress.txt
EOF

    log_log_phase "PHASE:architecture STATUS:DONE Architecture complete"

    echo "planning" > "$STATE_DIR/current-phase.txt"
}

run_planning_phase() {
    log "Breaking down into tasks..."

    claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions << 'EOF' 2>/dev/null || true
You are iter-planner. Break down work into tasks.

Task: Create Tasks section in PLAN.md with:
- Milestones (Phase 1-4)
- TASK-IDs with descriptions
- Dependencies
- Acceptance criteria

Output: Append to .iter/PLAN.md

Log progress to .iter/progress.txt
EOF

    log_iteration "PHASE:planning STATUS:DONE Tasks defined"

    echo "review" > "$STATE_DIR/current-phase.txt"
}

run_review_phase() {
    log "Running quality gate review..."

    if [ "$REVIEWER_ENABLED" = "true" ]; then
        local review_result=$(echo "Review PLAN.md against quality gates" | claude-code --model "$REVIEWER_MODEL" --dangerously-skip-permissions 2>/dev/null || echo "REVISE")

        echo "$review_result" > "$STATE_DIR/review-result.md"

        if echo "$review_result" | grep -qi "SHIP"; then
            log_iteration "PHASE:review STATUS:SHIP All gates passed"
            echo "complete" > "$STATE_DIR/current-phase.txt"
            touch "$STATE_DIR/.complete"
        else
            log_iteration "PHASE:review STATUS:REVISE Review requested changes"
            # Continue loop to address feedback
        fi
    else
        log_iteration "PHASE:review STATUS:SKIPPED Review disabled"
        echo "complete" > "$STATE_DIR/current-phase.txt"
        touch "$STATE_DIR/.complete"
    fi
}

run_implementation_phase() {
    log "Implementing tasks..."

    claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions << 'EOF' 2>/dev/null || true
You are iter-coder. Implement tasks from PLAN.md using TDD.

Task: Implement tasks with:
- Write failing tests first
- Implement code to pass tests
- Run test suite
- Fix any issues

Output: Write code to src/

Log progress to .iter/progress.txt
EOF

    log_iteration "PHASE:implementation STATUS:DONE Implementation complete"
}

run_custom_phase() {
    local phase="$1"
    log "Running custom phase: $phase"

    claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions << EOF 2>/dev/null || true
You are working on phase: $phase

Execute the task and log progress to .iter/progress.txt
EOF
}

log_iteration() {
    local message="$1"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "[$timestamp] [AGENT:auto-loop] [PHASE:auto] [STATUS:UPDATE] $message" >> "$STATE_DIR/progress.txt" 2>/dev/null || true
}

main() {
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║           ITERNAUT AUTO-LOOP - CONTINUOUS EXECUTION           ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    init_state

    log "State directory: $STATE_DIR"
    log "Max iterations: $MAX_ITERATIONS"
    log "Worker model: $WORKER_MODEL"

    echo ""

    run_continuous

    echo ""
    if check_ship || check_completion; then
        success "═══════════════════════════════════════════════════════════════════"
        success "  WORKFLOW COMPLETE - SHIP!"
        success "═══════════════════════════════════════════════════════════════════"
        log_iteration "WORKFLOW COMPLETE - Auto-loop finished successfully"

        echo ""
        echo "Output files in $STATE_DIR/"
        echo "  - progress.txt (full log)"
        echo "  - PLAN.md (implementation plan)"
        echo "  - review-result.md (review decision)"
    else
        error "═══════════════════════════════════════════════════════════════════"
        error "  Auto-loop stopped (max iterations or error)"
        error "═══════════════════════════════════════════════════════════════════"
    fi

    echo ""
    echo "Progress: $STATE_DIR/progress.txt"
}

main "$@"
