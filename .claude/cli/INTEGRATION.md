# CLI Framework Integration Guide

How to integrate the CLI tool framework with agent rules, skills, and workflows.

## Integration Points

```
┌─────────────────────────────────┐
│   Agent/Claude Code             │
└────────────┬────────────────────┘
             │
      ┌──────┴──────┐
      ▼             ▼
┌───────────┐  ┌──────────────┐
│   Rules   │  │   Skills     │
│ (*.md)    │  │ (SKILL.md)   │
└────┬──────┘  └──────┬───────┘
     │                │
     └────────┬───────┘
              ▼
      ┌──────────────────┐
      │  CLI Tools       │
      │ (.claude/cli/)   │
      └──────────────────┘
```

## 1. Integration with Agent Rules

**File:** `.agent/rules/04-cli-tools.md`

```markdown
# CLI Tool Integration Rules

## Available CLI Tools

All tools are located in `.claude/cli/tools/` and follow a standardized JSON I/O contract.

### Tool Catalog

- **http-client.sh** — HTTP requests (GET, POST, HEAD, generic REQUEST)
- **json-processor.sh** — JSON validation, parsing, transformation
- [Add more as you create them]

## I/O Contract

Every tool expects JSON input on stdin:

```json
{
  "action": "action-name",
  "params": { /* action-specific parameters */ },
  "context": { /* optional auth/config */ }
}
```

And returns JSON on stdout:

```json
{
  "success": true|false,
  "data": /* action result or null */,
  "error": /* error object or null */,
  "metadata": { /* performance/version info */ }
}
```

## Usage Pattern

```bash
# 1. Prepare input as JSON
INPUT=$(jq -n '{
  action: "get",
  params: {url: "https://example.com"}
}')

# 2. Call the tool
RESULT=$(cat <<< "$INPUT" | ./.claude/cli/tools/http-client.sh)

# 3. Check success and process result
if echo "$RESULT" | jq -e '.success' > /dev/null; then
    DATA=$(echo "$RESULT" | jq -r '.data')
    # use $DATA
else
    ERROR=$(echo "$RESULT" | jq -r '.error.message')
    # handle error
fi
```

## When to Use CLI Tools

- **Use CLI tools** for:
  - External API calls (HTTP requests)
  - Data transformation/validation
  - Structured I/O operations
  - Actions that need error handling

- **Avoid CLI tools** for:
  - Simple inline operations (echo, ls, grep)
  - Operations that don't need structured responses
  - Very frequent calls (overhead not worth it)

## Error Handling

All tools return consistent error structures:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { /* context-specific info */ }
  }
}
```

Common error codes:
- `INVALID_PARAM` — Missing or invalid parameters
- `INVALID_JSON` — JSON parsing failed
- `TIMEOUT_ERROR` — Request timed out
- `HTTP_ERROR` — HTTP request failed
- `UNSUPPORTED_ACTION` — Unknown action
- `TRANSFORM_ERROR` — Data transformation failed

## Performance Considerations

- Each tool invocation has ~5-20ms startup overhead
- JSON serialization/deserialization adds ~1-2ms
- Batch operations when possible (merge multiple calls into single tool action)
- Tools cache nothing by default (stateless design)

## Debugging

Enable stderr output to see tool logs:

```bash
RESULT=$(./.claude/cli/tools/http-client.sh <<< "$INPUT" 2>&1)
```

Tool logs appear on stderr and won't pollute JSON output:
```
[INFO] Starting HTTP request
[WARN] Timeout set to 30 seconds
[ERROR] Failed to parse URL
```

## Security

### Secrets Management

Never hardcode API keys. Use the secret loading utilities:

```bash
# Load from ~/.claude/secrets/api-key
API_KEY=$(. ./.claude/cli/lib/utils.sh && load_secret "api-key")

# Use in request
INPUT=$(jq -n \
  --arg key "$API_KEY" \
  '{
    action: "get",
    params: {
      url: "https://api.example.com/data",
      headers: {"Authorization": "Bearer \($key)"}
    }
  }')
```

### Input Validation

Always validate input before passing to tools:

```bash
URL="$1"
if [[ ! "$URL" =~ ^https?:// ]]; then
    echo "Invalid URL" >&2
    exit 1
fi
```

---

## 2. Integration with Agent Skills

**File:** `.agent/skills/api-client/SKILL.md`

