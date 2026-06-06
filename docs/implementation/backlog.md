# Product Backlog — DevTools-AI

> Historias de usuario detalladas ordenadas por sprint y prioridad.  
> Cada US incluye criterios de aceptación, dependencias y referencias a repos fuente.

---

## Convenciones

- **Estimación**: Story Points (Fibonacci: 1, 2, 3, 5, 8, 13)
- **Estado**: `[ ]` pendiente · `[x]` completada · `[~]` en progreso
- **Referencia mycardiochef**: `MC:.github/<ruta>`
- **Referencia bankinter-devtools**: `BK:<ruta>`

---

---

# SPRINT 0 — Fundamentos (EP-1 + inicio EP-2)

> **Objetivo**: El repositorio es navegable, tiene governance y permite añadir artefactos con calidad.  
> **Capacidad**: 34 SP

---

## US-001 — Inicialización del repositorio y estructura de directorios

**Épica**: EP-1 | **Prioridad**: P0 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como desarrollador que va a contribuir al repo,  
quiero encontrar la estructura de directorios completa y lista desde el primer commit,  
para poder añadir artefactos en el namespace correcto sin tener que decidir dónde van.

### Criterios de aceptación
- [ ] Existen los directorios: `agents/{global,android/{compose,legacy,kmp},ios/{swiftui,uikit},multiplatform/{kmp,cmp},backend/{kotlin-ktor,python,spring-java}}`
- [ ] Misma jerarquía para `skills/` y `prompts/` e `instructions/`
- [ ] Cada directorio tiene un `.gitkeep` o README mínimo
- [ ] Existe `docs/implementation/` con los documentos de governance
- [ ] Existe `scripts/` con estructura lista para shell tools
- [ ] Existe `cli-tools/` con estructura Python base

### Dependencias
- Ninguna (primer ticket)

### Referencias
- `BK:` estructura de `agents/android/`, `agents/ios/`, `agents/global/`
- `BK:cli-tools/` como base del paquete CLI

---

## US-002 — Constitution, governance y README principal

**Épica**: EP-1 | **Prioridad**: P0 | **SP**: 2 | **Estado**: `[x]`

### Descripción
Como contributor o consumidor del repo,  
quiero leer en el README el propósito, estructura y cómo empezar,  
para entender rápidamente qué hay aquí y cómo usarlo.

### Criterios de aceptación
- [x] `docs/implementation/constitution.md` existe y está ratificado
- [ ] `README.md` en raíz con: propósito, mapa de estructura, quick-start, link a constitution
- [ ] `.github/copilot-instructions.md` apunta a los documentos clave del repo

### Referencias
- `BK:.github/copilot-instructions.md`
- `MC:.github/copilot-instructions.md`

---

## US-003 — Template base para skills

**Épica**: EP-1 | **Prioridad**: P0 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como desarrollador creando una nueva skill,  
quiero un template `_TEMPLATE/` con SKILL.md y references/overview.md rellenos de ejemplo,  
para generar skills consistentes sin partir de cero.

### Criterios de aceptación
- [ ] Existe `skills/_TEMPLATE/SKILL.md` con frontmatter completo (name, description, triggers, non-triggers)
- [ ] Existe `skills/_TEMPLATE/references/overview.md` con diagrama Mermaid de ejemplo
- [ ] El template incluye secciones: Purpose, When to use, When NOT to use, Inputs, Steps, Expected outputs, Validation, Examples
- [ ] El skill-generator puede usar este template como base

### Referencias
- `MC:.github/skills/clean-code-guardian/SKILL.md` — ejemplo de skill compleja
- Global skill `skill-generator` en `~/.copilot/skills/skill-generator/`

---

## US-004 — Template base para agentes

**Épica**: EP-1 | **Prioridad**: P0 | **SP**: 2 | **Estado**: `[ ]`

### Descripción
Como desarrollador creando un nuevo agente,  
quiero un template `_TEMPLATE.agent.md` como punto de partida,  
para mantener estructura y frontmatter consistentes.

