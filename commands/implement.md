---
description: Implement tasks from PLAN.md using iter-coder with TDD, iter-tester, and iter-debugger
---

# Iternaut Implement Command

Implement tasks from PLAN.md using the full development workflow.

## Usage

```
/iternaut:implement [TASK-ID]
```

## What It Does

1. Read task from PLAN.md
2. iter-coder implements with TDD
3. iter-tester writes comprehensive tests
4. iter-debugger fixes any issues
5. iter-security-auditor scans for vulnerabilities
6. iter-documenter adds code documentation

## Example

```bash
# Implement specific task
/iternaut:implement TASK-001

# Implement all tasks
/iternaut:implement
```

## Progress Logged

All subagents append to `.iter/progress.txt`:
```
[TIMESTAMP] [AGENT:coder] [PHASE:implementation] [STATUS:DONE] TASK-001 complete
[TIMESTAMP] [AGENT:tester] [PHASE:testing] [STATUS:DONE] Tests written
[TIMESTAMP] [AGENT:security-auditor] [PHASE:security] [STATUS:DONE] Security scan passed
```
