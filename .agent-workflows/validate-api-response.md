# Validate API Response Workflow

Workflow for validating API responses against expected schemas and constraints.

## Overview

This workflow:
1. Makes an HTTP request to an API endpoint
2. Validates the response structure and format
3. Checks for required fields
4. Validates field types and values
5. Reports validation results

## Usage

```bash
bash ./.agent/workflows/validate-api-response.md \
    --url "https://api.example.com/data" \
    --schema '{"type": "object", "required": ["id", "name"]}'
```

## Parameters

- `--url` (required) — API endpoint to test
- `--schema` (required) — Expected JSON schema or field list
- `--timeout` (optional) — Request timeout (default: 30s)

## Workflow Script

```bash
#!/bin/bash
# Workflow: Validate API Response
# Location: .agent/workflows/validate-api-response.md

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

API_URL=""
SCHEMA=""
TIMEOUT="30"

# ============================================================
# Parse Arguments
# ============================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --url) API_URL="$2"; shift 2 ;;
        --schema) SCHEMA="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$API_URL" ]] || [[ -z "$SCHEMA" ]]; then
    echo "Error: --url and --schema are required" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_TOOLS="$SCRIPT_DIR/.claude/cli/tools"

# ============================================================
# Step 1: Fetch API Response
# ============================================================

echo "📡 Fetching: $API_URL"

FETCH_RESULT=$("$CLI_TOOLS/http-client.sh" <<< "$(jq -n \
    --arg url "$API_URL" \
    --arg timeout "$TIMEOUT" \
    '{action: "get", params: {url: $url, timeout: $timeout}}')")

if ! echo "$FETCH_RESULT" | jq -e '.success' > /dev/null; then
    ERROR=$(echo "$FETCH_RESULT" | jq -r '.error.message')
    echo "❌ Request failed: $ERROR" >&2
    exit 1
fi

RESPONSE=$(echo "$FETCH_RESULT" | jq -r '.data')
echo "✓ Response received"

# ============================================================
# Step 2: Validate JSON Format
# ============================================================

echo "🔍 Validating JSON format..."

VALIDATE_RESULT=$("$CLI_TOOLS/json-processor.sh" <<< "$(jq -n \
    --arg input "$RESPONSE" \
    '{action: "validate", params: {input: $input}}')")

if ! echo "$VALIDATE_RESULT" | jq -e '.success' > /dev/null; then
    echo "❌ Invalid JSON in response" >&2
    exit 1
fi

echo "✓ Valid JSON"

# ============================================================
# Step 3: Parse Response
# ============================================================

echo "📋 Parsing response..."

PARSED_RESPONSE=$(echo "$RESPONSE" | jq .)

# ============================================================
# Step 4: Validate Required Fields
# ============================================================

if [[ "$SCHEMA" =~ ^\{.*\}$ ]]; then
    # Schema is JSON object
    REQUIRED_FIELDS=$(echo "$SCHEMA" | jq -r '.required[]?' 2>/dev/null || echo "")
else
    # Schema is simple field list (comma-separated or JSON array)
    REQUIRED_FIELDS="$SCHEMA"
fi

if [[ -n "$REQUIRED_FIELDS" ]]; then
    echo "✅ Checking required fields..."

    MISSING_FIELDS=()
    while IFS= read -r field; do
        if ! echo "$PARSED_RESPONSE" | jq -e ".${field}" > /dev/null 2>&1; then
            MISSING_FIELDS+=("$field")
        fi
    done <<< "$(echo "$REQUIRED_FIELDS" | tr ',' '\n')"

    if [[ ${#MISSING_FIELDS[@]} -gt 0 ]]; then
        echo "❌ Missing required fields: ${MISSING_FIELDS[*]}"
        exit 1
    fi

    echo "✓ All required fields present"
fi

# ============================================================
# Step 5: Validate Field Types
# ============================================================

echo "🏷️  Validating field types..."

# Example type checks
TYPE_ERRORS=()

# Check if 'id' is a number
if echo "$PARSED_RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    if ! echo "$PARSED_RESPONSE" | jq -e '.id | type == "number"' > /dev/null 2>&1; then
        TYPE_ERRORS+=("'id' should be a number")
    fi
fi

# Check if 'name' is a string
if echo "$PARSED_RESPONSE" | jq -e '.name' > /dev/null 2>&1; then
    if ! echo "$PARSED_RESPONSE" | jq -e '.name | type == "string"' > /dev/null 2>&1; then
        TYPE_ERRORS+=("'name' should be a string")
    fi
fi

if [[ ${#TYPE_ERRORS[@]} -gt 0 ]]; then
    echo "❌ Type validation errors:"
    for error in "${TYPE_ERRORS[@]}"; do
        echo "   - $error"
    done
    exit 1
fi

echo "✓ All types valid"

# ============================================================
# Step 6: Report Summary
# ============================================================

echo ""
echo "✨ Validation Complete"
echo "========================================"
echo "✓ JSON is valid"
echo "✓ Required fields present"
echo "✓ Field types correct"
echo ""
echo "Response Preview:"
echo "$PARSED_RESPONSE" | jq '.' | head -20

if [[ $(echo "$PARSED_RESPONSE" | jq '. | length // (. | keys | length)') -gt 20 ]]; then
    echo "... (truncated)"
fi
```

