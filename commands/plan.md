---
description: |
  Convert PRD.md to implementation PLAN.md. Claude is the orchestrator that spawns subagents.
  All subagents append progress to .iter/progress.txt for tracking.
  Single-pass workflow for simpler PRDs.
---

# Iternaut Plan Command

**Claude is the orchestrator**. You spawn specialized subagents to do all the work.

## Usage

```
/iternaut:plan [prd-version]
```

Examples:
```bash
/iternaut:plan                    # Use LATEST PRD from registry
/iternaut:plan v1.0.0             # Use specific version
/iternaut:plan prd-001-task.md    # Use specific file
```

## PRD Location

PRDs are stored in `.claude/prds/` with version prefix:
```
.claude/prds/
  v1.0.0-prd-001-task-manager.md
  v1.1.0-prd-002-payment-api.md
  .prd-registry                    # Version registry
```

The `.prd-registry` file defines which PRD is LATEST.

## How It Works

1. **You (Claude)** read PRD from `.claude/prds/`
2. **You** initialize `.iter/progress.txt`
3. **You** spawn subagents for each phase
4. **Subagents** do the work and write to `.iter/progress.txt`
5. **You** read `.iter/progress.txt` to track progress
6. **You** coordinate handoffs between subagents

## Phases

| Phase | Subagent | Output |
|-------|----------|--------|
| Boot | (you) | Read PRD from prds/, init progress.txt |
| Research (parallel) | iter-researcher | research-*.md |
| Architecture | iter-architect | PLAN.md#Architecture |
| Planning | iter-planner | PLAN.md#Tasks |
| Review | iter-reviewer | SHIP/REVISE |
| Finalize | iter-*, iter-tester, iter-documenter, iter-code-simplifier | artifacts/ |

## Tracking Progress

**Read `.iter/progress.txt`** to see what subagents have done:

```bash
# See completed work
cat .iter/progress.txt | grep "STATUS:DONE"

# See all phases
cat .iter/progress.txt
```

## Example

```
/iternaut:plan v1.0.0

# Claude reads v1.0.0-prd-001-task-manager.md from .claude/prds/
# Claude initializes .iter/progress.txt
# Claude spawns:
#   - iter-researcher (Technical)
#   - iter-researcher (Patterns)
#   - iter-researcher (Risks)
# Claude waits for all researchers to complete
# Claude reads progress.txt to verify completion
# Claude spawns iter-architect
# Claude reads progress.txt
# Claude spawns iter-planner
# Claude reads progress.txt
# Claude spawns iter-reviewer
# Claude checks for SHIP/REVISE
# Claude spawns finalize subagents (including iter-code-simplifier)
# Claude writes COMPLETE
```

## Input Files

- `.claude/prds/v*.md` (versioned PRD, required)
- `.claude/CONTEXT.md` (optional)
- `.claude/NON_GOALS.md` (optional)

## Output Files

- `.iter/progress.txt` (READ THIS)
- `.iter/PLAN.md`
- `.iter/research-*.md`
- `.iter/artifacts/*`

## For Iteration

Use `/iternaut:plan:iter` if you need the iterative workflow with quality gate loop.
