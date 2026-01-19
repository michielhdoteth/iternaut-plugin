# Iternaut Claude Plugin

PRD-to-finished development via context engineering with iterative subagents. Claude orchestrates, subagents do the work.

## Overview

Iternaut is a comprehensive framework for context-engineered AI-assisted development that takes a PRD through to fully finished implementation:
- **Claude orchestration** - Main agent coordinates all work
- **Specialized subagents** - 12 agents for different phases
- **Iterative quality gates** - Work until all criteria pass
- **File-based state** - All progress persists in `.iter/`
- **Complete delivery** - Not just planning, but full implementation

## Commands

| Command | Description |
|---------|-------------|
| `/iternaut:plan` | Convert PRD to PLAN with parallel subagents |
| `/iternaut:plan:iter` | Iterative planning with quality gate loop |
| `/iternaut:implement [TASK]` | Implement tasks with TDD |
| `/iternaut:review [ITEM]` | Review against quality gates |
| `/iternaut:debug [ERROR]` | Debug errors and fix bugs |
| `/iternaut:deploy [ENV]` | Deploy and configure monitoring |

## Subagents

### Planning Phase
| Agent | Model | Role |
|-------|-------|------|
| `iter-researcher` | sonnet | Research technical, patterns, risks |
| `iter-architect` | opus | System design, API, data model |
| `iter-planner` | sonnet | Task breakdown, milestones |
| `iter-explorer` | haiku | Fast codebase exploration |

### Development Phase
| Agent | Model | Role |
|-------|-------|------|
| `iter-coder` | sonnet | Implementation with TDD |
| `iter-tester` | sonnet | Comprehensive testing |
| `iter-debugger` | sonnet | Bug fixes, error resolution |
| `iter-documenter` | sonnet | Code docs, API docs |

### Review Phase
| Agent | Model | Role |
|-------|-------|------|
| `iter-reviewer` | sonnet | Quality gates, SHIP/REVISE |
| `iter-security-auditor` | sonnet | Vulnerability scanning |

### Operations Phase
| Agent | Model | Role |
|-------|-------|------|
| `iter-deployer` | sonnet | CI/CD, deployment |
| `iter-monitor` | sonnet | Observability, alerts |

## Installation

```bash
# Load plugin
claude --plugin-dir ./iternaut-plugin
```

## Usage

### Quick Start

```bash
# 1. Create PRD in .claude/
mkdir -p .claude
cat > .claude/PRD.md << 'EOF'
# My Project

## Overview
Build a REST API for task management

## Goals
- User authentication
- CRUD operations for tasks
- Unit tests > 80% coverage
EOF

# 2. Run planning
/iternaut:plan
```

### Iterative Planning

```bash
# With cross-model review
export ITRNAUT_WORKER_MODEL=sonnet
export ITRNAUT_REVIEWER_MODEL=opus
/iternaut:plan:iter
```

## Input Files

Place in `.claude/`:

| File | Required | Description |
|------|----------|-------------|
| `PRD.md` | Yes | Product requirements |
| `CONTEXT.md` | No | Stack, conventions |
| `NON_GOALS.md` | No | Scope boundaries |

## Output Files

Creates `.iter/` directory:

| File | Description |
|------|-------------|
| `progress.txt` | Execution log (ALL subagents append) |
| `PLAN.md` | Implementation plan |
| `research-*.md` | Research outputs |
| `artifacts/decisions.md` | Architectural decisions |
| `artifacts/open-questions.md` | Unknowns with mitigations |
| `artifacts/risks.md` | Risk register |
| `artifacts/acceptance-tests.md` | Test criteria |
| `artifacts/security-scan.md` | Security audit |

## Progress Tracking

All subagents append to `.iter/progress.txt`:

```
[TIMESTAMP] [AGENT:<name>] [PHASE:<phase>] [STATUS:<STATUS>] <summary> | refs:<file> | tags:<tags>
```

### Example Log

