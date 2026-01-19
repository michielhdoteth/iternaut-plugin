# Hooks Documentation

Iternaut uses Claude Code hooks for automatic progress tracking and workflow automation.

## Overview

Hooks are configured in `.claude/settings.json` and trigger shell scripts in `.claude/hooks/`. All hooks append to `.iter/progress.txt` for visibility.

## Hook Types

### PreToolUse Hooks

Trigger BEFORE a tool is used.

| Matcher | Hook File | Purpose |
|---------|-----------|---------|
| `Write\|Edit\|MultiEdit` | `pre-write.sh` | Log file write operation |
| `Task` | `pre-task.sh` | Log subagent launch |
| `Bash` | `pre-bash.sh` | Log command execution |

### PostToolUse Hooks

Trigger AFTER a tool is used.

| Matcher | Hook File | Purpose |
|---------|-----------|---------|
| `Write\|Edit\|MultiEdit` | `post-write.sh` | Update progress after file write |
| `Task` | `post-task.sh` | Detect phase completion |
| `Bash` | `post-bash.sh` | Check for test/build completion |

### Lifecycle Hooks

| Hook Type | Matcher | Hook File | Purpose |
|-----------|---------|-----------|---------|
| `Stop` | (all) | `on-stop.sh` | Session end summary |
| `Notification` | (all) | `on-notification.sh` | Handle permission requests |
| `SubagentStart` | `iter-.*` | `subagent-start.sh` | Log iter-* subagent start |
| `SubagentStop` | `iter-.*` | `subagent-stop.sh` | Log iter-* subagent stop |

## Hook Files

### pre-write.sh
```bash
# Triggered before Write/Edit operations
# Logs: "[TIMESTAMP] [AGENT:main] [PHASE:write] [STATUS:START] Writing to FILE"
```

### post-write.sh
```bash
# Triggered after Write/Edit operations
# Checks if PLAN.md is ready for review
# Logs phase transitions
```

### pre-task.sh
```bash
# Triggered before Task tool (subagent launch)
# Logs: "[TIMESTAMP] [AGENT:main] [PHASE:subagent] [STATUS:START] Launching AGENT"
```

### post-task.sh
```bash
# Triggered after Task tool completes
# Detects subagent completion
# Triggers next phase if ready
# Detects SHIP/REVISE decisions
```

### pre-bash.sh
```bash
# Triggered before Bash commands
# Logs command execution
```

### post-bash.sh
```bash
# Triggered after Bash commands
# Checks for test/build completion
```

### on-stop.sh
```bash
# Triggered when session ends
# Logs session summary
# Shows workflow status
# Counts completed phases
```

### on-notification.sh
```bash
# Triggered on permission requests
# Logs notification type
# Handles errors
```

### subagent-start.sh
```bash
# Triggered when iter-* subagent starts
# Logs: "[TIMESTAMP] [AGENT:NAME] [PHASE:start] [STATUS:START]"
# Tracks iteration number
```

### subagent-stop.sh
```bash
# Triggered when iter-* subagent stops
# Logs completion
# Detects SHIP/REVISE
# Increments iteration if REVISE
```

## Progress Log Format

All hooks append to `.iter/progress.txt`:

```
[TIMESTAMP] [AGENT:<name>] [PHASE:<phase>] [STATUS:<STATUS>] <summary> | refs:<file> | tags:<tags>
```

### Example Output
```
[2026-01-19T13:00:00Z] [AGENT:main] [PHASE:boot] [STATUS:START] Starting
[2026-01-19T13:01:00Z] [AGENT:researcher] [PHASE:angle-1-tech] [STATUS:DONE] Architecture research
[2026-01-19T13:06:00Z] [AGENT:reviewer] [PHASE:review] [STATUS:DONE] ALL GATES PASSED - SHIP
[2026-01-19T13:07:00Z] [AGENT:main] [PHASE:complete] [STATUS:COMPLETE] Iternaut complete
```

## Configuration

Hooks are enabled via `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...],
    "Notification": [...],
    "SubagentStart": [...],
    "SubagentStop": [...]
  }
}
```

## Customization

### Disable Hooks

Remove or comment out hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": []  // Disable session end hooks
  }
}
```

### Add Custom Hooks

Add new hook entries:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Custom",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/custom-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting

### Hooks not firing
- Verify `.claude/settings.json` is valid JSON
- Check hook scripts are executable: `chmod +x .claude/hooks/*.sh`
- Ensure `.iter/` directory is writable

### Permission denied
- Run: `chmod +x .claude/hooks/*.sh`
- Check file permissions

### Hook errors in logs
- Check hook script syntax
- Verify jq is installed (required for JSON parsing)
- Review `.iter/progress.txt` for error details

## Dependencies

Hooks require:
- `bash` - Shell interpreter
- `jq` - JSON parsing (for extracting tool input)
- `date` - Timestamp generation

Install dependencies:
```bash
# Ubuntu/Debian
apt-get install bash jq

# macOS
brew install jq

# Windows
# Use Git Bash or WSL
```

## File Locations

```
.claude/
  settings.json           # Hook configuration
  hooks/
    pre-write.sh          # Before file writes
    post-write.sh         # After file writes
    pre-task.sh           # Before subagent launch
    post-task.sh          # After subagent completion
    pre-bash.sh           # Before commands
    post-bash.sh          # After commands
    on-stop.sh            # Session end
    on-notification.sh    # Permission requests
    subagent-start.sh     # Subagent starts
    subagent-stop.sh      # Subagent stops
```
