# copilot-devkit

Repositorio centralizado de agentes, skills, prompts e instrucciones reutilizables para GitHub Copilot en proyectos multi-stack. Los equipos lo consumen via CLI sin duplicar ni mantener copias locales.

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

## Estructura del repositorio

```text
copilot-devkit/
├── .github/            # copilot-instructions.md + agentes activos
├── agents/             # Agentes por stack (global, android, ios, multiplatform, backend)
├── skills/             # Skills por stack (misma jerarquía que agents/)
├── prompts/            # Prompts por stack (misma jerarquía que agents/)
├── instructions/       # Instrucciones .instructions.md por stack
├── cli-tools/          # CLI Python: devtools scaffold / validate / sync
├── scripts/            # Scripts de validación y setup
└── docs/               # Governance, backlog y documentación
```

## Quick-start para proyectos consumidores

```bash
pip install -e cli-tools/
devtools sync --manifest devtools.manifest.json
```

## Quick-start para contributors

```bash
./scripts/setup.sh
devtools scaffold skill mi-skill global
```

## Governance

- Decisiones de diseño: [`docs/implementation/constitution.md`](docs/implementation/constitution.md)
- Épicas y roadmap: [`docs/implementation/epics.md`](docs/implementation/epics.md)
- Backlog: [`docs/implementation/user-stories/backlog-index.md`](docs/implementation/user-stories/backlog-index.md)
- Estrategia de sync: [`docs/implementation/sync-strategy.md`](docs/implementation/sync-strategy.md)
