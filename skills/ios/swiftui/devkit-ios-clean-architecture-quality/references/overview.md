# devkit-ios-clean-architecture-quality - Overview

## Purpose

Auditoria de calidad de arquitectura iOS/Swift con reglas por severidad y evidencia verificable.

## Workflow

```mermaid
flowchart TD
    A[Definir scope iOS] --> B[Validar reglas obligatorias]
    B --> C[Analizar codigo Swift]
    C --> D[Recolectar evidencia]
    D --> E[Priorizar por severidad]
    E --> F[Emitir informe y plan 7/30 dias]
```

## Rule files

- `references/ios-rules-critical.md`
- `references/ios-rules-high.md`
- `references/ios-rules-medium.md`
- `references/ios-rules-low.md`
