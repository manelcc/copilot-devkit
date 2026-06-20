# Scrum Backlog — DevTools-AI

> Repositorio centralizado de agentes, skills y prompts multi-stack  
> (Android Compose · Android Legacy · iOS SwiftUI · KMP/CMP · Backend Kotlin · Python · Spring)

---

## Resumen funcional

DevTools-AI es el repositorio centralizado que actúa como fuente única de verdad para todos los artefactos de automatización IA (agentes, skills, prompts, instrucciones) reutilizables en proyectos de la organización. Los proyectos consumidores importan desde aquí mediante el CLI `devtools sync` sin duplicar ni mantener copias propias.

El backlog cubre 4 sprints principales:
- **Sprint 0**: Fundamentos del repositorio (estructura, templates, CLI base, sync)
- **Sprint 1**: Migración masiva de artefactos backend y globales desde proyectos fuente
- **Sprint 2**: Stack Android Compose y iOS SwiftUI
- **Sprint 3**: Multiplatform KMP, CLI completo y comandos scaffold/validate

---

## Épicas

### EP-1: Fundamentos e Inicialización
**Descripción**: Crear la estructura base, governance y herramientas mínimas para que el repo sea operable.
**Objetivo**: Al final de Sprint 0, el repositorio tiene estructura, templates, validación y documentación.

### EP-2: Sync Skills Strategy
**Descripción**: Definir e implementar el mecanismo por el que proyectos consumidores importan artefactos.
**Objetivo**: Comando `devtools sync` funcional con manifest y lock para distribución controlada.

### EP-3: Stack Android Compose
**Descripción**: Skills, agentes e instrucciones para proyectos Kotlin + Jetpack Compose.
**Objetivo**: Coverage completo del stack Android moderno con patrones, Navigation 3 y migración.

### EP-5: Stack iOS
**Descripción**: Skills, agentes e instrucciones para proyectos Swift + SwiftUI (y UIKit legacy).
**Objetivo**: Skills iOS probadas de bankinter-devtools disponibles centralizadas.

### EP-6: Multiplatform KMP/CMP
**Descripción**: Skills y agentes para Kotlin Multiplatform y Compose Multiplatform.
**Objetivo**: Módulo KMP compartido cubierto con patrones expect/actual, Ktor Client, SQLDelight.

### EP-7: Stack Backend
**Descripción**: Migración de artefactos Kotlin/Ktor de mycardiochef + skills Python y Spring.
**Objetivo**: 6 skills y 6 agentes Kotlin/Ktor disponibles centralizados.

### EP-8: Global Cross-Stack
**Descripción**: Skills y agentes reutilizables en cualquier stack.
**Objetivo**: clean-code, git-workflow, MR-description y project-orchestrator disponibles globalmente.

### EP-9: CLI Tools
**Descripción**: CLI Python `devtools` con comandos sync, scaffold, validate y list.
**Objetivo**: Experiencia unificada para operar el repositorio desde la terminal.

---

## User Stories (índice)

### Sprint 0 — Fundamentos

#### US-001 — Inicializar estructura de directorios
Como contributor, quiero encontrar todos los directorios de namespaces desde el primer commit, para añadir artefactos sin ambigüedad.
Épica: EP-1 | Prioridad: Alta (P0) | Fichero: [US-001-inicializar-estructura-directorios.md](US-001-inicializar-estructura-directorios.md)

#### US-002 — README, governance y copilot-instructions
Como consumidor o contributor, quiero un README que explique el propósito y cómo empezar en < 5 min, para usar o contribuir al repo.
Épica: EP-1 | Prioridad: Alta (P0) | Fichero: [US-002-readme-governance-copilot-instructions.md](US-002-readme-governance-copilot-instructions.md)

#### US-003 — Templates base de skills y agentes
Como contributor creando una nueva skill o agente, quiero un template completo, para generar artefactos consistentes sin partir de cero.
Épica: EP-1 | Prioridad: Alta (P0) | Fichero: [US-003-templates-base-skills-agentes.md](US-003-templates-base-skills-agentes.md)

#### US-004 — Pre-commit, validación y setup local
Como contributor, quiero que un pre-commit rechace skills mal formadas y que un único comando configure mi entorno, para mantener calidad sin revisión manual.
Épica: EP-1 | Prioridad: Alta (P1) | Fichero: [US-004-precommit-validacion-setup-local.md](US-004-precommit-validacion-setup-local.md)

