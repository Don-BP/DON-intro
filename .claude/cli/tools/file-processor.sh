#!/bin/bash
# File Processor Tool
# Handles file operations (read, write, list, search, aggregate)

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

TOOL_NAME="file-processor"
SUPPORTED_ACTIONS=("read" "write" "list" "search" "aggregate" "lines" "list")

# ============================================================
# ACTIONS
# ============================================================

action_read() {
    local params="$1"

    local path=$(json_get "$params" ".path")
    local limit=$(json_get "$params" ".limit // \"0\"")

    if [[ -z "$path" ]]; then
        error_response "Missing required parameter: path" "INVALID_PARAM"
        return 1
    fi

    if [[ ! -f "$path" ]]; then
        error_response "File not found: $path" "NOT_FOUND"
        return 1
    fi

    local content
    if [[ "$limit" == "0" ]]; then
        content=$(cat "$path")
    else
        content=$(head -n "$limit" "$path")
    fi

    local file_info=$(jq -n \
        --arg path "$path" \
        --arg size "$(stat -f%z "$path" 2>/dev/null || stat -c%s "$path" 2>/dev/null || echo 0)" \
        --arg lines "$(wc -l < "$path" 2>/dev/null || echo 0)" \
        '{path: $path, size: $size, lines: $lines}')

    local result=$(jq -n \
        --arg content "$content" \
        --argjson info "$file_info" \
        '{content: $content, info: $info}')

    success_response "$result"
}

action_write() {
    local params="$1"

    local path=$(json_get "$params" ".path")
    local content=$(json_get "$params" ".content")
    local append=$(json_get "$params" ".append // \"false\"")

    if [[ -z "$path" ]] || [[ -z "$content" ]]; then
        error_response "Missing required parameters: path, content" "INVALID_PARAM"
        return 1
    fi

    # Ensure directory exists
    mkdir -p "$(dirname "$path")"

    if [[ "$append" == "true" ]]; then
        echo "$content" >> "$path"
    else
        echo "$content" > "$path"
    fi

    success_response "{\"message\": \"File written: $path\", \"path\": \"$path\"}"
}

action_list() {
    local params="$1"

    local path=$(json_get "$params" ".path // \".\"")
    local pattern=$(json_get "$params" ".pattern // \"*\"")
    local recursive=$(json_get "$params" ".recursive // \"false\"")

    if [[ ! -d "$path" ]]; then
        error_response "Directory not found: $path" "NOT_FOUND"
        return 1
    fi

    local find_cmd="find '$path'"
    [[ "$recursive" != "true" ]] && find_cmd="$find_cmd -maxdepth 1"
    find_cmd="$find_cmd -name '$pattern' -type f"

    local files=$(eval "$find_cmd" 2>/dev/null | sort)

    local result=$(jq -n \
        --arg files "$files" \
        '{files: ($files | split("\n") | map(select(. != "")))}')

    success_response "$result"
}

action_search() {
    local params="$1"

    local path=$(json_get "$params" ".path")
    local pattern=$(json_get "$params" ".pattern")
    local context=$(json_get "$params" ".context // \"0\"")

    if [[ -z "$path" ]] || [[ -z "$pattern" ]]; then
        error_response "Missing required parameters: path, pattern" "INVALID_PARAM"
        return 1
    fi

    if [[ ! -f "$path" ]]; then
        error_response "File not found: $path" "NOT_FOUND"
        return 1
    fi

    local matches=$(grep -n -C "$context" "$pattern" "$path" 2>/dev/null || echo "")

    local result=$(jq -n \
        --arg matches "$matches" \
        '{matches: ($matches | split("\n") | map(select(. != "")))}')

    success_response "$result"
}

action_aggregate() {
    local params="$1"

    local files=$(json_get "$params" ".files" | jq -r '.[]' 2>/dev/null || echo "")
    local separator=$(json_get "$params" ".separator // \"\\n---\\n\"")

    if [[ -z "$files" ]]; then
        error_response "Missing required parameter: files" "INVALID_PARAM"
        return 1
    fi

    local aggregated=""
    local file_count=0

    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            if [[ -n "$aggregated" ]]; then
                aggregated="$aggregated$separator"
            fi
            aggregated="$aggregated$(cat "$file")"
            file_count=$((file_count + 1))
        fi
    done <<< "$files"

    local result=$(jq -n \
        --arg content "$aggregated" \
        --arg file_count "$file_count" \
        '{content: $content, files_aggregated: $file_count}')

    success_response "$result"
}

action_lines() {
    local params="$1"

    local path=$(json_get "$params" ".path")
    local start=$(json_get "$params" ".start // \"1\"")
    local end=$(json_get "$params" ".end // \"0\"")

    if [[ -z "$path" ]]; then
        error_response "Missing required parameter: path" "INVALID_PARAM"
        return 1
    fi

    if [[ ! -f "$path" ]]; then
        error_response "File not found: $path" "NOT_FOUND"
        return 1
    fi

    local content
    if [[ "$end" == "0" ]]; then
        content=$(sed -n "${start},\$p" "$path")
    else
        content=$(sed -n "${start},${end}p" "$path")
    fi

    success_response "{\"content\": $(echo "$content" | jq -R . | jq -s .)}"
}

action_list_cmd() {
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
        "read")
            action_read "$params"
            ;;
        "write")
            action_write "$params"
            ;;
        "list")
            action_list "$params"
            ;;
        "search")
            action_search "$params"
            ;;
        "aggregate")
            action_aggregate "$params"
            ;;
        "lines")
            action_lines "$params"
            ;;
        *)
            action_list_cmd
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
