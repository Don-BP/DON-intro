# Lead Generation Pipeline Workflow

Autonomous workflow for lead generation, deduplication, and enrichment.

## Overview

This workflow:
1. Fetches lead data from API or file
2. Deduplicates based on email/ID
3. Segments by industry/region
4. Enriches with additional data
5. Analyzes quality metrics
6. Returns actionable lead list

## Usage

```bash
bash ./.agent/workflows/lead-generation-pipeline.md \
    --source "https://api.example.com/leads" \
    --enrich "./.data/enrichment.json" \
    --segment-by "industry"
```

## Parameters

- `--source` (required) — API endpoint or file path with lead data
- `--enrich` (optional) — File path with enrichment data
- `--segment-by` (optional) — Field to segment by (default: industry)
- `--min-quality` (optional) — Minimum quality score (0-100)

## Workflow Script

```bash
#!/bin/bash
# Workflow: Lead Generation Pipeline
# Location: .agent/workflows/lead-generation-pipeline.md

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

SOURCE=""
ENRICHMENT=""
SEGMENT_BY="industry"
MIN_QUALITY="0"

# ============================================================
# Parse Arguments
# ============================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --source) SOURCE="$2"; shift 2 ;;
        --enrich) ENRICHMENT="$2"; shift 2 ;;
        --segment-by) SEGMENT_BY="$2"; shift 2 ;;
        --min-quality) MIN_QUALITY="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$SOURCE" ]]; then
    echo "Error: --source is required" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_TOOLS="$SCRIPT_DIR/.claude/cli/tools"

# ============================================================
# Step 1: Fetch Lead Data
# ============================================================

echo "[1/5] Fetching lead data..."

LEAD_DATA=""

if [[ "$SOURCE" =~ ^https?:// ]]; then
    # API source
    FETCH_RESULT=$("$CLI_TOOLS/http-client.sh" <<< "$(jq -n \
        --arg url "$SOURCE" \
        '{action: "get", params: {url: $url, timeout: "30"}}')")

    if ! echo "$FETCH_RESULT" | jq -e '.success' > /dev/null; then
        echo "❌ Failed to fetch leads" >&2
        exit 1
    fi

    LEAD_DATA=$(echo "$FETCH_RESULT" | jq -r '.data')
elif [[ -f "$SOURCE" ]]; then
    # File source
    LEAD_DATA=$(cat "$SOURCE")
else
    echo "❌ Invalid source: $SOURCE" >&2
    exit 1
fi

echo "✓ Fetched $(echo "$LEAD_DATA" | jq 'length') leads"

# ============================================================
# Step 2: Deduplicate
# ============================================================

echo "[2/5] Deduplicating leads..."

DEDUPE_RESULT=$("$CLI_TOOLS/market-research.sh" <<< "$(jq -n \
    --arg data "$LEAD_DATA" \
    --arg key "email" \
    '{action: "deduplicate", params: {data: ($data | fromjson), key_field: $key}}')")

if ! echo "$DEDUPE_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Deduplication failed" >&2
    exit 1
fi

DEDUPED_DATA=$(echo "$DEDUPE_RESULT" | jq -r '.data.data')
DEDUPE_STATS=$(echo "$DEDUPE_RESULT" | jq -r '.data | {original: .original_count, deduped: .deduped_count, removed: .duplicates_removed}')

echo "✓ Removed $(echo "$DEDUPE_STATS" | jq -r '.removed') duplicates"

# ============================================================
# Step 3: Segment Data
# ============================================================

echo "[3/5] Segmenting leads by $SEGMENT_BY..."

SEGMENT_RESULT=$("$CLI_TOOLS/market-research.sh" <<< "$(jq -n \
    --arg data "$DEDUPED_DATA" \
    --arg seg_field "$SEGMENT_BY" \
    '{action: "segment-data", params: {data: ($data | fromjson), segment_by: $seg_field}}')")

if ! echo "$SEGMENT_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Segmentation failed" >&2
    exit 1
fi

SEGMENTS=$(echo "$SEGMENT_RESULT" | jq -r '.data')
SEGMENT_COUNT=$(echo "$SEGMENTS" | jq 'length')

echo "✓ Created $SEGMENT_COUNT segments"

# ============================================================
# Step 4: Enrich Data (Optional)
# ============================================================

if [[ -n "$ENRICHMENT" && -f "$ENRICHMENT" ]]; then
    echo "[4/5] Enriching lead data..."

    ENRICHMENT_DATA=$(cat "$ENRICHMENT")

    ENRICH_RESULT=$("$CLI_TOOLS/market-research.sh" <<< "$(jq -n \
        --arg data "$DEDUPED_DATA" \
        --arg enrich "$ENRICHMENT_DATA" \
        '{action: "enrich", params: {data: ($data | fromjson), enrichment: ($enrich | fromjson)}}')")

    if ! echo "$ENRICH_RESULT" | jq -e '.success' > /dev/null; then
        echo "⚠️  Enrichment failed, continuing without enrichment"
    else
        DEDUPED_DATA=$(echo "$ENRICH_RESULT" | jq -r '.data')
        echo "✓ Data enriched"
    fi
else
    echo "[4/5] Skipping enrichment (no enrichment file)"
fi

# ============================================================
# Step 5: Analyze Quality
# ============================================================

echo "[5/5] Analyzing lead quality..."

ANALYSIS_RESULT=$("$CLI_TOOLS/market-research.sh" <<< "$(jq -n \
    --arg leads "$DEDUPED_DATA" \
    '{action: "analyze-leads", params: {leads: ($leads | fromjson)}}')")

if ! echo "$ANALYSIS_RESULT" | jq -e '.success' > /dev/null; then
    echo "⚠️  Analysis failed, continuing without analysis"
    ANALYSIS=""
else
    ANALYSIS=$(echo "$ANALYSIS_RESULT" | jq -r '.data')
    echo "✓ Analysis complete"
fi

# ============================================================
# Output Results
# ============================================================

echo ""
echo "╔════════════════════════════════════════╗"
echo "║     LEAD GENERATION PIPELINE COMPLETE  ║"
echo "╚════════════════════════════════════════╝"
echo ""

echo "📊 Statistics:"
echo "  Original leads:      $(echo "$DEDUPE_STATS" | jq -r '.original')"
echo "  After dedup:         $(echo "$DEDUPE_STATS" | jq -r '.deduped')"
echo "  Duplicates removed:  $(echo "$DEDUPE_STATS" | jq -r '.removed')"
echo "  Segments created:    $SEGMENT_COUNT"
echo ""

if [[ -n "$ANALYSIS" ]]; then
    echo "📈 Quality Metrics:"
    echo "$ANALYSIS" | jq -r '"  Average quality score: \(.quality_score)
  Total leads: \(.total_leads)
  Segments: \(.by_industry | length)"'
    echo ""
fi

echo "📁 Segmentation:"
echo "$SEGMENTS" | jq -r '.[] | "  \(.segment): \(.count) leads"'
echo ""

echo "✨ Output data ready for next steps"
echo "$DEDUPED_DATA" | jq -r 'length | "   (\(.) total leads)"'
```

