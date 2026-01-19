---
name: iternaut-iter-agent-loop
description: |
  Iternaut PRD-to-SHIPPED skill - Claude orchestrates subagents for complete PRD-to-shipped conversion.
  Claude is the orchestrator, spawning specialized subagents for each phase.
  All subagents append progress to .iter/progress.txt for Claude to track.
  Iterative pattern: Work -> Review -> Iterate until SHIP.
---

# Iternaut Iter-Agent-Loop Skill

You are running the Iternaut PRD-to-SHIPPED skill. **You (Claude) are the orchestrator** that spawns specialized subagents to do all the work.

## Your Role: Orchestrator

As the orchestrator, your job is to:
1. Read the PRD and understand requirements
2. Spawn subagents for each phase of work
3. Monitor progress from `.iter/progress.txt`
4. Coordinate handoffs between subagents
5. Run quality gate reviews
6. Iterate until ALL quality gates pass (SHIP)

## State File: `.iter/progress.txt`

**Critical**: ALL subagents append to `.iter/progress.txt`. Read this file to see what each subagent has done.

Format:
```
[TIMESTAMP] [AGENT:<name>] [PHASE:<phase>] [STATUS:<STATUS>] <summary> | refs:<file> | tags:<tags>
```

## Workflow Phases

### Phase 1: BOOT
1. Read `.claude/PRD.md`
2. Read `.claude/CONTEXT.md` (optional)
3. Read `.claude/NON_GOALS.md` (optional)
4. Initialize `.iter/` directory
5. Write START entry to `.iter/progress.txt`

### Phase 2: RESEARCH (Parallel)
Spawn 3 iter-researcher subagents in parallel:

**iter-researcher (Technical)** - Research architecture:
- System components and design
- Technology stack choices
- Data flow between components
- API patterns
- Database schema

**iter-researcher (Patterns)** - Research market:
- Comparable solutions (GitHub Copilot, Cursor, CodeRabbit)
- Industry best practices
- Differentiation opportunities

**iter-researcher (Risks)** - Research risks:
- Implementation risks
- Edge cases
- Open questions needing resolution

Track progress by reading `.iter/progress.txt`:
```bash
cat .iter/progress.txt | grep "STATUS:DONE.*researcher"
```

Wait until all 3 researchers complete before proceeding.

### Phase 3: ARCHITECTURE
Spawn `iter-architect` subagent to:
- Design system architecture
- Define API surface
- Create data model
- Write to `.iter/PLAN.md#Architecture`

### Phase 4: PLANNING
Spawn `iter-planner` subagent to:
- Break down work into milestones (Phase 1-4)
- Create TASK-IDs with descriptions
- Define dependencies
- Write acceptance criteria
- Append to `.iter/PLAN.md#Tasks`

### Phase 5: QUALITY GATE REVIEW
Spawn `iter-reviewer` subagent to validate:
- GATE 1: Architecture, API, data model, tasks defined
- GATE 2: All requirements mapped, risks identified
- GATE 3: No contradictions, dependencies explicit
- GATE 4: Developer can pick any task and start

### Phase 6: ITERATE (Iterative)
If ANY gate fails:
1. iter-reviewer returns REVISE with feedback
2. You identify which phase needs work
3. Spawn appropriate subagent to fill gaps
4. iter-reviewer reviews again
5. Repeat until ALL gates pass

If ALL gates pass:
1. iter-reviewer returns SHIP
2. Proceed to finalize

### Phase 7: FINALIZE
Spawn subagents for completion:
- `iter-security-auditor` - Security scan
- `iter-tester` - Write acceptance tests
- `iter-documenter` - Create documentation

## Subagents Available

| Subagent | Role | When to Spawn |
|----------|------|---------------|
| `iter-researcher` | Research technical, patterns, risks | Phase 2 |
| `iter-architect` | System design, API, data model | Phase 3 |
| `iter-planner` | Task breakdown, milestones | Phase 4 |
| `iter-reviewer` | Quality gates, SHIP/REVISE | Phase 5 |
| `iter-coder` | Implement with TDD | Implementation |
| `iter-tester` | Write tests | Finalize |
| `iter-debugger` | Fix bugs | When needed |
| `iter-security-auditor` | Security scan | Finalize |
| `iter-documenter` | Create docs | Finalize |
| `iter-explorer` | Fast codebase search | When needed |

