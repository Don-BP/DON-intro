# Claude Code Project Template

This template contains all essentials for a new Claude Code project with CLI framework integration.

## What's Included

### ✅ CLI Framework (80%+ Token Savings)
- `claude-cli/` — Complete CLI tool framework
  - 6 production-ready CLI tools
  - Utilities library
  - JSON I/O contract
  - Documentation

- `claude-hooks/` — Validation hooks
  - Input validation
  - Security checks

### ✅ Agent System
- `agent-rules/` — Universal rules
  - CLI tool integration rules
  - Framework documentation

- `agent-skills/` — Default skills
  - http-fetch (HTTP requests)
  - json-process (JSON operations)
  - cli-tools-help (Tool discovery)
  - Plus your custom skills

- `agent-workflows/` — Default workflows
  - fetch-transform-validate
  - validate-api-response
  - Plus your custom workflows

### 📄 Documentation
- `TEMPLATE-SETUP.md` — This file
- `TEMPLATE-INIT.sh` — Initialization script
- `TEMPLATE-CHECKLIST.md` — Setup checklist
- `ANTIGRAVITY.md` — Project structure template

---

## How to Use This Template

### Option 1: Automated Setup (Recommended)

```bash
# Create new project directory
mkdir my-new-project
cd my-new-project

# Copy template
cp -r /path/to/market_research/.template/* .

# Run initialization
bash TEMPLATE-INIT.sh
```

### Option 2: Manual Setup

```bash
# Create directories
mkdir -p my-new-project/{.claude,.agent}
cd my-new-project

# Copy framework
cp -r /path/to/template/.claude-cli ./.claude/cli
cp -r /path/to/template/.claude-hooks ./.claude/hooks

# Copy agent system
cp -r /path/to/template/.agent-rules ./.agent/rules
cp -r /path/to/template/.agent-skills ./.agent/skills
cp -r /path/to/template/.agent-workflows ./.agent/workflows

# Create orchestrator
cat > ./.agent/rules/00-orchestrator.md <<EOF
# [Your Project] Orchestrator Rules
(Customize based on your needs)
EOF

# Copy and customize ANTIGRAVITY
cp /path/to/template/ANTIGRAVITY.md ./ANTIGRAVITY.md
# Edit ANTIGRAVITY.md with your project details

# Create project README
cat > README.md <<EOF
# [Your Project Name]

[Project description]

## Setup

See ANTIGRAVITY.md for project structure.
See .claude/cli/README.md for CLI tool usage.

## Quick Start

[Your quick start steps]
EOF

# Initialize git
git init
echo ".template/" >> .gitignore
git add .
git commit -m "Initial commit with CLI framework template"
```

---

## ⚠️ CRITICAL: Understanding SETUP.md

**`.claude/cli/SETUP.md` is DOCUMENTATION, NOT an executable script!**

Do NOT run: `bash ./.claude/cli/SETUP.md`

Instead, read the file to see installation instructions, then install jq manually:

```bash
# Windows (Git Bash)
winget install jqlang.jq

# macOS
brew install jq

# Linux
sudo apt-get install jq
```

---

## What Needs Customization

### 1. Create `.agent/rules/00-orchestrator.md`

This is **project-specific** and defines your agent system. Template:

```markdown
# [Project Name] Orchestrator Rules

### ROLE & IDENTITY
You are the **System Orchestrator**. Your identity is defined by the capabilities below.

### CORE AGENTS
- **Architect**: [Your description]
- **Builder**: [Your description]
- **Inspector**: [Your description]

### BOOT PROTOCOL
1. **Read the Map**: Silently read `ANTIGRAVITY.md`
2. **Load Skills**: Scan `.agent/skills/` directory
3. **Initialize CLI Tools**: Verify `.claude/cli/tools/` available
4. **[Custom Step]**: [Description]

### CLI TOOL FRAMEWORK
See `.agent/rules/04-cli-tools.md` for CLI tool integration.

### [CUSTOM SECTION]: [Your domain-specific rules]
```

### 2. Edit `ANTIGRAVITY.md`

Template provided in `ANTIGRAVITY.md`. Customize:
- Project name
- Directory structure
- Capabilities
- Custom sections

### 3. Create `README.md`