### Criterios de aceptación
- [ ] Existe `agents/_TEMPLATE.agent.md` con frontmatter: description, handoffs, skills referenciadas
- [ ] Incluye secciones estándar: Pre-Execution Checks, Outline, Post-Execution
- [ ] Existe ejemplo de handoff a otro agente

### Referencias
- `MC:.github/agents/_TEMPLATE.agent.md`
- `BK:.github/agents/speckit.specify.agent.md` — ejemplo con hooks

---

## US-005 — Pre-commit hooks y script de validación

**Épica**: EP-1 | **Prioridad**: P1 | **SP**: 5 | **Estado**: `[ ]`

### Descripción
Como contributor,  
quiero que el pre-commit rechace skills mal formadas antes de llegar a main,  
para mantener la calidad del catálogo sin revisión manual de cada PR.

### Criterios de aceptación
- [ ] `scripts/validate-skill.sh <path>` valida: frontmatter YAML, secciones obligatorias, overview.md con Mermaid
- [ ] `.githooks/pre-commit` llama al script para todo `skills/**/*.md` modificado
- [ ] `setup.sh` instala el hook automáticamente (`git config core.hooksPath .githooks`)
- [ ] El script sale con código 1 y mensaje descriptivo si falla
- [ ] El script sale con código 0 y lista de skills validadas si todo ok

### Referencias
- `BK:scripts/validate-skill.sh`
- `BK:.githooks/pre-push`

---

## US-006 — Setup local del desarrollador

**Épica**: EP-1 | **Prioridad**: P1 | **SP**: 2 | **Estado**: `[ ]`

### Descripción
Como nuevo contributor,  
quiero ejecutar un único comando (`./setup.sh`) para tener el entorno listo,  
para no perder tiempo configurando hooks, dependencias Python y permisos.

### Criterios de aceptación
- [ ] `setup.sh` instala hooks git, hace `pip install -e cli-tools/`, y verifica dependencias (Python ≥ 3.11)
- [ ] Imprime resumen de lo instalado
- [ ] Es idempotente (ejecutarlo dos veces no rompe nada)

### Referencias
- `BK:setup.sh`

---

## US-010 — Definición de la estrategia sync_skills

**Épica**: EP-2 | **Prioridad**: P0 | **SP**: 5 | **Estado**: `[ ]`

### Descripción
Como arquitecto del ecosistema,  
quiero una decisión documentada sobre cómo los proyectos consumidores importan artefactos,  
para que todos los equipos usen el mismo mecanismo y no haya deriva.

### Criterios de aceptación
- [ ] `docs/implementation/sync-strategy.md` documenta las opciones evaluadas y la decisión tomada
- [ ] La estrategia elegida soporta: selección por namespace, versionado semántico, detección de conflictos
- [ ] Existe un `devtools.manifest.json` de ejemplo para proyectos consumidores
- [ ] La estrategia es independiente de si el proyecto consumidor es Android, iOS o Backend

### Referencias
- `BK:.specify/integrations/copilot.manifest.json`
- `BK:cli-tools/sync_skills/`

---

---

# SPRINT 1 — Migración Backend + Global (EP-7 + EP-8)

> **Objetivo**: El mayor volumen de artefactos existentes (mycardiochef) está migrado y disponible.  
> **Capacidad**: 34 SP

---

## US-060 — Migrar skills backend Kotlin/Ktor

**Épica**: EP-7 | **Prioridad**: P0 | **SP**: 8 | **Estado**: `[ ]`

### Descripción
Como desarrollador backend Kotlin,  
quiero encontrar todas las skills de mycardiochef disponibles en `skills/backend/kotlin-ktor/`,  
para usarlas en cualquier proyecto Ktor sin copiarlas manualmente.

### Criterios de aceptación
- [ ] Skills migradas a `skills/backend/kotlin-ktor/`:
  - `kotlin-mcp-server-generator/`
  - `logging-kotlin/`
  - `unit-testing-kotlin/`
  - `postgresql-crud/`
  - `mycardio-middleware-auth-flow/` → renombrada a `ktor-auth-flow/`
  - `middleware-webscraping-contract/`
