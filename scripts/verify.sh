#!/bin/bash
# verify.sh - Verify Iternaut plugin installation
# Checks all required files are present

# DEPENDENCIES:
# - bash: Shell interpreter
# - No external dependencies required
# Runs with built-in commands only

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Verifying Iternaut plugin at: $PLUGIN_DIR"
echo ""

ERRORS=0

check_file() {
    local file="$1"
    if [ -f "$PLUGIN_DIR/$file" ]; then
        echo "✓ $file"
    else
        echo "✗ MISSING: $file"
        ERRORS=$((ERRORS + 1))
    fi
}

check_dir() {
    local dir="$1"
    if [ -d "$PLUGIN_DIR/$dir" ]; then
        echo "✓ $dir/ (directory exists)"
    else
        echo "✗ MISSING: $dir/"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "=== Core Files ==="
check_file ".claude-plugin/plugin.json"
check_file "README.md"
check_file ".claude/settings.json"

echo ""
echo "=== Commands ==="
check_file "commands/plan.md"
check_file "commands/plan-iterative.md"
check_file "commands/implement.md"
check_file "commands/review.md"
check_file "commands/debug.md"
check_file "commands/deploy.md"

echo ""
echo "=== Subagents ==="
echo "Note: Claude is the orchestrator (not a subagent)"
check_file "agents/iter-researcher.md"
check_file "agents/iter-architect.md"
check_file "agents/iter-planner.md"
check_file "agents/iter-explorer.md"
check_file "agents/iter-coder.md"
check_file "agents/iter-tester.md"
check_file "agents/iter-debugger.md"
check_file "agents/iter-documenter.md"
check_file "agents/iter-reviewer.md"
check_file "agents/iter-security-auditor.md"
check_file "agents/iter-deployer.md"
check_file "agents/iter-monitor.md"
check_file "agents/iter-code-simplifier.md"
echo ""
echo "=== Claude Orchestration ==="
echo "Claude is the main orchestrator (no subagent needed)"
echo "  - Reads .iter/progress.txt"
echo "  - Spawns subagents"
echo "  - Makes decisions"

echo ""
echo "=== Skills ==="
check_file "skills/iter-agent/SKILL.md"
check_file "skills/iter-agent/skill.yaml"
check_file "skills/iter-agent-loop/SKILL.md"
check_file "skills/iter-agent-loop/skill.yaml"

echo ""
echo "=== Hooks ==="
check_file "hooks/hooks.json"

echo ""
echo "=== Artifacts ==="
check_dir "artifacts"
check_file "artifacts/decisions.md"
check_file "artifacts/open-questions.md"
check_file "artifacts/risks.md"
check_file "artifacts/acceptance-tests.md"

echo ""
echo "=== Templates ==="
check_dir "templates"
check_file "templates/PRD.md"
check_file "templates/CONTEXT.md"
check_file "templates/NON_GOALS.md"

echo ""
echo "=== Examples ==="
check_dir "examples"
check_file "examples/basic/PRD.md"
check_file "examples/full-stack/PRD.md"
check_file "examples/api/PRD.md"

echo ""
echo "=== Scripts ==="
check_file "scripts/iternaut-loop.sh"
check_file "scripts/iternaut-review.sh"

echo ""
echo "=== Documentation ==="
check_file "docs/hooks.md"
check_file "DEPENDENCIES.md"
check_file "CHANGELOG.md"

echo ""
echo "=== Config ==="
check_file "config/settings.json"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✓ All files present! Plugin is ready to use."
    echo ""
    echo "To use the plugin:"
    echo "  claude --plugin-dir $PLUGIN_DIR"
    exit 0
else
    echo "✗ $ERRORS file(s) missing. Please recreate them."
    exit 1
fi
