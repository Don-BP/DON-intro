---
name: code-quality-analyzer
description: Code quality and review combining Semgrep patterns, CodeQL, complexity metrics, performance analysis, security scanning, and accessibility checks
---

# Code Quality Analyzer - Enhanced Edition

Comprehensive code analysis combining **Semgrep pattern matching**, **CodeQL queries**, **complexity metrics**, **performance analysis**, **OWASP security scanning**, and **WCAG accessibility checks** for code.

## When to Use

- ✅ Automated **pre-commit** code quality gates
- ✅ **CI/CD** quality enforcement
- ✅ Code **complexity** analysis and refactoring targets
- ✅ **Performance** bottleneck detection
- ✅ **Security** vulnerability scanning
- ✅ **Dead code** and unused dependency elimination
- ✅ **Accessibility** compliance in frontend code

## Core Patterns

### 1. Semgrep Quality Rules

```yaml
rules:
  - id: unused-variable
    pattern: |
      $VAR = $VAL
      ...
    pattern-not: |
      $VAR
    message: "Unused variable"
    languages: [javascript, python]
    severity: WARNING

  - id: todo-without-tracking
    pattern: |
      // TODO: $MSG
    message: "TODO without issue number"
    languages: [javascript, python, java]
    severity: INFO

  - id: long-function
    patterns:
      - pattern: |
          def $FUNC(...):
              ...
              ...
              ...
              ...
              ...
              ...
              ...
              ...
              ...
              ...
    message: "Function exceeds 10 lines - consider refactoring"
    languages: [python]
    severity: WARNING
```

### 2. Complexity Metrics

```python
import ast
from radon.metrics import mi_parameters, mi_visit

# Cyclomatic Complexity
def calculate_cyclomatic_complexity(code):
    tree = ast.parse(code)
    metrics = {}

    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            complexity = count_branches(node)
            metrics[node.name] = {
                'cyclomatic_complexity': complexity,
                'rating': 'Simple' if complexity <= 5 else
                          'Moderate' if complexity <= 10 else 'Complex'
            }

    return metrics

def count_branches(node):
    count = 1
    for child in ast.walk(node):
        if isinstance(child, (ast.If, ast.For, ast.While, ast.And, ast.Or)):
            count += 1
    return count

# Maintainability Index (0-100)
def calculate_maintainability(code):
    with_halstead = mi_parameters(code)
    mi = mi_visit(code, with_halstead)
    return {
        'maintainability_index': mi,
        'maintainability': 'High' if mi >= 80 else
                          'Medium' if mi >= 50 else 'Low'
    }
```

### 3. Performance Analysis

```python
def detect_performance_issues(code):
    issues = []

    # N+1 queries
    if 'for' in code and 'db.query' in code:
        issues.append({
            'issue': 'Potential N+1 query',
            'severity': 'HIGH',
            'fix': 'Use database joins or eager loading'
        })

    # Large payload in loop
    if re.search(r'for .+ in .+:\s+.{200,}request\(', code):
        issues.append({
            'issue': 'Large data in loop',
            'severity': 'HIGH',
            'fix': 'Batch requests outside loop'
        })

    # Missing memoization
    if re.search(r'def (fibonacci|factorial)\(.+\):', code):
        issues.append({
            'issue': 'Missing memoization on recursive function',
            'severity': 'MEDIUM',
            'fix': 'Use @lru_cache decorator'
        })

    return issues
```

### 4. Security Checks

```python
def security_analysis(code):
    checks = {
        'sql_injection': scan_sql_injection(code),
        'xss': scan_xss(code),
        'hardcoded_secrets': scan_secrets(code),
        'weak_crypto': scan_crypto(code),
        'missing_validation': scan_validation(code)
    }
    return checks

def scan_secrets(code):
    patterns = [
        r'api_key\s*=\s*[\'"]([A-Z0-9]+)[\'"]',
        r'password\s*=\s*[\'"](\w+)[\'"]',
        r'secret\s*=\s*[\'"]([^\'\"]+)[\'"]'
    ]

    secrets = []
    for pattern in patterns:
        matches = re.finditer(pattern, code, re.IGNORECASE)
        for match in matches:
            secrets.append({
                'type': 'Hardcoded Secret',
                'severity': 'CRITICAL',
                'line': code[:match.start()].count('\n') + 1,
                'fix': 'Use environment variables'
            })

    return secrets
```

### 5. Dead Code Detection

```python
def find_dead_code(code_file, imports_file):
    """Find unused functions and imports"""

    # Parse definitions
    with open(code_file) as f:
        code = f.read()

    tree = ast.parse(code)
    defined_funcs = {node.name for node in ast.walk(tree)
                     if isinstance(node, ast.FunctionDef)}

    # Find usages
    used_funcs = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name):
                used_funcs.add(node.func.id)

    # Dead functions
    dead = defined_funcs - used_funcs
    return {
        'dead_functions': dead,
        'removal_recommendation': [
            f'Delete function: {func}' for func in dead
        ]
    }
```

### 6. Accessibility Checks (Code)

```python
def check_accessibility_patterns(jsx_code):
    issues = []

    # Missing alt text
    if '<img' in jsx_code and 'alt=' not in jsx_code:
        issues.append({
            'issue': 'Missing alt text on image',
            'severity': 'HIGH',
            'wcag': '1.1.1 Non-text Content',
            'fix': 'Add alt="{description}" to <img>'
        })

    # Missing labels on inputs
    if '<input' in jsx_code and '<label' not in jsx_code:
        issues.append({
            'issue': 'Input without associated label',
            'severity': 'HIGH',
            'wcag': '3.3.2 Labels or Instructions',
            'fix': '<label htmlFor="id">Label</label><input id="id">'
        })

    # Missing role on interactive elements
    if '<div onClick=' in jsx_code and 'role=' not in jsx_code:
        issues.append({
            'issue': 'Interactive div missing role',
            'severity': 'MEDIUM',
            'wcag': '4.1.2 Name, Role, Value',
            'fix': '<div onClick={} role="button">...</div>'
        })

    return issues
```

## Quality Gates

```bash
# Semgrep
semgrep --config=p/security-audit \
        --config=p/python.best-practices \
        --config=p/performance \
        --exit-code=1 \
        app/

# CodeQL
codeql database analyze db \
  --format=sarif-latest \
  --output=results.sarif \
  security-and-quality.qls

# Complexity
radon cc -a app/

# Dead code
vulture app/

# Type checking (Python)
mypy app/ --strict

# Linting (JavaScript)
eslint app/ --fix
prettier app/ --write
```

## Common Use Cases

1. **Pre-commit Hook** → Block commits with CRITICAL issues
2. **Pull Request** → Automatic quality check on every PR
3. **Release Gate** → Ensure quality before deployment
4. **Refactoring** → Identify complexity reduction targets
5. **Performance** → Catch N+1 and bottlenecks early
6. **Compliance** → Verify accessibility and security

---

**Enhanced version combining Semgrep, CodeQL, complexity metrics, performance, security, and accessibility analysis.**
