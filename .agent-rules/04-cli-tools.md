# CLI Tool Integration Rules

The agent system uses a standardized **CLI Tool Framework** for external tool invocations. This replaces traditional MCP servers with lightweight, controllable command-line wrappers.

## Core Principle

All CLI tools follow a **unified JSON I/O contract**:

```
Input: JSON on stdin
  {action: "action-name", params: {...}}

Output: JSON on stdout
  {success: true|false, data: ..., error: ..., metadata: ...}
```

This contract ensures:
- Consistent error handling
- Predictable behavior
- Minimal token overhead
- Direct debugging capability

## Available Tools

### http-client

**Location:** `.claude/cli/tools/http-client.sh`
**Skill:** `.agent/skills/http-fetch/SKILL.md`

**Purpose:** Make HTTP requests (GET, POST, HEAD, generic)

**Supported Actions:**
- `get` — HTTP GET
- `post` — HTTP POST
- `head` — HTTP HEAD
- `request` — Generic HTTP with method specification
- `list` — List available actions

**Quick Example:**
```bash
echo '{"action": "get", "params": {"url": "https://api.example.com"}}' | \
    ./.claude/cli/tools/http-client.sh
```

**Parameters:**
```json
{
  "action": "get",
  "params": {
    "url": "https://example.com",
    "headers": {"Authorization": "Bearer token"},
    "timeout": "30"
  }
}
```

### json-processor

**Location:** `.claude/cli/tools/json-processor.sh`
**Skill:** `.agent/skills/json-process/SKILL.md`

**Purpose:** Validate, parse, and transform JSON

**Supported Actions:**
- `validate` — Check JSON syntax
- `parse` — Extract value at path
- `transform` — Apply jq filter
- `merge` — Merge objects
- `extract` — Extract keys
- `list` — List available actions

**Quick Example:**
```bash
echo '{"action": "validate", "params": {"input": "{\"test\": true}"}}' | \
    ./.claude/cli/tools/json-processor.sh
```

**Parameters:**
```json
{
  "action": "transform",
  "params": {
    "input": "[1,2,3]",
    "filter": "map(. * 2) | add"
  }
}
```

## Usage by Agent Role

### Architect Role

Use CLI tools in planning and context initialization:

```bash
# Discover available API capabilities
SCHEMA=$(echo '{"action": "get", "params": {"url": "https://api.example.com/schema"}}' | \
    ./.claude/cli/tools/http-client.sh)

# Validate and parse the schema
VALID=$(echo "$SCHEMA" | \
    jq -n '{action: "validate", params: {input: input}}' | \
    ./.claude/cli/tools/json-processor.sh)
```

### Builder Role

Use CLI tools for data fetching and transformation during implementation:

```bash
# Fetch upstream data
UPSTREAM=$(echo '{"action": "get", "params": {"url": "'$UPSTREAM_URL'"}}' | \
    ./.claude/cli/tools/http-client.sh)

# Extract and transform
PROCESSED=$(echo "{\"action\": \"extract\", \"params\": {\"input\": \"$UPSTREAM\", \"keys\": [\"id\", \"name\"]}}" | \
    ./.claude/cli/tools/json-processor.sh)
```

### Inspector Role

Use CLI tools for verification and validation:

```bash
# Fetch current state from API
CURRENT=$(echo '{"action": "get", "params": {"url": "'$API_STATE_URL'"}}' | \
    ./.claude/cli/tools/http-client.sh)

# Validate against expected schema
VALID=$(echo '{"action": "validate", "params": {"input": "'$CURRENT'"}}' | \
    ./.claude/cli/tools/json-processor.sh)
```

## Error Handling

All tools return consistent error structure:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { /* context */ }
  }
}
```

**Common Error Codes:**

| Code | Meaning | Action |
|------|---------|--------|
| `INVALID_PARAM` | Missing/invalid parameter | Validate parameters |
| `INVALID_JSON` | JSON parse error | Check JSON syntax |
| `HTTP_ERROR` | Network/HTTP error | Check URL, network, API status |
| `TIMEOUT_ERROR` | Request timeout | Increase timeout or check network |
| `TRANSFORM_ERROR` | jq filter failed | Check filter syntax |
| `UNSUPPORTED_ACTION` | Unknown action | Use "list" action to see available |

**Error Handling Pattern:**

```bash
RESULT=$(./.claude/cli/tools/tool-name.sh <<< "$INPUT")

if ! echo "$RESULT" | jq -e '.success' > /dev/null; then
    ERROR_CODE=$(echo "$RESULT" | jq -r '.error.code')
    ERROR_MSG=$(echo "$RESULT" | jq -r '.error.message')
    echo "Error [$ERROR_CODE]: $ERROR_MSG" >&2
    # Handle error appropriately
    exit 1
fi

# Process result
DATA=$(echo "$RESULT" | jq -r '.data')
```

## Common Patterns

### Pattern 1: Fetch and Parse

```bash
#!/bin/bash
API_URL="$1"

# Fetch
RESPONSE=$(echo '{"action": "get", "params": {"url": "'$API_URL'"}}' | \
    ./.claude/cli/tools/http-client.sh)

# Check success
if ! echo "$RESPONSE" | jq -e '.success' > /dev/null; then
    echo "Failed to fetch" >&2
    exit 1
fi

# Extract data
DATA=$(echo "$RESPONSE" | jq -r '.data | fromjson')
echo "$DATA" | jq .
```

### Pattern 2: Validate, Transform, Extract

```bash
#!/bin/bash
JSON_INPUT="$1"