- [ ] Cada skill tiene frontmatter actualizado con namespace correcto
- [ ] Referencias internas actualizadas (paths relativos válidos)
- [ ] `references/overview.md` existe en cada una

### Fuente
> `MC:.github/skills/kotlin-mcp-server-generator/`  
> `MC:.github/skills/logging-kotlin/`  
> `MC:.github/skills/unit-testing-kotlin/`  
> `MC:.github/skills/postgresql-crud/`  
> `MC:.github/skills/mycardio-middleware-auth-flow/`  
> `MC:.github/skills/middleware-webscraping-contract/`

---

## US-061 — Migrar agentes backend

**Épica**: EP-7 | **Prioridad**: P0 | **SP**: 5 | **Estado**: `[ ]`

### Descripción
Como desarrollador backend,  
quiero encontrar los agentes especializados de mycardiochef en `agents/backend/kotlin-ktor/`,  
para orquestar tareas Ktor sin mantener copias locales en cada proyecto.

### Criterios de aceptación
- [ ] Agentes migrados a `agents/backend/kotlin-ktor/`:
  - `kotlin-expert-pattern.agent.md`
  - `kotlin-server-quality.agent.md`
  - `kotlin-mcp-expert.agent.md`
  - `payload-logging-trace.agent.md`
  - `x-correlation-id-strategy.agent.md`
  - `devops-agent.agent.md`
- [ ] Agente `project-orchestrator.agent.md` → `agents/global/`
- [ ] Agente `qa-testcase-agent.agent.md` → `agents/global/`
- [ ] Handoffs internos actualizados a las nuevas rutas

### Fuente
> `MC:.github/agents/kotlin-expert-pattern.agent.md`  
> `MC:.github/agents/kotlin-server-quality.agent.md`  
> `MC:.github/agents/kotlin-mcp-expert.agent.md`  
> `MC:.github/agents/payload-logging-trace.agent.md`  
> `MC:.github/agents/x-correlation-id-strategy.agent.md`  
> `MC:.github/agents/project-orchestrator.agent.md`  
> `MC:.github/agents/qa-testcase-agent.agent.md`

---

## US-062 — Migrar instrucciones Ktor

**Épica**: EP-7 | **Prioridad**: P0 | **SP**: 2 | **Estado**: `[ ]`

### Descripción
Como desarrollador Ktor en cualquier proyecto,  
quiero que `instructions/backend-kotlin.instructions.md` contenga las reglas del `copilot-instructions.md` de mycardiochef,  
para que Copilot genere código Ktor de calidad sin configuración adicional.

### Criterios de aceptación
- [ ] `instructions/backend-kotlin.instructions.md` creado con `applyTo: "**/*.kt"` en proyectos backend
- [ ] Incluye reglas de: estructura Ktor, HMAC auth, Flyway, Coroutines, documentación Kotlin
- [ ] Referencia las skills de `backend/kotlin-ktor/` para tareas específicas

### Fuente
> `MC:.github/copilot-instructions.md`  
> `MC:.github/copilot-kotlin-server-rules.md`  
> `MC:.github/copilot-hmac-auth.md`

---

## US-070 — Migrar skill clean-code-guardian

**Épica**: EP-8 | **Prioridad**: P0 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como revisor de código en cualquier stack,  
quiero la skill `clean-code-guardian` en `skills/global/clean-code-guardian/`,  
para detectar violaciones de clean code en Kotlin, Java, Swift y Python.

### Criterios de aceptación
- [ ] Skill migrada con catálogos de reglas para Kotlin, Java, Swift y Python
- [ ] Script `check-clean-code.sh` incluido y funcional
- [ ] Frontmatter actualizado con triggers para todos los lenguajes soportados

### Fuente
> `MC:.github/skills/clean-code-guardian/`

---

## US-071 — Migrar skills git globales

**Épica**: EP-8 | **Prioridad**: P0 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como desarrollador en cualquier proyecto,  
quiero las skills de git y workflow en `skills/global/`,  
para seguir convenciones de branching, commits y MR en todos los proyectos.