## Example Invocations

### From API with Segmentation

```bash
bash ./.agent/workflows/lead-generation-pipeline.md \
    --source "https://api.example.com/leads" \
    --segment-by "industry" \
    --enrich "./.data/enrichment.json"
```

### From Local File

```bash
bash ./.agent/workflows/lead-generation-pipeline.md \
    --source "./.data/raw-leads.json" \
    --segment-by "region"
```

### With Quality Filter

```bash
bash ./.agent/workflows/lead-generation-pipeline.md \
    --source "https://api.example.com/leads" \
    --min-quality "75"
```

## Output Example

```
[1/5] Fetching lead data...
✓ Fetched 1,250 leads
[2/5] Deduplicating leads...
✓ Removed 89 duplicates
[3/5] Segmenting leads by industry...
✓ Created 12 segments
[4/5] Enriching lead data...
✓ Data enriched
[5/5] Analyzing lead quality...
✓ Analysis complete

╔════════════════════════════════════════╗
║     LEAD GENERATION PIPELINE COMPLETE  ║
╚════════════════════════════════════════╝

📊 Statistics:
  Original leads:      1250
  After dedup:         1161
  Duplicates removed:  89
  Segments created:    12

📈 Quality Metrics:
  Average quality score: 78
  Total leads: 1161
  Segments: 12

📁 Segmentation:
  Technology: 245 leads
  Healthcare: 198 leads
  Finance: 167 leads
  ...

✨ Output data ready for next steps
   (1161 total leads)
```

## Integration

Outputs can be piped to:
- `json-process` skill for further transformation
- `http-client` skill for API uploads
- `file-processor` skill for file storage

## Related

- **Market Research Tool:** `.claude/cli/tools/market-research.sh`
- **Market Research Skill:** `.agent/skills/market-research/SKILL.md`
- **Competitive Analysis Workflow:** `.agent/workflows/competitive-analysis.md`

---

**Last Updated:** 2026-03-16
**Version:** 1.0