Project overview for developers. Include:
- Project description
- Setup instructions
- Quick start guide
- Key features
- Important files

---

## Files Structure After Setup

```
your-new-project/
├── .claude/
│   ├── cli/                    ✅ From template
│   │   ├── lib/
│   │   ├── tools/
│   │   ├── schema/
│   │   ├── examples/
│   │   └── *.md
│   └── hooks/                  ✅ From template
│       └── pre-tool-use-cli-validate.sh
├── .agent/
│   ├── rules/
│   │   ├── 00-orchestrator.md  🔧 CREATE (customize)
│   │   └── 04-cli-tools.md     ✅ From template
│   ├── skills/                 ✅ From template
│   │   ├── http-fetch/
│   │   ├── json-process/
│   │   ├── cli-tools-help/
│   │   └── [your-skills]/
│   └── workflows/              ✅ From template
│       ├── fetch-transform-validate.md
│       ├── validate-api-response.md
│       └── [your-workflows]/
├── ANTIGRAVITY.md              🔧 CUSTOMIZE (from template)
├── README.md                   🔧 CREATE
├── .gitignore                  🔧 CREATE
└── [other project files]
```

✅ = Ready to use
🔧 = Customize/create

---

## Validation Checklist

After setup, verify everything works:

```bash
# 1. Check CLI tools are accessible
echo '{"action": "list", "params": {}}' | \
    ./.claude/cli/tools/json-processor.sh

# 2. Test http-client
echo '{"action": "get", "params": {"url": "https://httpbin.org/status/200"}}' | \
    ./.claude/cli/tools/http-client.sh

# 3. Verify benchmark
echo '{"action": "list", "params": {}}' | \
    ./.claude/cli/tools/benchmark.sh

# 4. Check skills are discoverable
cat ./.agent/skills/cli-tools-help/SKILL.md
```

---

## What You Get

- ✅ **6 CLI tools** ready to use
- ✅ **80-90% token savings** immediately
- ✅ **3 default skills** for common operations
- ✅ **2 example workflows** for automation
- ✅ **Validation hooks** for safety
- ✅ **Complete documentation**
- ✅ **Zero setup time** (copy and go)

---

## Customization Examples

### Add a Custom Skill

```bash
mkdir -p ./.agent/skills/my-skill
cat > ./.agent/skills/my-skill/SKILL.md <<EOF
---
name: my-skill
description: What it does
---

# My Skill

## Usage

#!/bin/bash
# Your code here
EOF
```

### Add a Custom Workflow

```bash
cat > ./.agent/workflows/my-workflow.md <<EOF
#!/bin/bash
# Your workflow steps here
EOF
```

### Add a Custom CLI Tool

```bash
cp ./.claude/cli/tools/template.sh ./.claude/cli/tools/my-tool.sh
# Edit my-tool.sh with your logic
chmod +x ./.claude/cli/tools/my-tool.sh
```

---

## Next Steps

1. Use `TEMPLATE-INIT.sh` for quick setup
2. Customize `00-orchestrator.md` for your project
3. Update `ANTIGRAVITY.md` with your structure
4. Create `README.md` with project details
5. Add custom skills/workflows as needed
6. Start developing with 80%+ token savings!

---

## Advanced: B.L.A.S.T. Protocol

For complex automation projects with multi-service integrations:

1. **Read:** `.agent/rules/03-blast-protocol.md`
2. **Create:** `task_plan.md`, `findings.md`, `progress.md`
3. **Follow 5 Phases:**
   - Blueprint (define goals & data)
   - Link (verify APIs)
   - Architect (build SOPs & tools)
   - Stylize (format outputs)
   - Trigger (deploy automation)

**Use B.L.A.S.T. for:**
- Multi-service integrations
- Business-critical workflows
- Long-term maintenance projects

---

## Support

- **CLI Framework:** See `.claude/cli/README.md`
- **Setup Help:** See `TEMPLATE-INIT.sh`
- **Checklist:** See `TEMPLATE-CHECKLIST.md`
- **Structure:** See `ANTIGRAVITY.md`
- **Advanced Workflows:** See `.agent/rules/03-blast-protocol.md`

---

**Template Version:** 1.0
**Date:** 2026-03-16
**Status:** Production Ready
**Includes:** B.L.A.S.T. Protocol for complex automation
