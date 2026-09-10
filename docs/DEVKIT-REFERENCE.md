# Copilot DevKit — Referencia Completa

> **Fuente única de verdad** de agentes, skills, prompts e instrucciones reutilizables de GitHub Copilot
> para proyectos multi-stack de la organización.

---

## ¿Qué es Copilot DevKit?

**copilot-devkit** es la fuente centralizada de inteligencia de desarrollo para GitHub Copilot
en la organización. En lugar de que cada equipo defina sus propias instrucciones, patrones y
flujos de trabajo de forma aislada, este repositorio los recoge, estandariza y distribuye a todos
los proyectos consumidores de forma automática.

### El problema que resuelve

Sin un estándar compartido, cada proyecto acaba con un Copilot que conoce patrones diferentes,
usa convenciones incompatibles y no puede aplicar las prácticas de calidad de la organización.
El resultado es inconsistencia: un equipo usa MVVM con StateFlow, otro usa LiveData sin ViewModel,
y ninguno tiene un agente que audite la arquitectura con los mismos criterios.

### Cómo lo resuelve

copilot-devkit actúa como un **repositorio de conocimiento vivo** que alimenta a Copilot con:

- **Skills**: instrucciones expertas que Copilot activa por contexto o invocación directa —
  patrones de diseño, auditorías de arquitectura, generadores de código, flujos de migración.
- **Agents**: modos de trabajo especializados que orquestan varias skills para completar tareas
  complejas — ciclos de desarrollo guiados, revisiones de calidad, generación de pipelines CI/CD.
- **Prompts**: plantillas reutilizables para disparar tareas frecuentes con un solo clic.
- **Instructions**: reglas de contexto que aplican convenciones del stack en todos los chats
  del proyecto automáticamente.

Todo se distribuye mediante **symlinks** desde este repositorio a `.github/` del proyecto
consumidor: no hay copias ni mantenimiento distribuido. Cuando una skill se mejora aquí,
todos los proyectos vinculados la reciben de inmediato.

### Qué cubre

9 stacks tecnológicos con artefactos propios y un conjunto global transversal:

| Stack | Tecnología |
|---|---|
| Android Compose | Kotlin + Jetpack Compose |
| Android Legacy | XML + Java (ViewBinding, MVVM, LiveData) |
| iOS SwiftUI | Swift + SwiftUI |
| iOS UIKit | Swift + UIKit |
| Backend Kotlin | Ktor + Exposed + PostgreSQL |
| Backend Python | FastAPI / Django / Python patterns |
| Backend Spring | Spring Boot + Java |
| KMP | Kotlin Multiplatform |
| CMP | Compose Multiplatform |

Cada artefacto lleva el prefijo **`devkit-`** (regla de oro) para ser identificable en cualquier
contexto y evitar colisiones con artefactos locales de cada proyecto.

---

## Instalación

### 1. Instalación global (una sola vez por máquina)

Instala las skills y agentes **transversales** en `~/.copilot/` y la CLI `devtools` en el PATH.
Requiere Python ≥ 3.11.

```bash
# Desde el root del repositorio copilot-devkit
bash scripts/setup.sh
source ~/.zshrc     # o ~/.bashrc según tu shell
```

Qué hace `setup.sh`:
- Exporta `$COPILOT_DEVKIT_HOME` apuntando al repositorio
- Instala la CLI `devtools` (Python editable) en el PATH
- Crea symlinks de `skills/global/devkit-*` → `~/.copilot/skills/`
- Crea symlinks de `agents/global/devkit-*` → `~/.copilot/agents/`
- Configura los git hooks (`pre-commit` con validación de skills)

Las skills globales quedan disponibles **en todos los proyectos** del equipo sin pasos adicionales.

---

### 2. Integración en proyecto consumidor (por tecnología)

Desde el **root del proyecto consumidor**, ejecuta el flag correspondiente a tu stack:

