# Clean Architecture Python Quality Skill — Overview

## Purpose

Audit Python project code quality against Clean Architecture principles with strict rule validation, evidence-based findings, severity prioritization, and actionable remediation planning.

## Workflow

```mermaid
flowchart TD
    A[User requests Clean Architecture Python quality audit] --> B[Define scope and focus]
    B --> C[Validate mandatory rule files in references/rules]
    C --> D{All files present?}
    D -- No --> E[Return mandatory missing-rules message and stop]
    D -- Yes --> F[Analyze Python code, imports and folder structure]
    F --> G[Collect evidence per finding]
    G --> H[Map severity CRITICAL/HIGH/MEDIUM/LOW]
    H --> I[Prioritize by impact and effort]
    I --> J[Return summary, findings, quick wins, 7/30-day plan]
```

## Rule files

- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-critical.md
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-high.md
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-medium.md
- .github/skills/clean-architecture-python-quality/references/rules/python-clean-arch-rules-low.md
