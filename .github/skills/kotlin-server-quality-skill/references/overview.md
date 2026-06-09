# Kotlin Server Quality Skill — Overview

## Purpose

Audit Kotlin server code quality with strict rule validation, evidence-based findings, severity prioritization, and actionable remediation planning.

## Workflow

```mermaid
flowchart TD
    A[User requests Kotlin server quality audit] --> B[Define scope and focus]
    B --> C[Validate mandatory rule files in references/rules]
    C --> D{All files present?}
    D -- No --> E[Return mandatory missing-rules message and stop]
    D -- Yes --> F[Analyze Kotlin server code and config]
    F --> G[Collect evidence per finding]
    G --> H[Map severity CRITICAL/HIGH/MEDIUM/LOW]
    H --> I[Prioritize by impact and effort]
    I --> J[Return summary, findings, quick wins, 7/30-day plan]
```

## Rule files

- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-critical.md
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-high.md
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-medium.md
- .github/skills/kotlin-server-quality-skill/references/rules/copilot-kotlin-server-rules-low.md
