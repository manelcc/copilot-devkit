---
name: devkit-clean-code-guardian
description: >
  Review and remediate Clean Code violations across Kotlin, Java, Swift and Python files.
  Detect oversized classes, long functions, deep nesting, magic numbers,
  weak naming and SRP violations. Can optionally run a static checker script.
triggers:
  - "review clean code"
  - "apply clean code"
  - "refactor this class"
  - "too many lines"
  - "srp violations"
non_triggers:
  - "generate unit tests"
  - "configure ci cd"
  - "review architecture boundaries"
  - "manage dependencies"
applyTo:
  - "**/*.kt"
  - "**/*.java"
  - "**/*.swift"
  - "**/*.py"
---

# Clean Code Guardian

## Purpose
Apply hybrid Clean Code rules (base + language-specific catalog) to detect and fix maintainability issues in Kotlin, Java, Swift and Python code.

## When to use
- User asks for a Clean Code review or refactor.
- A class or file is too large or has multiple responsibilities.
- A function is too long or heavily nested.
- Magic numbers or unclear naming reduce readability.

## When NOT to use
- Creating tests from scratch.
- CI/CD pipeline setup.
- Module architecture or dependency boundary audits.
- Security-only audits.

## Inputs
- Target source file(s): `.kt`, `.java`, `.swift`, `.py`.
- Optional domain context and expected class responsibility.

## Steps
1. Load base rules from `references/rules.md`.
2. Detect file language and load only its matching catalog:
   - `references/catalog/clean-code-kotlin-rules.json`
   - `references/catalog/clean-code-java-rules.json`
   - `references/catalog/clean-code-swift-rules.json`
   - `references/catalog/clean-code-python-rules.json`
3. Run static script when useful (especially Kotlin):
   - `bash skills/global/devkit-clean-code-guardian/scripts/check-clean-code.sh <file.kt>`
4. Inspect code and report violations with line references and remediation.
5. Apply focused refactors preserving behavior.
6. Re-check limits and run project checks/tests.

## Expected outputs
- Prioritized list of findings with file/line evidence.
- Concrete remediation proposal per finding.
- Updated code with equivalent behavior after refactor.

## Validation
- Confirm catalogs exist for Kotlin, Java, Swift and Python.
- Confirm script is executable on macOS bash 3.2+.
- Re-run local build/tests for touched modules.

## Examples
- "Review this Swift class for clean code violations."
- "Refactor this Python service to reduce nesting and function size."
