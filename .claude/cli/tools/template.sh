#!/bin/bash
# CLI Tool Template
# Copy this file and rename for each new tool
# This template demonstrates the standard pattern all tools should follow

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/utils.sh"

# ============================================================
# CONFIGURATION
# ============================================================

TOOL_NAME="template"
SUPPORTED_ACTIONS=("action1" "action2" "list")

# ============================================================
# ACTIONS
# ============================================================

# Example action 1
action_action1() {
    local params="$1"

    # Extract parameters
    local param1=$(json_get "$params" ".param1")
    local param2=$(json_get "$params" ".param2")

    if [[ -z "$param1" ]]; then
        error_response "Missing required parameter: param1" "INVALID_PARAM"
        return 1
    fi

    # Do actual work here
    log_info "Executing action1 with param1=$param1, param2=$param2"

    # Return success with data
    local result_data="{\"input\": \"$param1\", \"processed\": true}"
    success_response "$result_data"
}

# Example action 2
action_action2() {
    local params="$1"

    local input=$(json_get "$params" ".input")

    if [[ -z "$input" ]]; then
        error_response "Missing required parameter: input" "INVALID_PARAM"
        return 1
    fi

    # Process
    local output="Processed: $input"

    success_response "{\"output\": \"$output\"}"
}

# List available actions
action_list() {
    local actions_json=$(printf '%s\n' "${SUPPORTED_ACTIONS[@]}" | jq -R . | jq -s .)
    success_response "$actions_json"
}

# ============================================================
# MAIN
# ============================================================

main() {
    # Read input from stdin
    local input=""
    read -t 10 -r input || input=""

    # Default to empty object if no input
    if [[ -z "$input" ]]; then
        input="{}"
    fi

    # Validate and parse input
    if ! parse_request "$input"; then
        error_response "Invalid request format" "PARSE_ERROR"
        return 1
    fi

    # Extract action
    local action=$(json_get "$input" ".action")
    local params=$(json_get "$input" ".params" | jq -c .)

    # Validate action is supported
    if ! require_action "$action" "${SUPPORTED_ACTIONS[@]}"; then
        error_response "Unsupported action: $action" "UNSUPPORTED_ACTION"
        return 1
    fi

    # Dispatch to action handler
    case "$action" in
        "action1")
            action_action1 "$params"
            ;;
        "action2")
            action_action2 "$params"
            ;;
        "list")
            action_list
            ;;
        *)
            error_response "Unknown action: $action" "UNKNOWN_ACTION"
            return 1
            ;;
    esac
}

# Execute main if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