```
[2026-01-19T13:00:00Z] [AGENT:claude] [PHASE:boot] [STATUS:START] Starting
[2026-01-19T13:01:00Z] [AGENT:researcher] [PHASE:angle-1-tech] [STATUS:DONE] Architecture research
[2026-01-19T13:02:00Z] [AGENT:researcher] [PHASE:angle-2-patterns] [STATUS:DONE] Patterns research
[2026-01-19T13:03:00Z] [AGENT:researcher] [PHASE:angle-3-risks] [STATUS:DONE] Risks research
[2026-01-19T13:04:00Z] [AGENT:architect] [PHASE:architecture] [STATUS:DONE] System design complete
[2026-01-19T13:05:00Z] [AGENT:planner] [PHASE:planning] [STATUS:DONE] 14 tasks created
[2026-01-19T13:06:00Z] [AGENT:reviewer] [PHASE:review] [STATUS:DONE] ALL GATES PASSED - SHIP
[2026-01-19T13:07:00Z] [AGENT:claude] [PHASE:complete] [STATUS:COMPLETE] Iternaut complete
```

## Quality Gates

| Gate | Criteria |
|------|----------|
| 1: Implementation | Architecture, API, data model, tasks defined |
| 2: Coverage | All requirements mapped, risks identified |
| 3: Blockers | No contradictions, dependencies explicit |
| 4: Actionable | Developer can pick any task and start |
| 5: Security | No critical/high vulnerabilities |
| 6: Tests | Coverage > 80%, all tests passing |

## Claude Orchestration

```
PRD.md
   ↓
┌─────────────────────────┐
│       CLAUDE            │
│    (Orchestrator)       │
│  - Reads progress.txt   │
│  - Spawns subagents     │
│  - Makes decisions      │
└───────────┬─────────────┘
            │
    ┌───────┴───────┐
    │               │
    ↓               ↓
┌─────────┐   ┌─────────────┐
│ Research │   │  Architecture│
│ (parallel)│   │  (iter-arch)│
└────┬────┘   └──────┬──────┘
     │               │
     └───────┬───────┘
             │
             ↓
       ┌───────────┐
       │  Planning │
       │(iter-plnr)│
       └─────┬─────┘
             │
             ↓
       ┌───────────┐
       │  Review   │
       │   Loop    │
       └─────┬─────┘
             │
    ┌────────┴────────┐
    │                 │
    ↓                 ↓
  SHIP             REVISE
    │                 │
    ↓                 ↓
 Exit           Fill gaps
                    ↓
               Review again
```

## Configuration

### Environment Variables

```bash
# Worker model (default: sonnet)
export ITRNAUT_WORKER_MODEL=sonnet

# Reviewer model (default: opus)
export ITRNAUT_REVIEWER_MODEL=opus

# Max iterations (default: 10)
export ITRNAUT_MAX_ITERATIONS=10

# Enable reviewer (default: true)
export ITRNAUT_REVIEWER_ENABLED=true
```

### Hooks

The plugin includes automatic progress tracking via hooks in `.claude/settings.json`.

## Examples

See `examples/` directory:

- `basic/` - Simple Task Manager API
- `full-stack/` - E-Commerce Dashboard
- `api/` - Payment Processing API

## Architecture

### Subagent Relay Benefits

| Metric | Single Agent | Iternaut |
|--------|--------------|----------|
| Tokens | ~150K | ~45K (3x savings) |
| Time | 2+ hours | 30-60 minutes |
| Quality | One-shot | Iterated until verified |
| Coverage | Variable | 100% requirements |

### File-Based State

```
.iter/
├── progress.txt          # Execution log
├── PLAN.md              # Implementation plan
├── research-*.md        # Research outputs
└── artifacts/
    ├── decisions.md
    ├── open-questions.md
    ├── risks.md
    ├── acceptance-tests.md
    └── security-scan.md
```

## Troubleshooting

### PRD not found
Ensure `PRD.md` is in `.claude/` directory.

### Progress.txt not updating
Check that `.iter/` directory is writable.

### Review failing repeatedly
Review feedback should be specific. Enhance PRD with more details.

### Max iterations reached
Increase `ITRNAUT_MAX_ITERATIONS` or simplify PRD scope.

### Subagent not working
Check subagent files exist in `agents/` directory.

## Resources

- [Subagents Reference](../../references/subagents.md)
- [Hooks Reference](../../references/hooks.md)
- [Claude Plugins Guide](../../references/claude-plugins.md)

## License

MIT
