# devkit-android-clean-architecture-quality - Overview

## Purpose

Auditoria de calidad de arquitectura Android/Kotlin con reglas por severidad y evidencia verificable.

## Workflow

```mermaid
flowchart TD
    A[Definir scope Android] --> B[Validar reglas obligatorias]
    B --> C[Analizar codigo Kotlin/Android]
    C --> D[Recolectar evidencia]
    D --> E[Priorizar por severidad]
    E --> F[Emitir informe y plan 7/30 dias]
```

## Rule files

- `references/android-rules-critical.md`
- `references/android-rules-high.md`
- `references/android-rules-medium.md`
- `references/android-rules-low.md`
