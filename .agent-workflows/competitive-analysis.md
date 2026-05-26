# Competitive Analysis Workflow

Autonomous workflow for gathering and analyzing competitive intelligence.

## Overview

This workflow:
1. Fetches competitor data from sources
2. Analyzes market positioning
3. Compares key metrics
4. Identifies strengths/weaknesses
5. Generates strategic insights
6. Returns competitive analysis report

## Usage

```bash
bash ./.agent/workflows/competitive-analysis.md \
    --competitors "./.data/competitors.json" \
    --metrics '["price", "market_share", "features"]'
```

## Parameters

- `--competitors` (required) — JSON file with competitor data
- `--metrics` (optional) — JSON array of metrics to compare
- `--output` (optional) — Output file path

## Workflow Script

```bash
#!/bin/bash
# Workflow: Competitive Analysis
# Location: .agent/workflows/competitive-analysis.md

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

COMPETITORS=""
METRICS='["price", "market_share", "features", "customer_satisfaction"]'
OUTPUT=""

# ============================================================
# Parse Arguments
# ============================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --competitors) COMPETITORS="$2"; shift 2 ;;
        --metrics) METRICS="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$COMPETITORS" ]]; then
    echo "Error: --competitors is required" >&2
    exit 1
fi

if [[ ! -f "$COMPETITORS" ]]; then
    echo "Error: Competitors file not found: $COMPETITORS" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_TOOLS="$SCRIPT_DIR/.claude/cli/tools"

# ============================================================
# Step 1: Load Competitor Data
# ============================================================

echo "[1/4] Loading competitor data..."

COMPETITOR_DATA=$(cat "$COMPETITORS")

if ! echo "$COMPETITOR_DATA" | jq empty 2>/dev/null; then
    echo "❌ Invalid JSON in competitors file" >&2
    exit 1
fi

COMPETITOR_COUNT=$(echo "$COMPETITOR_DATA" | jq 'length')
echo "✓ Loaded $COMPETITOR_COUNT competitors"

# ============================================================
# Step 2: Validate Data Structure
# ============================================================

echo "[2/4] Validating competitor data..."

VALIDATE_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$(jq -n \
    --arg input "$COMPETITOR_DATA" \
    '{action: "validate", params: {input: $input}}')")

if ! echo "$VALIDATE_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Data validation failed" >&2
    exit 1
fi

echo "✓ Data is valid"

# ============================================================
# Step 3: Analyze Competition
# ============================================================

echo "[3/4] Analyzing competitive landscape..."

ANALYSIS_RESULT=$("$CLI_TOOLS/market-research.sh" <<< "$(jq -n \
    --arg competitors "$COMPETITOR_DATA" \
    --argjson metrics "$METRICS" \
    '{action: "competitive-analysis", params: {competitors: ($competitors | fromjson), metrics: $metrics}}')")

if ! echo "$ANALYSIS_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Competitive analysis failed" >&2
    exit 1
fi

ANALYSIS=$(echo "$ANALYSIS_RESULT" | jq -r '.data')
echo "✓ Analysis complete"

# ============================================================
# Step 4: Generate Insights
# ============================================================

echo "[4/4] Generating strategic insights..."

INSIGHTS=$(echo "$ANALYSIS" | jq '
{
    market_leader: .leader.name,
    leader_market_share: .leader.market_share,
    competitor_count: .total_competitors,
    metrics_analyzed: .metrics_coverage,
    key_insights: [
        ("Market leader: \(.leader.name) with \(.leader.market_share)% share"),
        ("\(.total_competitors) competitors analyzed across \(.metrics_coverage) dimensions"),
        ("Average market dynamics suggest \(if .average_metrics | length > 3 then "diverse competitive landscape" else "concentrated market" end)")
    ]
}')

echo "✓ Insights generated"

# ============================================================
# Output Report
# ============================================================

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║      COMPETITIVE ANALYSIS REPORT      ║"
echo "╚═══════════════════════════════════════╝"
echo ""

echo "🎯 Market Overview:"
echo "$INSIGHTS" | jq -r '"  Competitors: \(.competitor_count)
  Metrics analyzed: \(.metrics_analyzed)
  Market leader: \(.market_leader) (\(.leader_market_share)% share)"'
echo ""

echo "📊 Detailed Analysis:"
echo "$ANALYSIS" | jq -r '.detailed[] | "
  Competitor: \(.name)
  Features: \(.features | join(", ") // "N/A")
  Strengths: \(.strengths | join(", ") // "N/A")
  Weaknesses: \(.weaknesses | join(", ") // "N/A")"'
echo ""

echo "💡 Strategic Insights:"
echo "$INSIGHTS" | jq -r '.key_insights[] | "  • \(.)"'
echo ""

# ============================================================
# Save Report (Optional)
# ============================================================

if [[ -n "$OUTPUT" ]]; then
    REPORT=$(jq -n \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson analysis "$ANALYSIS" \
        --argjson insights "$INSIGHTS" \
        '{
            generated_at: $timestamp,
            summary: $insights,
            detailed_analysis: $analysis
        }')

    echo "$REPORT" > "$OUTPUT"
    echo "✓ Report saved to: $OUTPUT"
fi

echo ""
echo "✨ Analysis complete"
```

