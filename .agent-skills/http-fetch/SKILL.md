---
name: http-fetch
description: Make HTTP requests (GET, POST, HEAD) using the CLI HTTP client tool
---

# HTTP Fetch Skill

Wrapper around the CLI HTTP client tool for making RESTful API calls.

## Usage

### Simple GET Request

```bash
#!/bin/bash
URL="https://api.example.com/data"

RESULT=$(jq -n \
  --arg url "$URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

if echo "$RESULT" | jq -e '.success' > /dev/null; then
    DATA=$(echo "$RESULT" | jq -r '.data')
    echo "Success: $DATA"
else
    ERROR=$(echo "$RESULT" | jq -r '.error.message')
    echo "Error: $ERROR" >&2
    exit 1
fi
```

### GET with Custom Headers

```bash
#!/bin/bash
URL="https://api.example.com/data"
API_KEY="your-api-key"

RESULT=$(jq -n \
  --arg url "$URL" \
  --arg key "$API_KEY" \
  '{
    action: "request",
    params: {
      method: "GET",
      url: $url,
      headers: {
        "Authorization": ("Bearer " + $key),
        "Accept": "application/json"
      },
      timeout: "30"
    }
  }' | \
  ./.claude/cli/tools/http-client.sh)

echo "$RESULT" | jq .
```

### POST Request with JSON Body

```bash
#!/bin/bash
URL="https://api.example.com/users"
PAYLOAD='{"name": "John", "email": "john@example.com"}'

RESULT=$(jq -n \
  --arg url "$URL" \
  --arg body "$PAYLOAD" \
  '{
    action: "post",
    params: {
      url: $url,
      body: $body
    }
  }' | \
  ./.claude/cli/tools/http-client.sh)

echo "$RESULT" | jq .
```

### HEAD Request (Check if URL exists)

```bash
#!/bin/bash
URL="https://example.com"

RESULT=$(jq -n \
  --arg url "$URL" \
  '{action: "head", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

if echo "$RESULT" | jq -e '.success' > /dev/null; then
    echo "✓ URL is accessible"
else
    echo "✗ URL is not accessible"
fi
```

## Available Actions

| Action | Description | Parameters |
|--------|-------------|------------|
| `get` | HTTP GET request | `url`, `headers?`, `timeout?` |
| `post` | HTTP POST request | `url`, `body?`, `headers?`, `timeout?` |
| `head` | HTTP HEAD request | `url`, `headers?`, `timeout?` |
| `request` | Generic HTTP request | `method`, `url`, `headers?`, `body?`, `timeout?` |
| `list` | List available actions | (none) |

## Parameters

### Common Parameters

- **url** (string, required) — Target URL (must be http/https)
- **method** (string, optional) — HTTP method (default: GET). Options: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
- **headers** (object, optional) — Custom HTTP headers
  ```json
  {
    "Authorization": "Bearer token",
    "Accept": "application/json",
    "X-Custom-Header": "value"
  }
  ```
- **body** (string, optional) — Request body (for POST, PUT, PATCH)
- **timeout** (string, optional) — Request timeout in seconds (default: 30)

## Response Format

### Success Response

```json
{
  "success": true,
  "data": "Response body (usually JSON string)",
  "error": null,
  "metadata": {
    "method": "GET",
    "url": "https://api.example.com/data"
  }
}
```

### Error Response

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "HTTP_ERROR",
    "message": "Failed to connect to API",
    "details": {}
  },
  "metadata": {}
}
```

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `INVALID_PARAM` | Missing required parameter | Check URL and parameters |
| `HTTP_ERROR` | Network or HTTP error | Check URL, network, API status |
| `TIMEOUT_ERROR` | Request timed out | Increase timeout, check network |
| `UNSUPPORTED_ACTION` | Unknown action | Use valid action from list |
| `PARSE_ERROR` | Invalid input JSON | Check JSON format |

## Common Patterns

### Pattern 1: Fetch and Parse JSON

```bash
#!/bin/bash
API_URL="$1"

RESPONSE=$(jq -n \
  --arg url "$API_URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

if echo "$RESPONSE" | jq -e '.success' > /dev/null; then
    # Parse the JSON response
    DATA=$(echo "$RESPONSE" | jq -r '.data | fromjson')
    echo "$DATA"
else
    ERROR=$(echo "$RESPONSE" | jq -r '.error.message')
    echo "Error: $ERROR" >&2
    exit 1
fi
```

### Pattern 2: Fetch, Check, Transform

```bash
#!/bin/bash
API_URL="$1"
REQUIRED_FIELD="$2"

RESPONSE=$(jq -n \
  --arg url "$API_URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

# Check if successful
if ! echo "$RESPONSE" | jq -e '.success' > /dev/null; then
    echo "Fetch failed" >&2
    exit 1
fi

# Parse and extract field
DATA=$(echo "$RESPONSE" | jq -r '.data | fromjson')
FIELD_VALUE=$(echo "$DATA" | jq -r ".${REQUIRED_FIELD}")

if [[ -z "$FIELD_VALUE" ]]; then
    echo "Field not found: $REQUIRED_FIELD" >&2
    exit 1
fi

echo "$FIELD_VALUE"
```

### Pattern 3: Retry on Failure

```bash
#!/bin/bash
URL="$1"
MAX_RETRIES=3
RETRY_DELAY=2

for ((i=1; i<=MAX_RETRIES; i++)); do
    RESULT=$(jq -n \
      --arg url "$URL" \
      '{action: "get", params: {url: $url}}' | \
      ./.claude/cli/tools/http-client.sh)

    if echo "$RESULT" | jq -e '.success' > /dev/null; then
        echo "$RESULT" | jq '.data'
        exit 0
    fi

    if [[ $i -lt $MAX_RETRIES ]]; then
        sleep $RETRY_DELAY
    fi
done

echo "Failed after $MAX_RETRIES attempts" >&2
exit 1
```

## Limitations

- Maximum request size: Depends on curl (typically 2GB)
- Timeout: Default 30 seconds (configurable)
- No built-in retry logic (implement in skill wrapper)
- No compression support (handled by curl automatically)
- Follows redirects automatically

## Performance Notes

- Typical latency: 100-500ms (network dependent)
- Startup overhead: ~15ms
- Suitable for: Integration with external APIs, webhooks, data fetching
- Not suitable for: High-frequency requests (>100/sec) — use SDK instead

## Security

- Never hardcode API keys in skill definitions
- Use secret loading utilities: `load_secret "api-key"`
- Always validate URLs before making requests
- Sanitize headers and body content
- Don't log sensitive response data

## See Also

- CLI Framework: `.claude/cli/README.md`
- HTTP Tool: `.claude/cli/tools/http-client.sh`
- JSON Processor: `.agent/skills/json-process/SKILL.md`

---

**Last Updated:** 2026-03-16
**Version:** 1.0
