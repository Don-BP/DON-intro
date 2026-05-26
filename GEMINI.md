---
trigger: always_on
version: 2.0
---

# GEMINI.md - Universal Agent Configuration

### Modular Skill Loading Protocol
Agent activated → Check frontmatter "skills:" field in agent files or rule definitions.

1. **Selective Reading**: Read `SKILL.md` first to understand the capability.
2. **Path Awareness**:
    - Skills: `.agent-skills/`
    - Workflows: `.agent-workflows/`
    - CLI Tools: `.claude/cli/tools/`

### Universal Rules
- **Clean Code**: Follow strict formatting and self-documentation.
- **Socratic Gate**: Always ask clarifying questions for complex tasks.
- **Automation First**: Prefer Pinchtab for browser-based verification.

### CLI TOOL INTEGRATION
When activating skills, check if a corresponding CLI tool exists:
- **API Discovery** → use `http-client` skill
- **Data Processing** → use `json-processor` skill
- **File Operations** → use `file-processor` skill
- **Git Operations** → use `git-ops` skill
- **Market Analysis** → use `market-research` skill
- **Performance Testing** → use `benchmark` skill

### SKILL DISCOVERY PATTERN
1. Check `.agent-skills/[skill-name]/SKILL.md` for documentation
2. Verify corresponding CLI tool in `.claude/cli/tools/[tool-name].sh`
3. Review JSON contract in `.agent-rules/04-cli-tools.md`
4. Test with example in tool's `--help` or documentation

### TOKEN EFFICIENCY FIRST
- Always prefer CLI tools over raw operations
- Batch related operations to minimize rounds
- Use caching when working with repeated data
- Reference this guide to avoid redundant work

## 🎯 INIT (READ FIRST)

**Session Bootstrap:**
1. Read ANTIGRAVITY.md → system map
2. Read project_context.md → project config
3. Read lessons_learned.md → past errors
4. Read Global_Manifest.md → current state

**Cognitive Protocol (MANDATORY before ANY action):**
```xml
<analysis>Break down request. ID ambiguities, unknowns, edge cases.</analysis>
<strategy>Which agent(s)/skill(s)? Execution path?</strategy>
<constraints>Risks? What breaks? Dependencies?</constraints>
```

## 🔥 REQUEST CLASSIFIER

| Type | Triggers | Output |
|------|----------|--------|
| **QUESTION** | "what is", "explain" | Text only |
| **SURVEY** | "analyze", "list" | Analysis (no files) |
| **SIMPLE EDIT** | "fix", "add" (1 file) | Inline edit |
| **COMPLEX** | "build", "create", multi-file | Task directive `.md` |
| **DESIGN** | "UI", "page", "design" | Task directive `.md` |
| **VERIFY** | "test", "check" | Validation report |

## 🤖 AGENT ROUTING (AUTO)

**Before ANY code/design:**

**Checklist:**
1. ✅ ID correct agent?
2. ✅ Read agent's `.md` rules?
3. ✅ Announce `🤖 Applying @[agent]...`?
4. ✅ Load skills from frontmatter?
5. ✅ Complete Cognitive Protocol?

**Agent Map:**
- Web UI → `frontend-specialist`
- Mobile → `mobile-developer` (NOT frontend!)
- API/Backend → `backend-specialist`
- Database → `database-architect`
- Security → `security-auditor`
- Testing → `test-engineer`
- Debug → `debugger`
- Planning → `project-planner`
- Multi-domain → `orchestrator`

## 🛡️ TIER 0: UNIVERSAL (ALWAYS)

### Language
- User NOT English → translate internally, respond in their language
- Code/comments → English

### Clean Code (Global)
- Follow `@[skills/clean-code]` - NO exceptions
- Tests mandatory: Unit > Integration > E2E (AAA pattern)
- Performance: Measure first, current year standards
- Security: OWASP, no secrets in code

### File Dependencies
**Before modifying ANY file:**
1. Check ANTIGRAVITY.md → deps
2. ID affected files
3. Update ALL together (atomic)

### Standard Paths
```
.
├── .agent-rules/          # Universal rules (this GEMINI.md)
├── .agent-skills/         # Reusable capabilities
│   └── {skill}/
│       ├── SKILL.md
│       └── references/
├── .agent-workflows/      # Automated multi-step processes
└── .agent-directives/     # Task files for complex work
```

### Read → Understand → Apply
```
❌ WRONG: Read → Code
✅ RIGHT: Read → Understand WHY → Apply PRINCIPLES → Code
```

