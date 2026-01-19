# Dependencies

This document lists all dependencies for the iternaut-plugin.

## Core Dependencies

### Required

| Dependency | Version | Purpose | Install |
|------------|---------|---------|---------|
| **bash** | 4.0+ | Shell interpreter | Built-in on most systems |
| **jq** | 1.6+ | JSON parsing for hooks | `apt install jq` / `brew install jq` |
| **claude-code** | Latest | Claude Code CLI | [claude.com/cli](https://claude.com/cli) |

### Optional

| Dependency | Purpose | Install |
|------------|---------|---------|
| **git** | Version control | Built-in or `apt install git` |
| **gh** | GitHub CLI | `brew install gh` / `apt install gh` |

## Script Dependencies

### iternaut-loop.sh
- `bash`
- `jq` (for JSON parsing)
- `claude-code` (CLI tool)

### iternaut-review.sh
- `bash`
- `claude-code` (CLI tool)

### verify.sh
- `bash` (no external dependencies)

### Hook Scripts (.claude/hooks/*.sh)
- `bash`
- `jq` (for parsing tool input)
- `date` (for timestamps, built-in)

## Installation

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y bash jq git
curl -sSL https://claude.com/cli | bash
```

### macOS
```bash
brew install jq git
curl -sSL https://claude.com/cli | bash
```

### Windows
```bash
# Option 1: Git Bash (comes with Git)
# Option 2: WSL (Windows Subsystem for Linux)
# Option 3: PowerShell with jq
```

## Verification

Run the verification script to check all dependencies:

```bash
bash scripts/verify.sh
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ITRNAUT_WORKER_MODEL` | sonnet | Model for work subagents |
| `ITRNAUT_REVIEWER_MODEL` | opus | Model for review subagent |
| `ITRNAUT_MAX_ITERATIONS` | 10 | Maximum iterations |
| `ITRNAUT_REVIEWER_ENABLED` | true | Enable cross-model review |
| `ITRNAUT_STATE_DIR` | .iternaut | State directory |

## Claude Code Configuration

The plugin requires Claude Code with subagent support. Ensure subagents are enabled:

```bash
claude --version  # Should be recent version
```

## Troubleshooting

### jq: command not found
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### claude-code: command not found
Install Claude Code CLI from [claude.com/cli](https://claude.com/cli)

### Hooks not firing
1. Check jq is installed: `jq --version`
2. Check scripts are executable: `chmod +x .claude/hooks/*.sh`
3. Verify settings.json is valid: `jq . .claude/settings.json`
