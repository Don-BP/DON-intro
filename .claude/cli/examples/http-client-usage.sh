#!/bin/bash
# HTTP Client Usage Examples

set -euo pipefail

CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$CLI_DIR/lib/utils.sh"

echo "=== HTTP Client Tool Examples ==="
echo

# ============================================================
# Example 1: Simple GET request
# ============================================================

echo "1. Simple GET request"
echo "Input:"
INPUT=$(jq -n '{
  action: "get",
  params: {
    url: "https://jsonplaceholder.typicode.com/posts/1"
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/http-client.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 2: GET with custom headers
# ============================================================

echo "2. GET with custom headers"
echo "Input:"
INPUT=$(jq -n '{
  action: "request",
  params: {
    method: "GET",
    url: "https://jsonplaceholder.typicode.com/users/1",
    headers: {
      "Accept": "application/json",
      "User-Agent": "CLI-Tool/1.0"
    },
    timeout: "10"
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/http-client.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 3: HEAD request (check if URL exists)
# ============================================================

echo "3. HEAD request (check URL availability)"
echo "Input:"
INPUT=$(jq -n '{
  action: "head",
  params: {
    url: "https://jsonplaceholder.typicode.com/posts/1"
  }
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/http-client.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 4: List available actions
# ============================================================

echo "4. List available actions"
echo "Input:"
INPUT=$(jq -n '{
  action: "list",
  params: {}
}')
echo "$INPUT" | jq .

echo "Output:"
OUTPUT=$("$CLI_DIR/tools/http-client.sh" <<< "$INPUT")
echo "$OUTPUT" | jq .
echo

# ============================================================
# Example 5: Usage in agent skill
# ============================================================

cat << 'EOF'
5. Usage in agent skill (.agent/skills/fetch-data/SKILL.md)

#!/bin/bash

FETCH_URL="$1"

# Call http-client tool
RESPONSE=$(jq -n \
  --arg url "$FETCH_URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

# Check if successful
if echo "$RESPONSE" | jq -e '.success' > /dev/null; then
    echo "✓ Fetch successful"
    DATA=$(echo "$RESPONSE" | jq -r '.data')
    echo "Data: $DATA"
else
    echo "✗ Fetch failed"
    ERROR=$(echo "$RESPONSE" | jq -r '.error.message')
    echo "Error: $ERROR"
    exit 1
fi
EOF
