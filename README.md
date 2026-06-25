# copilot-devkit

Repositorio centralizado de agentes, skills, prompts e instrucciones reutilizables para GitHub Copilot en proyectos multi-stack. Los equipos lo consumen via scripts de setup sin duplicar ni mantener copias locales.

---

## Stacks cubiertos

| Stack | Lenguaje | Frameworks clave |
|---|---|---|
| Android Compose | Kotlin | Jetpack Compose, Coroutines, Hilt, Navigation 3 |
| Android Legacy | Java + Kotlin | XML Views, ViewBinding, Retrofit |
| iOS SwiftUI | Swift | SwiftUI, Combine, SPM |
| iOS UIKit | Swift | UIKit, Storyboard/XIB |
| KMP | Kotlin | Kotlin Multiplatform, Ktor Client, SQLDelight |
| CMP | Kotlin | Compose Multiplatform (Android + iOS + Desktop) |
| Backend Kotlin | Kotlin | Ktor, Exposed/JPA, Flyway, Coroutines |
| Backend Python | Python | FastAPI, SQLAlchemy, Pydantic |
| Backend Spring | Java | Spring Boot, JPA, Maven/Gradle |

---

## Instalación

### 1 — Global (una sola vez por máquina)

Desde la raíz de este repo, ejecuta el setup global. Instala el CLI `devtools`, enlaza las skills globales en `~/.copilot/skills/` y exporta `$COPILOT_DEVKIT_HOME`.

```bash
./scripts/setup.sh
```

Qué hace:
- Añade `COPILOT_DEVKIT_HOME` y `devtools` a tu `~/.zshrc` (o bashrc)
- Crea un venv Python e instala el CLI `devtools`
- Enlaza `skills/global/` → `~/.copilot/skills/` para que Copilot las detecte siempre

### 2 — Por proyecto (una vez por repo consumidor)

Desde la **raíz del proyecto** que va a usar el devkit, ejecuta el setup de tecnología. Crea symlinks en `.github/` con los artefactos del stack.

```bash
# Android
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android

# iOS
bash $COPILOT_DEVKIT_HOME/setup-project.sh --ios

# Multiplatform KMP
bash $COPILOT_DEVKIT_HOME/setup-project.sh --kmp

# Compose Multiplatform
bash $COPILOT_DEVKIT_HOME/setup-project.sh --cmp

# Backend Python
bash $COPILOT_DEVKIT_HOME/setup-project.sh --python

# Proyecto con múltiples tecnologías
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android --kmp

# Ver qué hay disponible para cada stack
bash $COPILOT_DEVKIT_HOME/setup-project.sh --list
```

Resultado en el proyecto:
```
.github/
├── skills/        ← skills del stack enlazadas
├── agents/        ← agentes del stack enlazados
├── prompts/       ← prompts del stack enlazados
└── instructions/  ← instrucciones del stack enlazadas
```

> Las skills globales (clean-code, git-workflow, etc.) ya están en `~/.copilot/skills/`
> y no necesitan enlazarse por proyecto.

---

## Agente maestro

El punto de entrada para cualquier tarea de desarrollo es el agente orquestador global:

```
devkit-development-lifecycle-orchestrator
```

Invócalo en Copilot Chat así:

```
@devkit-development-lifecycle-orchestrator ejecuta el ciclo IA de la US-042
```

El agente orquesta el ciclo completo de 9 fases:
- **A** — Plan de implementación con consulta a expertos (arquitectura, patrones, calidad)
- **B** — Implementación según el plan
- **C** — Generación de tests (cobertura ≥40%)
- **D** — Quality gates (clean-code + clean-architecture)
- **E** — Bucle de corrección si los quality gates fallan (máx. 3 iteraciones)
- **F/G** — Tests E2E y smoke tests (opcionales, el agente pregunta)
- **H** — Commits atómicos (el agente pregunta antes de ejecutar)
- **I** — Descripción de MR/PR con trazabilidad completa

Si no tienes un stack específico o no sabes qué agente usar, **siempre empieza por este**.

---

## Template de ciclo de desarrollo por proyecto

Para crear el template de flujo de desarrollo personalizado para tu proyecto:

```
@devkit-development-lifecycle-orchestrator necesito configurar el ciclo de desarrollo para este proyecto
```

El agente te hará un formulario con preguntas sobre:
- Stack(s) del proyecto
- Herramientas de calidad disponibles (linters, test runners, cobertura)
- Estrategia de branches y commits
- Requisitos de pruebas (unit, E2E, smoke)
- Reglas de MR/PR del equipo

Y generará en `docs/plan-implementation/` el template de plan de implementación adaptado a tu proyecto.

---

## Estructura del repositorio

```text
copilot-devkit/
├── .github/            # copilot-instructions.md + agentes activos del propio devkit
├── agents/             # Agentes por stack (global, android, ios, multiplatform, backend)
├── skills/             # Skills por stack (misma jerarquía que agents/)
├── prompts/            # Prompts por stack (misma jerarquía que agents/)
├── instructions/       # Instrucciones .instructions.md por stack
├── cli-tools/          # CLI Python: devtools list / scaffold / validate / sync
├── scripts/            # setup.sh (global) y devkit-validate-skill.sh
├── setup-project.sh    # Setup por tecnología para proyectos consumidores
└── docs/               # Governance, backlog y documentación
```

### Inventario de artefactos disponibles

```bash
devtools list                          # todos los artefactos
devtools list --type skill             # solo skills
devtools list --namespace android      # solo namespace android
devtools list --format json            # salida JSON
```

---

## Quick-start para contributors

```bash
# 1. Setup global
./scripts/setup.sh

# 2. Crear una nueva skill
devtools scaffold skill mi-nueva-skill global

# 3. Validar antes de hacer commit
devtools validate skill skills/global/mi-nueva-skill/
```

---

## Governance

| Documento | Propósito |
|---|---|
| [`docs/implementation/constitution.md`](docs/implementation/constitution.md) | Decisiones de diseño, stacks y namespaces |
| [`docs/implementation/epics.md`](docs/implementation/epics.md) | Épicas y roadmap del producto |
| [`docs/implementation/user-stories/backlog-index.md`](docs/implementation/user-stories/backlog-index.md) | Backlog completo con estado de US |
| [`docs/implementation/sync-strategy.md`](docs/implementation/sync-strategy.md) | Estrategia de sync entre repo y consumidores |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | Guía para contributors |