```bash
# Android (Compose + Legacy)
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android

# iOS (SwiftUI + UIKit)
bash $COPILOT_DEVKIT_HOME/setup-project.sh --ios

# Kotlin Multiplatform
bash $COPILOT_DEVKIT_HOME/setup-project.sh --kmp

# Compose Multiplatform
bash $COPILOT_DEVKIT_HOME/setup-project.sh --cmp

# Backend Python
bash $COPILOT_DEVKIT_HOME/setup-project.sh --python

# Backend Kotlin/Ktor
bash $COPILOT_DEVKIT_HOME/setup-project.sh --kotlin

# Solo DevOps global
bash $COPILOT_DEVKIT_HOME/setup-project.sh --devops

# Skill individual
bash $COPILOT_DEVKIT_HOME/setup-project.sh --skill devkit-logging-kotlin

# Ver qué flags hay disponibles
bash $COPILOT_DEVKIT_HOME/setup-project.sh --list
```

> **Nota:** Existe flag `--kotlin` para Backend Kotlin/Ktor y flag `--devops` para el paquete
> global de DevOps. No existe flag `--spring` por ahora; Spring se integra con `--skill <nombre>`
> o symlink manual.
>
> Si activas `--python` o `--kotlin`, el script habilita también DevOps automáticamente.

El script crea symlinks en `.github/` del proyecto consumidor:

```
.github/
  skills/     ← symlinks a skills/android/compose/devkit-*, etc.
  agents/     ← symlinks a agents/android/devkit-*, etc.
  prompts/    ← symlinks a prompts/android/compose/devkit-*, etc.
  instructions/ ← symlinks a instructions/devkit-android-compose.instructions.md, etc.
```

---

## Sincronización

Los artefactos se sirven en **tiempo real** desde el repositorio central. No hay paso de sync
ni copia local: si actualizas una skill en copilot-devkit, todos los proyectos vinculados la
reciben automáticamente porque el symlink siempre apunta al origen.

Para re-ejecutar el setup en un proyecto (p. ej., al añadir nuevos artefactos):

```bash
# Desde el root del proyecto consumidor
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android   # re-crea symlinks faltantes
```

Los symlinks ya existentes se omiten sin error; sólo se crean los nuevos.

---

## Índice por tecnología

