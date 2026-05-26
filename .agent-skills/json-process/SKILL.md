---
name: json-process
description: Validate, parse, and transform JSON data using the CLI JSON processor tool
---

# JSON Process Skill

Wrapper around the CLI JSON processor tool for JSON manipulation and validation.

## Usage

### Validate JSON

```bash
#!/bin/bash
JSON_INPUT='{"name": "John", "age": 30}'

RESULT=$(jq -n \
  --arg input "$JSON_INPUT" \
  '{action: "validate", params: {input: $input}}' | \
  ./.claude/cli/tools/json-processor.sh)

if echo "$RESULT" | jq -e '.success' > /dev/null; then
    echo "✓ Valid JSON"
else
    echo "✗ Invalid JSON"
    exit 1
fi
```

### Parse JSON (Extract Value)

```bash
#!/bin/bash
JSON_DATA='{"user": {"name": "Alice", "email": "alice@example.com"}}'
JSON_PATH=".user.email"

RESULT=$(jq -n \
  --arg input "$JSON_DATA" \
  --arg path "$JSON_PATH" \
  '{action: "parse", params: {input: $input, path: $path}}' | \
  ./.claude/cli/tools/json-processor.sh)

EMAIL=$(echo "$RESULT" | jq -r '.data')
echo "Email: $EMAIL"
```

### Transform JSON (Apply jq Filter)

```bash
#!/bin/bash
JSON_ARRAY='[1, 2, 3, 4, 5]'
FILTER='map(. * 2) | add'  # Multiply each by 2, then sum

RESULT=$(jq -n \
  --arg input "$JSON_ARRAY" \
  --arg filter "$FILTER" \
  '{action: "transform", params: {input: $input, filter: $filter}}' | \
  ./.claude/cli/tools/json-processor.sh)

echo "Result: $(echo "$RESULT" | jq -r '.data')"
```

### Merge JSON Objects

```bash
#!/bin/bash
RESULT=$(jq -n \
  '{
    action: "merge",
    params: {
      objects: [
        {"name": "John", "age": 30},
        {"email": "john@example.com", "city": "NYC"}
      ]
    }
  }' | \
  ./.claude/cli/tools/json-processor.sh)

MERGED=$(echo "$RESULT" | jq '.data')
echo "Merged: $MERGED"
```

### Extract Specific Keys

```bash
#!/bin/bash
JSON_DATA='{"id": 123, "name": "Product", "price": 99.99, "stock": 50, "sku": "ABC123"}'
KEYS='["id", "name", "price"]'

RESULT=$(jq -n \
  --arg input "$JSON_DATA" \
  --argjson keys "$KEYS" \
  '{action: "extract", params: {input: $input, keys: $keys}}' | \
  ./.claude/cli/tools/json-processor.sh)

echo "Extracted: $(echo "$RESULT" | jq '.data')"
```

## Available Actions

| Action | Description | Parameters |
|--------|-------------|------------|
| `validate` | Check if JSON is valid | `input` |
| `parse` | Extract value at JSON path | `input`, `path` |
| `transform` | Apply jq filter | `input`, `filter` |
| `merge` | Merge multiple JSON objects | `objects` (array) |
| `extract` | Extract specific keys | `input`, `keys` (array) |
| `list` | List available actions | (none) |

## Parameters

### validate
- **input** (string, required) — JSON string to validate

### parse
- **input** (string, required) — JSON string
- **path** (string, optional) — jq path expression (default: `.`)

Example paths:
- `.field` — Access field
- `.field.nested` — Nested access
- `.[0]` — Array index
- `.[]` — Iterate array
- `.field | keys` — Pipe operation

### transform
- **input** (string, required) — JSON string
- **filter** (string, required) — jq filter expression

Example filters:
- `map(. * 2)` — Double each array element
- `select(.age > 21)` — Filter objects
- `group_by(.type)` — Group by field
- `sort_by(.date)` — Sort by field
- `.[] | {name, email}` — Project fields

### merge
- **objects** (array, required) — Array of JSON objects to merge

```json
{
  "objects": [
    {"a": 1},
    {"b": 2},
    {"c": 3}
  ]
}
```

### extract
- **input** (string, required) — JSON string
- **keys** (array, required) — Array of key names to extract

```json
{
  "input": "{\"a\": 1, \"b\": 2, \"c\": 3}",
  "keys": ["a", "c"]
}
```

## Response Format

### Success Response

```json
{
  "success": true,
  "data": "Processed result (JSON-encoded)",
  "error": null,
  "metadata": {
    "action": "parse",
    "path": ".user.email"
  }
}
```

