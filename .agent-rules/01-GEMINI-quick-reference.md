---
trigger: always_on
version: 2.0
reference: true
type: quick-reference
---

# GEMINI Quick Reference (Agent Rules)

⚠️ **This is a QUICK REFERENCE only.**

**For complete agent configuration and protocols, read the master file: `/GEMINI.md`**

This file provides essential rules for quick lookup. For full details and decision trees, refer to the master GEMINI.md at the project root.

## Quick Reference

Essential rules for agent behavior:

### 1. Skill Loading Protocol
- Read `SKILL.md` first to understand capability
- Skills in: `.agent-skills/`
- Workflows in: `.agent-workflows/`
- CLI Tools in: `.claude/cli/tools/`

### 2. Universal Rules
- **Clean Code**: Follow strict formatting and self-documentation
- **Socratic Gate**: Always ask clarifying questions for complex tasks
- **Automation First**: Prefer CLI tools over manual operations

### 3. CLI Tool Integration
When activating skills, use corresponding CLI tools:
- **API Discovery** → `http-client`
- **Data Processing** → `json-processor`
- **File Operations** → `file-processor`
- **Git Operations** → `git-ops`
- **Market Analysis** → `market-research`
- **Performance Testing** → `benchmark`

### 4. Bootstrap Protocol (READ FIRST)

When starting work on any task:

1. Read **ANTIGRAVITY.md** → Project structure
2. Read **Global_Manifest.md** → What's active
3. Read **project_context.md** → Tech stack & rules
4. Read **/GEMINI.md** → Universal agent configuration
5. Read **lessons_learned.md** → Errors to avoid

### 5. Key Principles

- **Cognitive Protocol**: Analyze → Strategy → Constraints (MANDATORY before action)
- **Socratic Gate**: Ask clarifying questions BEFORE coding
- **Token Efficiency**: Always prefer CLI tools over raw operations
- **No Hallucinations**: Can't verify? Assume broken
- **Log Learnings**: Update lessons_learned.md after every fix

## When to Reference This File

- **Quick**: Need to remember which CLI tool does what?
- **Bootstrap**: Starting a new task?
- **Reference**: What's the skill discovery pattern?

## When to Read the Master GEMINI.md

- **Full context**: Understanding complete agent system
- **Complex work**: Multi-domain orchestration
- **Planning**: Creating task directives
- **Verification**: Pre-deployment checklist

---

**The Master GEMINI.md contains:**
- Request classifier (what type of work?)
- Agent routing checklist
- 3 execution tiers (Universal, Code, Design)
- Socratic gate rules
- Orchestration protocol
- Verification procedures
- Security guidelines
- Complete decision tree

**Read `/GEMINI.md` for the complete system.**