| Tecnología | Skills | Agents | Prompts | Instrucción |
|---|:---:|:---:|:---:|:---:|
| [Global (transversal)](#global-transversal) | 6 | 1 | — | 1 |
| [Android Compose](#android-compose) | 4 | 4 | 2 | 1 |
| [Android Legacy](#android-legacy) | 1 | — | — | 1 |
| [iOS SwiftUI](#ios-swiftui) | 4 | 3 | 2 | 1 |
| [iOS UIKit](#ios-uikit) | 1 | — | — | 1 |
| [Backend Kotlin / Ktor](#backend-kotlin--ktor) | 6 | 7 | — | 1 |
| [Backend Python](#backend-python) | 2 | 3 | 2 | — |
| [Backend Spring Java](#backend-spring-java) | 1 | 1 | — | — |
| [KMP — Kotlin Multiplatform](#kmp--kotlin-multiplatform) | 1 | 2 | — | 1 |
| [CMP — Compose Multiplatform](#cmp--compose-multiplatform) | 1 | 2 | — | 1 |

---

## Global (transversal)

> Disponibles en **todos los proyectos** sin configuración adicional (instaladas por `setup.sh`).

### Skills

| Skill | Descripción |
|---|---|
| `devkit-clean-architecture-quality` | Auditoría de clean architecture en Java/Kotlin/Swift/Python: hallazgos CRITICAL/HIGH/MEDIUM/LOW con plan de remediación accionable |
| `devkit-clean-code-guardian` | Revisa y corrige violaciones de Clean Code (clases >500 líneas, funciones >30 líneas, anidamiento >3 niveles, magic numbers, SRP) en Kotlin/Java/Swift/Python |
| `devkit-development-lifecycle` | Ciclo guiado completo de desarrollo de una US: planificación, consulta experta, implementación, quality gates con loop de corrección e interacción con el usuario |
| `devkit-development-lifecycle` | Ciclo completo guiado por US: planificación, expertos, tests, quality gates, corrección, E2E/smoke opcionales y MR. Configuración custom via `.github/devkit-project.config.md` |
| `devkit-git-workflow` | Workflow git end-to-end: rama desde develop actualizado, commits atómicos semánticos, quality gates, push seguro y preparación de MR/PR |
| `devkit-mr-description-generator` | Genera descripción de MR/PR en Markdown desde commits de rama y contexto de US; válido para cualquier stack |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-development-lifecycle-orchestrator` | Orquestador del ciclo de desarrollo guiado con planificación, consulta experta, quality gates y decisiones interactivas; garantiza trazabilidad y adaptabilidad al código existente |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-global.instructions.md` | Convenciones globales aplicadas a todos los chats de Copilot en el proyecto |

---

## Android Compose

> Flag de activación: `--android`
>
> Ruta en el repo: `skills/android/compose/`, `agents/android/compose/`, `prompts/android/compose/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-android-patterns` | Guía de patrones de diseño Android/Kotlin: diagnostica el problema, recomienda 2-3 patrones candidatos con trade-offs e implementación idiomática |
| `devkit-android-clean-architecture-quality` | Auditoría de clean architecture para Android/Kotlin con severidad y plan de remediación accionable |
| `devkit-jetpack-compose-patterns` | Guía práctica de patrones Jetpack Compose: state hoisting, `remember`/`rememberSaveable`, side-effects, producción-ready |
| `devkit-migrate-xml-to-compose` | Workflow estructurado de migración incremental de XML Views a Jetpack Compose: planificación, dependencias, theming, migración de layout y limpieza |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-android-project-orchestrator` | Orquestador principal de proyectos Android; enruta hacia el agente o skill especializada correcta |
| `devkit-android-clean-architecture-quality` | Auditor de arquitectura limpia Android con hallazgos priorizados y basados en evidencia |
| `devkit-android-compose-expert` | Experto en Jetpack Compose para implementación de features y resolución de problemas |
| `devkit-android-expert-pattern` | Guía de patrones Android/Kotlin; diagnóstico y recomendación de 2-3 patrones con trade-offs |

### Prompts

| Prompt | Cuándo usarlo |
|---|---|
| `devkit-android-clean-architecture-quality-analyze.prompt.md` | Lanzar una auditoría de arquitectura limpia sobre el módulo Android activo |
| `devkit-android-expert-patterns.prompt.md` | Solicitar recomendación de patrón de diseño para un problema Android concreto |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-android-compose.instructions.md` | Reglas y convenciones Kotlin + Compose para todos los chats del proyecto |

---

## Android Legacy

> Flag de activación: `--android` (incluido junto con Compose)
>
> Ruta en el repo: `skills/android/legacy/`, `agents/android/legacy/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-android-xml-java-patterns` | Patrones Android legacy con XML + Java: ViewBinding, Retrofit, Room, MVVM con LiveData y recomendaciones de migración gradual a Kotlin/Compose |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-android-legacy.instructions.md` | Convenciones para proyectos Android legacy (XML + Java/Kotlin sin Compose) |

---

## iOS SwiftUI

> Flag de activación: `--ios`
>
> Ruta en el repo: `skills/ios/swiftui/`, `agents/ios/swiftui/`, `prompts/ios/swiftui/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-ios-clean-architecture-quality` | Auditoría de clean architecture para iOS/Swift con hallazgos CRITICAL/HIGH/MEDIUM/LOW y plan de remediación |
| `devkit-ios-patterns` | Guía de patrones de diseño iOS/Swift: diagnóstico, 2-3 candidatos con trade-offs e implementación idiomática |
| `devkit-ios-swift-concurrency` | Guía estructurada de Swift concurrency: `async`/`await`, `actors`, `Task`, structured concurrency y patrones de producción |
| `devkit-swiftui-testing-xctest` | Patrones prácticos de testing SwiftUI con XCTest: pruebas asíncronas, view testing y cobertura |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-ios-project-orchestrator` | Orquestador principal de proyectos iOS; enruta hacia agente o skill especializada |
| `devkit-ios-clean-architecture-quality` | Auditor de arquitectura limpia iOS/Swift con hallazgos priorizados |
| `devkit-ios-swiftui-expert` | Experto en SwiftUI para implementación de features y resolución de problemas |

### Prompts

| Prompt | Cuándo usarlo |
|---|---|
| `devkit-ios-clean-architecture-quality-analyze.prompt.md` | Lanzar auditoría de arquitectura limpia sobre el módulo iOS activo |
| `ios-expert-patterns.prompt.md` | Solicitar recomendación de patrón iOS/Swift para un problema concreto |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-ios-swiftui.instructions.md` | Convenciones Swift + SwiftUI para todos los chats del proyecto |

---

## iOS UIKit

> Flag de activación: `--ios` (incluido junto con SwiftUI)
>
> Ruta en el repo: `skills/ios/uikit/`, `agents/ios/uikit/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-uikit-patterns` | Patrones UIKit clásicos para desarrollar y mantener apps iOS legacy: Coordinator, MVVM+DataSource, delegates y lifecycle |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-ios-uikit.instructions.md` | Convenciones para proyectos iOS legacy con UIKit |

---

## Backend Kotlin / Ktor

> Flag de activación: `--kotlin`
>
> Ruta en el repo: `skills/backend/kotlin-ktor/`, `agents/backend/kotlin-ktor/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-kotlin-mcp-server-generator` | Genera un servidor MCP completo en Kotlin con Clean Architecture, PostgreSQL/Exposed, tests JaCoCo ≥40% y soporte KMP |
| `devkit-ktor-auth-flow` | Fuente de verdad del sistema de autenticación Ktor: Argon2id password hashing, JWT, gestión de sesiones |
| `devkit-logging-kotlin` | Convención de logging Kotlin/Ktor con trazabilidad `X-Request-ID`/`X-Correlation-ID`, niveles, privacidad y lazy evaluation |
| `devkit-postgresql-crud` | Patrones de acceso a PostgreSQL con Exposed DSL y Flyway: tablas, repositorios, `dbQuery` coroutine-safe y migraciones versionadas |
| `devkit-unit-testing-kotlin` | Patrones de unit testing: JUnit5 + MockK + Kotest assertions, cobertura JaCoCo ≥40%, naming given/when/then y H2 in-memory |
| `devkit-webscraping-contract` | Contrato operativo middleware ↔ web-scraping con seguridad HMAC v1 y checklist de validación end-to-end |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-backend-kotlin-project-orchestrator` | Orquestador principal de proyectos backend Kotlin/Ktor |
| `devkit-kotlin-expert-pattern` | Guía de patrones Kotlin server-side y KMP con trade-offs e implementación Ktor/Exposed/Koin |
| `devkit-kotlin-mcp-expert` | Genera servidores MCP Kotlin end-to-end con Clean Architecture y CI/CD |
| `devkit-kotlin-server-quality` | Auditor de calidad Kotlin server-side con hallazgos priorizados y basados en evidencia |
| `devkit-payload-logging-trace` | Implementa logging de payloads request/response JSON con trazabilidad; mejora troubleshooting sin exponer secretos |
| `devkit-x-correlation-id-strategy` | Define e implementa la estrategia de trazabilidad `X-Correlation-ID`/`X-Request-ID` entre servicios HTTP |

> El orquestador DevOps (`devkit-devops-orchestrator`) es global y se instala con `setup.sh`.
> Opcionalmente puede enlazarse en el proyecto con `setup-project.sh --devops`.

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-backend-kotlin.instructions.md` | Convenciones Kotlin + Ktor + Exposed para todos los chats del proyecto |

---

## Backend Python

> Flag de activación: `--python`
>
> Ruta en el repo: `skills/backend/python/`, `agents/backend/python/`, `prompts/backend/python/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-python-clean-architecture-quality` | Auditoría de clean architecture para backend Python con hallazgos priorizados por severidad y plan de remediación |
| `devkit-python-patterns` | Guía de patrones de diseño Python: diagnóstico del problema, 2-3 candidatos con trade-offs e implementación idiomática |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-backend-python-project-orchestrator` | Orquestador principal de proyectos backend Python |
| `devkit-python-clean-architecture-quality` | Auditor de arquitectura limpia Python con hallazgos priorizados |
| `devkit-python-expert-pattern` | Guía de patrones Python con recomendaciones de implementación idiomática |

### Prompts

| Prompt | Cuándo usarlo |
|---|---|
| `devkit-python-clean-architecture-quality-analyze.prompt.md` | Lanzar auditoría de arquitectura limpia sobre el módulo Python activo |
| `devkit-python-expert-patterns.prompt.md` | Solicitar recomendación de patrón de diseño para un problema Python concreto |

---

## Backend Spring Java

> Flag de activación: `--skill devkit-spring-java-patterns` (o symlink manual)
>
> Ruta en el repo: `skills/backend/spring-java/`, `agents/backend/spring-java/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-spring-java-patterns` | Patrones Spring Boot Java para servicios backend mantenibles: capas de dominio, repositorios, servicios y controllers alineados con Clean Architecture |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-backend-java-project-orchestrator` | Orquestador principal de proyectos backend Spring Boot Java |

---

## KMP — Kotlin Multiplatform

> Flag de activación: `--kmp`
>
> Ruta en el repo: `skills/multiplatform/kmp/`, `agents/multiplatform/kmp/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-kmp-shared-module-patterns` | Patrones para módulos compartidos KMP: `expect`/`actual`, Ktor Client, SQLDelight, coroutines y iOS interop |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-kmp-project-orchestrator` | Orquestador principal de proyectos KMP |
| `devkit-kmp-expert` | Experto en Kotlin Multiplatform: implementación de módulos shared, targets y estrategia iOS/Android |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-kmp.instructions.md` | Convenciones KMP para todos los chats del proyecto |

---

## CMP — Compose Multiplatform

> Flag de activación: `--cmp`
>
> Ruta en el repo: `skills/multiplatform/cmp/`, `agents/multiplatform/cmp/`

### Skills

| Skill | Descripción |
|---|---|
| `devkit-cmp-ui-patterns` | Patrones UI Compose Multiplatform: gestión de estado MVI/MVVM, navegación type-safe, theming y optimización de rendimiento para Android e iOS |

### Agents

| Agent | Descripción |
|---|---|
| `devkit-cmp-project-orchestrator` | Orquestador principal de proyectos Compose Multiplatform |
| `devkit-cmp-expert` | Experto en CMP para implementación de features de UI compartida entre Android e iOS |

### Instrucción de Copilot

| Fichero | Alcance |
|---|---|
| `devkit-cmp.instructions.md` | Convenciones Compose Multiplatform para todos los chats del proyecto |

---

## Convenciones del repositorio

- **Prefijo obligatorio**: todos los artefactos llevan el prefijo `devkit-` (regla de oro)
- **Simetría 1:1**: todo namespace en `agents/` existe en `skills/` y `prompts/`
- **Commits semánticos**: `feat`, `fix`, `docs`, `chore` + referencia de US (`feat(US-001): ...`)
- **Validación automática**: cada `skills/**/*.md` modificado pasa `scripts/devkit-validate-skill.sh` en pre-commit
- **Sin duplicados**: los proyectos consumen vía symlink; nunca copian artefactos
