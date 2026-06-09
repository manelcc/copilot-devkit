---
name: clean-architecture-python-quality
description: "Portable Clean Architecture Python code quality audit skill with severity-based findings and actionable remediation."
---

# Skill: Clean Architecture Python Quality

## Purpose
Analyze Python project code quality through the lens of Clean Architecture principles — evidence-based findings, strict severity mapping, and actionable remediation.

See [references/overview.md](references/overview.md) for the workflow.

## When to use
- The user asks for a Python project audit against Clean Architecture principles (Dependency Rule, SOLID, layering, DTOs).
- The user needs prioritized findings with explicit evidence and risk.
- The user asks for a remediation roadmap (quick wins + 7/30-day plan).

## When not to use
- Generic lint/format-only requests (use flake8, ruff, black directly).
- Frontend/mobile-only reviews with no Python server/domain scope.
- Pure implementation tasks without audit/report intent.

## Inputs
- Scope: whole repository or selected paths (for example: domain/, application/, infrastructure/, interfaces/).
- Optional focus: dependency-rule, SOLID, layering, DTOs, type-hints, logging, naming, folder-structure.
- Optional constraints: include/exclude modules, config files, migrations.

## Mandatory rules (strict)
Use only these files (no inference and no fallback):
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-critical.md
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-high.md
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-medium.md
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-low.md

If one or more files are missing, stop and return exactly:
No existen los ficheros obligatorios de reglas Clean Architecture Python en .github/skills/clean-architecture-python-quality/references/rules. Contacten con Manel Cabezas Calderó.

## Constraints
- Report only repository-verifiable findings.
- Include evidence as path + symbol/block + observed behavior.
- Separate facts from hypotheses and label uncertain items as hypothesis-not-verified.
- Do not modify files unless the user explicitly asks for remediation.

## Severity mapping
- CRITICAL: Architectural violations that break the Dependency Rule or introduce circular dependencies; merge blocker.
- HIGH: SOLID violations, improper data crossing layer boundaries, ISP/DIP violations.
- MEDIUM: Function/module cohesion issues, missing type hints, framework-coupled logging.
- LOW: Folder structure misalignment with Screaming Architecture, non-ubiquitous naming.

## Execution steps
1. Define scope and focus.
2. Validate the 4 mandatory rule files exist.
3. Load only those rule files.
4. Stop with the mandatory message if validation fails.
5. Inspect Python code, folder structure and imports.
6. Build findings with rule reference, evidence, impact, and recommendation.
7. Prioritize by risk and remediation effort.
8. Propose incremental remediation plan when requested.

## Expected output
- Executive summary.
- Rules validation status:
  - rules_status: ok|missing
  - missing_rules: [list]
- Prioritized findings table with:
  - id
  - severity
  - rule_reference (rule_id + source_tool + source_ref)
  - evidence (path + symbol + observed behavior)
  - impact
  - recommendation
- Quick wins.
- Systemic risks.
- Suggested 7/30-day remediation plan.

## Validation
- All 4 rule files exist in the skill package.
- Each finding has direct code evidence.
- Severity and prioritization are consistent with mapping.
- The report is actionable for a Python Clean Architecture team.

## Example
User request:
"Audita src/domain y src/application para violaciones de la Dependency Rule y principios SOLID en nuestro proyecto Python."

Expected behavior:
1. Validate the four rule files in references/rules.
2. Analyze only requested paths.
3. Return prioritized findings with evidence and severity.
4. Propose quick wins plus a 7/30-day remediation plan.