### Criterios de aceptación
- [ ] `skills/global/git-workflow/` migrada y funcional
- [ ] `skills/global/mr-description-generator/` migrada con template MR
- [ ] `skills/global/feature-lifecycle/` actualizada (no deprecated, reemplaza a la anterior)

### Fuente
> `MC:.github/skills/git-workflow/`  
> `MC:.github/skills/mr-description-generator/`  
> `BK:.github/agents/speckit.git.*` — como referencia de workflow git avanzado

---

## US-074 — Crear agente project-orchestrator global

**Épica**: EP-8 | **Prioridad**: P0 | **SP**: 5 | **Estado**: `[ ]`

### Descripción
Como usuario del repo,  
quiero un agente orquestador que sepa delegar al agente/skill correcto según el stack y la tarea,  
para no tener que saber qué skill invocar manualmente.

### Criterios de aceptación
- [ ] `agents/global/project-orchestrator.agent.md` creado
- [ ] Detecta el stack del proyecto (Android, iOS, KMP, Backend) y redirige al agente correcto
- [ ] Incluye handoffs explícitos a todos los agentes de stack
- [ ] Tiene criterios de activación claros

### Fuente
> `MC:.github/agents/project-orchestrator.agent.md`

---

---

# SPRINT 2 — Stack Android + iOS (EP-3 + EP-5)

> **Objetivo**: Los stacks mobile principales están cubiertos con instrucciones y skills core.  
> **Capacidad**: 34 SP

---

## US-020 — Migrar skill migrate-xml-to-compose

**Épica**: EP-3 | **Prioridad**: P0 | **SP**: 3 | **Estado**: `[ ]`

### Descripción
Como desarrollador Android migrando de XML a Compose,  
quiero la skill de migración disponible en `skills/android/compose/`,  
para obtener guía paso a paso sin buscarla en awesome-copilot.

### Criterios de aceptación
- [ ] `skills/android/compose/migrate-xml-to-compose/` creada y adaptada al namespace del repo
- [ ] Dependencias de awesome-copilot documentadas en `references/`
- [ ] Triggers actualizados para el contexto del repo

### Fuente
> Skill `migrate-xml-views-to-jetpack-compose` de awesome-copilot (disponible en `~/.claude/skills/`)

---

## US-026 — Instrucciones Android Compose

**Épica**: EP-3 | **Prioridad**: P0 | **SP**: 2 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `instructions/android-compose.instructions.md` con `applyTo: "**/*.kt"` (proyectos Compose)
- [ ] Cubre: Composables, State hoisting, Navigation 3, Hilt, Coroutines + Flow
- [ ] Referencia skills de `android/compose/`

---

## US-040 — Migrar skills iOS de bankinter-devtools

**Épica**: EP-5 | **Prioridad**: P0 | **SP**: 5 | **Estado**: `[ ]`

### Descripción
Como desarrollador iOS,  
quiero las skills de `bankinter-devtools/skills/ios/` disponibles en `skills/ios/`,  
para usarlas en cualquier proyecto sin dependencia de bankinter-devtools.

### Criterios de aceptación
- [ ] Todas las skills de `BK:skills/ios/` migradas al namespace `skills/ios/{swiftui,uikit}/`
- [ ] Frontmatter actualizado
- [ ] Agentes de `BK:agents/ios/` migrados a `agents/ios/`

### Fuente
> `BK:skills/ios/`  
> `BK:agents/ios/`

---

## US-045 — Instrucciones iOS SwiftUI

**Épica**: EP-5 | **Prioridad**: P0 | **SP**: 2 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `instructions/ios-swiftui.instructions.md` con reglas para Swift + SwiftUI
- [ ] Cubre: MVVM, Combine, NavigationStack, async/await, SPM

---

---

# SPRINT 3 — CLI Tools + Sync (EP-9 + EP-2 completo)

> **Objetivo**: El CLI es funcional y permite sincronización básica desde proyectos consumidores.  
> **Capacidad**: 34 SP

---

## US-080 — Estructura CLI devtools

**Épica**: EP-9 | **Prioridad**: P0 | **SP**: 3 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `cli-tools/devtools/` con `__init__.py`, entry points registrados en `pyproject.toml`
- [ ] Comando `devtools --help` funcional
- [ ] Subcomandos: `sync`, `scaffold`, `validate`, `list`
- [ ] Tests unitarios básicos

