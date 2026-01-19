---
description: Debug errors, fix bugs, and resolve test failures using iter-debugger
---

# Iternaut Debug Command

Debug errors, fix bugs, and resolve test failures.

## Usage

```
/iternaut:debug [ERROR_MESSAGE]
```

## What It Does

1. iter-debugger captures error context
2. Identifies root cause
3. Implements fix
4. Adds regression tests
5. Verifies all tests pass

## Example

```bash
/iternaut:debug TypeError: Cannot read property 'name' of undefined
/iternaut:debug Test failed: User login returns 401
/iternaut:debug npm test shows 3 failing tests
```

## Debugging Process

1. Capture error and stack trace
2. Search codebase for patterns
3. Isolate root cause
4. Implement minimal fix
5. Add test case
6. Verify all tests pass

## Progress Logged

```
[TIMESTAMP] [AGENT:debugger] [PHASE:debugging] [STATUS:START] Investigating error
[TIMESTAMP] [AGENT:debugger] [PHASE:debugging] [STATUS:DONE] Fixed in src/user.ts:42
```
