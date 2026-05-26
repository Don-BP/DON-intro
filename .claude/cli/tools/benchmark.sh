#!/bin/bash
# Benchmark Tool
# Measures CLI tool performance (latency, memory, token estimation)

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

TOOL_NAME="benchmark"
SUPPORTED_ACTIONS=("run", "compare", "profile", "list")

# ============================================================
# Helper Functions
# ============================================================

# Measure execution time
measure_time() {
    local cmd="$1"
    local start=$(date +%s%N)
    eval "$cmd" > /dev/null 2>&1
    local end=$(date +%s%N)
    echo $(( (end - start) / 1000000 ))  # Convert to milliseconds
}

# Estimate tokens based on JSON size
estimate_tokens() {
    local json="$1"
    local json_size=$(echo "$json" | wc -c)
    # Rough estimation: ~4 chars per token
    local tokens=$((json_size / 4))
    # Add ~100 tokens for JSON overhead
    echo $((tokens + 100))
}

# ============================================================
# ACTIONS
# ============================================================

action_run() {
    local params="$1"

    local tool=$(json_get "$params" ".tool")
    local action=$(json_get "$params" ".action")
    local request=$(json_get "$params" ".request // {}")
    local iterations=$(json_get "$params" ".iterations // \"10\"")

    if [[ -z "$tool" ]] || [[ -z "$action" ]]; then
        error_response "Missing required parameters: tool, action" "INVALID_PARAM"
        return 1
    fi

    local tool_path="./.claude/cli/tools/${tool}.sh"
    if [[ ! -f "$tool_path" ]]; then
        error_response "Tool not found: $tool" "NOT_FOUND"
        return 1
    fi

    # Prepare request
    local test_request=$(jq -n \
        --arg action "$action" \
        --argjson params "$request" \
        '{action: $action, params: $params}')

    # Run benchmarks
    local total_time=0
    local times=()

    log_info "Running benchmark: $tool.$action (iterations=$iterations)"

    for ((i=0; i<iterations; i++)); do
        local start=$(date +%s%N)
        "$tool_path" <<< "$test_request" > /dev/null 2>&1
        local end=$(date +%s%N)
        local elapsed=$(( (end - start) / 1000000 ))
        times+=($elapsed)
        total_time=$((total_time + elapsed))
    done

    # Calculate statistics
    local avg=$((total_time / iterations))
    local min=${times[0]}
    local max=${times[0]}

    for time in "${times[@]}"; do
        [[ $time -lt $min ]] && min=$time
        [[ $time -gt $max ]] && max=$time
    done

    # Estimate token usage
    local input_tokens=$(estimate_tokens "$test_request")
    local output_tokens=100  # Rough estimate

    # Return results
    local result=$(jq -n \
        --arg tool "$tool" \
        --arg action "$action" \
        --arg iterations "$iterations" \
        --arg avg "$avg" \
        --arg min "$min" \
        --arg max "$max" \
        --arg total "$total_time" \
        --arg input_tokens "$input_tokens" \
        --arg output_tokens "$output_tokens" \
        '{
            tool: $tool,
            action: $action,
            iterations: $iterations,
            time_ms: {
                average: $avg,
                min: $min,
                max: $max,
                total: $total
            },
            tokens: {
                input: $input_tokens,
                output: $output_tokens,
                total: ($input_tokens | tonumber) + ($output_tokens | tonumber)
            }
        }')

    success_response "$result"
}

action_compare() {
    local params="$1"

    local tool1=$(json_get "$params" ".tool1")
    local action1=$(json_get "$params" ".action1")
    local tool2=$(json_get "$params" ".tool2")
    local action2=$(json_get "$params" ".action2")
    local iterations=$(json_get "$params" ".iterations // \"10\"")

    if [[ -z "$tool1" ]] || [[ -z "$action1" ]] || [[ -z "$tool2" ]] || [[ -z "$action2" ]]; then
        error_response "Missing required parameters" "INVALID_PARAM"
        return 1
    fi

    # Benchmark first tool
    local result1_json=$(jq -n \
        --arg tool "$tool1" \
        --arg action "$action1" \
        --arg iterations "$iterations" \
        '{action: "run", params: {tool: $tool, action: $action, iterations: $iterations, request: {}}}')

    local result1=$("$0" <<< "$result1_json")

    # Benchmark second tool
    local result2_json=$(jq -n \
        --arg tool "$tool2" \
        --arg action "$action2" \
        --arg iterations "$iterations" \
        '{action: "run", params: {tool: $tool, action: $action, iterations: $iterations, request: {}}}')

    local result2=$("$0" <<< "$result2_json")

    if ! echo "$result1" | jq -e '.success' > /dev/null || ! echo "$result2" | jq -e '.success' > /dev/null; then
        error_response "Benchmark failed" "BENCHMARK_ERROR"
        return 1
    fi

    # Compare
    local diff=$(echo "$result1" "$result2" | jq -n \
        --slurpfile r1 <(echo "$result1") \
        --slurpfile r2 <(echo "$result2") \
        '{
            tool1: ($r1[0].data.tool + "." + $r1[0].data.action),
            tool2: ($r2[0].data.tool + "." + $r2[0].data.action),
            time_diff_ms: ($r2[0].data.time_ms.average - $r1[0].data.time_ms.average),
            token_diff: ($r2[0].data.tokens.total - $r1[0].data.tokens.total),
            faster: ($r1[0].data.time_ms.average < $r2[0].data.time_ms.average)
        }')

    success_response "$diff"
}

action_profile() {
    local params="$1"

    local tool=$(json_get "$params" ".tool")
    if [[ -z "$tool" ]]; then
        error_response "Missing required parameter: tool" "INVALID_PARAM"
        return 1
    fi

    local tool_path="./.claude/cli/tools/${tool}.sh"
    if [[ ! -f "$tool_path" ]]; then
        error_response "Tool not found: $tool" "NOT_FOUND"
        return 1
    fi

    # List tool actions
    local actions_json=$("$tool_path" <<< '{"action": "list", "params": {}}')

    if ! echo "$actions_json" | jq -e '.success' > /dev/null; then
        error_response "Failed to get tool actions" "PROFILE_ERROR"
        return 1
    fi

    local actions=$(echo "$actions_json" | jq -r '.data[]')

    # Benchmark each action
    local results=()
    while IFS= read -r action; do
        local benchmark_request=$(jq -n \
            --arg tool "$tool" \
            --arg action "$action" \
            '{action: "run", params: {tool: $tool, action: $action, iterations: "5", request: {}}}')

        local result=$("$0" <<< "$benchmark_request")
        if echo "$result" | jq -e '.success' > /dev/null; then
            results+=($(echo "$result" | jq '.data'))
        fi
    done <<< "$actions"

    # Aggregate results
    local profile=$(jq -n \
        --arg tool "$tool" \
        --slurpfile results <(printf '%s\n' "${results[@]}") \
        '{
            tool: $tool,
            actions: $results,
            avg_time_ms: ($results[].time_ms.average | add / length | round),
            total_actions: ($results | length)
        }')

    success_response "$profile"
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
        "run")
            action_run "$params"
            ;;
        "compare")
            action_compare "$params"
            ;;
        "profile")
            action_profile "$params"
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
