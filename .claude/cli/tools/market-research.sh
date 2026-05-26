#!/bin/bash
# Market Research Tool
# Domain-specific tool for market research operations
# Actions: analyze-leads, competitive-analysis, segment-data, deduplicate, enrich

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

TOOL_NAME="market-research"
SUPPORTED_ACTIONS=("analyze-leads" "competitive-analysis" "segment-data" "deduplicate" "enrich" "list")

# ============================================================
# ACTIONS
# ============================================================

action_analyze_leads() {
    local params="$1"

    local leads=$(json_get "$params" ".leads")

    if [[ -z "$leads" ]]; then
        error_response "Missing required parameter: leads" "INVALID_PARAM"
        return 1
    fi

    # Validate JSON
    if ! validate_json "$leads"; then
        error_response "Invalid JSON in leads parameter" "INVALID_JSON"
        return 1
    fi

    # Analyze leads
    local analysis=$(echo "$leads" | jq '
        {
            total_leads: length,
            by_status: (group_by(.status // "unknown") | map({status: .[0].status, count: length})),
            by_industry: (group_by(.industry // "unknown") | map({industry: .[0].industry, count: length})),
            by_region: (group_by(.region // "unknown") | map({region: .[0].region, count: length})),
            quality_score: (map(.quality_score // 0) | add / length | round)
        }
    ')

    success_response "$analysis"
}

action_competitive_analysis() {
    local params="$1"

    local competitors=$(json_get "$params" ".competitors")
    local metrics=$(json_get "$params" ".metrics // [\"price\", \"market_share\", \"features\"]")

    if [[ -z "$competitors" ]]; then
        error_response "Missing required parameter: competitors" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$competitors"; then
        error_response "Invalid JSON in competitors parameter" "INVALID_JSON"
        return 1
    fi

    # Perform competitive analysis
    local analysis=$(echo "$competitors" | jq \
        --argjson metrics "$metrics" \
        '{
            total_competitors: length,
            metrics_coverage: ($metrics | length),
            leader: (max_by(.market_share // 0) | {name, market_share}),
            average_metrics: (
                reduce .[] as $item ({};
                    . + ($metrics as $m |
                        reduce $m[] as $metric ({};
                            .[$metric] = ((.[$metric] // []) + [$item[$metric] // null])
                        )
                    )
                ) | with_entries(
                    .value |= map(select(. != null)) | select((.value | length) > 0) | .value |= (add / length | round)
                )
            ),
            detailed: map({name, features: .features // [], strengths: .strengths // [], weaknesses: .weaknesses // []})
        }
    ')

    success_response "$analysis"
}

action_segment_data() {
    local params="$1"

    local data=$(json_get "$params" ".data")
    local segment_by=$(json_get "$params" ".segment_by")

    if [[ -z "$data" ]] || [[ -z "$segment_by" ]]; then
        error_response "Missing required parameters: data, segment_by" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$data"; then
        error_response "Invalid JSON in data parameter" "INVALID_JSON"
        return 1
    fi

    # Segment the data
    local segmented=$(echo "$data" | jq \
        --arg seg_field "$segment_by" \
        'group_by(.[$seg_field] // "unclassified") |
         map({
             segment: .[0][$seg_field] // "unclassified",
             count: length,
             items: .
         })'
    )

    success_response "$segmented"
}

action_deduplicate() {
    local params="$1"

    local data=$(json_get "$params" ".data")
    local key_field=$(json_get "$params" ".key_field // \"id\"")

    if [[ -z "$data" ]]; then
        error_response "Missing required parameter: data" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$data"; then
        error_response "Invalid JSON in data parameter" "INVALID_JSON"
        return 1
    fi

    # Deduplicate based on key field
    local deduped=$(echo "$data" | jq \
        --arg key "$key_field" \
        'unique_by(.[$key]) |
         {
             original_count: input | length,
             deduped_count: length,
             duplicates_removed: (input | length - length),
             data: .
         }'
    )

    # Return just the deduplicated data with stats
    local result=$(echo "$data" | jq \
        --arg key "$key_field" \
        '{
            original_count: length,
            deduped_count: (unique_by(.[$key]) | length),
            duplicates_removed: (length - (unique_by(.[$key]) | length)),
            data: unique_by(.[$key])
        }'
    )

    success_response "$result"
}

action_enrich() {
    local params="$1"

    local data=$(json_get "$params" ".data")
    local enrichment=$(json_get "$params" ".enrichment")

    if [[ -z "$data" ]] || [[ -z "$enrichment" ]]; then
        error_response "Missing required parameters: data, enrichment" "INVALID_PARAM"
        return 1
    fi

    if ! validate_json "$data" || ! validate_json "$enrichment"; then
        error_response "Invalid JSON in data or enrichment parameter" "INVALID_JSON"
        return 1
    fi

    # Enrich data by merging with enrichment data (based on common fields)
    local enriched=$(echo "$data" | jq \
        --argjson enrich "$enrichment" \
        'map(
            . as $item |
            ($enrich[] | select(.id == $item.id) // {}) as $enrichment_data |
            $item * $enrichment_data
        )'
    )

    success_response "$enriched"
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
        "analyze-leads")
            action_analyze_leads "$params"
            ;;
        "competitive-analysis")
            action_competitive_analysis "$params"
            ;;
        "segment-data")
            action_segment_data "$params"
            ;;
        "deduplicate")
            action_deduplicate "$params"
            ;;
        "enrich")
            action_enrich "$params"
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
