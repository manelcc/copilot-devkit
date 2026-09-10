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

Desde la **raíz del proyecto** que va a usar el devkit, ejecuta el setup de tecnología.

#### GitHub Copilot (VS Code)

Crea symlinks en `.github/` con los artefactos del stack.

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

# Backend Kotlin/Ktor
bash $COPILOT_DEVKIT_HOME/setup-project.sh --kotlin

# Solo DevOps global (skills + orquestador)
bash $COPILOT_DEVKIT_HOME/setup-project.sh --devops

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

> Las skills globales (clean-code, git-workflow, devops, etc.) ya están en `~/.copilot/skills/`
> y no necesitan enlazarse por proyecto.
>
> Si ejecutas `--python` o `--kotlin`, `setup-project.sh` también enlaza automáticamente
> el bloque DevOps global en `.github/` para mejorar descubribilidad dentro del proyecto.

#### Gemini (Android Studio)

Añade `--gemini` a cualquier comando anterior. Crea la estructura nativa de Android Studio:

```bash
# Android + Gemini
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android --gemini

# Android + KMP + Gemini
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android --kmp --gemini
```

Resultado adicional en el proyecto:
```
.agents/
└── skills/        ← skills en estructura plana (.agents/skills/<name>/SKILL.md)
AGENTS.md          ← instrucciones y definición de agentes cargadas en cada prompt
```

| Artefacto | Gemini | Cómo usarlo |
|---|---|---|
| Skills | `.agents/skills/` | `@skill-name` en el chat del Modo Agente |
| Instructions | `AGENTS.md` | Se carga automáticamente en cada prompt |
| Agents | `AGENTS.md` | Importado vía `@./` desde `.github/agents/` |
| Prompts | Prompt Library (UI) | Gestión manual desde Android Studio |

> `--gemini` puede combinarse con cualquier tech flag y es compatible con el setup
> de Copilot. Los mismos ficheros sirven para ambos IDEs sin duplicar nada.

#### Usar ambos IDEs en el mismo proyecto

```bash
bash $COPILOT_DEVKIT_HOME/setup-project.sh --android --gemini
```

Un solo comando configura tanto Copilot como Gemini simultáneamente.

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

## Actualizar un proyecto consumidor con los últimos cambios del devkit

Los proyectos consumen el devkit via **symlinks**, lo que significa que el contenido de las skills y agentes existentes se actualiza automáticamente. Solo hay que actuar cuando el devkit añade artefactos **nuevos**.

### Artefactos existentes (ya enlazados)

No requieren ninguna acción. Al leer un fichero a través del symlink, Copilot siempre lee la versión actual del devkit.

### Artefactos nuevos (añadidos al devkit)

Re-ejecuta el setup de tecnología del proyecto para crear los nuevos symlinks:

```bash
cd /ruta/al/proyecto-x
bash $COPILOT_DEVKIT_HOME/setup-project.sh --python   # o el stack del proyecto
```

El script detecta qué symlinks ya existen y solo crea los que faltan — nunca sobreescribe.

---

## Promover una skill de proyecto al devkit

Cuando en la Fase J del ciclo de desarrollo creas una skill en un proyecto X y quieres que sea reutilizable por otros proyectos del mismo stack, usa `devtools promote`.

### Flujo completo

```
Proyecto X (.github/skills/devkit-mi-feature/)
         ↓  devtools promote devkit-mi-feature --tech python
Devkit (skills/backend/python/devkit-mi-feature/)   ← fuente de verdad
         ↑ symlink automático desde proyecto X        ← el proyecto sigue usándola
         ↑ symlink en ~/.copilot/skills/              ← VS Code la carga globalmente
```

### Uso

```bash
# Desde el proyecto X, promover al stack de tecnología detectado
devtools promote devkit-auth-retry --tech python

# Promover como artefacto global (independiente de stack)
devtools promote devkit-ci-conventions --tech global

# Ver qué haría sin ejecutar nada
devtools promote devkit-auth-retry --tech python --dry-run

# Desde otra ruta
devtools promote devkit-auth-retry --tech kotlin --project ../mi-proyecto-kotlin
```

### Namespaces de tecnología disponibles

| Flag `--tech` | Destino en devkit |
|---|---|
| `python` | `skills/backend/python/` |
| `kotlin` / `kotlin-ktor` | `skills/backend/kotlin-ktor/` |
| `spring` / `spring-java` | `skills/backend/spring-java/` |
| `android` / `android-compose` | `skills/android/compose/` |
| `android-legacy` | `skills/android/legacy/` |
| `ios` / `ios-swiftui` | `skills/ios/swiftui/` |
| `ios-uikit` | `skills/ios/uikit/` |
| `kmp` | `skills/multiplatform/kmp/` |
| `cmp` | `skills/multiplatform/cmp/` |
| `global` | `skills/global/` |

Tras la promoción, la skill queda disponible para cualquier proyecto del mismo stack al re-ejecutar `setup-project.sh`.

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

