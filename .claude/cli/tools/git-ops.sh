#!/bin/bash
# Git Operations Tool
# Provides CLI interface to git operations (status, log, diff, commit, etc.)

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

TOOL_NAME="git-ops"
SUPPORTED_ACTIONS=("status" "log" "diff" "commit" "branch" "tag" "remote" "list")

# ============================================================
# ACTIONS
# ============================================================

action_status() {
    local params="$1"

    local result=$(git status --porcelain 2>&1 || echo "")
    local branch=$(git rev-parse --abbrev-ref HEAD 2>&1 || echo "unknown")

    local status_json=$(jq -n \
        --arg branch "$branch" \
        --arg changes "$result" \
        '{
            branch: $branch,
            has_changes: ($changes != ""),
            changes: ($changes | split("\n") | map(select(. != "")))
        }')

    success_response "$status_json"
}

action_log() {
    local params="$1"

    local limit=$(json_get "$params" ".limit // \"10\"")
    local format=$(json_get "$params" ".format // \"oneline\"")

    local log_output=$(git log --oneline -n "$limit" 2>&1 || echo "")

    local log_json=$(jq -n \
        --arg output "$log_output" \
        '{
            commits: ($output | split("\n") | map(select(. != "")))
        }')

    success_response "$log_json"
}

action_diff() {
    local params="$1"

    local target=$(json_get "$params" ".target // \"HEAD\"")
    local stat=$(json_get "$params" ".stat // \"false\"")

    local cmd="git diff $target"
    [[ "$stat" == "true" ]] && cmd="$cmd --stat"

    local diff_output=$(eval "$cmd" 2>&1 | head -100 || echo "")

    local diff_json=$(jq -n \
        --arg output "$diff_output" \
        '{
            diff: $output
        }')

    success_response "$diff_json"
}

action_commit() {
    local params="$1"

    local message=$(json_get "$params" ".message")
    local all=$(json_get "$params" ".all // \"false\"")

    if [[ -z "$message" ]]; then
        error_response "Missing required parameter: message" "INVALID_PARAM"
        return 1
    fi

    local cmd="git commit -m '$message'"
    [[ "$all" == "true" ]] && cmd="git add -A && $cmd"

    local result=$(eval "$cmd" 2>&1 || echo "")

    local commit_json=$(jq -n \
        --arg output "$result" \
        '{
            result: $output
        }')

    success_response "$commit_json"
}

action_branch() {
    local params="$1"

    local action=$(json_get "$params" ".action // \"list\"")
    local name=$(json_get "$params" ".name // \"\"")

    case "$action" in
        "list")
            local branches=$(git branch --format="%(refname:short)" 2>&1)
            local branch_json=$(jq -n \
                --arg branches "$branches" \
                '{branches: ($branches | split("\n") | map(select(. != "")))}')
            success_response "$branch_json"
            ;;
        "create")
            if [[ -z "$name" ]]; then
                error_response "Missing parameter: name" "INVALID_PARAM"
                return 1
            fi
            local result=$(git checkout -b "$name" 2>&1)
            success_response "{\"message\": \"Branch created: $name\"}"
            ;;
        "delete")
            if [[ -z "$name" ]]; then
                error_response "Missing parameter: name" "INVALID_PARAM"
                return 1
            fi
            local result=$(git branch -d "$name" 2>&1)
            success_response "{\"message\": \"Branch deleted: $name\"}"
            ;;
        "switch")
            if [[ -z "$name" ]]; then
                error_response "Missing parameter: name" "INVALID_PARAM"
                return 1
            fi
            local result=$(git checkout "$name" 2>&1)
            success_response "{\"message\": \"Switched to: $name\"}"
            ;;
        *)
            error_response "Unknown branch action: $action" "INVALID_PARAM"
            return 1
            ;;
    esac
}

action_tag() {
    local params="$1"

    local action=$(json_get "$params" ".action // \"list\"")
    local name=$(json_get "$params" ".name // \"\"")

    case "$action" in
        "list")
            local tags=$(git tag --list 2>&1)
            success_response "{\"tags\": $(echo "$tags" | jq -R . | jq -s .)}"
            ;;
        "create")
            if [[ -z "$name" ]]; then
                error_response "Missing parameter: name" "INVALID_PARAM"
                return 1
            fi
            git tag "$name" 2>&1
            success_response "{\"message\": \"Tag created: $name\"}"
            ;;
        "delete")
            if [[ -z "$name" ]]; then
                error_response "Missing parameter: name" "INVALID_PARAM"
                return 1
            fi
            git tag -d "$name" 2>&1
            success_response "{\"message\": \"Tag deleted: $name\"}"
            ;;
        *)
            error_response "Unknown tag action: $action" "INVALID_PARAM"
            return 1
            ;;
    esac
}

action_remote() {
    local params="$1"

    local action=$(json_get "$params" ".action // \"list\"")
    local name=$(json_get "$params" ".name // \"\"")
    local url=$(json_get "$params" ".url // \"\"")

    case "$action" in
        "list")
            local remotes=$(git remote -v 2>&1)
            success_response "{\"remotes\": $(echo "$remotes" | jq -R . | jq -s .)}"
            ;;
        "add")
            if [[ -z "$name" ]] || [[ -z "$url" ]]; then
                error_response "Missing parameters: name, url" "INVALID_PARAM"
                return 1
            fi
            git remote add "$name" "$url" 2>&1
            success_response "{\"message\": \"Remote added: $name\"}"
            ;;
        "remove")
            if [[ -z "$name" ]]; then
                error_response "Missing parameter: name" "INVALID_PARAM"
                return 1
            fi
            git remote remove "$name" 2>&1
            success_response "{\"message\": \"Remote removed: $name\"}"
            ;;
        *)
            error_response "Unknown remote action: $action" "INVALID_PARAM"
            return 1
            ;;
    esac
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
        "status")
            action_status "$params"
            ;;
        "log")
            action_log "$params"
            ;;
        "diff")
            action_diff "$params"
            ;;
        "commit")
            action_commit "$params"
            ;;
        "branch")
            action_branch "$params"
            ;;
        "tag")
            action_tag "$params"
            ;;
        "remote")
            action_remote "$params"
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
