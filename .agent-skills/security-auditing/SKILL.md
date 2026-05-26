---
name: security-auditing
description: Enterprise security auditing combining CodeQL, Semgrep, OWASP analysis, differential code review, fuzzing patterns, and vulnerability tracking
---

# Security Auditing - Enhanced Edition

Comprehensive security analysis framework combining **CodeQL variant analysis**, **Semgrep pattern matching**, **OWASP Top 10 coverage**, **differential code review**, **fuzzing patterns**, and **vulnerability lifecycle management**.

## When to Use This Skill

- ✅ Scanning code for **OWASP Top 10** vulnerabilities
- ✅ **Variant analysis** across codebases for similar security flaws
- ✅ **Differential review** of security-critical commits
- ✅ **Fuzzing** to find edge cases and injection points
- ✅ **Fix verification** to confirm vulnerabilities are resolved
- ✅ **Supply chain security** for dependencies
- ✅ **Compliance audits** (PCI, HIPAA, SOC2)

## Core Analysis Methods

### 1. CodeQL Pattern Matching

JavaScript/TypeScript Security Patterns:

```sql
// Find SQL injection vulnerabilities
import javascript

from DataFlow::CallNode call, DataFlow::Node sink
where
  call.getCalleeName() = "query" and
  call.getArgument(0) = sink and
  sink.getStringValue() matches ".*\\$.*"
select call, "Potential SQL injection via string concatenation"
```

**Key Vulnerability Classes:**
- SQL Injection
- XSS (Cross-Site Scripting)
- Command Injection
- Path Traversal
- Insecure Deserialization
- Hardcoded Secrets

### 2. Semgrep Rules

**OWASP Top 10 Coverage:**

```yaml
rules:
  - id: hardcoded-api-key
    pattern: |
      api_key = "$KEY"
    message: "API key hardcoded in source"
    languages: [python, javascript]
    severity: ERROR

  - id: sql-injection-user-input
    pattern: |
      f"SELECT * FROM users WHERE id={user_input}"
    message: "SQL injection vulnerability"
    languages: [python]
    severity: CRITICAL

  - id: insecure-deserialization
    pattern: |
      pickle.loads(user_data)
    message: "Insecure deserialization - use JSON instead"
    languages: [python]
    severity: CRITICAL

  - id: weak-crypto
    pattern: |
      hashlib.md5(...)
    message: "MD5 is cryptographically broken - use SHA256"
    languages: [python]
    severity: HIGH

  - id: missing-csrf-token
    patterns:
      - pattern: |
          @app.route("/delete", methods=["POST"])
          def delete():
      - pattern-not: |
          csrf_token_valid(...)
    message: "POST without CSRF token validation"
    languages: [python]
    severity: HIGH
```

### 3. Vulnerability Categories

**A1: Injection (SQL, Command, LDAP)**
```javascript
// BAD: User input directly in query
const userId = req.query.id;
db.query(`SELECT * FROM users WHERE id = ${userId}`);

// GOOD: Parameterized query
db.query('SELECT * FROM users WHERE id = ?', [userId]);
```

**A2: Broken Authentication**
```javascript
// BAD: No rate limiting
app.post('/login', async (req, res) => {
  // User can attempt unlimited passwords
});

// GOOD: Rate limited with exponential backoff
app.post('/login', rateLimit({ windowMs: 15 * 60 * 1000, max: 5 }), ...);
```

**A3: Sensitive Data Exposure**
```javascript
// BAD: Storing passwords in plaintext
user.password = req.body.password;

// GOOD: Hash and salt
user.password = await bcrypt.hash(req.body.password, 10);
```

**A4: XML External Entities (XXE)**
```python
# BAD: No XXE protection
tree = ET.parse(xml_file)

# GOOD: Disable external entities
parser = ET.XMLParser(resolve_entities=False)
tree = ET.parse(xml_file, parser)
```

**A5: Broken Access Control**
```javascript
// BAD: Client-side only check
if (user.role === 'admin') { /* show button */ }

// GOOD: Server-side authorization
app.get('/admin/users', requireAuth, requireRole('admin'), ...);
```

