#!/bin/bash
# ralph-loop.sh - Continuous Ralph Loop with hooks automation
# Runs until SHIP signal is detected or max iterations reached

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"
STATE_DIR="${ITRNAUT_STATE_DIR:-.iternaut}"
PROMPT_FILE="${1:-PROMPT.md}"
MAX_ITERATIONS="${ITRNAUT_MAX_ITERATIONS:-10}"
WORKER_MODEL="${ITRNAUT_WORKER_MODEL:-sonnet}"
REVIEWER_MODEL="${ITRNAUT_REVIEWER_MODEL:-opus}"
REVIEWER_ENABLED="${ITRNAUT_REVIEWER_ENABLED:-true}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH]${NC} $*"; }
warn() { echo -e "${YELLOW}[RALPH]${NC} $*"; }
error() { echo -e "${RED}[RALPH]${NC} $*" >&2; }
success() { echo -e "${GREEN}[RALPH]${NC} $*"; }
phase() { echo -e "${CYAN}[RALPH]${NC} $*"; }

log_iteration() {
    local message="$1"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "[$timestamp] [AGENT:ralph-loop] [PHASE:loop] [STATUS:UPDATE] $message" >> "$STATE_DIR/progress.txt"
}

check_ship() {
    if grep -qi "ALL GATES PASSED.*SHIP\|WORKFLOW COMPLETE.*SHIP\|<promise>COMPLETE</promise>" "$STATE_DIR/progress.txt" 2>/dev/null; then
        return 0
    fi
    return 1
}

check_revise() {
    if grep -qi "REVISE\|Quality gates not passed" "$STATE_DIR/progress.txt" 2>/dev/null; then
        return 0
    fi
    return 1
}

get_iteration() {
    if [ -f "$STATE_DIR/iteration.txt" ]; then
        cat "$STATE_DIR/iteration.txt"
    else
        echo "0"
    fi
}

increment_iteration() {
    local current=$(get_iteration)
    local next=$((current + 1))
    echo "$next" > "$STATE_DIR/iteration.txt"
    echo "$next"
}

init_state() {
    mkdir -p "$STATE_DIR"

    if [ -f "$PROMPT_FILE" ]; then
        cp "$PROMPT_FILE" "$STATE_DIR/task.md"
        log "Loaded task from: $PROMPT_FILE"
    fi

    cat > "$STATE_DIR/progress.txt" << 'EOF'
# Iternaut Ralph Loop Progress Log
# This file tracks all progress - all subagents append here
# Format: [TIMESTAMP] [AGENT:<name>] [PHASE:<phase>] [STATUS:<STATUS>] <summary> | refs:<file> | tags:<tags>

EOF
    echo "Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$STATE_DIR/progress.txt"
    echo "" >> "$STATE_DIR/progress.txt"

    echo "1" > "$STATE_DIR/iteration.txt"
}

run_work_phase() {
    phase "▶ WORK PHASE (Model: $WORKER_MODEL)"

    log_iteration "Starting work phase, iteration $(get_iteration)/$MAX_ITERATIONS"

    local output
    if output=$(cat "$STATE_DIR/task.md" 2>/dev/null | claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions 2>&1); then
        echo "$output" > "$STATE_DIR/work-output.md"

        local summary=$(echo "$output" | tail -50)
        echo "$summary" >> "$STATE_DIR/progress.txt"

        log_iteration "Work phase completed"
        return 0
    else
        echo "$output" > "$STATE_DIR/work-error.md"
        log_iteration "Work phase failed"
        warn "Work phase failed"
        return 1
    fi
}

