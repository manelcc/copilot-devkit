# devkit-clean-architecture-quality - Overview

## Purpose

Auditoria de calidad de arquitectura limpia y codigo en Java, Kotlin, Swift y Python con validacion estricta de reglas.

## Workflow

```mermaid
flowchart TD
    A[Usuario solicita auditoria de calidad] --> B[Definir scope y focus]
    B --> C[Detectar lenguaje del scope]
    C --> D[Validar reglas obligatorias en references/rules]
    D --> E{Reglas completas?}
    E -- No --> F[Devolver error de reglas faltantes y detener]
    E -- Si --> G[Validar y cargar template oficial de COPILOT]
    G --> H{Template accesible?}
    H -- No --> I[Devolver error de template y detener]
    H -- Si --> J[Cargar reglas del lenguaje detectado]
    J --> K[Analizar codigo y configuracion]
    K --> L[Recoger evidencia por hallazgo]
    L --> M[Clasificar severidad]
    M --> N[Priorizar por impacto y esfuerzo]
    N --> O[Rellenar template oficial]
    O --> P[Escribir informe en docs/quality/clean-architecture-YYYY-MM-DD.md]
```

## Template oficial (obligatorio)

- `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-architecture-report.md`
- Sin template accesible no se emite informe.

## Rule files

### Java
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-low.md`

### Kotlin
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-low.md`

### Swift
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-low.md`

### Python
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-low.md`
