#!/bin/bash
# PreToolUse Hook: CLI Tool Input Validation
#
# Validates CLI tool invocations before execution:
# - Checks for valid JSON input
# - Validates required action field
# - Ensures parameters are present

set -euo pipefail

INPUT=$(cat)

# Only validate CLI tool calls
if ! echo "$INPUT" | grep -q "\.claude/cli/tools"; then
    # Not a CLI tool, pass through
    exit 0
fi

# Extract the command that would be run
COMMAND=$(echo "$INPUT" | jq -r '.command // empty' 2>/dev/null || echo "")
ARGS=$(echo "$INPUT" | jq -r '.args // empty' 2>/dev/null || echo "")

# Check if this is a CLI tool invocation
if ! echo "$COMMAND" | grep -q "\.claude/cli/tools"; then
    exit 0
fi

# Try to extract stdin that would be passed to the tool
STDIN_DATA=$(echo "$INPUT" | jq -r '.stdin // empty' 2>/dev/null || echo "")

if [[ -n "$STDIN_DATA" ]]; then
    # Validate JSON format
    if ! echo "$STDIN_DATA" | jq empty 2>/dev/null; then
        echo "BLOCKED: Invalid JSON input to CLI tool" >&2
        echo "Input: $STDIN_DATA" >&2
        exit 1
    fi

    # Validate required fields
    ACTION=$(echo "$STDIN_DATA" | jq -r '.action // empty' 2>/dev/null || echo "")
    PARAMS=$(echo "$STDIN_DATA" | jq -r '.params // empty' 2>/dev/null || echo "")

    if [[ -z "$ACTION" ]]; then
        echo "BLOCKED: Missing required field 'action' in CLI tool input" >&2
        exit 1
    fi

    if [[ -z "$PARAMS" ]]; then
        echo "BLOCKED: Missing required field 'params' in CLI tool input" >&2
        exit 1
    fi

    # Validate params is an object
    if ! echo "$STDIN_DATA" | jq -e '.params | type == "object"' > /dev/null 2>&1; then
        echo "BLOCKED: 'params' must be a JSON object" >&2
        exit 1
    fi

    # Warn about sensitive data in input
    if echo "$STDIN_DATA" | grep -qE 'password|secret|token|key'; then
        echo "[WARN] CLI tool input contains potential sensitive data (password/secret/token/key)" >&2
    fi
fi

# Validation passed
exit 0
