# Template Quick Start Guide

Copy-paste instructions to get started with a new Claude Code project in 5 minutes.

## One-Minute Setup

```bash
# 1. Create project directory
mkdir my-new-project
cd my-new-project

# 2. Copy template (from your market_research project)
cp -r /path/to/market_research/.template/* .

# 3. Initialize
bash TEMPLATE-INIT.sh

# 4. Customize (edit these 3 files)
# - .agent-rules/00-orchestrator.md
# - ANTIGRAVITY.md
# - README.md

# 5. Test
echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/json-processor.sh

# Done! You have 80%+ token savings ready to go.
```

## Detailed Steps

### Step 1: Create New Project

```bash
mkdir my-new-project
cd my-new-project
git init
```

### Step 2: Copy Template Files

**Option A - Copy Everything (Recommended)**
```bash
cp -r /path/to/market_research/.template/* .
```

**Note:** Recommended to copy all files to get the complete governance system and all tools.

### Step 3: Run Initialization

```bash
bash TEMPLATE-INIT.sh
```

This will:
- ✓ Create directories
- ✓ Copy framework files
- ✓ Create project templates
- ✓ Verify setup

Output will show:
```
[1/5] Validating template files...
[2/5] Creating project structure...
[3/5] Copying framework files...
[4/5] Creating project-specific files...
[5/5] Verifying setup...

✓ PROJECT INITIALIZED!

🔧 CUSTOMIZE THESE FILES:
   1. .agent-rules/00-orchestrator.md
   2. ANTIGRAVITY.md
   3. README.md
```

### Step 4: Read Bootstrap Files

Before customizing, read these in order:

1. **`GEMINI.md`** — Master agent configuration (complete system)
2. **`ANTIGRAVITY.md`** — Project structure and integration map
3. **`Global_Manifest.md`** — Active files, tasks, and dependencies

### Step 5: Customize Your Project

Edit these 3 files:

**`.agent-rules/00-orchestrator.md`**
- Change the ROLE & IDENTITY section with your project name
- Customize agent responsibilities as needed

**`ANTIGRAVITY.md`**
- Fill in Project Overview with your specific purpose
- Update integration points and core capabilities

**`README.md`**
- Update project title and description
- Add your specific usage instructions

### Step 6: Install Dependencies

Install jq (required for all CLI tools):

**Windows (Git Bash):**
```bash
winget install jqlang.jq
```

**macOS:**
```bash
brew install jq
```

**Linux:**
```bash
sudo apt-get install jq
```

### Step 7: Verify Everything Works

```bash
# Test JSON processor
echo '{"action": "validate", "params": {"input": "{\"test\": true}"}}' | \
    ./.claude/cli/tools/json-processor.sh

# Should output: {"success": true, ...}

# Test HTTP client
echo '{"action": "get", "params": {"url": "https://httpbin.org/status/200"}}' | \
    ./.claude/cli/tools/http-client.sh

# Should output: {"success": true, ...}
```

### Step 8: Initialize Git

```bash
git add .
git commit -m "Initial commit with CLI framework template"
```

## You're Done!

Your project now has:
- ✅ 6 CLI tools ready to use
- ✅ 80-90% token savings
- ✅ 3 default skills
- ✅ 2 example workflows
- ✅ Complete documentation
- ✅ Validation hooks

## Next Steps

### Add Your First Skill

```bash
mkdir -p ./.agent-skills/my-skill
cat > ./.agent-skills/my-skill/SKILL.md <<EOF
---
name: my-skill
description: What this skill does
---

# My Skill

## Usage

#!/bin/bash
# Your implementation here
EOF
```

### Add Your First Workflow

```bash
cat > ./.agent-workflows/my-workflow.md <<EOF
#!/bin/bash
# Step 1: Do something
# Step 2: Do something else
# Step 3: Output result
EOF
```

### Use CLI Tools in Your Code

