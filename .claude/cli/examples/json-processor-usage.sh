#!/bin/bash
# JSON Processor Usage Examples

set -euo pipefail

CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$CLI_DIR/lib/utils.sh"

echo "=== JSON Processor Tool Examples ==="
echo

# ============================================================
# Example 1: Validate JSON
# ============================================================

echo "1. Validate JSON"
echo "Input:"
INPUT=$(jq -n '{
  action: "validate",
  params: {
    input: "{\"name\": \"John\", \"age\": 30}"
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/json-processor.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 2: Parse JSON with path
# ============================================================

echo "2. Parse JSON with path"
echo "Input:"
INPUT=$(jq -n '{
  action: "parse",
  params: {
    input: "{\"user\": {\"name\": \"Alice\", \"email\": \"alice@example.com\"}}",
    path: ".user.email"
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/json-processor.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 3: Transform with jq filter
# ============================================================

echo "3. Transform with jq filter"
echo "Input:"
INPUT=$(jq -n '{
  action: "transform",
  params: {
    input: "[1, 2, 3, 4, 5]",
    filter: "map(. * 2) | add"
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/json-processor.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 4: Merge JSON objects
# ============================================================

echo "4. Merge JSON objects"
echo "Input:"
INPUT=$(jq -n '{
  action: "merge",
  params: {
    objects: [
      {"name": "John", "age": 30},
      {"email": "john@example.com", "city": "New York"}
    ]
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/json-processor.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 5: Extract specific keys
# ============================================================

echo "5. Extract specific keys"
echo "Input:"
INPUT=$(jq -n '{
  action: "extract",
  params: {
    input: "{\"id\": 123, \"name\": \"Product\", \"price\": 99.99, \"stock\": 50}",
    keys: ["id", "name", "price"]
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/json-processor.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 6: List available actions
# ============================================================

echo "6. List available actions"
echo "Input:"
INPUT=$(jq -n '{
  action: "list",
  params: {}
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/json-processor.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 7: Complex transformation pipeline
# ============================================================

echo "7. Complex transformation (fetch, then process)"
echo "Code:"
cat << 'EOF'
#!/bin/bash

# Step 1: Fetch JSON data
API_RESPONSE=$(jq -n '{
  action: "get",
  params: {
    url: "https://jsonplaceholder.typicode.com/users/1"
  }
}' | ./.claude/cli/tools/http-client.sh)

# Step 2: Parse the response
USER_DATA=$(echo "$API_RESPONSE" | jq -r '.data')

# Step 3: Transform the data (extract specific fields)
PROCESSED=$(jq -n \
  --arg data "$USER_DATA" \
  '{
    action: "extract",
    params: {
      input: $data,
      keys: ["id", "name", "email", "phone"]
    }
  }' | ./.claude/cli/tools/json-processor.sh)

# Step 4: Output result
echo "Processed user data:"
echo "$PROCESSED" | jq '.data'
EOF
echo
