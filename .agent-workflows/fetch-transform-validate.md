# Fetch → Transform → Validate Workflow

Autonomous workflow demonstrating the complete CLI tool pipeline: fetch data from API, transform it, and validate the result.

## Overview

This workflow:
1. Fetches data from a remote API using `http-client`
2. Validates the response is valid JSON using `json-processor`
3. Transforms the data using jq filters
4. Extracts specific fields
5. Returns processed result or error

## Usage

```bash
bash ./.agent/workflows/fetch-transform-validate.md \
    --url "https://api.example.com/users" \
    --filter ".[] | select(.active == true)" \
    --keys '["id", "name", "email"]'
```

## Parameters

- `--url` (required) — API endpoint to fetch from
- `--filter` (optional) — jq filter to apply (default: identity)
- `--keys` (optional) — JSON array of keys to extract
- `--timeout` (optional) — Request timeout in seconds (default: 30)

## Workflow Steps

### Step 1: Parse Arguments

```bash
#!/bin/bash
set -euo pipefail

# Default values
API_URL=""
JQ_FILTER="."
EXTRACT_KEYS=""
TIMEOUT="30"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --url) API_URL="$2"; shift 2 ;;
        --filter) JQ_FILTER="$2"; shift 2 ;;
        --keys) EXTRACT_KEYS="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Validate required parameters
if [[ -z "$API_URL" ]]; then
    echo "Error: --url is required" >&2
    exit 1
fi

# Resolve relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_TOOLS="$SCRIPT_DIR/.claude/cli/tools"
```

### Step 2: Fetch Data from API

```bash
echo "[1/4] Fetching data from API..."

FETCH_REQUEST=$(jq -n \
    --arg url "$API_URL" \
    --arg timeout "$TIMEOUT" \
    '{
        action: "get",
        params: {
            url: $url,
            timeout: $timeout
        }
    }')

FETCH_RESULT=$("$CLI_TOOLS/http-client.sh" <<< "$FETCH_REQUEST")

# Check if fetch succeeded
if ! echo "$FETCH_RESULT" | jq -e '.success' > /dev/null; then
    ERROR_CODE=$(echo "$FETCH_RESULT" | jq -r '.error.code')
    ERROR_MSG=$(echo "$FETCH_RESULT" | jq -r '.error.message')
    echo "❌ Fetch failed: [$ERROR_CODE] $ERROR_MSG" >&2
    exit 1
fi

RAW_DATA=$(echo "$FETCH_RESULT" | jq -r '.data')
echo "✓ Fetched $(echo "$RAW_DATA" | wc -c) bytes"
```

### Step 3: Validate JSON

```bash
echo "[2/4] Validating JSON..."

VALIDATE_REQUEST=$(jq -n \
    --arg input "$RAW_DATA" \
    '{
        action: "validate",
        params: {
            input: $input
        }
    }')

VALIDATE_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$VALIDATE_REQUEST")

if ! echo "$VALIDATE_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Invalid JSON in response" >&2
    exit 1
fi

echo "✓ JSON is valid"
```

### Step 4: Transform Data

```bash
echo "[3/4] Transforming data..."

TRANSFORM_REQUEST=$(jq -n \
    --arg input "$RAW_DATA" \
    --arg filter "$JQ_FILTER" \
    '{
        action: "transform",
        params: {
            input: $input,
            filter: $filter
        }
    }')

TRANSFORM_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$TRANSFORM_REQUEST")

if ! echo "$TRANSFORM_RESULT" | jq -e '.success' > /dev/null; then
    ERROR_MSG=$(echo "$TRANSFORM_RESULT" | jq -r '.error.message')
    echo "❌ Transform failed: $ERROR_MSG" >&2
    exit 1
fi

TRANSFORMED_DATA=$(echo "$TRANSFORM_RESULT" | jq -r '.data')
echo "✓ Transform applied"
```

### Step 5: Extract Fields (Optional)

```bash
if [[ -n "$EXTRACT_KEYS" ]]; then
    echo "[4/4] Extracting fields..."

    EXTRACT_REQUEST=$(jq -n \
        --arg input "$TRANSFORMED_DATA" \
        --argjson keys "$EXTRACT_KEYS" \
        '{
            action: "extract",
            params: {
                input: $input,
                keys: $keys
            }
        }')

    EXTRACT_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$EXTRACT_REQUEST")

    if ! echo "$EXTRACT_RESULT" | jq -e '.success' > /dev/null; then
        ERROR_MSG=$(echo "$EXTRACT_RESULT" | jq -r '.error.message')
        echo "❌ Extract failed: $ERROR_MSG" >&2
        exit 1
    fi

    FINAL_DATA=$(echo "$EXTRACT_RESULT" | jq -r '.data')
    echo "✓ Fields extracted"
else
    FINAL_DATA="$TRANSFORMED_DATA"
fi
```

### Step 6: Return Result

```bash
echo ""
echo "=== Result ==="
echo "$FINAL_DATA" | jq .
```

## Complete Workflow Script

