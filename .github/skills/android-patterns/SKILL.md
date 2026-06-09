---
name: android-patterns
description: >
  Guía de patrones de diseño Kotlin para proyectos server-side y KMP. Diagnostica problemas,
  recomienda 2-3 patrones candidatos con trade-offs e implementación idiomática en Kotlin.
applyTo:
  - "**/*.kt"
triggers:
  - "qué patrón uso"
  - "cómo diseño esto"
  - "aplica un patrón"
  - "patrón de diseño"
  - "cómo estructuro este código"
  - "hay un patrón para esto"
  - "refactoriza con un patrón"
nonTriggers:
  - Revisión de calidad de código (usar clean-code-guardian)
  - Definición de capas de arquitectura (usar clean-architecture)
  - Generación de tests (usar unit-testing-kotlin)
---

# Kotlin Patterns

## Goal

Ayudar a seleccionar e implementar patrones de diseño en Kotlin server-side y KMP
con guía práctica, testable y mantenible. Orientado a producción, no solo explicación conceptual.

## Pattern knowledge files

- `references/behavioral-patterns.md`
- `references/creational-patterns.md`
- `references/structural-patterns.md`
- `references/concurrency-patterns.md`
- `references/kotlin-server-patterns.md`

## Scope

Esta skill cubre patrones para:
- **Kotlin server-side** (Ktor, Exposed, Koin)
- **Kotlin Multiplatform** (commonMain, expect/actual)
- **Clean Architecture** en Kotlin (UseCase, Repository, Adapter)
- **Coroutines y Flow** (concurrencia estructurada, pipelines)

No cubre patrones específicos de Android (ViewModel, Compose, Lifecycle).

## Execution flow

1. Diagnosticar el problema concreto del usuario y sus constraints.
2. Recomendar 2-3 patrones candidatos con pros, contras y cuándo NO usarlos.
3. Seleccionar el enfoque y proponer pasos de implementación.
4. Proveer skeleton de código Kotlin idiomático alineado con el stack del proyecto.
5. Incluir estrategia de testing para el patrón elegido.
6. Destacar anti-patrones a evitar.

## Anti-patterns a desaconsejar

- Patrón por el patrón (overengineering)
- Estado mutable global / singleton con estado
- Coroutines no acotadas / sin cancellation safety
- God class con múltiples responsabilidades (violación SRP)
- Side effects ocultos en repositorios o use cases
- Imports entre capas (violación de Clean Architecture)

## Output format

- Diagnóstico del problema
- Patrones candidatos (con pros/cons)
- Opción recomendada y justificación
- Implementation checklist
- Test checklist
- Código Kotlin idiomático alineado con el stack: Ktor + UseCase + Repository + Koin