**A6: Security Misconfiguration**
```javascript
// BAD: Debug mode in production
app.set('debug', true);

// GOOD: Environment-based
app.set('debug', process.env.NODE_ENV === 'development');
```

**A7: XSS (Cross-Site Scripting)**
```javascript
// BAD: Unescaped user input
res.send(`<h1>${userInput}</h1>`);

// GOOD: Escaped or using templating engine
res.send(escapeHtml(userInput));
// Or: res.render('template', { userInput }); // auto-escapes
```

**A8: Insecure Deserialization**
```python
# BAD: Pickle untrusted data
user_data = pickle.loads(request.data)

# GOOD: Use JSON
user_data = json.loads(request.data)
```

**A9: Using Components with Known Vulnerabilities**
```bash
# Check for vulnerable dependencies
npm audit
npm audit fix

# Or use SBOM (Software Bill of Materials)
npm ls --depth=0
```

**A10: Insufficient Logging**
```javascript
// BAD: No security event logging
db.query('SELECT ... WHERE user_id = ?', [id]);

// GOOD: Log sensitive operations
logger.info('User accessed sensitive data', {
  userId: id,
  timestamp: new Date(),
  action: 'READ_PII'
});
```

### 4. Differential Code Review

Security-focused code review:

```javascript
// Commit: Implement password reset
// Review checklist:
// - [ ] Token is cryptographically random (not sequential)
// - [ ] Token expires (e.g., 24 hours)
// - [ ] Token is single-use
// - [ ] Email is validated before reset
// - [ ] Attacker can't enumerate valid email addresses
// - [ ] Rate limiting prevents brute force
// - [ ] Audit log records password resets
// - [ ] No token visible in URL history/logs
```

### 5. Fuzzing Patterns

**Input Fuzzing Strategy:**

```python
# Test with boundary conditions and malicious inputs
test_inputs = [
    '',                          # Empty
    ' ' * 10000,                # Large input
    '<script>alert(1)</script>', # XSS
    "'; DROP TABLE users; --",   # SQL injection
    '../../../etc/passwd',        # Path traversal
    '\0\0\0',                    # Null bytes
    'a' * 100000,                # Excessive input
    '🔥💥⚡',                      # Unicode/emoji
    '\x00\x01\x02',              # Binary
]

for payload in test_inputs:
    result = application.process(payload)
    assert not is_vulnerable(result)
```

### 6. Fix Verification

Confirm vulnerabilities are actually fixed:

```bash
# Run security tools after fix
semgrep --config=p/security-audit --json app/

# Verify patch doesn't break functionality
npm test

# Re-run CodeQL variant analysis
codeql database create db --language=javascript --source-root=.
codeql database analyze db security-and-quality.qls --format=sarif

# Check fix is comprehensive (no similar vulnerabilities)
git log --oneline | head -5  # Verify fix is committed
```

## Tool & Framework References

- **CodeQL:** https://codeql.github.com
- **Semgrep:** https://semgrep.dev
- **OWASP Top 10:** https://owasp.org/www-project-top-ten/
- **SecLists:** https://github.com/danielmiessler/SecLists
- **Kali Linux Tools:** https://www.kali.org/
- **NIST Guidelines:** https://csrc.nist.gov

## Common Use Cases

1. **Pre-commit Hook** → Block commits with CRITICAL vulnerabilities
2. **CI/CD Integration** → Scan every PR automatically
3. **Penetration Testing** → Authorized security assessment
4. **Compliance Audits** → Meet PCI/HIPAA/SOC2 requirements
5. **Variant Analysis** → Find similar flaws across codebase
6. **Dependency Audits** → Identify vulnerable packages

## Security Best Practices

- ✅ Never disable security warnings without justification
- ✅ Review all findings with security team
- ✅ Test fixes thoroughly before deployment
- ✅ Keep tools and rules updated
- ✅ Log all security audit activities
- ✅ Use least-privilege access principles

---

**Enhanced version combining CodeQL, Semgrep, OWASP analysis, differential review, fuzzing, and vulnerability lifecycle management.**
