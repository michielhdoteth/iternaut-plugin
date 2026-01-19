---
description: Review code and plans against quality gates - returns SHIP or REVISE with feedback
---

# Iternaut Review Command

Review work against quality gates and return SHIP or REVISE decision.

## Usage

```
/iternaut:review [FILE|PLAN]
```

## What It Does

1. Read work item (PLAN.md, code files, or entire implementation)
2. iter-reviewer evaluates against quality gates
3. iter-security-auditor scans for vulnerabilities
4. Returns SHIP or REVISE with specific feedback

## Example

```bash
/iternaut:review .iter/PLAN.md
/iternaut:review src/
/iternaut:review .
```

## Quality Gates Checked

| Gate | Description |
|------|-------------|
| 1: Implementation | Code compiles, tests pass, features work |
| 2: Quality | Clean code, proper naming, no duplication |
| 3: Security | No vulnerabilities, proper auth |
| 4: Testing | Coverage > 80%, tests meaningful |
| 5: Documentation | Code commented, docs updated |

## Decision Output

**SHIP** - All gates pass:
```
SHIP

GATE 1: PASS
GATE 2: PASS
GATE 3: PASS
GATE 4: PASS
GATE 5: PASS

Ready for production.
```

**REVISE** - Some gates fail:
```
REVISE

GATE 1: PASS
GATE 2: FAIL
- Line 42: Variable naming unclear
- Line 78: Complex logic needs comment

GATE 4: FAIL
- Test coverage 72% (requirement: 80%)
```

## Progress Logged

```
[TIMESTAMP] [AGENT:reviewer] [PHASE:review] [STATUS:START] Reviewing TASK-001
[TIMESTAMP] [AGENT:reviewer] [PHASE:review] [STATUS:UPDATE] GATE 1: PASS | GATE 2: FAIL
[TIMESTAMP] [AGENT:reviewer] [PHASE:review] [STATUS:DONE] REVISE - feedback provided
```
