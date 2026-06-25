---
name: devkit-android-patterns
description: >
  Skill de patrones de diseño Android/Kotlin para decidir patrón aplicable en
  una implementación, identificar el patrón existente en código y detectar
  antipatrones con acciones de remediación.
triggers:
  - "que patron aplica android"
  - "identifica patron en este codigo kotlin"
  - "esto es antipatron en android"
  - "plan de implementacion con patrones android"
  - "review de patrones kotlin compose"
non_triggers:
  - "pipeline ci"
  - "infraestructura cloud"
  - "ios swiftui"
---

# Android Patterns

## Purpose
Aportar una metodología práctica para seleccionar patrones de diseño en Kotlin/Android, reconocer patrones ya presentes y detectar antipatrones antes de implementar o refactorizar.

## When to use
- Estás planificando una implementación Android y necesitas decidir patrón.
- Quieres auditar una feature para saber qué patrón ya está aplicado.
- Quieres detectar antipatrones de diseño y proponer una ruta de mejora.
- Quieres justificar arquitectura en una review técnica.

## When NOT to use
- Tareas puramente de UI styling sin decisiones de diseño.
- Cambios de infraestructura/CI/CD.
- Código no Kotlin o fuera del dominio Android.

## Inputs
- Objetivo de negocio y constraints técnicos.
- Fragmentos de código relevantes (ViewModel, UseCase, Repository, Composable).
- Requisitos no funcionales: testabilidad, concurrencia, performance, mantenibilidad.
- Contexto de versión (API level, Compose, Hilt, Coroutines).

## Steps
1. Clasificar el problema: creación, estructura, comportamiento, concurrencia o patrón Kotlin/Android-específico.
2. Evaluar 2-3 patrones candidatos con trade-offs y criterio de descarte.
3. Identificar el patrón actualmente aplicado (si existe) y su grado de correcta implementación.
4. Detectar antipatrones asociados y su severidad (CRITICAL/HIGH/MEDIUM/LOW).
5. Verificar evidencia en código del patrón detectado; si no hay evidencia suficiente, marcarlo como hipótesis-no-verificada.
6. Recomendar decisión final: mantener, ajustar o migrar de patrón.
7. Proponer plan de implementación o refactor con pasos verificables.
8. Definir checklist de validación (tests, acoplamiento, extensibilidad, thread-safety).

### Per-file references
- `references/overview.md`
- `references/behavioral-patterns.md`
- `references/creational-patterns.md`
- `references/structural-patterns.md`
- `references/concurrency-patterns.md`
- `references/kotlin-android-patterns.md`
- `references/anti-patterns.md`

### Pattern families covered
- Creacionales: Singleton, Factory Method, Abstract Factory, Builder/DSL, Dependency Injection.
- Estructurales: Adapter, Decorator, Facade, Proxy, Composite.
- Comportamiento: Observer/Listener, Strategy, State, Command, Mediator, Chain of Responsibility.
- Concurrencia: Structured concurrency, producer-consumer, actor-style isolation, flow pipelines.
- Kotlin/Android-específicos: Sealed state reducer, Repository + UseCase, Delegation, DSL builders, UDF Compose.

### Anti-pattern heuristics
- Singleton con estado global mutable.
- God ViewModel con responsabilidades mezcladas.
- Acceso directo a datos desde UI sin Repository.
- Coroutines sin scope ni cancelación controlada.
- Colecciones mutables cruzando límites de capas.
- Side effects en repositorios o use cases.

## Expected outputs
- Diagnóstico de patrón recomendado con razonamiento y trade-offs.
- Identificación del patrón actual en el código (o ausencia de patrón claro).
- Lista priorizada de antipatrones detectados con severidad e impacto.
- Estado de evidencia: verificado o hipótesis-no-verificada (no bloqueante).
- Plan de implementación/refactor en pasos concretos.

## Validation
- [ ] Se identifica la familia de patrón aplicable.
- [ ] Se comparan al menos 2 candidatos cuando hay ambigüedad.
- [ ] Se indica patrón actualmente aplicado (o "ninguno").
- [ ] Se listan antipatrones con severidad y remediación.
- [ ] Si falta evidencia, se marca como hipótesis-no-verificada sin bloquear recomendación.
- [ ] Se entrega checklist de verificación técnica.
- [ ] `references/overview.md` existe con diagrama Mermaid.

## Examples

### Example 1 - Selección de patrón en planning

```text
Input: "Tengo un ViewModel con 400 líneas, mezcla de lógica UI, red y validación"

Salida esperada:
1) Candidatos: Repository + UseCase split, State pattern, Strategy.
2) Decisión: Repository + UseCase + State.
3) Patrón actual detectado: God ViewModel (antipatrón HIGH).
4) Plan:
   - Extraer AuthRepository con interfaz.
   - Crear LoginUseCase que valide y delegue.
   - Modelar LoginUiState como sealed interface.
   - ViewModel solo despacha intents y expone StateFlow.
```

### Example 2 - Detección de antipatrón

```kotlin
object UserSession {
    var token: String = ""
    var userId: Int = -1
}
```

```text
Diagnóstico:
- Patrón detectado: Singleton.
- Antipatrón: estado global mutable sin scope definido.
- Riesgo: CRITICAL (testabilidad, concurrencia).
- Remediación:
  - Crear SessionRepository con interfaz.
  - Inyectar como dependencia via Hilt.
  - Estado interno inmutable expuesto como Flow.
```

## Sources
- Source origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-patterns/
- Android official docs: https://developer.android.com/topic/architecture
- Kotlin official docs: https://kotlinlang.org/docs/home.html
