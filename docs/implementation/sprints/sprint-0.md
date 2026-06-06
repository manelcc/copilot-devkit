# Sprint 0 — Fundamentos del Repositorio

> **Objetivo**: El repositorio es navegable, tiene governance y permite añadir  
> artefactos con calidad desde el primer día.  
> **Fecha**: Sprint 0 (arranque)  
> **Capacidad**: 22 SP

---

## Sprint Goal

> Al finalizar este sprint, el repositorio DevTools-AI existe con su estructura completa,  
> los documentos de governance están en su lugar, los templates base permiten crear skills y agentes,  
> y el CLI está bootstrapped con el comando `devtools sync` mínimo viable.

---

## Backlog del Sprint

| US | Título | SP | Estado | Bloqueante |
|---|---|---|---|---|
| US-001 | Inicialización del repositorio y estructura | 3 | `[ ]` | — |
| US-002 | Constitution, governance y README | 2 | `[~]` | US-001 |
| US-003 | Template base para skills | 3 | `[ ]` | US-001 |
| US-004 | Template base para agentes | 2 | `[ ]` | US-001 |
| US-005 | Pre-commit hooks y validación | 5 | `[ ]` | US-001, US-003 |
| US-006 | Setup local del desarrollador | 2 | `[ ]` | US-005 |
| US-010 | Definición de sync_skills strategy | 5 | `[~]` | — |

**Total**: 22 SP

---

## US-001 — Inicialización del repositorio y estructura de directorios

**Épica**: EP-1 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como desarrollador que va a contribuir al repo,  
quiero encontrar la estructura de directorios completa y lista desde el primer commit,  
para poder añadir artefactos en el namespace correcto sin tener que decidir dónde van.

### Tarea técnica — estructura a crear

```
devtools-ai/
├── .github/
│   ├── copilot-instructions.md
│   └── agents/
│       └── project-orchestrator.agent.md     (stub)
├── agents/
│   ├── _TEMPLATE.agent.md                    (generado en US-004)
│   ├── global/
│   │   └── .gitkeep
│   ├── android/
│   │   ├── compose/
│   │   │   └── .gitkeep
│   │   ├── legacy/
│   │   │   └── .gitkeep
│   │   └── kmp/
│   │       └── .gitkeep
│   ├── ios/
│   │   ├── swiftui/
│   │   │   └── .gitkeep
│   │   └── uikit/
│   │       └── .gitkeep
│   ├── multiplatform/
│   │   ├── kmp/
│   │   │   └── .gitkeep
│   │   └── cmp/
│   │       └── .gitkeep
│   └── backend/
│       ├── kotlin-ktor/
│       │   └── .gitkeep
│       ├── python/
│       │   └── .gitkeep
│       └── spring-java/
│           └── .gitkeep
├── skills/
│   ├── _TEMPLATE/                             (generado en US-003)
│   ├── global/
│   ├── android/ { compose/, legacy/, kmp/ }
│   ├── ios/ { swiftui/, uikit/ }
│   ├── multiplatform/ { kmp/, cmp/ }
│   └── backend/ { kotlin-ktor/, python/, spring-java/ }
├── prompts/
│   └── (misma jerarquía que skills/)
├── instructions/
│   └── global.instructions.md                (stub)
├── docs/
│   └── implementation/
│       ├── constitution.md                    ✅ hecho
│       ├── epics.md                           ✅ hecho
│       ├── backlog.md                         ✅ hecho
│       ├── sync-strategy.md                   ✅ hecho
│       └── sprints/
│           └── sprint-0.md                   ✅ este archivo
├── cli-tools/
│   ├── pyproject.toml
│   └── devtools/
│       └── __init__.py
├── scripts/
│   └── validate-skill.sh
├── .githooks/
│   └── pre-commit
├── setup.sh
└── README.md
```

### Criterios de aceptación
- [ ] Todos los directorios de namespaces existen en `agents/`, `skills/`, `prompts/`
- [ ] `instructions/` existe con stub de `global.instructions.md`
- [ ] `cli-tools/` existe con `pyproject.toml` mínimo y entry point `devtools`
- [ ] `setup.sh` existe aunque sea stub

### Dependencias
- Ninguna — primer ticket del proyecto

---

## US-002 — Constitution, governance y README principal

**Épica**: EP-1 | **SP**: 2 | **Estado**: `[~]` (constitution.md ya creado)

### Pendiente de completar
- [ ] `README.md` en raíz con: propósito, mapa de estructura, quick-start, link a constitution
- [ ] `.github/copilot-instructions.md` que apunte a los documentos clave

### Formato del README

```markdown
# DevTools-AI

> Repositorio centralizado de agentes, skills y prompts para GitHub Copilot  
> multi-stack: Android · iOS · KMP/CMP · Backend Kotlin · Python · Spring

## Stacks cubiertos
...tabla de stacks...

## Quick-start para proyectos consumidores
...comandos devtools sync...

## Estructura del repositorio
...árbol simplificado...

## Governance
Ver [constitution.md](docs/implementation/constitution.md)
```

### Referencia
- `BK:.github/copilot-instructions.md`
- `MC:.github/copilot-instructions.md`

---

## US-003 — Template base para skills

**Épica**: EP-1 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como desarrollador creando una nueva skill,  
quiero un template con SKILL.md y references/overview.md de ejemplo,  
para generar skills consistentes sin partir de cero.

### Archivos a crear