#### US-005 — Bootstrap CLI devtools ✅ DONE
Como desarrollador, quiero un comando `devtools` instalable con subcomandos base, para no depender de scripts bash dispersos.
Épica: EP-9 | Prioridad: Alta (P0) | Fichero: [US-005-bootstrap-cli-devtools.md](US-005-bootstrap-cli-devtools.md) | Solve: [US-005-bootstrap-cli-devtools.md](../solve/US-005-bootstrap-cli-devtools.md)

#### US-006 — Implementar devtools sync copy-on-demand ✅ DONE
Como desarrollador de un proyecto consumidor, quiero `devtools sync` para importar artefactos según un manifest, para no copiar manualmente ni perder actualizaciones.
Épica: EP-2 | Prioridad: Alta (P1) | Fichero: [US-006-devtools-sync-copy-on-demand.md](US-006-devtools-sync-copy-on-demand.md) | Solve: [US-006-devtools-sync-copy-on-demand.md](../solve/US-006-devtools-sync-copy-on-demand.md)

---

### Sprint 1 — Migración Backend + Global

#### US-007 — Migrar skills backend Kotlin/Ktor ✅ DONE
Como desarrollador backend Kotlin, quiero las 6 skills de mycardiochef en `skills/backend/kotlin-ktor/`, para usarlas en cualquier proyecto Ktor.
Épica: EP-7 | Prioridad: Alta (P0) | Fichero: [US-007-migrar-skills-backend-kotlin-ktor.md](US-007-migrar-skills-backend-kotlin-ktor.md) | Solve: [US-007-migrar-skills-backend-kotlin-ktor.md](../solve/US-007-migrar-skills-backend-kotlin-ktor.md)

#### US-008 — Migrar agentes e instrucciones backend Ktor ✅ DONE
Como desarrollador backend Kotlin, quiero los agentes de mycardiochef en `agents/backend/kotlin-ktor/` y las instrucciones Ktor, para orquestar tareas desde cualquier proyecto.
Épica: EP-7 | Prioridad: Alta (P0) | Fichero: [US-008-migrar-agentes-instrucciones-backend-ktor.md](US-008-migrar-agentes-instrucciones-backend-ktor.md) | Solve: [US-008-migrar-agentes-instrucciones-backend-ktor.md](../solve/US-008-migrar-agentes-instrucciones-backend-ktor.md)

#### US-009 — Migrar skills globales (clean-code, git, MR)
Como desarrollador en cualquier stack, quiero las skills de calidad y git en `skills/global/`, para seguir convenciones en todos los proyectos.
Épica: EP-8 | Prioridad: Alta (P0) | Fichero: [US-009-migrar-skills-globales.md](US-009-migrar-skills-globales.md)

#### US-010 — Agente project-orchestrator e instrucciones globales
Como usuario en cualquier stack, quiero un agente orquestador que delegue al agente correcto según mi contexto, para no saber de memoria qué skill invocar.
Épica: EP-8 | Prioridad: Alta (P0) | Fichero: [US-010-agente-orchestrator-instrucciones-globales.md](US-010-agente-orchestrator-instrucciones-globales.md)

---

### Sprint 2 — Android Compose + iOS SwiftUI

#### US-011 — Skill migrate-xml-to-compose e instrucciones Android Compose
Como desarrollador Android migrando a Compose, quiero la skill de migración y las instrucciones Compose, para implementar features con guía de calidad.
Épica: EP-3 | Prioridad: Alta (P0) | Fichero: [US-011-skill-xml-to-compose-instrucciones-android.md](US-011-skill-xml-to-compose-instrucciones-android.md)

#### US-012 — Skills y agente Android Compose (patterns, Nav3)
Como desarrollador Android Compose, quiero skills de patrones Compose, Navigation 3 y un agente experto, para implementar features modernas con calidad.
Épica: EP-3 | Prioridad: Alta (P1) | Fichero: [US-012-skills-agente-android-compose.md](US-012-skills-agente-android-compose.md)

#### US-013 — Migrar skills e instrucciones iOS SwiftUI ✅ DONE
Como desarrollador iOS, quiero las skills de bankinter-devtools en `skills/ios/swiftui/` y las instrucciones Swift/SwiftUI, para implementar features iOS con calidad.
Épica: EP-5 | Prioridad: Alta (P0) | Fichero: [US-013-migrar-skills-instrucciones-ios-swiftui.md](US-013-migrar-skills-instrucciones-ios-swiftui.md)

---

### Sprint 3 — KMP + CLI completo

#### US-014 — Skills KMP y agente multiplatform
Como desarrollador KMP, quiero skills del módulo compartido y un agente KMP, para implementar lógica multiplataforma con patrones correctos.
Épica: EP-6 | Prioridad: Alta (P1) | Fichero: [US-014-skills-kmp-agente-multiplatform.md](US-014-skills-kmp-agente-multiplatform.md)