### Fuente
> `BK:cli-tools/` estructura y patrón de entry points

---

## US-083 — Comando devtools sync

**Épica**: EP-9 | **Prioridad**: P1 | **SP**: 8 | **Estado**: `[ ]`

### Descripción
Como desarrollador de un proyecto consumidor,  
quiero ejecutar `devtools sync` para importar los artefactos que necesito,  
sin copiarlos manualmente ni romper actualizaciones futuras.

### Criterios de aceptación
- [ ] `devtools sync --manifest devtools.manifest.json` lee el manifest y copia artefactos al destino
- [ ] Soporta `mode: copy` (copia física) y `mode: symlink`
- [ ] Detecta y reporta versiones incompatibles
- [ ] No sobreescribe sin confirmación si hay cambios locales
- [ ] Genera un `devtools.lock.json` con el estado sincronizado

### Fuente
> `BK:cli-tools/sync_skills/`

---

## US-081 — Comando devtools scaffold

**Épica**: EP-9 | **Prioridad**: P1 | **SP**: 5 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `devtools scaffold skill <name> <namespace>` genera la estructura completa desde `_TEMPLATE/`
- [ ] Reemplaza placeholders en SKILL.md con el nombre y namespace indicados
- [ ] Abre el archivo generado en el editor si está disponible

---

## US-082 — Comando devtools validate

**Épica**: EP-9 | **Prioridad**: P1 | **SP**: 3 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `devtools validate skill <path>` valida frontmatter, secciones obligatorias y overview.md
- [ ] Salida en formato tabla con ✓/✗ por criterio
- [ ] `--fix` mode corrige problemas automáticos (frontmatter faltante)

---

---

# SPRINT 4 — Multiplatform + Stacks secundarios (EP-6 + EP-4)

> **Objetivo**: Cobertura completa de stacks KMP/CMP y Android Legacy.  
> **Capacidad**: 34 SP

---

## US-050 — Skill KMP shared module patterns

**Épica**: EP-6 | **Prioridad**: P1 | **SP**: 5 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `skills/multiplatform/kmp/kmp-shared-module-patterns/` creada
- [ ] Cubre: expect/actual, ktor-client, SQLDelight, shared ViewModels
- [ ] Ejemplos para iOS + Android

---

## US-030 — Skill Android XML+Java patterns

**Épica**: EP-4 | **Prioridad**: P1 | **SP**: 5 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `skills/android/legacy/android-xml-java-patterns/` creada
- [ ] Cubre: ViewBinding, Retrofit, Room, patrón MVVM legacy

---

## US-063 — Skill Python FastAPI patterns

**Épica**: EP-7 | **Prioridad**: P2 | **SP**: 5 | **Estado**: `[ ]`

### Criterios de aceptación
- [ ] `skills/backend/python/backend-python-fastapi-patterns/` creada
- [ ] Cubre: routers, Pydantic models, SQLAlchemy async, pytest

---

## Backlog pendiente (sin sprint asignado)

| US | Descripción | EP | SP |
|---|---|---|---|
| US-022 | Skill android-navigation-compose | EP-3 | 3 |
| US-023 | Skill android-hilt-injection | EP-3 | 3 |
| US-024 | Skill android-unit-testing-compose | EP-3 | 3 |
| US-025 | Agente android-compose-expert | EP-3 | 5 |
| US-042 | Skill uikit-patterns | EP-5 | 5 |
| US-044 | Agente ios-uikit-expert | EP-5 | 5 |
| US-051 | Skill cmp-ui-patterns | EP-6 | 5 |
| US-052 | Agente kmp-expert | EP-6 | 5 |
| US-064 | Skill spring-java-patterns | EP-7 | 5 |
| US-065 | Agente backend-python-expert | EP-7 | 3 |
| US-075 | Agente qa-testcase global | EP-8 | 5 |
| US-084 | Comando devtools list | EP-9 | 3 |
| US-014 | Detección incompatibilidades sync | EP-2 | 5 |
