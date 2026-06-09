---
name: "Kotlin Server Quality Analyze"
description: "Run Kotlin Server Quality Analyst to audit Kotlin server code quality with verifiable evidence."
argument-hint: "Optional: scope (e.g. src/, routes/, services/), focus (security|architecture|coroutines|database|logging|testing)"
agent: "Kotlin Server Quality Analyst"
---
Load and apply the skill `kotlin-server-quality-skill`.

Objective:
- Analyze Kotlin server-side code quality for the target repository.
- Prioritize findings by risk/impact.
- Deliver actionable remediation guidance.

Instructions:
1) Determine analysis scope (if missing, use full Kotlin server repository scope).
2) Validate required rules in `.github/skills/kotlin-server-quality-skill/references/rules/`:
	- `copilot-kotlin-server-rules-critical.md`
	- `copilot-kotlin-server-rules-high.md`
	- `copilot-kotlin-server-rules-medium.md`
	- `copilot-kotlin-server-rules-low.md`
3) If any required file is missing, stop and return exactly:
	`No existen los ficheros obligatorios de reglas Kotlin Server en .github/skills/kotlin-server-quality-skill/references/rules. Contacten con Manel Cabezas Calderó.`
4) Report only verifiable evidence (path + symbol + behavior).
5) Classify severity (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`).
6) Separate facts vs hypotheses-not-verified.
7) Do not modify files unless explicitly requested.
8) If remediation is requested, propose and apply minimal validated changes.

Expected output:
- Executive summary
- Rules validation status (`rules_status`, `missing_rules`)
- Prioritized findings (`id`, `severity`, `rule_reference`, `evidence`, `impact`, `recommendation`)
- Quick wins
- 7/30-day remediation plan
- Open risks
