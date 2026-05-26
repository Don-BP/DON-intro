#!/bin/bash
# Claude Code Project Template Initializer
# Converts template into a ready-to-use project

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code Project Initializer      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# ============================================================
# Detect if running from template directory or new project
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/TEMPLATE-SETUP.md" ]]; then
    # Running from template directory
    echo "📍 Template directory detected: $SCRIPT_DIR"

    # Check if we're initializing in-place or need to copy
    if [[ "$SCRIPT_DIR" == */\.template ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  You're in the template directory.${NC}"
        echo "Use this to initialize a NEW project:"
        echo ""
        echo "  mkdir my-new-project && cd my-new-project"
        echo "  cp -r /path/to/.template/* ."
        echo "  bash TEMPLATE-INIT.sh"
        echo ""
        exit 0
    fi
else
    echo -e "${YELLOW}Note: Running from current directory${NC}"
fi

WORK_DIR="$(pwd)"
PROJECT_NAME=$(basename "$WORK_DIR")

echo -e "${BLUE}Project directory:${NC} $WORK_DIR"
echo -e "${BLUE}Project name:${NC} $PROJECT_NAME"
echo ""

# ============================================================
# Step 1: Validate Template Files
# ============================================================

echo "[1/5] Validating template files..."

required_dirs=(
    ".claude-cli"
    ".claude-hooks"
    ".agent-rules"
    ".agent-skills"
    ".agent-workflows"
)

for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
        echo -e "${YELLOW}⚠️  Missing: $dir${NC}"
        echo "Some features may not be available."
    fi
done

echo -e "${GREEN}✓${NC} Template files validated"
echo ""

# ============================================================
# Step 2: Create Directory Structure
# ============================================================

echo "[2/5] Creating project structure..."

mkdir -p "./.claude/cli"
mkdir -p "./.claude/hooks"
mkdir -p "./.agent/rules"
mkdir -p "./.agent/skills"
mkdir -p "./.agent/workflows"
mkdir -p "./CLAUDE_CODE_PROJECT_FILES"

echo -e "${GREEN}✓${NC} Directories created"
echo ""

# ============================================================
# Step 3: Copy Framework Files
# ============================================================

echo "[3/5] Copying framework files..."

# Copy CLI framework
if [[ -d "$SCRIPT_DIR/.claude-cli" ]]; then
    cp -r "$SCRIPT_DIR/.claude-cli"/* "./.claude/cli/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} CLI framework"
fi

# Copy hooks
if [[ -d "$SCRIPT_DIR/.claude-hooks" ]]; then
    cp -r "$SCRIPT_DIR/.claude-hooks"/* "./.claude/hooks/" 2>/dev/null || true
    chmod +x "./.claude/hooks"/*.sh 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Validation hooks"
fi

# Copy universal rules
if [[ -d "$SCRIPT_DIR/.agent-rules" ]]; then
    cp -r "$SCRIPT_DIR/.agent-rules"/* "./.agent/rules/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} CLI tool rules"
fi

# Copy default skills
if [[ -d "$SCRIPT_DIR/.agent-skills" ]]; then
    cp -r "$SCRIPT_DIR/.agent-skills"/* "./.agent/skills/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Default skills"
fi

# Copy default workflows
if [[ -d "$SCRIPT_DIR/.agent-workflows" ]]; then
    cp -r "$SCRIPT_DIR/.agent-workflows"/* "./.agent/workflows/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Default workflows"
fi

echo ""

# ============================================================
# Step 4: Create Project-Specific Files
# ============================================================

echo "[4/5] Creating project-specific files..."

# Create orchestrator template
if [[ ! -f "./.agent/rules/00-orchestrator.md" ]]; then
    cat > "./.agent/rules/00-orchestrator.md" <<'ORCHESTRATOR_EOF'
# Orchestrator Rules

### ROLE & IDENTITY
You are the **System Orchestrator**. Your identity is defined by the capabilities below.

### CORE AGENTS
- **Architect**: Responsible for planning, context initialization, and strategy
- **Builder**: Responsible for implementation and code
- **Inspector**: Responsible for verification and testing

### BOOT PROTOCOL
1. **Read the Map**: Silently read `ANTIGRAVITY.md` to understand the project structure
2. **Load Skills**: Scan `.agent/skills/` directory and activate required capabilities
3. **Initialize CLI Tools**: Verify `.claude/cli/tools/` are available and executable
4. **Load Rules**: Verify all rules in `.agent/rules/` are accessible

### CLI TOOL FRAMEWORK
The system uses a standardized **CLI Tool Framework** for external operations:
- All tools located in `.claude/cli/tools/`
- Unified JSON I/O contract (see `.agent/rules/04-cli-tools.md`)
- Available tools: http-client, json-processor, git-ops, file-processor, benchmark, market-research
- Use tools for: API calls, data transformation, file operations, version control

### AGENT ROLE INTEGRATION

**Architect:**
- Use cli-tools-help skill to discover available tools
- Use http-client to explore external APIs
- Reference CLI tools in planning

**Builder:**
- Use http-client for data fetching
- Use json-processor for transformation
- Use file-processor for file operations
- Use benchmark for performance measurement

**Inspector:**
- Use git-ops to verify repository state
- Use http-client to validate endpoints
- Use benchmark to measure performance

### CUSTOM SECTIONS
(Add your project-specific rules here)

---

For more details, see `.agent/rules/04-cli-tools.md`
ORCHESTRATOR_EOF

    echo -e "  ${GREEN}✓${NC} Orchestrator rules (CUSTOMIZE THIS)"
fi

# Create ANTIGRAVITY.md template
if [[ ! -f "ANTIGRAVITY.md" ]]; then
    cat > "ANTIGRAVITY.md" <<'ANTIGRAVITY_EOF'
# Project Structure & Integration Map

## Project Overview
[Describe your project purpose and goals]

## Directory Structure

- `.claude/`
    - `cli/` — CLI tool framework (80%+ token savings)
        - `lib/` — Shared utilities
        - `tools/` — CLI tool implementations
        - `schema/` — JSON I/O contracts
        - `examples/` — Usage examples
    - `hooks/` — Validation and security hooks
    - `settings.local.json` — Local Claude Code settings

- `.agent/`
    - `rules/` — Agent system rules
        - `00-orchestrator.md` — Core agent configuration (CUSTOMIZE)
        - `04-cli-tools.md` — CLI tool integration
        - `[custom-rules].md` — Project-specific rules
    - `skills/` — Agent capabilities
        - `http-fetch/` — HTTP request skill
        - `json-process/` — JSON operation skill
        - `cli-tools-help/` — Tool discovery
        - `[your-skills]/` — Your custom skills
    - `workflows/` — Automation workflows
        - `fetch-transform-validate.md` — Example workflow
        - `[your-workflows].md` — Your workflows

## Core Capabilities

- **CLI Tool Framework**: 6 production tools with 80%+ token savings
- **Agent System**: Architect, Builder, Inspector roles
- **Skills**: Modular capabilities for agents
- **Workflows**: Automated multi-step processes

## Quick Start

1. CLI Tools: See `.claude/cli/README.md`
2. Agent Rules: See `.agent/rules/04-cli-tools.md`
3. Skills: Explore `.agent/skills/*/SKILL.md`
4. Workflows: See `.agent/workflows/*.md`

## Custom Sections

(Add your project-specific documentation here)

---

Last Updated: [DATE]
ANTIGRAVITY_EOF

    echo -e "  ${GREEN}✓${NC} ANTIGRAVITY.md (CUSTOMIZE THIS)"
fi

# Create README.md
if [[ ! -f "README.md" ]]; then
    cat > "README.md" <<README_EOF
# $PROJECT_NAME

[Project description and purpose]

## Setup

This project uses the Claude Code CLI framework for automation and token efficiency.

### Prerequisites
- bash 4.0+
- jq (install via SETUP.md)
- curl (install via SETUP.md)

### Quick Start

1. **Install dependencies:**
   \`\`\`bash
   bash ./.claude/cli/SETUP.md
   \`\`\`

2. **Verify setup:**
   \`\`\`bash
   echo '{"action": "list", "params": {}}' | \
       ./.claude/cli/tools/json-processor.sh
   \`\`\`

3. **Read the docs:**
   - Project structure: \`ANTIGRAVITY.md\`
   - CLI tools: \`./.claude/cli/README.md\`
   - Agent rules: \`./.agent/rules/04-cli-tools.md\`

## Key Features

- 🚀 **80%+ token savings** with CLI framework
- 📚 **6 production-ready tools** for common operations
- ⚙️ **Modular skills** system for agents
- 🔄 **Ready-to-run workflows** for automation
- 🔐 **Security hooks** for safe execution

## Project Structure

See \`ANTIGRAVITY.md\` for detailed structure documentation.

## Usage

[Add your project-specific usage examples]

## Documentation

- \`ANTIGRAVITY.md\` — Project structure
- \`./.claude/cli/README.md\` — CLI framework guide
- \`./.agent/rules/04-cli-tools.md\` — Tool integration
- \`./.agent/skills/*/SKILL.md\` — Skill documentation

## Getting Help

1. Check \`./.claude/cli/SETUP.md\` for environment setup
2. Review \`./.agent/rules/04-cli-tools.md\` for tool usage
3. See \`./.agent/skills/cli-tools-help/SKILL.md\` for tool discovery

---

Created with Claude Code CLI Framework
README_EOF

    echo -e "  ${GREEN}✓${NC} README.md (CUSTOMIZE THIS)"
fi

# Create B.L.A.S.T. project files (optional, for complex projects)
if [[ ! -f "task_plan.md" ]]; then
    cat > "task_plan.md" <<'TASKPLAN_EOF'
# Task Plan & Blueprint

**Project:** $PROJECT_NAME
**Created:** $(date +%Y-%m-%d)

## 🎯 North Star
[Singular desired outcome - one sentence]

## 📋 Phases & Checklists

### Phase 0: Initialization
- [ ] Discovery questions answered
- [ ] Data schema defined in `gemini.md`
- [ ] `findings.md` created
- [ ] `progress.md` created

### Phase 1: Blueprint
- [ ] North Star defined
- [ ] Integrations identified
- [ ] Source of Truth identified
- [ ] Delivery Payload defined
- [ ] Behavioral Rules defined

### Phase 2: Link
- [ ] API connections verified
- [ ] Credentials in `.env`
- [ ] Handshake scripts tested

### Phase 3: Architect
- [ ] Architecture SOPs written
- [ ] Tools built and tested

### Phase 4: Stylize
- [ ] Output payload formatted
- [ ] Feedback collected

### Phase 5: Trigger
- [ ] Cloud deployment ready
- [ ] Automation triggers set

---

**For complex projects, use this with B.L.A.S.T. protocol (see `.agent/rules/03-blast-protocol.md`)**
TASKPLAN_EOF

    echo -e "  ${GREEN}✓${NC} task_plan.md (for B.L.A.S.T. projects)"
fi

# Create .gitignore if it doesn't exist
if [[ ! -f ".gitignore" ]]; then
    cat > ".gitignore" <<'GITIGNORE_EOF'
# Project-specific
.env
.env.local
secrets.json

# Logs
*.log
logs/

# Cache
.cache/
*.tmp

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Template artifacts
.template/
TEMPLATE-*.md
TEMPLATE-*.sh
GITIGNORE_EOF

    echo -e "  ${GREEN}✓${NC} .gitignore"
fi

echo ""

# ============================================================
# Step 5: Verify Setup
# ============================================================

echo "[5/5] Verifying setup..."

# Check directories exist
if [[ -d "./.claude/cli/tools" ]] && \
   [[ -d "./.agent/rules" ]] && \
   [[ -d "./.agent/skills" ]]; then
    echo -e "  ${GREEN}✓${NC} All directories created"
else
    echo -e "  ${YELLOW}⚠️  Some directories missing${NC}"
fi

# Check key files exist
if [[ -f "./.agent/rules/04-cli-tools.md" ]] && \
   [[ -f "./.agent/rules/00-orchestrator.md" ]]; then
    echo -e "  ${GREEN}✓${NC} Rules files present"
else
    echo -e "  ${YELLOW}⚠️  Some rules files missing${NC}"
fi

# Test a CLI tool
if command -v jq &> /dev/null; then
    if echo '{"action": "list", "params": {}}' | \
           ./.claude/cli/tools/json-processor.sh > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} CLI tools functional"
    else
        echo -e "  ${YELLOW}⚠️  CLI tools need jq installation${NC}"
        echo "     Run: bash ./.claude/cli/SETUP.md"
    fi
else
    echo -e "  ${YELLOW}⚠️  jq not installed${NC}"
    echo "     Run: bash ./.claude/cli/SETUP.md"
fi

echo ""

# ============================================================
# Final Summary
# ============================================================

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      ✓ PROJECT INITIALIZED!           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

echo "📁 Project: $PROJECT_NAME"
echo "📍 Location: $WORK_DIR"
echo ""

echo "🔧 CUSTOMIZE THESE FILES:"
echo "   1. .agent/rules/00-orchestrator.md — Agent configuration"
echo "   2. ANTIGRAVITY.md — Project structure"
echo "   3. README.md — Project documentation"
echo ""

echo "📚 NEXT STEPS:"
echo "   1. Install jq (required dependency):"
echo "      Windows: winget install jqlang.jq"
echo "      macOS: brew install jq"
echo "      Linux: sudo apt-get install jq"
echo ""
echo "   2. Edit the 3 files with your project details:"
echo "      - .agent/rules/00-orchestrator.md"
echo "      - ANTIGRAVITY.md"
echo "      - README.md"
echo ""
echo "   3. Verify CLI tools work:"
echo "      echo '{\"action\": \"list\", \"params\": {}}' | ./.claude/cli/tools/json-processor.sh"
echo ""
echo "   4. Review agent rules:"
echo "      - .agent/rules/00-orchestrator.md (agent configuration)"
echo "      - .agent/rules/04-cli-tools.md (tool usage patterns)"
echo ""
echo "   5. Start building with 80%+ token savings!"
echo ""

echo "🚀 QUICK COMMANDS:"
echo "   # List available tools:"
echo "   ls -1 ./.claude/cli/tools/"
echo ""
echo "   # View available skills:"
echo "   ls -1 ./.agent/skills/"
echo ""
echo "   # View agent rules:"
echo "   ls -1 ./.agent/rules/"
echo ""

echo -e "${BLUE}Happy coding!${NC} 🎉"
