#!/bin/bash
# iternaut-loop.sh - Iterative Loop for Claude Code
# Iterates until quality gates pass

# DEPENDENCIES:
# - bash: Shell interpreter (POSIX compatible)
# - jq: JSON parsing (for reading JSON files)
# - claude-code: Claude Code CLI tool
#
# Install dependencies:
#   Ubuntu/Debian: apt-get install bash jq
#   macOS: brew install jq
#   Windows: Use Git Bash or WSL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
NC='\033[0m'

log() { echo -e "${BLUE}[ITRNAUT]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }

init_state() {
    mkdir -p "$STATE_DIR"

    if [ -f "$PROMPT_FILE" ]; then
        cp "$PROMPT_FILE" "$STATE_DIR/task.md"
        log "Loaded task from: $PROMPT_FILE"
    fi

    echo "# Iternaut Progress Log" > "$STATE_DIR/progress.txt"
    echo "Started: $(date)" >> "$STATE_DIR/progress.txt"
    echo "" >> "$STATE_DIR/progress.txt"
}

record_progress() {
    local message="$1"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "[$timestamp] $message" >> "$STATE_DIR/progress.txt"
}

check_complete() {
    if [ -f "$STATE_DIR/.complete" ]; then
        success "Task marked as complete!"
        return 0
    fi

    if grep -q "<promise>COMPLETE</promise>" "$STATE_DIR/output.md" 2>/dev/null; then
        touch "$STATE_DIR/.complete"
        success "Completion signal detected!"
        return 0
    fi

    return 1
}

run_iteration() {
    local iteration=$1

    log "Iteration $iteration / $MAX_ITERATIONS"
    record_progress "=== Iteration $iteration ==="

    if [ -f "$STATE_DIR/feedback.md" ]; then
        warn "Previous feedback found, incorporating..."
        record_progress "Feedback: $(head -1 "$STATE_DIR/feedback.md")"
    fi

    log "Running Claude Code..."

    local output
    if output=$(cat "$STATE_DIR/task.md" | claude-code --model "$WORKER_MODEL" --dangerously-skip-permissions 2>&1); then
        echo "$output" > "$STATE_DIR/output.md"

        local summary=$(echo "$output" | tail -20)
        echo "$summary" >> "$STATE_DIR/progress.txt"

        record_progress "Iteration $iteration completed"
    else
        echo "$output" > "$STATE_DIR/output-error.md"
        error "Iteration $iteration failed"
        record_progress "Iteration $iteration FAILED"
        return 1
    fi

    if [ "$REVIEWER_ENABLED" = "true" ]; then
        run_review
    fi
}

run_review() {
    log "Running reviewer ($REVIEWER_MODEL)..."

    local review_prompt="Review the Claude Code output and determine if the task is complete.

    Task: $(cat "$STATE_DIR/task.md")
    Output: $(cat "$STATE_DIR/output.md")

    Respond with:
    - 'SHIP' if the task is complete
    - 'REVISE' with specific feedback if incomplete"

    local review_result
    if review_result=$(echo "$review_prompt" | claude-code --model "$REVIEWER_MODEL" --dangerously-skip-permissions 2>/dev/null); then
        echo "$review_result" > "$STATE_DIR/review-result.md"

        if echo "$review_result" | grep -qi "SHIP"; then
            success "Reviewer approved!"
            return 0
        else
            warn "Reviewer requested revisions"
            echo "$review_result" > "$STATE_DIR/feedback.md"
            return 1
        fi
    fi

    warn "Review failed, continuing..."
    return 1
}

main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              ITERNAUT RALPH LOOP - AUTONOMOUS              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ ! -f "$PROMPT_FILE" ]; then
        error "Prompt file not found: $PROMPT_FILE"
        error "Usage: $0 [prompt.md]"
        exit 1
    fi

    init_state
    record_progress "Iternaut session started"
    record_progress "Prompt: $PROMPT_FILE"
    record_progress "Max iterations: $MAX_ITERATIONS"
    record_progress "Worker model: $WORKER_MODEL"

    if [ "$REVIEWER_ENABLED" = "true" ]; then
        record_progress "Reviewer: $REVIEWER_MODEL"
    fi

    echo ""

    iteration=0
    while [ $iteration -lt $MAX_ITERATIONS ]; do
        iteration=$((iteration + 1))

        if run_iteration $iteration; then
            if check_complete; then
                record_progress "Task COMPLETE after $iteration iteration(s)"
                echo ""
                success "Task completed in $iteration iteration(s)"
                echo ""
                echo "State: $STATE_DIR/"
                exit 0
            fi
        fi

        if [ $iteration -eq $MAX_ITERATIONS ]; then
            error "Max iterations ($MAX_ITERATIONS) reached"
            record_progress "FAILED: Max iterations reached"
            echo ""
            echo "State: $STATE_DIR/"
            exit 1
        fi

        echo ""
        warn "Continuing to next iteration..."
        echo ""
    done
}

main "$@"