```bash
#!/bin/bash
# Workflow: Fetch → Transform → Validate
# Location: .agent/workflows/fetch-transform-validate.md

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

API_URL=""
JQ_FILTER="."
EXTRACT_KEYS=""
TIMEOUT="30"

# ============================================================
# Parse Arguments
# ============================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --url) API_URL="$2"; shift 2 ;;
        --filter) JQ_FILTER="$2"; shift 2 ;;
        --keys) EXTRACT_KEYS="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$API_URL" ]]; then
    echo "Error: --url is required" >&2
    echo "Usage: $0 --url <url> [--filter <filter>] [--keys <keys>]" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_TOOLS="$SCRIPT_DIR/.claude/cli/tools"

# ============================================================
# Step 1: Fetch
# ============================================================

echo "[1/4] Fetching from: $API_URL"

FETCH_RESULT=$("$CLI_TOOLS/http-client.sh" <<< "$(jq -n \
    --arg url "$API_URL" \
    --arg timeout "$TIMEOUT" \
    '{action: "get", params: {url: $url, timeout: $timeout}}')")

if ! echo "$FETCH_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Fetch failed: $(echo "$FETCH_RESULT" | jq -r '.error.message')" >&2
    exit 1
fi

RAW_DATA=$(echo "$FETCH_RESULT" | jq -r '.data')
echo "✓ Fetched successfully"

# ============================================================
# Step 2: Validate
# ============================================================

echo "[2/4] Validating JSON..."

VALIDATE_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$(jq -n \
    --arg input "$RAW_DATA" \
    '{action: "validate", params: {input: $input}}')")

if ! echo "$VALIDATE_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Invalid JSON" >&2
    exit 1
fi

echo "✓ JSON validated"

# ============================================================
# Step 3: Transform
# ============================================================

echo "[3/4] Transforming with filter: $JQ_FILTER"

TRANSFORM_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$(jq -n \
    --arg input "$RAW_DATA" \
    --arg filter "$JQ_FILTER" \
    '{action: "transform", params: {input: $input, filter: $filter}}')")

if ! echo "$TRANSFORM_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Transform failed: $(echo "$TRANSFORM_RESULT" | jq -r '.error.message')" >&2
    exit 1
fi

TRANSFORMED_DATA=$(echo "$TRANSFORM_RESULT" | jq -r '.data')
echo "✓ Transform applied"

# ============================================================
# Step 4: Extract (Optional)
# ============================================================

if [[ -n "$EXTRACT_KEYS" ]]; then
    echo "[4/4] Extracting keys..."

    EXTRACT_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$(jq -n \
        --arg input "$TRANSFORMED_DATA" \
        --argjson keys "$EXTRACT_KEYS" \
        '{action: "extract", params: {input: $input, keys: $keys}}')")

    if ! echo "$EXTRACT_RESULT" | jq -e '.success' > /dev/null; then
        echo "❌ Extract failed: $(echo "$EXTRACT_RESULT" | jq -r '.error.message')" >&2
        exit 1
    fi

    FINAL_DATA=$(echo "$EXTRACT_RESULT" | jq -r '.data')
    echo "✓ Fields extracted"
else
    FINAL_DATA="$TRANSFORMED_DATA"
fi

# ============================================================
# Output Result
# ============================================================

echo ""
echo "=== Result ==="
echo "$FINAL_DATA" | jq '.'
```

## Example Invocations

### Fetch and List Active Users

```bash
bash ./.agent/workflows/fetch-transform-validate.md \
    --url "https://api.example.com/users" \
    --filter '.[] | select(.active == true)'
```

### Fetch and Extract Specific Fields

```bash
bash ./.agent/workflows/fetch-transform-validate.md \
    --url "https://jsonplaceholder.typicode.com/users" \
    --filter '.' \
    --keys '["id", "name", "email"]'
```

### Complex Transformation

```bash
bash ./.agent/workflows/fetch-transform-validate.md \
    --url "https://jsonplaceholder.typicode.com/posts" \
    --filter '
        group_by(.userId)
        | map({
            userId: .[0].userId,
            postCount: length,
            titles: map(.title)
          })'
```

## Error Handling

The workflow includes comprehensive error handling:

1. **Invalid URL** → Exit with error message
2. **Network Error** → Display HTTP error code and message
3. **Invalid JSON** → Indicate JSON validation failure
4. **Transform Failure** → Show jq filter error
5. **Extract Failure** → Show extraction error

Each step is independent, so failure in one step stops the workflow cleanly.

## Performance

- **Typical execution:** 200-700ms (depends on API latency)
- **Network time:** 100-500ms (API dependent)
- **Processing time:** 50-100ms (jq transformations)
- **Overhead:** ~50ms (bash + tool invocation)

## Extending the Workflow

To add more steps:

1. **Add a new parameter** (e.g., `--post-filter`)
2. **Add a step condition** (e.g., `if [[ -n "$POST_FILTER" ]]`)
3. **Call appropriate CLI tool** (http-client, json-processor, or custom)
4. **Handle errors** with success check
5. **Pass output to next step**

## Related

- **Skills:** `.agent/skills/http-fetch/`, `.agent/skills/json-process/`
- **Rules:** `.agent/rules/04-cli-tools.md`
- **CLI Tools:** `.claude/cli/tools/http-client.sh`, `.claude/cli/tools/json-processor.sh`

---

**Last Updated:** 2026-03-16
**Version:** 1.0
