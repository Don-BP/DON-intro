---
name: cli-tools-help
description: Discover and list available CLI tools and their actions
---

# CLI Tools Help Skill

Provides discovery, documentation, and usage information for all available CLI tools.

## Usage

### List All Available Tools

```bash
#!/bin/bash
# Show available CLI tools
ls -1 ./.claude/cli/tools/*.sh | while read tool; do
    TOOL_NAME=$(basename "$tool" .sh)
    echo "- $TOOL_NAME"
done
```

### Get Available Actions for a Tool

```bash
#!/bin/bash
TOOL="$1"  # e.g., "http-client"

RESULT=$(jq -n \
  '{action: "list", params: {}}' | \
  "./.claude/cli/tools/${TOOL}.sh")

echo "$RESULT" | jq '.data[] | "\(.)"' -r
```

### Show Tool Documentation

```bash
#!/bin/bash
TOOL="$1"  # e.g., "http-client"

echo "=== $TOOL Documentation ==="
echo

# Check for documentation
if [[ -f "./.claude/cli/examples/${TOOL}-usage.sh" ]]; then
    echo "Usage Examples:"
    cat "./.claude/cli/examples/${TOOL}-usage.sh" | grep -A 10 "^echo"
fi

if [[ -f "./.agent/skills/${TOOL}-skill/SKILL.md" ]]; then
    echo "Skill Documentation:"
    cat "./.agent/skills/${TOOL}-skill/SKILL.md"
fi
```

## Available Tools

### http-client
**Purpose:** Make HTTP requests (GET, POST, HEAD)

**Actions:**
- `get` — HTTP GET request
- `post` — HTTP POST request
- `head` — HTTP HEAD request
- `request` — Generic HTTP request with method specification
- `list` — List available actions

**Quick Example:**
```bash
echo '{"action": "get", "params": {"url": "https://example.com"}}' | \
    ./.claude/cli/tools/http-client.sh
```

**Skill:** `.agent/skills/http-fetch/SKILL.md`

### json-processor
**Purpose:** Validate, parse, and transform JSON data

**Actions:**
- `validate` — Check if JSON is syntactically valid
- `parse` — Extract value at JSON path expression
- `transform` — Apply jq filter to JSON
- `merge` — Merge multiple JSON objects
- `extract` — Extract specific keys from JSON
- `list` — List available actions

**Quick Example:**
```bash
echo '{"action": "validate", "params": {"input": "{\"test\": true}"}}' | \
    ./.claude/cli/tools/json-processor.sh
```

**Skill:** `.agent/skills/json-process/SKILL.md`

### template (Reference)
**Purpose:** Template for creating new CLI tools

**Use:** Copy this file to create a new tool wrapper

**Location:** `.claude/cli/tools/template.sh`

## Tool Invocation Pattern

All CLI tools follow the same pattern:

```bash
# 1. Create JSON request
INPUT=$(jq -n '{
  action: "action-name",
  params: { /* parameters */ }
}')

# 2. Call the tool
RESULT=$(cat <<< "$INPUT" | ./.claude/cli/tools/tool-name.sh)

# 3. Process response
echo "$RESULT" | jq '{success, error, data}'
```

## Response Format

All tools return:

```json
{
  "success": true|false,
  "data": /* action result or null */,
  "error": /* error object or null */,
  "metadata": { /* info */ }
}
```

Check `.success` to determine if action succeeded:

```bash
if echo "$RESULT" | jq -e '.success' > /dev/null; then
    echo "Success!"
    DATA=$(echo "$RESULT" | jq -r '.data')
else
    echo "Error: $(echo "$RESULT" | jq -r '.error.message')"
fi
```

## Tool Invocation Reference

### http-client

**GET Request:**
```bash
jq -n '{action: "get", params: {url: "https://api.example.com/data"}}' | \
    ./.claude/cli/tools/http-client.sh
```

**POST Request:**
```bash
jq -n '{
  action: "post",
  params: {
    url: "https://api.example.com/users",
    body: "{\"name\": \"John\"}"
  }
}' | ./.claude/cli/tools/http-client.sh
```

**HEAD Request:**
```bash
jq -n '{action: "head", params: {url: "https://example.com"}}' | \
    ./.claude/cli/tools/http-client.sh
```

**Custom Headers:**
```bash
jq -n '{
  action: "request",
  params: {
    method: "GET",
    url: "https://api.example.com/data",
    headers: {
      "Authorization": "Bearer token123",
      "Accept": "application/json"
    }
  }
}' | ./.claude/cli/tools/http-client.sh
```

### json-processor

**Validate JSON:**
```bash
jq -n '{action: "validate", params: {input: "{\"test\": true}"}}' | \
    ./.claude/cli/tools/json-processor.sh
```

**Parse with Path:**
```bash
jq -n '{
  action: "parse",
  params: {
    input: "{\"user\": {\"name\": \"Alice\"}}",
    path: ".user.name"
  }
}' | ./.claude/cli/tools/json-processor.sh
```

**Transform:**
```bash
jq -n '{
  action: "transform",
  params: {
    input: "[1,2,3,4,5]",
    filter: "map(. * 2) | add"
  }
}' | ./.claude/cli/tools/json-processor.sh
```

