# DevTools-AI Constitution

> Documento rector del repositorio centralizado de agentes, skills y prompts  
> para stacks mobile, multiplatform y backend.

---

## I. Propósito

Este repositorio es la **fuente única de verdad** para todos los artefactos de automatización IA (agentes, skills, prompts, instrucciones) reutilizables en proyectos de la organización.  
Cualquier proyecto consumidor importa desde aquí — nunca duplica ni mantiene su propia copia.

---

## II. Principios Fundamentales

### 1. Un artefacto, un trabajo
Cada skill, agente o prompt tiene exactamente **una responsabilidad**. Si hace dos cosas, se divide.

### 2. Namespace por stack
La estructura de directorios refleja el stack tecnológico:

```
agents/ skills/ prompts/
├── global/           # Cross-stack (git, clean-code, MR, feature-lifecycle)
├── android/
│   ├── compose/      # Kotlin + Jetpack Compose
│   ├── legacy/       # XML Views + Java
│   └── kmp/          # Kotlin Multiplatform (capa compartida)
├── ios/
│   ├── swiftui/      # Swift + SwiftUI
│   └── uikit/        # Swift + UIKit (legacy)
├── multiplatform/
│   ├── kmp/          # Kotlin Multiplatform (lógica de negocio)
│   └── cmp/          # Compose Multiplatform (UI compartida)
└── backend/
    ├── kotlin-ktor/  # Ktor + Coroutines
    ├── python/       # Python (FastAPI, scripts)
    └── spring-java/  # Spring Boot + Java
```

### 3. Composición sobre duplicación
Los proyectos consumidores **referencian** artefactos mediante `sync_skills`. Nunca copian y pegan.  
Si un artefacto necesita customización, se crea una variante en el namespace del proyecto.

### 4. Documentación obligatoria
Toda skill incluye:
- `SKILL.md` con frontmatter, triggers, ejemplos y validación
- `references/overview.md` con diagrama Mermaid del workflow

### 5. Calidad verificable
- Todo agente tiene criterios de activación y no-activación explícitos
- Los scripts tienen manejo de errores y comentarios
- Cada US tiene criterios de aceptación medibles

### 6. Retrocompatibilidad
- Los cambios breaking se marcan con versión semántica
- Las skills deprecadas se marcan `deprecated: true` y apuntan al reemplazo
- El `sync_skills` CLI reporta incompatibilidades antes de sincronizar

---

## III. Stacks de Referencia

| Stack | Lenguaje principal | Frameworks clave |
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

## IV. Repos de Referencia

Estos proyectos son la fuente de artefactos iniciales y ejemplos validados:

| Proyecto | Ruta local | Stack cubierto |
|---|---|---|
| `mycardiochef/middleware` | `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/mycardiochef/middleware/.github/` | Backend Kotlin/Ktor, global |
| `bankinter-devtools` | `/Users/manelcc/Documents/BANKINTER/bankinter-devtools/` | Android, iOS, global, CLI tools |

---

## V. Governance

- Este documento supersede cualquier convención local de proyecto
- Cualquier enmienda requiere: descripción del cambio, impacto en consumidores, plan de migración
- Todas las PRs deben verificar cumplimiento de esta constitución
- El agente `project-orchestrator` es el guardián operativo de estas reglas

**Version**: 1.0.0 | **Ratified**: 2026-06-06 | **Last Amended**: 2026-06-06
