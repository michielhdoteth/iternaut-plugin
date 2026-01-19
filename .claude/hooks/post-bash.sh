#!/bin/bash
# post-bash.sh - Post-bash hook for Iternaut
# Logs command execution and checks for completion signals

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // "unknown"' 2>/dev/null || echo "unknown")
DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // ""' 2>/dev/null || echo "")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log the command
echo "[$TIMESTAMP] [AGENT:main] [PHASE:bash] [STATUS:UPDATE] $COMMAND | refs:.iter/progress.txt | tags:bash" >> .iter/progress.txt 2>/dev/null || true

# Check for completion signals
if [[ "$COMMAND" == *"npm test"* ]] || [[ "$COMMAND" == *"yarn test"* ]]; then
    # Tests were run - could trigger next phase
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:testing] [STATUS:COMPLETE] Test suite executed | refs:.iter/progress.txt | tags:testing" >> .iter/progress.txt 2>/dev/null || true
fi

# Check for build commands
if [[ "$COMMAND" == *"npm run build"* ]] || [[ "$COMMAND" == *"yarn build"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:build] [STATUS:COMPLETE] Build completed | refs:.iter/progress.txt | tags:build" >> .iter/progress.txt 2>/dev/null || true
fi

exit 0