### Error Response

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "INVALID_JSON",
    "message": "Invalid JSON: unexpected character",
    "details": {}
  },
  "metadata": {}
}
```

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `INVALID_PARAM` | Missing required parameter | Check parameters |
| `INVALID_JSON` | JSON parsing failed | Check JSON syntax |
| `TRANSFORM_ERROR` | jq filter failed | Check filter syntax |
| `UNSUPPORTED_ACTION` | Unknown action | Use valid action |
| `PARSE_ERROR` | Input parsing failed | Check input format |

## Common Patterns

### Pattern 1: Fetch API Data → Extract Fields

```bash
#!/bin/bash
API_URL="$1"

# Fetch
API_RESPONSE=$(jq -n \
  --arg url "$API_URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

RAW_DATA=$(echo "$API_RESPONSE" | jq -r '.data')

# Extract specific fields
RESULT=$(jq -n \
  --arg input "$RAW_DATA" \
  --argjson keys '["id", "name", "email"]' \
  '{action: "extract", params: {input: $input, keys: $keys}}' | \
  ./.claude/cli/tools/json-processor.sh)

echo "$RESULT" | jq '.data'
```

### Pattern 2: Validate → Parse → Transform

```bash
#!/bin/bash
JSON_INPUT="$1"

# Step 1: Validate
VALID=$(jq -n \
  --arg input "$JSON_INPUT" \
  '{action: "validate", params: {input: $input}}' | \
  ./.claude/cli/tools/json-processor.sh)

if ! echo "$VALID" | jq -e '.success' > /dev/null; then
    echo "Invalid JSON" >&2
    exit 1
fi

# Step 2: Parse and transform
RESULT=$(jq -n \
  --arg input "$JSON_INPUT" \
  --arg filter 'map(select(.status == "active")) | sort_by(.date)' \
  '{action: "transform", params: {input: $input, filter: $filter}}' | \
  ./.claude/cli/tools/json-processor.sh)

echo "$RESULT" | jq '.data'
```

### Pattern 3: Merge and Validate

```bash
#!/bin/bash
OBJ1='{"name": "John"}'
OBJ2='{"email": "john@example.com"}'
OBJ3='{"age": 30}'

# Merge
MERGED=$(jq -n \
  --argjson o1 "$OBJ1" \
  --argjson o2 "$OBJ2" \
  --argjson o3 "$OBJ3" \
  '{action: "merge", params: {objects: [$o1, $o2, $o3]}}' | \
  ./.claude/cli/tools/json-processor.sh)

RESULT=$(echo "$MERGED" | jq '.data')
echo "Merged result: $RESULT"
```

### Pattern 4: Complex Transformation Pipeline

```bash
#!/bin/bash
JSON_ARRAY='[
  {"id": 1, "name": "Product A", "price": 10, "status": "active"},
  {"id": 2, "name": "Product B", "price": 20, "status": "inactive"},
  {"id": 3, "name": "Product C", "price": 15, "status": "active"}
]'

# Filter active products, extract fields, sum prices
FILTER='
  [.[] | select(.status == "active")]
  | map({id, name, price})
  | {products: ., total_price: map(.price) | add}
'

RESULT=$(jq -n \
  --arg input "$JSON_ARRAY" \
  --arg filter "$FILTER" \
  '{action: "transform", params: {input: $input, filter: $filter}}' | \
  ./.claude/cli/tools/json-processor.sh)

echo "$RESULT" | jq '.data'
```

## jq Filter Syntax Quick Reference

### Basics
- `.` — Identity (return as-is)
- `.field` — Access field
- `.["field"]` — Access with string key
- `.[0]` — Array index

### Iteration
- `.[]` — Iterate array/object values
- `.[] | .field` — Map operation
- `map(.field)` — Transform array

### Selection
- `select(.condition)` — Filter by condition
- `.[] | select(.age > 21)` — Filter items

### Transformation
- `{field1, field2}` — Project fields
- `{name: .name, email: .email}` — Rename fields
- `{key: .value}` — Create new structure

### Aggregation
- `length` — Count elements
- `add` — Sum array
- `min`, `max` — Min/max values
- `group_by(.field)` — Group by field
- `sort_by(.field)` — Sort by field
- `unique_by(.field)` — Deduplicate

### Combining
- `|` — Pipe (pass output as input)
- `,` — Multiple outputs
- `[...]` — Array construction

## Performance Notes

- Typical latency: 1-5ms
- Startup overhead: ~15ms
- Suitable for: JSON validation, transformation, extraction
- Not suitable for: Streaming large datasets (>100MB)

## Limitations

- Input JSON must be valid (pre-validate if needed)
- jq filter syntax required for transformations
- No streaming support (full object in memory)
- Maximum object size: ~100MB (system dependent)

## See Also

- CLI Framework: `.claude/cli/README.md`
- JSON Processor Tool: `.claude/cli/tools/json-processor.sh`
- HTTP Fetch Skill: `.agent/skills/http-fetch/SKILL.md`
- jq Manual: https://stedolan.github.io/jq/manual/

---

**Last Updated:** 2026-03-16
**Version:** 1.0
