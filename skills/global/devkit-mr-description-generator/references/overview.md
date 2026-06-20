# MR Description Generator — Visión general

## Diagrama de flujo

```mermaid
flowchart TD
    A([Usuario: quiero abrir MR]) --> B[Leer rama actual\ngit branch --show-current]
    B --> C{¿Sigue el patrón\nfeature/MCP-X.Y-slug?}
    C -- No --> ERR1[🚫 Error: naming de rama\nincorrecto. Usar git-operations]
    C -- Sí --> D[Extraer US ID\nde la rama]
    D --> E[Obtener commits desde develop\ngit log origin/develop..HEAD]
    E --> F{¿Hay commits\nen la rama?}
    F -- No --> ERR2[🚫 Error: rama vacía.\nNo hay nada que mergeear]
    F -- Sí --> G[Localizar doc de la US\ndoc/implementation/US-X.Y-*.md]
    G --> H{¿Existe el\ndoc de la US?}
    H -- No --> ERR3[⚠️ Advertencia: US doc no encontrado.\nGenerar MR sin criterios de aceptación]
    H -- Sí --> I[Leer criterios de aceptación\ny objetivo funcional]
    ERR3 --> J
    I --> J[Agrupar commits por tipo\nfeat / fix / test / refactor / docs / ci / chore]
    J --> K[Construir bloque\nCómo probar en local]
    K --> L[Generar doc/mr/branch-slug-mr.md\ncon plantilla MR completa]
    L --> M{¿Ya existe\nbloque de cierre\nen la US doc?}
    M -- Sí --> N[Omitir — idempotente]
    M -- No --> O[Añadir bloque ✅ Cierre de la US\nal final del doc de la US]
    N --> P
    O --> P[Mostrar resumen al usuario\ncon próximos pasos]
    P --> Z([Fin: MR lista para abrir\nen GitLab])
```

## Responsabilidades

| Paso | Qué hace |
|---|---|
| Detección de rama | Parsea el nombre para extraer el ID de la US |
| Lectura de commits | `git log origin/develop..HEAD` — solo commits de esta rama |
| Localización del doc | `find doc/implementation -name "US-<id>-*.md"` |
| Generación del MR doc | Inyecta datos en `references/mr-template.md` |
| Bloque "Cómo probar" | Genera pasos locales sin Docker (guardrail del orquestador) |
| Cierre de la US | Añade `## ✅ Cierre de la US` al doc de implementación |

## Inputs / Outputs

```
Inputs:
  - git: rama actual + commits desde develop
  - filesystem: doc/implementation/US-<id>-*.md

Outputs:
  - doc/mr/<branch-slug>-mr.md       (NUEVO)
  - doc/implementation/US-<id>-*.md  (MODIFICADO — bloque de cierre añadido)
```

## Integración en el ecosistema

```mermaid
flowchart LR
    ORC[project-orchestrator] -->|"genera la MR"| MRG[devkit-mr-description-generator]
    FLA[devkit-feature-lifecycle-agent] -->|último paso| MRG
    MRG -->|lee convenciones| GIT[skill: git-operations]
    MRG -->|genera artefacto| MRDOC[doc/mr/*.md]
    MRG -->|actualiza| USDOC[doc/implementation/US-*.md]
```
