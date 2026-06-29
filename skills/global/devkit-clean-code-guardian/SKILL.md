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

## Scope policy (mandatory)
- Default scope: only current branch diff against `origin/develop`.
- Mandatory inspection order:
  1. uncommitted changes in current branch,
  2. branch-only commits (`origin/develop..HEAD`).
- Never analyze the whole repository unless user explicitly asks for full-repo review.
- If `origin/develop` is unavailable, stop and request base branch confirmation.

## Template source of truth (mandatory)
- Clean code template path:
  - `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-clean-code-report.md`
- Mandatory rule:
  - The final report MUST use this template as the base structure.
  - The agent MUST NOT invent sections or output format when a template exists.
  - If the template does not exist or cannot be read, stop and return exactly:
    - `Template not found or unreadable: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-clean-code-report.md`

## Steps
1. Load base rules from `references/rules.md`.
2. Detect file language and load only its matching catalog:
   - `references/catalog/clean-code-kotlin-rules.json`
   - `references/catalog/clean-code-java-rules.json`
   - `references/catalog/clean-code-swift-rules.json`
   - `references/catalog/clean-code-python-rules.json`
3. Restrict analysis scope to branch diff against `origin/develop` (working tree + branch commits).
4. Load mandatory clean code template from COPILOT path.
5. Run static script when useful (especially Kotlin):
   - `bash skills/global/devkit-clean-code-guardian/scripts/check-clean-code.sh <file.kt>`
6. Inspect code and report violations with line references and remediation.
7. Apply focused refactors preserving behavior.
8. Re-check limits and run project checks/tests.
9. Write findings report to the analyzed project using the exact template structure:
   - Path: `docs/quality/clean-code-<YYYY-MM-DD>.md` (use actual execution date).
   - Create `docs/quality/` directory if it does not exist.
  - The file must preserve template sections and order.
   - If a file for the same day already exists, overwrite it.

## Preflight gate (mandatory, fail-fast)
- Before writing any report, validate all:
  1. `origin/develop` exists and is readable.
  2. Clean code template exists and is readable.
  3. Base rules and language catalog exist.
  4. Effective scope is only:
     - branch working tree changes,
     - commits in `origin/develop..HEAD`.
- If any validation fails, stop and do not generate report.

## Definition of Done (mandatory)
- A clean code report is valid only if ALL items pass:
  1. Exact official template structure (same sections and order).
  2. Explicit scope: branch diff against `origin/develop`.
  3. Findings include file/symbol evidence and concrete remediation.
  4. Includes at least one external reference (book or official web) for each reported severity.
  5. Includes one "good example" per reported severity.
  6. Quality Gate status is consistent with report metrics.

## Contractual errors (exact output)
- Template missing: `Template not found or unreadable: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-clean-code-report.md`
- Base branch missing: `Cannot resolve origin/develop. Confirm base branch before continuing quality analysis.`

## Expected outputs
- Prioritized list of findings with file/line evidence.
- Concrete remediation proposal per finding.
- Updated code with equivalent behavior after refactor.
- File `docs/quality/clean-code-<YYYY-MM-DD>.md` written in the analyzed project.

## Validation
- Confirm catalogs exist for Kotlin, Java, Swift and Python.
- Confirm script is executable on macOS bash 3.2+.
- Re-run local build/tests for touched modules.

## Examples
- "Review this Swift class for clean code violations."
- "Refactor this Python service to reduce nesting and function size."