## How to Spawn Subagents

```bash
# Launch a subagent
Use the iter-researcher subagent to research technical architecture for the project
```

Claude will spawn the subagent. The subagent:
1. Does its work
2. Appends progress to `.iter/progress.txt`
3. Returns results to you

## Tracking Progress

**Always read `.iter/progress.txt`** to see what subagents have done:

```bash
# See all completed phases
cat .iter/progress.txt | grep "STATUS:DONE"

# See current iteration
cat .iter/progress.txt | grep "iteration"

# See review decision
cat .iter/progress.txt | grep "SHIP\|REVISE"

# See full log
cat .iter/progress.txt
```

## Iterative Pattern

```
┌─────────────────────────────────────────────────────┐
│                    CLAUDE (ORCHESTRATOR)             │
│           Reads .iter/progress.txt                   │
│           Spawns subagents                           │
│           Makes decisions                            │
└────────────────────┬────────────────────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
    ↓                ↓                ↓
┌─────────┐   ┌─────────────┐   ┌─────────────┐
│Research │   │ Architecture│   │  Planning   │
│(parallel)│   │  (iter-arc) │   │(iter-plnr) │
└────┬────┘   └──────┬──────┘   └──────┬──────┘
     │               │                 │
     └───────────────┼─────────────────┘
                     ↓
              ┌─────────────┐
              │   Review    │
              │(iter-rev)   │
              └──────┬──────┘
                     │
            ┌────────┴────────┐
            │                 │
            ↓                 ↓
          SHIP             REVISE
            │                 │
            ↓                 ↓
         Exit            Fill gaps
                             ↓
                        Review again
```

## Quality Gates

| Gate | Criteria |
|------|----------|
| 1: Implementation | Architecture, API, data model, tasks defined |
| 2: Coverage | All requirements mapped, risks identified |
| 3: Blockers | No contradictions, dependencies explicit |
| 4: Actionable | Developer can pick any task and start |

## Complete Workflow Example

```markdown
1. Read PRD.md
2. Initialize state:
   mkdir -p .iter/artifacts
   echo "[TIMESTAMP] [AGENT:claude] [PHASE:boot] [STATUS:START] Starting PRD-to-PLAN | refs:.claude/PRD.md | tags:init" > .iter/progress.txt

3. Spawn parallel researchers:
   Use iter-researcher to research technical architecture
   Use iter-researcher to research market patterns
   Use iter-researcher to research implementation risks

4. Check progress:
   cat .iter/progress.txt | grep "STATUS:DONE.*researcher"
   (Wait until all 3 complete)

5. Spawn architect:
   Use iter-architect to design system architecture and API

6. Spawn planner:
   Use iter-planner to break down into milestones and tasks

7. Spawn reviewer:
   Use iter-reviewer to validate quality gates

8. Check decision:
   cat .iter/progress.txt | grep "SHIP\|REVISE"

9. If REVISE:
   Identify gaps from review feedback
   Spawn appropriate subagent to fill gaps
   GOTO step 7

10. If SHIP:
    Spawn iter-security-auditor
    Spawn iter-tester
    Spawn iter-documenter
    Write COMPLETE to progress.txt
```

## Output Files

All in `.iter/`:
- `progress.txt` - Execution log (READ THIS)
- `PLAN.md` - Implementation plan
- `research-*.md` - Research outputs
- `artifacts/` - Decisions, risks, tests, docs

## Tips

- **Read progress.txt** after spawning subagents to track their work
- **Wait for subagents to complete** before proceeding
- **Use iter-explorer** to quickly search the codebase if needed
- **Iterate until SHIP** - don't settle for partial completion
- **All subagents write to progress.txt** - this is your visibility

## Start Now

1. Read `.claude/PRD.md`
2. Create `.iter/` directory
3. Write START to `.iter/progress.txt`
4. Begin orchestrating the workflow