#### US-015 — Comandos CLI scaffold y validate
Como contributor, quiero `devtools scaffold skill` y `devtools validate skill` completamente funcionales, para crear y verificar skills sin conocer la estructura interna.
Épica: EP-9 | Prioridad: Alta (P1) | Fichero: [US-015-comandos-cli-scaffold-validate.md](US-015-comandos-cli-scaffold-validate.md)

---

### Backlog sin sprint (P2 — stacks secundarios)

| US | Descripción | Épica |
|---|---|---|
| US-016 | Skills Android Compose avanzadas (Hilt, Testing) | EP-3 |
| US-017 | Skills e instrucciones iOS UIKit legacy | EP-5 |
| US-018 | Skills Compose Multiplatform (CMP) | EP-6 |
| US-019 | Skills backend Python FastAPI | EP-7 |
| US-020 | Skills backend Spring Java | EP-7 |
| US-021 | Skills Android Legacy (XML+Java) | EP-4 |
| US-086 | Detección incompatibilidades sync + docs consumidores | EP-2 |
| US-023 | Comando devtools list (inventario de artefactos) | EP-9 |

---

## Definition of Done

- DOD-001: La US implementada no rompe ninguna US anterior (regresión)
- DOD-002: Todo fichero SKILL.md creado o modificado pasa `validate-skill.sh` con exit 0
- DOD-003: Todo fichero `.agent.md` creado tiene frontmatter YAML válido (parseable)
- DOD-004: Ningún artefacto migrado contiene referencias a paths o proyectos de origen (mycardiochef, bankinter)
- DOD-005: Si la US crea un comando CLI, tiene `--help` descriptivo y al menos un test unitario
- DOD-006: Si la US crea instrucciones `.instructions.md`, tiene `applyTo` en frontmatter
- DOD-007: El `README.md` y los links internos del fichero se verifican como no rotos
- DOD-008: La PR incluye resumen del cambio y referencia a la US

---

## Bloqueos

- BLK-001: Acceso al path local de `mycardiochef/middleware/.github/` requerido para US-007, US-008, US-009 (path: `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/mycardiochef/middleware/.github/`)
- BLK-002: Acceso al path local de `bankinter-devtools/skills/ios/` requerido para US-013 (path: `/Users/manelcc/Documents/BANKINTER/bankinter-devtools/skills/ios/`)
- BLK-003: Acceso a `~/.claude/skills/migrate-xml-views-to-jetpack-compose/` requerido para US-011
- BLK-004: Decisión de librería CLI (argparse/click/typer) pendiente para US-005

---

## Supuestos

- SUP-001: Los namespaces definidos en `constitution.md` son estables durante todo el Sprint 0; cambios requieren RFC
- SUP-002: Las skills de `bankinter-devtools/skills/ios/` contienen al menos algunas skills genéricas migrables (no todas son project-specific)
- SUP-003: Navigation 3 es el estándar para proyectos Android Compose nuevos; Navigation 2 no se documenta en las instrucciones
- SUP-004: KMP 2.0 es el baseline; no se cubre KMM (deprecated naming)
- SUP-005: El modo `local path` del devtools sync es suficiente para Sprint 0; modo git-URL se implementa en iteración posterior
- SUP-006: Python 3.11+ está disponible en las máquinas de todos los contributors
- SUP-007: `prompts/` sigue la misma jerarquía de namespaces que `agents/` y `skills/`

---

## Dudas abiertas

- Q-001: ¿`prompts/` necesita sub-namespaces jerárquicos o puede ser plano?
- Q-002: ¿El `devtools.lock.json` se commitea en el proyecto consumidor o va en `.gitignore`?
- Q-003: ¿Las skills project-specific de bankinter-devtools (bro/inx/nbo) se incluyen con namespace de proyecto o se descartan?
- Q-004: ¿El agente `project-orchestrator` necesita un fichero `.devtools-stack` en el proyecto para bypass de detección automática?
- Q-005: ¿La skill `mycardio-middleware-user-profile` de mycardiochef se incluye en la migración de US-007?
- Q-006: ¿Los agentes `project-orchestrator` y `qa-testcase` de mycardiochef se migran en US-008 (backend) o en US-010 (global)?
- Q-007: ¿El comando `devtools scaffold` abre automáticamente el fichero creado en el editor (`$EDITOR`) o solo imprime el path?

---

## Fichero fuente
Generado a partir de: `docs/implementation/` (epics.md, backlog.md, constitution.md, sync-strategy.md, sprints/sprint-0.md)  
Directorio de salida: `docs/implementation/user-stories/`  
Fecha de generación: 2026-06-06