## Example Invocations

### Basic Competitive Analysis

```bash
bash ./.agent/workflows/competitive-analysis.md \
    --competitors "./.data/competitors.json"
```

### With Custom Metrics

```bash
bash ./.agent/workflows/competitive-analysis.md \
    --competitors "./.data/competitors.json" \
    --metrics '["price", "market_share", "features", "brand_strength"]'
```

### With Report Output

```bash
bash ./.agent/workflows/competitive-analysis.md \
    --competitors "./.data/competitors.json" \
    --output "./.reports/competitive-analysis-$(date +%Y%m%d).json"
```

## Data Format

Expected competitors.json format:

```json
[
  {
    "name": "Competitor A",
    "market_share": 25,
    "price": 99.99,
    "features": ["feature1", "feature2"],
    "strengths": ["brand recognition", "market reach"],
    "weaknesses": ["high price", "limited features"]
  },
  {
    "name": "Competitor B",
    "market_share": 18,
    "price": 49.99,
    "features": ["feature2", "feature3"],
    "strengths": ["affordability", "ease of use"],
    "weaknesses": ["weak brand", "limited support"]
  }
]
```

## Output Example

```
[1/4] Loading competitor data...
✓ Loaded 5 competitors
[2/4] Validating competitor data...
✓ Data is valid
[3/4] Analyzing competitive landscape...
✓ Analysis complete
[4/4] Generating strategic insights...
✓ Insights generated

╔═══════════════════════════════════════╗
║      COMPETITIVE ANALYSIS REPORT      ║
╚═══════════════════════════════════════╝

🎯 Market Overview:
  Competitors: 5
  Metrics analyzed: 4
  Market leader: Competitor A (25% share)

📊 Detailed Analysis:
  Competitor: Competitor A
  Features: feature1, feature2
  Strengths: brand recognition, market reach
  Weaknesses: high price, limited features

  Competitor: Competitor B
  Features: feature2, feature3
  Strengths: affordability, ease of use
  Weaknesses: weak brand, limited support

💡 Strategic Insights:
  • Market leader: Competitor A with 25% share
  • 5 competitors analyzed across 4 dimensions
  • Average market dynamics suggest diverse competitive landscape

✓ Report saved to: ./.reports/competitive-analysis-20260316.json

✨ Analysis complete
```

## Integration

Results can be:
- Stored in `.reports/` directory
- Uploaded via API using `http-client`
- Transformed using `json-processor`
- Visualized in documentation

## Related

- **Market Research Tool:** `.claude/cli/tools/market-research.sh`
- **Lead Generation Workflow:** `.agent/workflows/lead-generation-pipeline.md`
- **HTTP Fetch Skill:** `.agent/skills/http-fetch/SKILL.md`

---

**Last Updated:** 2026-03-16
**Version:** 1.0