```markdown
---
name: api-client
description: Call external APIs using CLI HTTP client tool
---

# API Client Skill

Uses the CLI HTTP tool to make RESTful API calls.

## Usage

```bash
# Get user data from API
RESULT=$(jq -n \
  --arg url "$USER_API_URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

# Extract data
if echo "$RESULT" | jq -e '.success' > /dev/null; then
    USER_DATA=$(echo "$RESULT" | jq -r '.data')
    echo "User: $USER_DATA"
fi
```

## Common Patterns

### Pattern 1: Fetch and Parse

```bash
RESPONSE=$(jq -n \
  --arg url "https://api.example.com/users" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

USERS=$(echo "$RESPONSE" | jq '.data[] | {id, name, email}')
```

### Pattern 2: Fetch and Transform

```bash
# Fetch data
RESPONSE=$(./.claude/cli/tools/http-client.sh <<< '...')
DATA=$(echo "$RESPONSE" | jq -r '.data')

# Transform using json-processor
TRANSFORMED=$(jq -n \
  --arg data "$DATA" \
  '{action: "transform", params: {input: $data, filter: "..."}}' | \
  ./.claude/cli/tools/json-processor.sh)

echo "$TRANSFORMED" | jq '.data'
```

### Pattern 3: Error Handling

```bash
RESULT=$(./.claude/cli/tools/http-client.sh <<< "$REQUEST")

if ! echo "$RESULT" | jq -e '.success' > /dev/null; then
    ERROR_CODE=$(echo "$RESULT" | jq -r '.error.code')
    ERROR_MSG=$(echo "$RESULT" | jq -r '.error.message')
    echo "Error: $ERROR_CODE - $ERROR_MSG" >&2
    exit 1
fi

# Process result
echo "$RESULT" | jq '.data'
```
```

---

## 3. Integration with Agent Hooks

**File:** `.claude/hooks/pre-tool-use-cli-validate.sh`

Validate CLI tool invocations before execution:

```bash
#!/bin/bash
# PreToolUse hook: Validate CLI tool calls

INPUT=$(cat)

# Check if this is a CLI tool invocation
if echo "$INPUT" | grep -q ".claude/cli/tools"; then
    # Validate JSON input
    STDIN_DATA=$(echo "$INPUT" | jq -r '.stdin // empty' 2>/dev/null)

    if [[ -n "$STDIN_DATA" ]]; then
        if ! echo "$STDIN_DATA" | jq empty 2>/dev/null; then
            echo "BLOCKED: Invalid JSON input to CLI tool"
            exit 1
        fi
    fi
fi

exit 0
```

---

## 4. Integration with Orchestrator

**File:** `.agent/rules/00-orchestrator.md` (add section)

```markdown
## CLI Tool Protocol

When Architect, Builder, or Inspector agents need to:
- **Fetch external data**: Use `http-client.sh` tool
- **Transform/validate JSON**: Use `json-processor.sh` tool
- **Create new capabilities**: Add tool to `.claude/cli/tools/` following template

All CLI tool invocations follow the standardized JSON I/O contract defined in `.claude/cli/schema/tool-contract.json`.
```

---

## 5. Integration with Workflows

**File:** `.agent/workflows/api-fetch.md`

```markdown
# API Fetch Workflow

Autonomous workflow for fetching and processing API data.

## Steps

1. **Validate Input**: Ensure API endpoint is provided
2. **Fetch Data**: Use CLI http-client tool
3. **Parse Response**: Extract JSON using json-processor tool
4. **Transform**: Apply business logic transformation
5. **Output**: Return processed data

## Example

```bash
#!/bin/bash
API_URL="$1"
TRANSFORM_FILTER="$2"

# Step 1: Fetch
RESPONSE=$(jq -n \
  --arg url "$API_URL" \
  '{action: "get", params: {url: $url}}' | \
  ./.claude/cli/tools/http-client.sh)

# Step 2: Check success
if ! echo "$RESPONSE" | jq -e '.success' > /dev/null; then
    ERROR=$(echo "$RESPONSE" | jq -r '.error.message')
    echo "Fetch failed: $ERROR" >&2
    exit 1
fi

# Step 3: Transform
RAW_DATA=$(echo "$RESPONSE" | jq -r '.data')
TRANSFORMED=$(jq -n \
  --arg data "$RAW_DATA" \
  --arg filter "$TRANSFORM_FILTER" \
  '{action: "transform", params: {input: $data, filter: $filter}}' | \
  ./.claude/cli/tools/json-processor.sh)

# Step 4: Output
echo "$TRANSFORMED" | jq '.data'
```
```

---

## 6. Creating Integration Checklist

When adding a new CLI tool, integrate it by:

- [ ] Create tool file in `.claude/cli/tools/[name].sh`
- [ ] Test tool standalone: `echo '{"action": "list", "params": {}}' | ./[name].sh`
- [ ] Add tool documentation to `.claude/cli/README.md`
- [ ] Create usage example in `.claude/cli/examples/[name]-usage.sh`
- [ ] Document tool in `.agent/rules/04-cli-tools.md`
- [ ] Create skill wrapper in `.agent/skills/[tool-name]/SKILL.md`
- [ ] Update orchestrator if tool is critical
- [ ] Add integration tests if applicable

---

## Next Steps (Phase 2)

Once CLI foundation is stable:

1. Create skill wrappers for each tool
2. Update existing rules to use CLI tools
3. Build automation workflows leveraging CLI tools
4. Profile and optimize frequently-used tool paths
5. Add type hints/validation schemas for tool parameters

---

**Last Updated:** 2026-03-16
**Version:** 1.0
