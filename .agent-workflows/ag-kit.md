---
description: Agent Kit management - initialize, validate, and update the .agent/ system
---

# Agent Kit Management

## `/ag-kit init`

Validates and initializes the agent kit system.

### Steps:

1. **Validate Directory Structure**
   - Check `.agent/` exists
   - Verify `agents/`, `skills/`, `workflows/`, `rules/` directories
   - Check `ARCHITECTURE.md` exists

2. **Validate Core Files**
   - Check `rules/GEMINI.md` exists and is valid
   - Verify `ARCHITECTURE.md` is up to date
   - Count agents in `agents/` directory
   - Count skills in `skills/` directory
   - Count workflows in `workflows/` directory

3. **Check for Issues**
   - Scan for broken skill references in agent files
   - Check for missing SKILL.md files in skill directories
   - Validate frontmatter in workflow files

4. **Report Status**
   - Display agent count
   - Display skill count
   - Display workflow count
   - List any issues found
   - Suggest fixes if needed

5. **Optional: Repair**
   - If issues found, offer to fix them
   - Create missing directories
   - Generate missing index files

---

## `/ag-kit update`

Updates agent kit components to latest standards.

### Steps:

1. **Check for Updates**
   - Compare current structure with latest standards
   - Check if new skills are available globally

2. **Backup Current State**
   - Create backup of current `.agent/` directory

3. **Apply Updates**
   - Update modified skills
   - Add new skills if available
   - Update GEMINI.md with new protocols

4. **Validate After Update**
   - Run `/ag-kit init` to verify integrity

---

## `/ag-kit status`

Quick status check of the agent kit system.

### Steps:

// turbo
1. Count and list all agents
// turbo
2. Count and list all skills
// turbo
3. Count and list all workflows
// turbo
4. Display last modification times
