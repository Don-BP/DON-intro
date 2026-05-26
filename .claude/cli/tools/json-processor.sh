#!/bin/bash
# JSON Processor Tool
# Actions: validate, parse, transform, merge, extract
# Utility for JSON data manipulation

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

TOOL_NAME="json-processor"
SUPPORTED_ACTIONS=("validate" "parse" "transform" "merge" "extract" "list")

# ============================================================
# ACTIONS
# ============================================================

action_validate() {
    local params="$1"

    local input=$(json_get "$params" ".input")

    if [[ -z "$input" ]]; then
        error_response "Missing required parameter: input" "INVALID_PARAM"
        return 1
    fi

    if validate_json "$input"; then
        success_response "{\"valid\": true, \"message\": \"Valid JSON\"}"
    else
        error_response "Invalid JSON: $input" "INVALID_JSON"
        return 1
    fi
}

action_parse() {
    local params="$1"

    local input=$(json_get "$params" ".input")
    local path=$(json_get "$params" ".path // \".\"")

    if [[ -z "$input" ]]; then
        error_response "Missing required parameter: input" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$input"; then
        error_response "Invalid JSON input" "INVALID_JSON"
        return 1
    fi

    local result=$(echo "$input" | jq "$path" 2>&1 || echo "null")
    success_response "$result" "{\"path\": \"$path\"}"
}

action_transform() {
    local params="$1"

    local input=$(json_get "$params" ".input")
    local filter=$(json_get "$params" ".filter // \".\"")

    if [[ -z "$input" ]]; then
        error_response "Missing required parameter: input" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$input"; then
        error_response "Invalid JSON input" "INVALID_JSON"
        return 1
    fi

    # Apply jq filter
    local result=$(echo "$input" | jq "$filter" 2>&1)
    local status=$?

    if [[ $status -ne 0 ]]; then
        error_response "Transform failed: $result" "TRANSFORM_ERROR"
        return 1
    fi

    success_response "$result" "{\"filter\": \"$filter\"}"
}

action_merge() {
    local params="$1"

    local obj1=$(json_get "$params" ".objects[0]")
    local obj2=$(json_get "$params" ".objects[1]")

    if [[ -z "$obj1" ]] || [[ -z "$obj2" ]]; then
        error_response "Missing required parameter: objects (array of 2+ JSON objects)" "INVALID_PARAM"
        return 1
    fi

    local result=$(jq -n --argjson o1 "$obj1" --argjson o2 "$obj2" '$o1 * $o2')
    success_response "$result"
}

action_extract() {
    local params="$1"

    local input=$(json_get "$params" ".input")
    local keys=$(json_get "$params" ".keys // []")

    if [[ -z "$input" ]]; then
        error_response "Missing required parameter: input" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$input"; then
        error_response "Invalid JSON input" "INVALID_JSON"
        return 1
    fi

    # Build jq filter to extract specific keys
    local filter='{}'
    while IFS= read -r key; do
        filter=$(jq -n --arg k "$key" --argjson obj "$filter" --argjson inp "$input" '$obj + {($k): $inp[$k]}')
    done < <(echo "$keys" | jq -r '.[]' 2>/dev/null)

    success_response "$filter"
}

action_list() {
    local actions_json=$(printf '%s\n' "${SUPPORTED_ACTIONS[@]}" | jq -R . | jq -s .)
    success_response "$actions_json"
}

# ============================================================
# MAIN
# ============================================================

main() {
    local input=""
    read -t 10 -r input || input=""

    if [[ -z "$input" ]]; then
        input="{}"
    fi

    if ! parse_request "$input"; then
        error_response "Invalid request format" "PARSE_ERROR"
        return 1
    fi

    local action=$(json_get "$input" ".action")
    local params=$(echo "$input" | jq -c '.params')

    if ! require_action "$action" "${SUPPORTED_ACTIONS[@]}"; then
        error_response "Unsupported action: $action" "UNSUPPORTED_ACTION"
        return 1
    fi

    case "$action" in
        "validate")
            action_validate "$params"
            ;;
        "parse")
            action_parse "$params"
            ;;
        "transform")
            action_transform "$params"
            ;;
        "merge")
            action_merge "$params"
            ;;
        "extract")
            action_extract "$params"
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