## Example Invocations

### Validate User API

```bash
bash ./.agent/workflows/validate-api-response.md \
    --url "https://jsonplaceholder.typicode.com/users/1" \
    --schema '{"required": ["id", "name", "email"]}'
```

### Validate Post API with Longer Timeout

```bash
bash ./.agent/workflows/validate-api-response.md \
    --url "https://jsonplaceholder.typicode.com/posts/1" \
    --schema '{"required": ["id", "title", "body"]}' \
    --timeout "60"
```

## Output Example

```
📡 Fetching: https://jsonplaceholder.typicode.com/users/1
✓ Response received
🔍 Validating JSON format...
✓ Valid JSON
📋 Parsing response...
✅ Checking required fields...
✓ All required fields present
🏷️  Validating field types...
✓ All types valid

✨ Validation Complete
========================================
✓ JSON is valid
✓ Required fields present
✓ Field types correct

Response Preview:
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  ...
}
```

## Error Codes

| Scenario | Output | Exit Code |
|----------|--------|-----------|
| Invalid URL | Request failed | 1 |
| Invalid JSON | Invalid JSON in response | 1 |
| Missing fields | Missing required fields: ... | 1 |
| Wrong types | Type validation errors | 1 |
| Success | Validation Complete | 0 |

## Extending the Workflow

### Add Custom Validation

```bash
# Check email format
if echo "$PARSED_RESPONSE" | jq -e '.email' > /dev/null 2>&1; then
    EMAIL=$(echo "$PARSED_RESPONSE" | jq -r '.email')
    if ! [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "❌ Invalid email format: $EMAIL"
        exit 1
    fi
fi
```

### Add Value Range Checks

```bash
# Check if age is between 0 and 150
if echo "$PARSED_RESPONSE" | jq -e '.age' > /dev/null 2>&1; then
    AGE=$(echo "$PARSED_RESPONSE" | jq -r '.age')
    if (( AGE < 0 )) || (( AGE > 150 )); then
        echo "❌ Invalid age: $AGE"
        exit 1
    fi
fi
```

### Add Nested Field Validation

```bash
# Validate nested address
if echo "$PARSED_RESPONSE" | jq -e '.address.city' > /dev/null 2>&1; then
    CITY=$(echo "$PARSED_RESPONSE" | jq -r '.address.city')
    if [[ -z "$CITY" ]]; then
        echo "❌ Address city is empty"
        exit 1
    fi
fi
```

## Related

- **HTTP Fetch Skill:** `.agent/skills/http-fetch/SKILL.md`
- **JSON Process Skill:** `.agent/skills/json-process/SKILL.md`
- **CLI Tools:** `.claude/cli/tools/http-client.sh`, `.claude/cli/tools/json-processor.sh`
- **Other Workflows:** `.agent/workflows/fetch-transform-validate.md`

---

**Last Updated:** 2026-03-16
**Version:** 1.0
