# iOS Quality Overview

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/ios-quality-skill/
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/ios-quality-rules/

## Workflow

```mermaid
flowchart TD
  A[Definir scope de auditoría iOS] --> B[Validar ficheros de reglas]
  B --> C{Reglas completas?}
  C -- No --> D[Detener y reportar reglas faltantes]
  C -- Sí --> E[Inspeccionar código Swift con reglas]
  E --> F[Registrar hallazgos verificables]
  F --> G[Clasificar CRITICAL/HIGH/MEDIUM/LOW]
  G --> H[Priorizar por impacto y esfuerzo]
  H --> I[Plan de remediación 7/30 días]
```

## Severity reference
- **CRITICAL**: bloquea merge. Seguridad, fugas de memoria estructurales, arquitectura rota.
- **HIGH**: corregir antes de release. Mutaciones UI fuera de MainActor, force unwrap en prod.
- **MEDIUM**: corregir en sprint actual. Massive ViewModel, NavigationView en código nuevo.
- **LOW**: corregir cuando sea posible. Inconsistencias de estilo, cobertura baja.

## Rules files
- ios-rules-critical.md
- ios-rules-high.md
- ios-rules-medium.md
- ios-rules-low.md
