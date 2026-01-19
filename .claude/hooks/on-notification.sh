#!/bin/bash
# on-notification.sh - Notification hook for Iternaut
# Handles permission requests and alerts

INPUT=$(cat)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null || echo "unknown")
MESSAGE=$(echo "$INPUT" | jq -r '.message // ""' 2>/dev/null || echo "")

# Ensure .iter directory exists
mkdir -p .iter 2>/dev/null || true

# Log notification
echo "[$TIMESTAMP] [AGENT:main] [PHASE:notification] [STATUS:UPDATE] $NOTIFICATION_TYPE: $MESSAGE | refs:.iter/progress.txt | tags:notification" >> .iter/progress.txt 2>/dev/null || true

# Handle specific notification types
if [[ "$NOTIFICATION_TYPE" == *"permission"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:permission] [STATUS:WAITING] Permission requested: $MESSAGE | refs:.iter/progress.txt | tags:permission" >> .iter/progress.txt 2>/dev/null || true
elif [[ "$NOTIFICATION_TYPE" == *"error"* ]]; then
    echo "[$TIMESTAMP] [AGENT:main] [PHASE:error] [STATUS:BLOCKED] Error: $MESSAGE | refs:.iter/progress.txt | tags:error" >> .iter/progress.txt 2>/dev/null || true
fi

exit 0
