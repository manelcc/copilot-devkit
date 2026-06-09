---
name: kotlin-server-quality-skill
description: "Portable Kotlin server-side code quality audit skill with severity-based findings and actionable remediation."
---

# Skill: Kotlin Server Quality

## Purpose
Analyze Kotlin server-side code quality (Ktor, Spring Boot, or similar) with evidence-based findings, strict severity mapping, and actionable remediation.

See [references/overview.md](references/overview.md) for the workflow.

## When to use
- The user asks for Kotlin backend quality audit or technical debt assessment.
- The user needs prioritized findings with explicit evidence and risk.
- The user asks for a remediation roadmap (quick wins + 7/30-day plan).

## When not to use
- Generic lint/format-only requests.
- Frontend/mobile-only reviews with no server Kotlin scope.
- Pure implementation tasks without audit/report intent.

## Inputs
- Scope: whole repository or selected paths (for example: src/, routes/, services/, data/).
- Optional focus: security, architecture, coroutines, DI, database, logging, testing, config.
- Optional constraints: include/exclude modules and config files.

## Mandatory rules (strict)
Use only these files (no inference and no fallback):
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-critical.md
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-high.md
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-medium.md
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-low.md

If one or more files are missing, stop and return exactly:
No existen los ficheros obligatorios de reglas Kotlin Server en .github/skills/kotlin-server-quality-skill/references/rules. Contacten con Manel Cabezas Calderó.

## Constraints
- Report only repository-verifiable findings.
- Include evidence as path + symbol/block + observed behavior.
- Separate facts from hypotheses and label uncertain items as hypothesis-not-verified.
- Do not modify files unless the user explicitly asks for remediation.

## Severity mapping
- CRITICAL: SEC_SERVER error-level findings; merge blocker.
- HIGH: Architecture, Ktor, Coroutine, DB, Logging, Config, DI error-level findings.
- MEDIUM: SEC_SERVER warning-level findings.
- LOW: Non-critical warnings and maintainability issues.

## Execution steps
1. Define scope and focus.
2. Validate the 4 mandatory rule files exist.
3. Load only those rule files.
4. Stop with the mandatory message if validation fails.
5. Inspect Kotlin server code and configuration.
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
- The report is actionable for a Kotlin server team.

## Example
User request:
"Audita src/main/kotlin y src/test/kotlin para riesgos de seguridad y coroutines en nuestro backend Ktor."

Expected behavior:
1. Validate the four rule files in references/rules.
2. Analyze only requested paths.
3. Return prioritized findings with evidence and severity.
4. Propose quick wins plus a 7/30-day remediation plan.
