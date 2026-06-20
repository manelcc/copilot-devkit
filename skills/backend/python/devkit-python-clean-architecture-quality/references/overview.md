# devkit-python-clean-architecture-quality - Overview

## Purpose

Auditoria de calidad de arquitectura backend Python con reglas por severidad y evidencia verificable.

## Workflow

```mermaid
flowchart TD
    A[Definir scope Python] --> B[Validar reglas obligatorias]
    B --> C[Analizar codigo Python]
    C --> D[Recolectar evidencia]
    D --> E[Priorizar por severidad]
    E --> F[Emitir informe y plan 7/30 dias]
```

## Rule files

- `references/python-rules-critical.md`
- `references/python-rules-high.md`
- `references/python-rules-medium.md`
- `references/python-rules-low.md`