**`skills/_TEMPLATE/SKILL.md`**:
```markdown
---
name: skill-name
description: >
  One sentence. Use this skill when [TRIGGER]. Do NOT use for [NON-TRIGGER].
---

# Skill: [Name]

## When to use
- [trigger phrase 1]
- [trigger phrase 2]

## When NOT to use
- [non-trigger 1]

## Inputs
- [input 1]

## Steps
1. [step 1]
2. [step 2]

## Expected outputs
- [output 1]

## Validation
- [ ] [criterion 1]

## Examples
**Prompt**: ...
**Output**: ...
```

**`skills/_TEMPLATE/references/overview.md`**:
```markdown
# Overview — [Skill Name]

## Workflow

\`\`\`mermaid
flowchart TD
    A[Input] --> B[Step 1]
    B --> C[Step 2]
    C --> D[Output]
\`\`\`

## Notes
```

### Criterios de aceptación
- [ ] Template existe en `skills/_TEMPLATE/`
- [ ] Secciones: frontmatter, when to use, when NOT to use, inputs, steps, outputs, validation, examples
- [ ] `references/overview.md` con Mermaid placeholder

### Referencia
- `MC:.github/skills/clean-code-guardian/SKILL.md` — ejemplo real
- Skill global `skill-generator` en `~/.copilot/skills/skill-generator/`

---

## US-004 — Template base para agentes

**Épica**: EP-1 | **SP**: 2 | **Estado**: `[ ]`

### Archivos a crear

**`agents/_TEMPLATE.agent.md`**:
```markdown
---
description: [One sentence. What this agent does and when to invoke it.]
handoffs:
  - label: [Next step label]
    agent: [target-agent-name]
    prompt: [Handoff prompt]
---

## Pre-Execution Checks
[Check for stack, project type, or required files]

## Outline
1. [Main step 1]
2. [Main step 2]
3. [Main step 3]

## Expected output
[What the agent produces]
```

### Criterios de aceptación
- [ ] Template en `agents/_TEMPLATE.agent.md`
- [ ] Incluye: description, handoffs, pre-checks, outline, output
- [ ] Ejemplo de handoff a otro agente

### Referencia
- `MC:.github/agents/_TEMPLATE.agent.md`
- `BK:.github/agents/speckit.specify.agent.md`

---

## US-005 — Pre-commit hooks y script de validación

**Épica**: EP-1 | **SP**: 5 | **Estado**: `[ ]`

### Descripción
Como contributor,  
quiero que el pre-commit rechace skills mal formadas,  
para mantener la calidad del catálogo sin revisión manual.

### `scripts/validate-skill.sh` — lógica

```bash
#!/usr/bin/env bash
# Valida que una skill tiene la estructura mínima requerida

SKILL_PATH="$1"
ERRORS=0

# 1. SKILL.md existe
# 2. Frontmatter tiene: name, description
# 3. Secciones obligatorias presentes: "When to use", "When NOT to use"
# 4. references/overview.md existe
# 5. overview.md contiene bloque mermaid
```

### `.githooks/pre-commit` — lógica

```bash
#!/usr/bin/env bash
# Para cada skills/*/SKILL.md modificado, ejecutar validate-skill.sh
```

### Criterios de aceptación
- [ ] `scripts/validate-skill.sh <path>` sale con 0 si válida, 1 con mensaje si falla
- [ ] `.githooks/pre-commit` itera skills modificadas y llama al script
- [ ] `setup.sh` ejecuta `git config core.hooksPath .githooks`

### Referencia
- `BK:scripts/validate-skill.sh`
- `BK:.githooks/pre-push`

---

## US-006 — Setup local del desarrollador

**Épica**: EP-1 | **SP**: 2 | **Estado**: `[ ]`

### `setup.sh` — comportamiento

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== DevTools-AI Setup ==="

# 1. Verificar Python >= 3.11
# 2. Instalar CLI: pip install -e cli-tools/
# 3. Instalar git hooks: git config core.hooksPath .githooks
# 4. Dar permisos ejecutables a scripts/
# 5. Imprimir resumen
```

### Criterios de aceptación
- [ ] Un solo comando configura todo el entorno
- [ ] Idempotente
- [ ] Imprime qué ha instalado/verificado

---

## US-010 — Definición de sync_skills strategy

**Épica**: EP-2 | **SP**: 5 | **Estado**: `[~]` (sync-strategy.md ya creado)

### Pendiente de completar
- [ ] `devtools.manifest.json` de ejemplo añadido en `docs/implementation/examples/`
- [ ] Revisar que la decisión en `sync-strategy.md` está validada por el equipo
- [ ] Primer test manual: sincronizar `skills/global/clean-code-guardian` a un directorio de prueba

---

## Definition of Done — Sprint 0

- [ ] Todos los directorios de la estructura existen en el repo
- [ ] `constitution.md`, `epics.md`, `backlog.md`, `sync-strategy.md` en `docs/implementation/`
- [ ] Templates `skills/_TEMPLATE/` y `agents/_TEMPLATE.agent.md` completos y probados
- [ ] `scripts/validate-skill.sh` funcional y testeado con la template
- [ ] `.githooks/pre-commit` instalado via `setup.sh`
- [ ] `README.md` explica propósito y quick-start
- [ ] `.github/copilot-instructions.md` apunta a documentos clave
- [ ] `devtools.manifest.json` ejemplo documentado en `sync-strategy.md`

---

## Notas del Sprint

- **US-002 y US-010** ya tienen entregables parciales (`constitution.md` y `sync-strategy.md` generados)
- El orden de ejecución recomendado: US-001 → US-003 → US-004 → US-002 → US-005 → US-006 → US-010
- Para US-001 usar el agente `project-orchestrator` o ejecutar scaffold manual
