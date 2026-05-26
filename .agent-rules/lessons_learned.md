---
trigger: always_on
---

# Compounding Project Memory

*SYSTEM INSTRUCTION: This file contains the collective wisdom of the Engineering Team. Read this before every task. Write to this after every fixed error.*

## 1. Technical Gotchas (Do Not Repeat)

Keep a running list of issues that have caused problems:

- **Example:** Do not use `time.sleep()` for rate limits; use strict exponential backoff.
- **Example:** The testing database resets at 00:00 UTC; do not run integration tests then.
- **Example:** Always validate external API responses before processing.

## 2. Environment Specifics

Document environment-specific configurations and quirks:

- **Example:** This project uses `pnpm`, not `npm`.
- **Example:** All Python scripts must import `load_dotenv` from `dotenv`.
- **Example:** Windows paths use backslashes; always normalize with `pathlib.Path()`.

## 3. Resolved Bugs Log

Track bugs and their fixes to prevent regressions:

| Date | Error | Root Cause | Fix Applied | Prevention |
|------|-------|-----------|-------------|-----------|
| YYYY-MM-DD | [Error Description] | [Why it happened] | [Fix Applied] | [How to prevent] |

## 4. Performance Insights

Document performance learnings:

- Database query patterns that are slow/fast
- API rate limits and backoff strategies
- Frontend rendering bottlenecks

## 5. Security Lessons

Track security issues and fixes:

- Vulnerability discovered
- How it was exploited
- Fix applied
- Verification method

---

**Update this file after every bug fix, performance improvement, or security incident.**
**Treat this as institutional memory for the team.**