**Ask before coding:**
1. GOAL of agent/skill?
2. PRINCIPLES to apply?
3. How DIFFERS from generic?
4. CONSTRAINTS/risks?

### No Hallucinations
- Can't verify? → Assumed broken
- Log ALL failures → `lessons_learned.md`

## 🛑 SOCRATIC GATE (MANDATORY)

**EVERY request must pass through gate BEFORE tools/implementation:**

| Type | Action |
|------|--------|
| **New Feature** | ASK 3+ strategic questions |
| **Edit/Bug** | Confirm understanding + impact questions |
| **Vague** | Ask Purpose, Users, Scope |
| **Orchestration** | STOP until user confirms plan |
| **Has Spec** | Ask 2 "Edge Case" questions anyway |

**Rules:**
- 1% unclear? → ASK
- Spec-heavy? → Still ask about trade-offs/edges
- Wait for user → NO tools/agents until cleared

## 🔧 TIER 1: CODE EXECUTION

### Project Routing
| Type | Agent | Skills |
|------|-------|--------|
| Mobile | `mobile-developer` | `mobile-design` |
| Web | `frontend-specialist` | `frontend-design`, `nextjs-react-expert` |
| Backend | `backend-specialist` | `api-patterns`, `database-design` |

### Task Directives
**For complex/multi-file → create task `.md` in directives folder**

Structure:
1. Objective + Success Criteria
2. Inputs & Context
3. Cognitive Protocol
4. Execution Plan
5. Verification (MANDATORY)

### Skill Loading
```
Request → Match Description → Load SKILL.md
                             ↓
                        Read references/
                             ↓
                        Use in execution
```
- Selective: Read SKILL.md index first
- Sections: Only relevant parts
- Priority: P0 (GEMINI) > P1 (Agent Rules) > P2 (Skill)

## 🎨 TIER 2: DESIGN

**Design rules in specialist agents, NOT here.**

| Task | Agent | Skills |
|------|-------|--------|
| Web UI | `frontend-specialist` | `frontend-design`, `ui-ux-pro-max` |
| Mobile | `mobile-developer` | `mobile-design` |

**Universal:**
- Anti-cliché design
- Deep Design Thinking
- Accessibility first (WCAG 2.1)

🔴 **For design → Read agent rules file first**

## 🔄 ORCHESTRATION

**Use Orchestrator when:**
- Multi-domain (frontend + backend + DB)
- 3+ sequential steps
- Parallel work needed
- Unclear scope

**Protocol:**
1. Decompose → agent subtasks
2. Delegate → specialist agents
3. Coordinate → manage deps
4. Integrate → combine outputs
5. Verify → end-to-end

## 🔍 COMPOUNDING WISDOM

**Update `lessons_learned.md` after EVERY fixed error:**

```markdown
### [YYYY-MM-DD]: [Description]
- Context: What we tried
- Issue: What failed
- Root Cause: Why
- Fix: Solution
- Prevention: Avoid future
```

Categories: Technical, Environment, Framework, Performance, Security, UX

**Update `project_context.md` when:** Stack changes, new deps, API integrations

## 🚀 VERIFICATION

**3 Layers:**
1. Continuous: Lint/types/unit tests
2. Pre-commit: Validation
3. Pre-deploy: Full verification

**Never deploy if:**
- Verification fails
- Critical security issues
- No rollback plan
- Breaking changes without migration

## 🔒 SECURITY

- No hardcoded secrets
- Input validation
- SQL injection prevention
- XSS protection
- CORS config
- Auth/authz

Reference: `@[skills/security-auditing]`

## ✅ CHECKLIST

❌ **DON'T:**
- Skip Cognitive Protocol
- Code before Socratic Gate
- Ignore agent rules
- Assume file contents
- Deploy without verification
- Forget lessons_learned.md

✅ **DO:**
- Complete Agent Routing Checklist
- Pass Socratic Gate first
- Verify continuously
- Log learnings
- Use specialists
- Create directives for complex work

## 📚 REFERENCE FILES

**Always read in this order:**
1. **ANTIGRAVITY.md** - Project structure & integration map
2. **Global_Manifest.md** - Source of truth (active files/tasks)
3. **project_context.md** - Tech stack & critical rules
4. **.agent-rules/\*** - Agent-specific rules
5. **.agent-skills/*/SKILL.md** - Capability documentation

---

**GEMINI v2.0** | Updated: 2026-03-16 | Read ANTIGRAVITY.md for full system overview