```bash
# Example: Fetch and transform data
RESPONSE=$(./.claude/cli/tools/http-client.sh <<< '{
  "action": "get",
  "params": {"url": "https://api.example.com/data"}
}')

DATA=$(echo "$RESPONSE" | jq '.data')
echo "$DATA"
```

## Common Issues & Solutions

### Issue: `bash: jq: command not found`
**Solution:** Install jq using your package manager:
```bash
# Windows: winget install jqlang.jq
# macOS: brew install jq
# Linux: sudo apt-get install jq
```

### Issue: `Permission denied` on scripts
**Solution:**
```bash
chmod +x ./.claude/cli/tools/*.sh
```

### Issue: Files not created correctly
**Solution:**
```bash
bash TEMPLATE-INIT.sh
# This recreates any missing files
```

### Issue: Tools not working
**Solution:**
1. Check jq is installed: `jq --version`
2. Check bash version: `bash --version` (4.0+)
3. Test tool: `echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/json-processor.sh`

## File Structure After Setup

```
my-new-project/
├── GEMINI.md                   ← Master agent config (READ FIRST!)
├── ANTIGRAVITY.md              ← Project structure (customize!)
├── Global_Manifest.md          ← Active files source of truth
├── README.md                   ← Project docs (customize!)
├── .claude/
│   └── cli/                    ← CLI framework (6 tools)
├── .agent-rules/               ← Agent orchestration
│   ├── 00-orchestrator.md      ← Customize!
│   ├── 01-GEMINI-quick-reference.md
│   ├── 02-research.md
│   ├── 03-blast-protocol.md
│   ├── 04-cli-tools.md
│   ├── project_context.md
│   └── lessons_learned.md
├── .agent-skills/              ← 7 enhanced skills
│   ├── webapp-testing-enhanced/
│   ├── security-auditing/
│   ├── animation-design/
│   ├── document-research/
│   ├── code-quality-analyzer/
│   ├── api-integration/
│   └── database-optimization/
├── .agent-workflows/           ← Workflows & processes
├── .gitignore                  ← Auto-generated
└── .git/                       ← Your repo
```

## Token Savings You Get

With this template:

| Operation | Before | After | Savings |
|-----------|--------|-------|---------|
| API call | 800 tokens | 150 tokens | **81%** |
| JSON processing | 700 tokens | 100 tokens | **86%** |
| File operations | 900 tokens | 150 tokens | **83%** |
| **Average** | **800** | **133** | **83%** |

**Every new project gets 80-90% token savings automatically.**

## Documentation Files

Once set up, refer to these docs:

| File | Purpose |
|------|---------|
| `ANTIGRAVITY.md` | Project structure |
| `README.md` | Project overview |
| `./.claude/cli/README.md` | CLI framework guide |
| `./.agent-rules/04-cli-tools.md` | Tool usage |
| `./.agent-skills/*/SKILL.md` | Skill documentation |

## Full Documentation

For more details, see:
- **`TEMPLATE-SETUP.md`** — Comprehensive setup guide
- **`TEMPLATE-CHECKLIST.md`** — Verification checklist
- **`README.md`** — Template overview

## Key Commands

```bash
# List all CLI tools
ls ./.claude/cli/tools/

# View CLI documentation
cat ./.claude/cli/README.md

# Discover available tools
cat ./.agent-skills/cli-tools-help/SKILL.md

# Profile tool performance
echo '{"action": "profile", "params": {"tool": "http-client"}}' | \
    ./.claude/cli/tools/benchmark.sh

# Test git operations
echo '{"action": "status", "params": {}}' | \
    ./.claude/cli/tools/git-ops.sh
```

## That's It!

You now have a production-ready Claude Code project with:
- All tools pre-configured
- All documentation in place
- All hooks ready
- 80%+ token savings enabled

**Start building!** 🚀

---

**Total setup time:** 5 minutes
**Token savings:** 80-90%
**Ready to use:** Immediately