# Validate
if ! echo '{"action": "validate", "params": {"input": "'$JSON_INPUT'"}}' | \
       ./.claude/cli/tools/json-processor.sh | \
       jq -e '.success' > /dev/null; then
    echo "Invalid JSON" >&2
    exit 1
fi

# Transform
TRANSFORMED=$(echo '{"action": "transform", "params": {"input": "'$JSON_INPUT'", "filter": "map(select(.status == \"active\")) | sort_by(.date)"}}' | \
    ./.claude/cli/tools/json-processor.sh)

echo "$TRANSFORMED" | jq '.data'
```

### Pattern 3: Batch Processing

```bash
#!/bin/bash
URLS=("$@")

# Fetch all in sequence (could parallelize)
for URL in "${URLS[@]}"; do
    RESULT=$(echo '{"action": "get", "params": {"url": "'$URL'"}}' | \
        ./.claude/cli/tools/http-client.sh)

    if echo "$RESULT" | jq -e '.success' > /dev/null; then
        echo "$RESULT" | jq '.data'
    fi
done
```

## Performance Considerations

### Token Overhead

CLI tools significantly reduce token usage:

- **Per-call overhead:** 50-100 tokens vs 500-1000 for MCP
- **Serialization:** ~5-10% of request size
- **Total savings:** 80-95% reduction per tool invocation

### Latency

- **Tool startup:** ~5-20ms (bash + jq)
- **JSON parsing:** ~1-2ms
- **Network requests:** 100-500ms (API dependent)

### Optimization Tips

1. **Batch operations** — Use single transform instead of multiple parse calls
2. **Cache results** — Store API responses locally when appropriate
3. **Increase timeouts** — For slow APIs, set `timeout: "60"` or higher
4. **Use direct commands** — For very simple operations, skip tool overhead

## Security

### Secrets Management

Never hardcode secrets. Use utilities to load securely:

```bash
# Load from ~/.claude/secrets/api-key
source ./.claude/cli/lib/utils.sh
API_KEY=$(load_secret "api-key")

# Use in request
RESULT=$(echo '{"action": "get", "params": {"url": "'$URL'", "headers": {"Authorization": "Bearer '$API_KEY'"}}}' | \
    ./.claude/cli/tools/http-client.sh)
```

### Input Validation

Validate all inputs before passing to tools:

```bash
URL="$1"
if [[ ! "$URL" =~ ^https?:// ]]; then
    echo "Invalid URL" >&2
    exit 1
fi
```

### Error Messages

Don't log sensitive data from responses:

```bash
# ❌ Bad: Logs full response
echo "Response: $RESULT"

# ✅ Good: Log only relevant data
SUCCESS=$(echo "$RESULT" | jq -r '.success')
echo "Request successful: $SUCCESS"
```

## Integration Points

### With Agent Rules

- **This file** (04-cli-tools.md) documents tool availability
- **02-research.md** can use HTTP client for external research
- **00-orchestrator.md** references CLI tool protocol

### With Agent Skills

Each tool has a corresponding skill:
- **http-fetch** — Wrapper for http-client.sh
- **json-process** — Wrapper for json-processor.sh
- **cli-tools-help** — Discovery and documentation

### With Agent Workflows

Workflows in `.agent/workflows/` use CLI tools:

```bash
# Workflow: api-fetch.sh
API_URL="$1"

# Use http-client skill/tool
RESPONSE=$(... | ./.claude/cli/tools/http-client.sh)

# Use json-processor skill/tool
PROCESSED=$(... | ./.claude/cli/tools/json-processor.sh)

# Output result
echo "$PROCESSED" | jq '.data'
```

### With Claude Code Hooks

Hooks can validate CLI tool invocations:

```bash
# .claude/hooks/pre-tool-use-cli-validate.sh
if [[ "$COMMAND" =~ \.claude/cli/tools ]]; then
    # Validate JSON input
    if ! echo "$INPUT" | jq empty 2>/dev/null; then
        echo "BLOCKED: Invalid JSON for CLI tool"
        exit 1
    fi
fi
```

## Dependencies

The CLI framework requires:
- **bash** (4.0+) — Shell interpreter
- **jq** (1.5+) — JSON processor
- **curl** (7.0+) — HTTP client (for http-client.sh)

See `.claude/cli/SETUP.md` for installation instructions.

## Documentation

- **CLI Framework Overview:** `.claude/cli/README.md`
- **Setup & Dependencies:** `.claude/cli/SETUP.md`
- **Integration Guide:** `.claude/cli/INTEGRATION.md`
- **HTTP Fetch Skill:** `.agent/skills/http-fetch/SKILL.md`
- **JSON Process Skill:** `.agent/skills/json-process/SKILL.md`
- **CLI Tools Help:** `.agent/skills/cli-tools-help/SKILL.md`

## Creating New Tools

To extend the framework with a new tool:

1. **Copy template:**
   ```bash
   cp ./.claude/cli/tools/template.sh ./.claude/cli/tools/my-tool.sh
   ```

2. **Implement action functions**

3. **Create skill wrapper:**
   ```bash
   mkdir -p ./.agent/skills/my-tool-skill
   # Create SKILL.md
   ```

4. **Update this file** with tool documentation

5. **Test:**
   ```bash
   echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/my-tool.sh
   ```

---

**Last Updated:** 2026-03-16
**Version:** 1.0
**Status:** Active
