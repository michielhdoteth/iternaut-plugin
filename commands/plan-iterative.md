---
description: |
  Iterative PRD-to-SHIPPED with quality gate loop. Claude orchestrates, subagents do work.
  All subagents append progress to .iter/progress.txt.
  Iterate until ALL quality gates pass (SHIP).
---

# Iternaut Plan Iterative Command

**Claude is the orchestrator**. You spawn subagents and iterate until quality gates pass.

## Usage

```bash
/iternaut:plan:iter [prd-version]
```

Examples:
```bash
/iternaut:plan:iter                    # Use LATEST PRD
/iternaut:plan:iter v1.0.0             # Use specific version
/iternaut:plan:iter prd-001-task.md    # Use specific file
```

With custom models:
```bash
export ITRNAUT_WORKER_MODEL=sonnet
export ITRNAUT_REVIEWER_MODEL=opus
/iternaut:plan:iter
```

## PRD Location

PRDs are stored in `.claude/prds/` with version prefix:
```
.claude/prds/
  v1.0.0-prd-001-task-manager.md
  v1.1.0-prd-002-payment-api.md
  .prd-registry                    # Version registry
```

## How It Works

```
┌─────────────────────────────────────────────────┐
│              CLAUDE (ORCHESTRATOR)               │
│  - Reads .iter/progress.txt                     │
│  - Reads PRD from .claude/prds/                 │
│  - Spawns subagents                             │
│  - Makes SHIP/REVISE decisions                  │
└────────────────────┬────────────────────────────┘
                     │
          ┌───────────┴───────────┐
          ↓                       ↓
     Subagents              Reviewer
     do work                validates
          │                       │
          └───────────┬───────────┘
                      ↓
             ┌────────┴────────┐
             │                 │
             ↓                 ↓
           SHIP             REVISE
             │                 │
             ↓                 ↓
          Exit            Fix gaps
                             ↓
                        Review again
```

## Claude's Responsibilities

1. **Initialize**: Create `.iter/progress.txt`
2. **Load PRD**: Read from `.claude/prds/` based on version
3. **Spawn**: Launch subagents for each phase
4. **Track**: Read `.iter/progress.txt` to see completion
5. **Coordinate**: Ensure proper handoff between phases
6. **Review**: Spawn iter-reviewer for quality gates
7. **Iterate**: If REVISE, spawn subagents to fix gaps
8. **Complete**: When SHIP, spawn finalize subagents (including iter-code-simplifier)

## Phases

| Phase | Subagent | Logs to |
|-------|----------|---------|
| Boot | (you) | progress.txt |
| Research | iter-researcher (x3) | progress.txt, research-*.md |
| Architecture | iter-architect | progress.txt, PLAN.md |
| Planning | iter-planner | progress.txt, PLAN.md#Tasks |
| Review | iter-reviewer | progress.txt, review-result.md |
| (Iterate) | (varies) | progress.txt |
| Finalize | iter-*, iter-tester, iter-documenter, iter-code-simplifier | progress.txt, artifacts/ |

## Tracking Progress

**Always read `.iter/progress.txt`**:

```bash
# Count completed researchers
cat .iter/progress.txt | grep -c "STATUS:DONE.*researcher"

# Check iteration
cat .iter/progress.txt | grep "iteration"

# Check decision
cat .iter/progress.txt | grep "SHIP\|REVISE"

# Full log
cat .iter/progress.txt
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

## Example Session

```bash
/iternaut:plan:iter v1.0.0

# Claude: Initialize
echo "[TIMESTAMP] [AGENT:claude] [PHASE:boot] [STATUS:START]" > .iter/progress.txt

# Claude: Load PRD from .claude/prds/v1.0.0-prd-001-task-manager.md

# Claude: Spawn researchers (parallel)
Use iter-researcher to research technical architecture
Use iter-researcher to research market patterns
Use iter-researcher to research implementation risks

# Claude: Check progress
cat .iter/progress.txt | grep "STATUS:DONE" | grep "researcher"
# (Claude sees 3 researchers completed)

# Claude: Spawn architect
Use iter-architect to design system architecture

# Claude: Check progress
cat .iter/progress.txt | grep "STATUS:DONE" | grep "architect"

# Claude: Spawn planner
Use iter-planner to create task breakdown

# Claude: Spawn reviewer
Use iter-reviewer to validate quality gates

# Claude: Check decision
cat .iter/progress.txt | grep "SHIP\|REVISE"

# If REVISE:
#   Claude: Identify gaps from review feedback
#   Claude: Spawn appropriate subagent to fix
#   Claude: Spawn reviewer again
#   (Loop until SHIP)

# If SHIP:
#   Claude: Spawn finalize subagents
#   Claude: Spawn iter-code-simplifier to clean up code
#   Claude: Write COMPLETE
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ITRNAUT_WORKER_MODEL` | sonnet | Model for subagents |
| `ITRNAUT_REVIEWER_MODEL` | opus | Model for review |
| `ITRNAUT_MAX_ITERATIONS` | 10 | Max iterations |
| `ITRNAUT_REVIEWER_ENABLED` | true | Enable cross-model review |

## Input Files

- `.claude/prds/v*.md` (versioned PRD, required)
- `.claude/CONTEXT.md` (optional)
- `.claude/NON_GOALS.md` (optional)

## Output Files

- `.iter/progress.txt` (READ THIS - all subagents log here)
- `.iter/PLAN.md`
- `.iter/research-*.md`
- `.iter/review-result.md`
- `.iter/artifacts/*`

## Tips

- **Read progress.txt** after spawning subagents
- **Wait for completion** before next phase
- **For REVISE**, identify specific gaps and spawn targeted subagents
- **Iterate until SHIP** - don't accept partial completion
- **Use iter-code-simplifier** in finalize to keep codebase clean
