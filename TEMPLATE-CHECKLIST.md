# Project Setup Checklist

Use this checklist to verify your project is set up correctly.

## ✅ Initialization

- [ ] Created new project directory
- [ ] Copied template files (using `TEMPLATE-INIT.sh` or manually)
- [ ] Verified directory structure exists
- [ ] Ran initialization script: `bash TEMPLATE-INIT.sh`

## ✅ Customization (Required)

These files MUST be customized for your project:

### 1. `.agent/rules/00-orchestrator.md`

- [ ] Updated ROLE & IDENTITY section
- [ ] Defined your CORE AGENTS (Architect, Builder, Inspector)
- [ ] Customized BOOT PROTOCOL if needed
- [ ] Added custom sections for your domain
- [ ] Reviewed against your project requirements

**Validation:**
```bash
cat ./.agent/rules/00-orchestrator.md | grep -c "Your Project"
# Should show matches (means you've customized it)
```

### 2. `ANTIGRAVITY.md`

- [ ] Updated "Project Overview" section
- [ ] Added custom directory explanations
- [ ] Added custom capabilities section
- [ ] Updated "Custom Sections" with your details
- [ ] Updated "Last Updated" date

**Validation:**
```bash
head -20 ANTIGRAVITY.md | grep -v "^#"
# Should contain your project details, not template text
```

### 3. `README.md`

- [ ] Updated project title and description
- [ ] Customized "Quick Start" section
- [ ] Added "Key Features" relevant to your project
- [ ] Added project-specific usage examples
- [ ] Reviewed links and references

**Validation:**
```bash
grep "Project description" README.md
# Should show your customization, not template text
```

## ✅ Dependency Verification

- [ ] bash 4.0+ installed: `bash --version`
- [ ] jq installed: `jq --version`
  - If not: Run `bash ./.claude/cli/SETUP.md`
- [ ] curl installed: `curl --version`
  - If not: Run `bash ./.claude/cli/SETUP.md`

**Test all together:**
```bash
echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/json-processor.sh
# Should return a list of available actions
```

## ✅ Framework Verification

### CLI Tools

- [ ] All tools exist in `./.claude/cli/tools/`:
  ```bash
  ls -1 ./.claude/cli/tools/*.sh
  # Should show: benchmark.sh, file-processor.sh, git-ops.sh,
  #              http-client.sh, json-processor.sh, market-research.sh, template.sh
  ```

- [ ] Tools are executable:
  ```bash
  test -x ./.claude/cli/tools/http-client.sh && echo "✓ http-client is executable"
  ```

- [ ] Each tool responds to "list" action:
  ```bash
  for tool in ./.claude/cli/tools/*.sh; do
    echo "Testing $(basename $tool)..."
    echo '{"action": "list", "params": {}}' | bash "$tool" > /dev/null 2>&1 && echo "  ✓ OK"
  done
  ```

### Agent System

- [ ] Orchestrator rules exist:
  ```bash
  ls -1 ./.agent/rules/
  # Should include: 00-orchestrator.md, 04-cli-tools.md
  ```

- [ ] Skills directory exists with defaults:
  ```bash
  ls -1 ./.agent/skills/
  # Should include: http-fetch, json-process, cli-tools-help
  ```

- [ ] Workflows directory exists:
  ```bash
  ls -1 ./.agent/workflows/
  # Should have some workflow files
  ```

### Documentation

- [ ] CLI documentation:
  - [ ] `./.claude/cli/README.md` exists
  - [ ] `./.claude/cli/SETUP.md` exists
  - [ ] `./.claude/cli/INTEGRATION.md` exists

- [ ] Project documentation:
  - [ ] `ANTIGRAVITY.md` customized
  - [ ] `README.md` customized
  - [ ] `.agent/rules/00-orchestrator.md` customized

## ✅ Git Setup

- [ ] Repository initialized: `git status`
- [ ] .gitignore created with appropriate entries
- [ ] Initial commit made:
  ```bash
  git add .
  git commit -m "Initial commit with CLI framework template"
  ```

**Validation:**
```bash
git log --oneline | head -1
# Should show your initial commit
```

## ✅ Quick Functionality Test

Run these quick tests to verify everything works:

### Test 1: JSON Processing
```bash
echo '{"action": "validate", "params": {"input": "{\"test\": true}"}}' | \
    ./.claude/cli/tools/json-processor.sh
# Should return: {"success": true, ...}
```

### Test 2: HTTP Client
```bash
echo '{"action": "get", "params": {"url": "https://httpbin.org/status/200"}}' | \
    ./.claude/cli/tools/http-client.sh
# Should return: {"success": true, ...}
```

### Test 3: Benchmark
```bash
echo '{"action": "list", "params": {}}' | \
    ./.claude/cli/tools/benchmark.sh
# Should list benchmark actions
```

### Test 4: Git Operations
```bash
echo '{"action": "status", "params": {}}' | \
    ./.claude/cli/tools/git-ops.sh
# Should return git status information
```

## ✅ Optional Customizations

These are optional based on your project needs:

- [ ] Add custom skills in `./.agent/skills/my-skill/`
- [ ] Add custom workflows in `./.agent/workflows/my-workflow.md`
- [ ] Create custom CLI tools using `./.claude/cli/tools/template.sh`
- [ ] Customize validation hooks in `./.claude/hooks/`
- [ ] Add project-specific rules to `./.agent/rules/`

## ✅ Pre-Deployment Checks

Before using the project in production:

- [ ] All tests pass (see "Quick Functionality Test" above)
- [ ] Documentation is complete and accurate
- [ ] .gitignore is properly configured
- [ ] No sensitive data in committed files
- [ ] Dependencies installed and working
- [ ] Orchestrator rules match your project
- [ ] All customizations completed

## ✅ Performance Verification

Verify token savings are working:

```bash
# Profile a tool to see performance metrics
echo '{"action": "profile", "params": {"tool": "http-client"}}' | \
    ./.claude/cli/tools/benchmark.sh
# Should show latency, token estimates, and statistics
```

## 🚀 Ready for Development

If you've checked all boxes, your project is ready to use!

### Next Steps:
1. Create your first skill: `mkdir -p ./.agent/skills/my-skill`
2. Create your first workflow: `cat > ./.agent/workflows/my-workflow.md`
3. Start building with 80%+ token savings!

### Common Commands:
```bash
# List available CLI tools
ls ./.claude/cli/tools/

# View tool documentation
cat ./.claude/cli/README.md

# Discover available tools
cat ./.agent/skills/cli-tools-help/SKILL.md

# Test CLI tools
echo '{"action": "list", "params": {}}' | ./.claude/cli/tools/json-processor.sh
```

---

## Troubleshooting

### CLI tools not working
- **Issue:** `jq: command not found`
- **Solution:** Run `bash ./.claude/cli/SETUP.md`

### Permission denied on scripts
- **Issue:** `bash: ./script.sh: Permission denied`
- **Solution:** Run `chmod +x ./.claude/cli/tools/*.sh`

### Skills not discoverable
- **Issue:** Skills not found
- **Solution:** Verify `./.agent/skills/*/SKILL.md` files exist

### Customization questions
- **Issue:** Not sure how to customize
- **Solution:** See `TEMPLATE-SETUP.md` for examples

---

**Checklist Version:** 1.0
**Last Updated:** 2026-03-16
