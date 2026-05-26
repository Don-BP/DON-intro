# CLI Framework Setup

## Prerequisites

The CLI framework requires these tools to be installed:

### Required
- **bash** - Shell interpreter (4.0+)
- **jq** - JSON processor (1.5+) — Used by all tools for JSON parsing

### Optional (depending on which tools you use)
- **curl** - HTTP client (used by http-client.sh)

## Installation

### macOS
```bash
# Install jq
brew install jq

# Install curl (usually pre-installed)
brew install curl
```

### Linux (Ubuntu/Debian)
```bash
# Install jq
sudo apt-get install jq

# Install curl
sudo apt-get install curl
```

### Linux (Fedora/RHEL)
```bash
# Install jq
sudo dnf install jq

# Install curl
sudo dnf install curl
```

### Windows

#### Option 1: Using Chocolatey
```bash
# Install jq
choco install jq

# Install curl (usually pre-installed with Git Bash)
choco install curl
```

#### Option 2: Using Windows Package Manager
```bash
# Install jq
winget install jqlang.jq

# Install curl
winget install cURL.cURL
```

#### Option 3: Manual Installation
1. Download jq from: https://stedolan.github.io/jq/download/
2. Extract to `C:\Program Files\jq\` (or add to PATH)
3. Verify: Open Git Bash and run `jq --version`

### Git Bash Specific (Windows)

If using Git Bash on Windows:

1. **Download jq binary:**
   ```bash
   cd /usr/local/bin
   curl -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.7/jq-win64.exe
   chmod +x jq
   ```

2. **Verify installation:**
   ```bash
   jq --version
   ```

3. **Test:**
   ```bash
   echo '{"test": true}' | jq .
   ```

## Verification

Run this to verify your setup:

```bash
cd D:\market_research

# Check bash version
bash --version

# Check jq installation
jq --version

# Check curl installation
curl --version

# Test the CLI framework
echo '{"action": "list", "params": {}}' | \
    ./.claude/cli/tools/json-processor.sh
```

Expected output:
```json
{
  "success": true,
  "data": [
    "validate",
    "parse",
    "transform",
    "merge",
    "extract",
    "list"
  ],
  "error": null,
  "metadata": {}
}
```

## Troubleshooting

### "jq: command not found"

1. Verify installation:
   ```bash
   which jq
   ```

2. If not found, install it (see above)

3. If installed but not in PATH:
   ```bash
   export PATH="/usr/local/bin:$PATH"
   # Or add to ~/.bashrc / ~/.bash_profile
   ```

### "curl: command not found"

Same process as jq above.

### Tools not executable

Make sure scripts have execute permissions:

```bash
chmod +x .claude/cli/tools/*.sh
chmod +x .claude/cli/lib/*.sh
```

### Scripts run but produce no output

Check if jq is working:

```bash
echo '{"test": true}' | jq '.'
```

If that fails, jq is not installed correctly.

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Bash | 4.0 | 5.0+ |
| jq | 1.5 | 1.7+ |
| curl | 7.0 | 8.0+ |
| RAM | 100MB | 512MB+ |
| Disk | 10MB | 100MB+ |

## Performance

- **Tool startup time**: ~5-20ms (bash + jq overhead)
- **JSON parsing**: ~1-2ms typical
- **Network requests** (http-client): ~100-500ms (depends on endpoint)

## Next Steps

Once setup is complete:

1. Test individual tools:
   ```bash
   ./.claude/cli/tools/http-client.sh --help  # or
   echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/http-client.sh
   ```

2. Run example scripts:
   ```bash
   bash ./.claude/cli/examples/json-processor-usage.sh
   bash ./.claude/cli/examples/http-client-usage.sh
   ```

3. Integrate with agent rules (see INTEGRATION.md)

---

**Last Updated:** 2026-03-16
**Version:** 1.0