run_review_phase() {
    if [ "$REVIEWER_ENABLED" != "true" ]; then
        log "Review disabled, skipping"
        return 0
    fi

    phase "▶ REVIEW PHASE (Model: $REVIEWER_MODEL)"

    log_iteration "Starting review phase"

    local review_prompt="You are an Iternaut Reviewer. Review the work output and determine if quality gates pass.

WORK OUTPUT:
$(cat "$STATE_DIR/work-output.md)

TASK:
$(cat "$STATE_DIR/task.md)

QUALITY GATES:
1. Architecture described (components, data flow)
2. API specified (interfaces, schemas)
3. Data model defined (tables, fields)
4. Tasks broken down with acceptance criteria
5. All requirements mapped
6. No blockers or contradictions

Respond with ONLY:
- 'SHIP' if ALL gates pass
- 'REVISE' with specific feedback if any gate fails"

    local review_result
    if review_result=$(echo "$review_prompt" | claude-code --model "$REVIEWER_MODEL" --dangerously-skip-permissions 2>/dev/null); then
        echo "$review_result" > "$STATE_DIR/review-result.md"

        if echo "$review_result" | grep -qi "SHIP"; then
            log_iteration "REVIEW: ALL GATES PASSED - SHIP"
            echo "$review_result" >> "$STATE_DIR/progress.txt"
            return 0
        else
            log_iteration "REVIEW: REVISE requested"
            echo "$review_result" >> "$STATE_DIR/progress.txt"
            return 1
        fi
    fi

    warn "Review failed, continuing"
    log_iteration "Review phase failed"
    return 1
}

update_task_with_feedback() {
    local feedback=$(cat "$STATE_DIR/review-result.md" 2>/dev/null)

    cat > "$STATE_DIR/task.md" << EOF
# Task (Iteration $(get_iteration))

Original Task:
$(cat "$STATE_DIR/task.md 2>/dev/null | head -20)

---

PREVIOUS FEEDBACK (must address):
$feedback

---

Please address the feedback above and complete the task.
EOF

    log_iteration "Task updated with feedback for next iteration"
}

main() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           ITERNAUT RALPH LOOP - CONTINUOUS AUTOMATION         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ ! -f "$PROMPT_FILE" ]; then
        error "Prompt file not found: $PROMPT_FILE"
        error "Usage: $0 [prompt.md]"
        exit 1
    fi

    init_state

    log "State directory: $STATE_DIR"
    log "Max iterations: $MAX_ITERATIONS"
    log "Worker model: $WORKER_MODEL"
    if [ "$REVIEWER_ENABLED" = "true" ]; then
        log "Reviewer model: $REVIEWER_MODEL"
    else
        warn "Reviewer disabled"
    fi
    echo ""

    local iteration=0
    local ship=false
    local revise=false

    while [ $iteration -lt $MAX_ITERATIONS ]; do
        iteration=$(increment_iteration)

        echo ""
        phase "════════════════════════════════════════════════════"
        phase "  ITERATION $iteration / $MAX_ITERATIONS"
        phase "════════════════════════════════════════════════════"
        echo ""

        # Work phase
        if ! run_work_phase; then
            warn "Work phase failed, continuing..."
        fi

        # Check for completion signal in work output
        if grep -qi "<promise>COMPLETE</promise>" "$STATE_DIR/work-output.md" 2>/dev/null; then
            success "Completion signal detected in work output!"
            ship=true
            break
        fi

        # Review phase
        if run_review_phase; then
            ship=true
            break
        else
            revise=true
            # Update task with feedback for next iteration
            update_task_with_feedback
        fi

        # Check if we should continue
        if [ $iteration -ge $MAX_ITERATIONS ]; then
            error "Max iterations reached"
            log_iteration "FAILED: Max iterations ($MAX_ITERATIONS) reached"
            break
        fi

        warn "Review requested revisions, continuing to next iteration..."
        log_iteration "Continuing to iteration $((iteration + 1))"
    done

    echo ""
    if [ "$ship" = true ]; then
        success "════════════════════════════════════════════════════"
        success "  SHIP! WORKFLOW COMPLETE"
        success "════════════════════════════════════════════════════"
        log_iteration "WORKFLOW COMPLETE - SHIP after $iteration iteration(s)"

        echo ""
        echo "Output files:"
        echo "  - $STATE_DIR/task.md"
        echo "  - $STATE_DIR/work-output.md"
        echo "  - $STATE_DIR/review-result.md"
        echo "  - $STATE_DIR/progress.txt"
    elif [ "$revise" = true ]; then
        error "════════════════════════════════════════════════════"
        error "  MAX ITERATIONS REACHED - REVISE mode"
        error "════════════════════════════════════════════════════"
        log_iteration "STOPPED: Max iterations, work incomplete"

        echo ""
        echo "Review feedback: $STATE_DIR/review-result.md"
    fi

    echo ""
    echo "State saved to: $STATE_DIR/"
    echo "Progress log: $STATE_DIR/progress.txt"

    exit 0
}

main "$@"
