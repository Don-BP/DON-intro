#!/bin/bash
# HTTP Client Tool
# Actions: request, get, post, head
# Wraps curl with consistent JSON I/O

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

TOOL_NAME="http-client"
SUPPORTED_ACTIONS=("request" "get" "post" "head" "list")

# ============================================================
# ACTIONS
# ============================================================

action_request() {
    local params="$1"

    local method=$(json_get "$params" ".method // \"GET\"")
    local url=$(json_get "$params" ".url")
    local headers=$(json_get "$params" ".headers // {}")
    local body=$(json_get "$params" ".body // empty")
    local timeout=$(json_get "$params" ".timeout // \"30\"")

    if [[ -z "$url" ]]; then
        error_response "Missing required parameter: url" "INVALID_PARAM"
        return 1
    fi

    # Build curl command
    local curl_cmd="curl -s -X $method"

    # Add timeout
    curl_cmd="$curl_cmd --max-time $timeout"

    # Add headers
    if [[ "$headers" != "{}" ]]; then
        while IFS='=' read -r key value; do
            curl_cmd="$curl_cmd -H '$key: $value'"
        done < <(echo "$headers" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
    fi

    # Add body if provided
    if [[ -n "$body" ]]; then
        curl_cmd="$curl_cmd -d '$body'"
    fi

    curl_cmd="$curl_cmd $url"

    # Execute
    local response
    if ! response=$(eval "$curl_cmd" 2>&1); then
        error_response "HTTP request failed" "HTTP_ERROR" "{\"error\": \"$response\"}"
        return 1
    fi

    success_response "$response" "{\"method\": \"$method\", \"url\": \"$url\"}"
}

action_get() {
    local params="$1"
    local url=$(json_get "$params" ".url")

    if [[ -z "$url" ]]; then
        error_response "Missing required parameter: url" "INVALID_PARAM"
        return 1
    fi

    local new_params=$(jq -n --arg url "$url" '{method: "GET", url: $url, headers: {}, timeout: "30"}')
    action_request "$new_params"
}

action_post() {
    local params="$1"
    local url=$(json_get "$params" ".url")
    local body=$(json_get "$params" ".body")

    if [[ -z "$url" ]]; then
        error_response "Missing required parameter: url" "INVALID_PARAM"
        return 1
    fi

    local new_params=$(jq -n --arg url "$url" --arg body "$body" '{method: "POST", url: $url, body: $body, headers: {"Content-Type": "application/json"}, timeout: "30"}')
    action_request "$new_params"
}

action_head() {
    local params="$1"
    local url=$(json_get "$params" ".url")

    if [[ -z "$url" ]]; then
        error_response "Missing required parameter: url" "INVALID_PARAM"
        return 1
    fi

    local new_params=$(jq -n --arg url "$url" '{method: "HEAD", url: $url, headers: {}, timeout: "30"}')
    action_request "$new_params"
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
        "request")
            action_request "$params"
            ;;
        "get")
            action_get "$params"
            ;;
        "post")
            action_post "$params"
            ;;
        "head")
            action_head "$params"
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
