---
name: "quality-validator"
description: "Code quality validation and analysis for a specific technology stack"
triggers:
  - "validate code quality"
  - "analyze codebase"
  - "check for code issues"
non_triggers:
  - "format code automatically"
  - "refactor code"
---

# Quality Validator Skill

## Purpose

This skill analyzes source code for quality issues, security vulnerabilities, and best practice violations. It provides a structured report with findings grouped by severity and includes remediation suggestions.

## When to use

- The user asks to validate code quality in a specific namespace (e.g., `backend/python`, `frontend/typescript`)
- Code review findings need to be categorized by severity and complexity
- A remediation roadmap is required before refactoring
- Automated quality gates need baseline metrics
- Static analysis results need human interpretation

**Trigger phrases:**
- "Validate code quality in `[namespace]`"
- "Analyze the `[SkillSlug]` codebase for issues"
- "Generate a quality report for `[directory]` with severity breakdown"
- "Check for vulnerabilities in my Python backend"

## When NOT to use

- The user wants automatic code formatting or linting fixes (use a formatter skill instead)
- The user wants refactoring recommendations without seeing current issues (use quality-validator first, then refactoring skill)
- The task is debugging a specific runtime error (use a debugger skill)
- The user needs performance profiling (use a performance-analyzer skill)

## Inputs

**Required context:**
- `codebase_path`: Root directory of the code to analyze (e.g., `/repo/backend/python`)
- `technology_stack`: Primary language/framework (e.g., `python`, `typescript`, `kotlin`)
- `quality_standards`: Standards or framework (e.g., `PEP8`, `ESLint`, `ktlint`, custom)

**Optional context:**
- `severity_threshold`: Minimum severity to report (e.g., `warning`, `error`)
- `excluded_patterns`: Directories or files to skip (e.g., `["*.test.ts", "node_modules"]`)
- `custom_rules_file`: Path to custom linting or quality config (e.g., `.eslintrc.json`)

## Steps

1. **Validate scope and inputs:**
   - Confirm the codebase path exists and is readable
   - Verify the technology stack matches the code in the directory
   - Check that quality standards are supported by the validation tool

2. **Gather context and configuration:**
   - Load existing config files (`.eslintrc.json`, `pyproject.toml`, `ktlint.xml`, etc.)
   - Identify language-specific linters and static analysis tools
   - Prepare analysis tools (e.g., `pylint`, `eslint`, `ktlint`)

3. **Execute analysis:**
   - Run static analysis tool(s) with configured rules
   - Capture findings (violations, security issues, style problems)
   - Classify each finding by severity (`critical`, `error`, `warning`, `info`)

4. **Process and structure findings:**
   - Group findings by category (security, performance, style, maintainability)
   - For each finding, include:
     - File path and line number
     - Rule/check that failed
     - Current problematic code snippet
     - Remediation suggestion
     - Estimated effort to fix

5. **Generate remediation roadmap:**
   - Prioritize findings by severity and impact
   - Suggest grouping related fixes
   - Estimate total effort and time to remediate

6. **Validate completeness:**
   - Confirm all directories were scanned
   - Verify no scan errors occurred
   - Cross-check findings against expected issues

## Expected outputs

**Primary output:** 
- `QUALITY_REPORT.md` - Structured report with findings grouped by severity

**Secondary outputs:**
- `FINDINGS_JSON.json` - Machine-readable findings for CI/CD integration
- `REMEDIATION_ROADMAP.md` - Prioritized action plan

**Completion signal:**
- "Quality validation complete. Found X critical, Y error, Z warning issues. See QUALITY_REPORT.md for details and remediation roadmap."

## Validation

- [ ] Frontmatter includes required fields: `name`, `description`, `triggers`, `non_triggers`
- [ ] All sections (Purpose, When to use, When NOT to use, Inputs, Steps, Expected outputs, Validation, Examples) are present
- [ ] Examples section includes at least 1 realistic usage with expected flow
- [ ] `references/overview.md` exists with a Mermaid workflow diagram
- [ ] Triggers and non-triggers are mutually exclusive and clear
- [ ] Inputs specify required vs optional context with clear examples
- [ ] Steps are numbered and actionable (not just descriptions)
- [ ] Output artifacts are machine-readable and human-friendly
- [ ] The skill can be validated with `./scripts/devkit-validate-skill.sh skills/[namespace]/[slug]`

## Examples

### Example 1 - Validate Python backend for quality issues

**User prompt:**
```
Necesito validar la calidad del código en mi backend Python. Quiero encontrar issues de seguridad, 
performance y mantenibilidad. Dame un reporte y un plan de remediación priorizado.
```

**Expected flow:**

1. Gather context:
   - Codebase path: `/repo/backend`
   - Stack: `python`
   - Standards: `PEP8, pylint, security checks`

2. Execute analysis:
   - Scan `/repo/backend` with `pylint`, `bandit` (security), `radon` (complexity)
   - Collect findings on style violations, potential bugs, security issues

3. Produce output:
   - Create `QUALITY_REPORT.md` grouping findings:
     - **Critical Security Issues** (e.g., hardcoded passwords)
     - **Errors** (e.g., undefined variables)
     - **Warnings** (e.g., unused imports, too complex functions)
     - **Info** (e.g., style suggestions)

4. Remediation roadmap:
   - Phase 1: Fix security issues (est. 4 hours)
   - Phase 2: Fix errors preventing tests (est. 6 hours)
   - Phase 3: Improve code complexity (est. 16 hours)

5. Return signal:
   ```
   Quality validation complete.
   Found 2 critical security issues, 8 errors, 24 warnings, 12 info items.
   See QUALITY_REPORT.md for details and REMEDIATION_ROADMAP.md for action plan.
   ```

### Example 2 - Template instantiation

**To create a new skill based on this template:**

1. Copy `skills/_TEMPLATE/SKILL.md` to `skills/[namespace]/[skill_slug]/SKILL.md`
2. Replace all placeholders:
   - `[Name]` → skill name
   - `[SkillSlug]` → kebab-case identifier
   - `[PrimaryCapability]` → main skill purpose
   - `[namespace]` → `backend/python`, `frontend/typescript`, etc.

3. Create `skills/[namespace]/[skill_slug]/references/overview.md` with a Mermaid diagram aligned with your Steps

4. Run validation:
   ```bash
   ./scripts/devkit-validate-skill.sh skills/[namespace]/[skill_slug]
   ```

5. Commit and push:
   ```bash
   git add skills/[namespace]/[skill_slug]
   git commit -m "feat(US-XXX): add [skill_name] skill to [namespace]"
   ```

---

**Template notes:**
- This is a real working example, not pseudo-code
- Placeholders use `[BRACKET_NOTATION]` for easy find-and-replace
- All sections are mandatory; do not skip any
- Keep the frontmatter YAML valid; use quotes for special characters
- The Mermaid diagram in `overview.md` must reflect the Steps flow
