# scrum-master-create-epics — Workflow Overview

This skill converts a product vision or PRD into structured Scrum Epics.

---

## Workflow

```mermaid
flowchart TD
    A([Usuario aporta PRD / Visión]) --> B[1. Analizar documento\nIdentificar dominios funcionales\ny Product Goal]
    B --> C{¿Product Goal\nexplícito?}
    C -- No --> D[Proponer Product Goal\nal usuario]
    C -- Sí --> E[2. Definir mapa de épicas\nTítulos + agrupación]
    D --> E
    E --> F{¿Usuario confirma\nagrupación?}
    F -- No --> E
    F -- Sí --> G[3. Redactar cada épica\ncon plantilla estándar]
    G --> H{¿Cambios\narquitecturales?}
    H -- Sí --> I[Insertar diagrama\nMermaid / draw.io\nen Alcance Técnico]
    H -- No --> J[4. Validar cohesión\ndel conjunto de épicas]
    I --> J
    J --> K{¿Epicas candidatas\na dividir o fusionar?}
    K -- Sí --> G
    K -- No --> L[5. Sugerir artefactos\ncomplementarios y\npriorización]
    L --> M([Documento Markdown\ncon épicas + mapa\nde dependencias])
```

---

## Archivos generados

| Archivo | Propósito |
|---|---|
| `SKILL.md` | Instrucciones completas para el agente |
| `references/overview.md` | Este documento — diagrama del workflow |

---

## Estructura de cada épica

```mermaid
flowchart LR
    E([EPIC-XX]) --> T[Título\nVerbo + Objeto + Beneficiario]
    E --> JB[Justificación\nde Negocio]
    E --> AT[Alcance Técnico\n+ Diagrama Mermaid\nsi aplica]
    E --> CE[Criterios\nde Éxito]
    E --> US[Notas para\ndesglose en\nHistorias de Usuario INVEST]
```

---

## Principios clave

- **Una épica = un dominio funcional cohesivo**
- Cada épica contribuye al **Product Goal**
- Los **Criterios de Éxito** son siempre medibles
- El desglose respeta el estándar **INVEST**
- Diagrama de arquitectura incluido cuando hay cambios estructurales significativos
