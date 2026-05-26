---
trigger: always_on
---

# Project Context & Constraints

*SYSTEM INSTRUCTION: This file defines the operating constraints for all agents. Reference this before every task.*

## 1. Project Identity

Define your project's purpose and current state:

- **Name:** [YOUR PROJECT NAME]
- **Core Objective:** [One sentence - what is the singular desired outcome?]
- **Current Phase:** [Setup / Development / Refactoring / Testing / Maintenance]
- **Team Size:** [Solo / Small (2-3) / Medium (4-10) / Large (10+)]
- **Timezone:** [Your working timezone]

## 2. Technology Stack (Hard Constraints)

Document what tech is locked in:

- **Language(s):** [e.g., Python 3.12, JavaScript/Node.js 20, Go 1.21]
- **Frameworks:** [e.g., FastAPI, React 19, Django, Express]
- **Database:** [e.g., PostgreSQL 16, SQLite, MongoDB]
- **Infrastructure:** [e.g., AWS, Docker, Kubernetes, Vercel]
- **Package Managers:** [e.g., pip, npm, pnpm, cargo]

## 3. Coding Standards

Define the "law" for code quality:

- **Style Guide:** [e.g., PEP 8, Prettier, ESLint config]
- **Import Strategy:** [Absolute imports only / Relative imports allowed]
- **Type Safety:** [Strict typing required / Optional typing allowed]
- **Testing:** [Every feature requires test / TDD mandatory / Tests optional]
- **Documentation:** [Docstrings required / Comments for complex logic / README per module]
- **Commit Style:** [Conventional commits / Free form / Ticket references required]

## 4. Critical Rules (Non-Negotiable)

**These must be followed without exception:**

- **No Ghosts:** Never reference a file that isn't listed in `Global_Manifest.md`
- **No Secrets:** Never hardcode API keys, passwords, or tokens. Use environment variables only.
- **No Blindness:** If a script fails, print STDOUT/STDERR. Do not silently ignore errors.
- **No Assumptions:** Always validate input data before processing.
- **No Breaking Changes:** Get approval before modifying public APIs or database schemas.

## 5. Known Limitations

Document what the system cannot do (yet):

- **Scale Limit:** [e.g., "SQLite can handle up to 1GB; use PostgreSQL for larger datasets"]
- **API Rate Limits:** [e.g., "OpenAI API: 3,500 RPM for GPT-4, 1M tokens/min"]
- **Architectural Constraints:** [e.g., "Cannot use WebSockets on current hosting"]
- **Browser Support:** [e.g., "Must support Chrome 90+, Safari 14+, Firefox 88+"]

## 6. Communication Protocols

Define how the team communicates:

- **Status Updates:** [Daily standup / Weekly sync / Async in Slack]
- **Decision Making:** [Consensus / Senior engineer decides / Owner decides]
- **Code Review:** [Mandatory / Optional / Self-approved for trivial changes]
- **Deployment:** [Manual / CI/CD / Scheduled releases]

## 7. Success Metrics

How do we know the project is working?

- **Performance:** [e.g., "API response time < 200ms, 99.9% uptime"]
- **Quality:** [e.g., "Test coverage > 80%, zero critical bugs in production"]
- **User Satisfaction:** [e.g., "User adoption rate, NPS score"]
- **Team Health:** [e.g., "No burnout, <2 week on-call rotation"]

---

**This document is the constitution of your project. Reference it constantly.**
**Update when context changes (new framework, team growth, business pivot).**
