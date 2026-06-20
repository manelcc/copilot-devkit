# Python Quality Overview

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-quality-skill/
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/python-quality-rules/

## Workflow

```mermaid
flowchart TD
  A[Definir scope de auditoría Python] --> B[Validar ficheros de reglas]
  B --> C{Reglas completas?}
  C -- No --> D[Detener y reportar reglas faltantes]
  C -- Sí --> E[Inspeccionar código Python con reglas]
  E --> F[Registrar hallazgos verificables]
  F --> G[Clasificar CRITICAL/HIGH/MEDIUM/LOW]
  G --> H[Priorizar por impacto y esfuerzo]
  H --> I[Plan de remediación 7/30 días]
```

## Severity reference
- **CRITICAL**: bloquea merge. Secretos hardcodeados, SQL injection, arquitectura rota.
- **HIGH**: corregir antes de release. God object, ausencia de typing en código crítico, excepciones ocultas.
- **MEDIUM**: corregir en sprint actual. Funciones >50 líneas, falta de tests en módulos clave.
- **LOW**: corregir cuando sea posible. Estilo inconsistente, imports no usados.

## Rules files
- python-rules-critical.md
- python-rules-high.md
- python-rules-medium.md
- python-rules-low.md