**Merge Objects:**
```bash
jq -n '{
  action: "merge",
  params: {
    objects: [
      {"a": 1},
      {"b": 2}
    ]
  }
}' | ./.claude/cli/tools/json-processor.sh
```

**Extract Keys:**
```bash
jq -n '{
  action: "extract",
  params: {
    input: "{\"id\": 1, \"name\": \"Test\", \"other\": \"data\"}",
    keys: ["id", "name"]
  }
}' | ./.claude/cli/tools/json-processor.sh
```

## Common Error Codes

| Code | Cause | Fix |
|------|-------|-----|
| `INVALID_PARAM` | Missing or invalid parameter | Check required parameters |
| `INVALID_JSON` | JSON parsing failed | Validate JSON syntax |
| `HTTP_ERROR` | Network or HTTP error | Check URL, network, API |
| `TIMEOUT_ERROR` | Request timeout | Increase timeout or check network |
| `TRANSFORM_ERROR` | jq filter failed | Check filter syntax |
| `UNSUPPORTED_ACTION` | Unknown action | Use "list" to see valid actions |

## Getting Help

### List Tool Actions
```bash
# List http-client actions
echo '{"action": "list", "params": {}}' | \
    ./.claude/cli/tools/http-client.sh

# List json-processor actions
echo '{"action": "list", "params": {}}' | \
    ./.claude/cli/tools/json-processor.sh
```

### Read Tool Documentation
```bash
# HTTP client skill docs
cat ./.agent/skills/http-fetch/SKILL.md

# JSON processor skill docs
cat ./.agent/skills/json-process/SKILL.md

# CLI framework documentation
cat ./.claude/cli/README.md
```

### See Usage Examples
```bash
# HTTP client examples
bash ./.claude/cli/examples/http-client-usage.sh

# JSON processor examples
bash ./.claude/cli/examples/json-processor-usage.sh
```

## Creating New Tools

To create a new CLI tool:

1. **Copy template:**
   ```bash
   cp ./.claude/cli/tools/template.sh ./.claude/cli/tools/my-tool.sh
   chmod +x ./.claude/cli/tools/my-tool.sh
   ```

2. **Edit the template:**
   - Set `TOOL_NAME`
   - Add action names to `SUPPORTED_ACTIONS`
   - Implement `action_*` functions
   - Keep `main()` unchanged

3. **Test it:**
   ```bash
   echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/my-tool.sh
   ```

4. **Create a skill wrapper:**
   ```bash
   mkdir -p ./.agent/skills/my-tool-skill
   # Create SKILL.md in that directory
   ```

5. **Document in this help:**
   - Add tool to "Available Tools" section
   - Include quick example
   - Link to skill documentation

## Performance Tips

### Batch Operations
Instead of multiple tool calls, batch operations:

```bash
# ❌ Inefficient: Multiple calls
RESULT1=$(echo '{"action": "parse", "params": {"input": "$JSON1", "path": ".a"}}' | tool)
RESULT2=$(echo '{"action": "parse", "params": {"input": "$JSON1", "path": ".b"}}' | tool)

# ✅ Efficient: Single transform call
RESULT=$(echo '{"action": "transform", "params": {"input": "$JSON1", "filter": "{a: .a, b: .b}"}}' | tool)
```

### Cache Results
If making repeated requests to the same URL:

```bash
CACHE_FILE=".cache/api-response"
URL="https://api.example.com/data"

if [[ -f "$CACHE_FILE" && $(find "$CACHE_FILE" -mmin -5) ]]; then
    # Use cached (less than 5 minutes old)
    RESULT=$(cat "$CACHE_FILE")
else
    # Fetch and cache
    RESULT=$(echo '{"action": "get", "params": {"url": "'$URL'"}}' | tool)
    mkdir -p .cache
    echo "$RESULT" > "$CACHE_FILE"
fi
```

### Timeout Configuration
For slow APIs, increase timeout:

```bash
jq -n '{
  action: "request",
  params: {
    method: "GET",
    url: "https://slow-api.example.com/data",
    timeout: "60"  # 60 seconds instead of default 30
  }
}' | ./.claude/cli/tools/http-client.sh
```

## Integration with Agent System

CLI tools are integrated at:

- **Rules:** `.agent/rules/04-cli-tools.md` — Tool availability and usage
- **Skills:** `.agent/skills/[tool-name]/SKILL.md` — Tool-specific documentation
- **Workflows:** `.agent/workflows/` — Automation using CLI tools
- **Hooks:** `.claude/hooks/` — Validation and error handling

Tools are designed to be called from any of these contexts.

## See Also

- CLI Framework: `.claude/cli/README.md`
- CLI Setup: `.claude/cli/SETUP.md`
- Integration Guide: `.claude/cli/INTEGRATION.md`
- HTTP Fetch Skill: `.agent/skills/http-fetch/SKILL.md`
- JSON Process Skill: `.agent/skills/json-process/SKILL.md`

---

**Last Updated:** 2026-03-16
**Version:** 1.0
