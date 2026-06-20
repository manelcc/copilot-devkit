---
name: ios-patterns
description: >
  Skill de patrones de diseño iOS/Swift para decidir patrón aplicable en una
  implementación, identificar el patrón existente en código y detectar
  antipatrones con acciones de remediación. Incluye SwiftUI como subtipo
  operativo dentro de la misma skill.
triggers:
  - "que patron aplica"
  - "identifica patron en este codigo swift"
  - "esto es antipatron swiftui"
  - "swiftui state patterns"
  - "navigationstack swiftui"
  - "plan de implementacion con patrones"
  - "review de patrones ios"
non_triggers:
  - "pipeline ci"
  - "infraestructura cloud"
  - "android compose"
---

# iOS Patterns

## Purpose
Aportar una metodología práctica para seleccionar patrones de diseño en Swift/SwiftUI, reconocer patrones ya presentes y detectar antipatrones antes de implementar o refactorizar.

## When to use
- Estás planificando una implementación iOS y necesitas decidir patrón.
- Quieres auditar una feature para saber qué patrón ya está aplicado.
- Quieres detectar antipatrones de diseño y proponer una ruta de mejora.
- Quieres justificar arquitectura en una review técnica.

## When NOT to use
- Tareas puramente de UI styling sin decisiones de diseño.
- Cambios de infraestructura/CI/CD.
- Código no Swift o fuera del dominio iOS.

## Inputs
- Objetivo de negocio y constraints técnicos.
- Fragmentos de código relevantes (View, ViewModel, servicios, navegación).
- Requisitos no funcionales: testabilidad, concurrencia, performance, mantenibilidad.
- Contexto de versión (Swift/SwiftUI/iOS target).

## Steps
1. Clasificar el problema: creación, estructura, comportamiento, concurrencia o patrón Swift-específico.
2. Evaluar 2-3 patrones candidatos con trade-offs y criterio de descarte.
3. Identificar el patrón actualmente aplicado (si existe) y su grado de correcta implementación.
4. Detectar antipatrones asociados y su severidad (CRITICAL/HIGH/MEDIUM/LOW).
5. Verificar evidencia en código del patrón detectado; si no hay evidencia suficiente, marcarlo como "hipótesis-no-verificada".
6. Recomendar decisión final: mantener, ajustar o migrar de patrón.
7. Proponer plan de implementación o refactor con pasos verificables.
8. Definir checklist de validación (tests, acoplamiento, extensibilidad, thread-safety).

### Per-file references
- `references/source-readme-map.md`
- `references/behavioral-patterns.md`
- `references/creational-patterns.md`
- `references/structural-patterns.md`
- `references/concurrency-patterns.md`
- `references/swift-patterns.md`
- `references/anti-patterns.md`

### Pattern families covered
- Creacionales: Singleton, Factory Method, Abstract Factory, Builder, Prototype, Lazy Initialization, Dependency Injection.
- Estructurales: Adapter, Decorator, Facade, Proxy, Delegate, Type Erasure, Coordinator.
- Comportamiento: Observer, Strategy, State, Command, Mediator, Iterator, Chain of Responsibility.
- Concurrencia: Actor model, Barrier, Read-Write Lock, Balking, async/await orchestration.
- Swift-específicos: Identifier/Phantom Types, Property Wrappers, Result Builders, Opaque Types, Value Binding.
- Subtipos SwiftUI (dentro de iOS patterns): ownership de estado (`@State`, `@Binding`, `@ObservableObject`/`@Observable`), navegación tipada con `NavigationStack`, lifecycle async con `.task {}`, estrategia de listas (`List` vs `LazyVStack`).

### Anti-pattern heuristics
- Singleton abuse con estado global mutable.
- Massive View / Massive ViewModel sin límites de responsabilidad.
- Navegación acoplada a vistas sin Coordinator o routing claro.
- Concurrencia no aislada en main actor para mutaciones UI.
- Callback hell o mezcla inconsistente de async/await y callbacks.
- Uso indiscriminado de Any/Type Erasure sin necesidad.

## Expected outputs
- Diagnóstico de patrón recomendado con razonamiento y trade-offs.
- Identificación del patrón actual en el código (o ausencia de patrón claro).
- Lista priorizada de antipatrones detectados con severidad e impacto.
- Estado de evidencia: verificado o hipótesis-no-verificada (no bloqueante).
- Plan de implementación/refactor en pasos concretos.

## Validation
- [ ] Se identifica explícitamente la familia de patrón aplicable.
- [ ] Se comparan al menos 2 candidatos cuando hay ambigüedad.
- [ ] Se indica patrón actualmente aplicado (o "ninguno").
- [ ] Se listan antipatrones con severidad y remediación.
- [ ] Si falta evidencia de patrón aplicado, se marca como hipótesis-no-verificada sin bloquear recomendación.
- [ ] Se entrega checklist de verificación técnica.
- [ ] `references/overview.md` existe con diagrama Mermaid.

## Examples

### Example 1 - Selección de patrón en planning

```text
Input: "Necesito un flujo de onboarding con 6 pantallas, deep links y pasos opcionales"

Salida esperada:
1) Candidatos: Coordinator, State, Strategy.
2) Decisión: Coordinator + State.
3) Patrón actual detectado: navegación embebida en View (antipatrón: acoplamiento alto).
4) Plan:
   - Crear OnboardingCoordinator con rutas tipadas.
   - Modelar estado del flujo en enum de estados.
   - Extraer lógica condicional de vistas a Strategy para pasos opcionales.
```

### Example 2 - Detección de antipatrón en implementación

```swift
final class SessionManager {
    static let shared = SessionManager()
    var token: String = ""
    var user: User?
    private init() {}
}
```

```text
Diagnóstico:
- Patrón detectado: Singleton.
- Antipatrón: singleton con estado global mutable y dependencia implícita.
- Riesgo: alto (testabilidad y acoplamiento).
- Remediación:
  - Extraer protocolo SessionStoring.
  - Inyectar dependencia por constructor.
  - Limitar mutabilidad y scope del estado.
```

## Sources
- Bankinter source knowledge: /Users/manelcc/Documents/BANKINTER/apps-ios/appmovil-nbo-ios/.github/skills/ios-patterns
- Apple Swift documentation: https://developer.apple.com/documentation/swift
- Apple SwiftUI documentation: https://developer.apple.com/documentation/swiftui
- Apple Concurrency documentation: https://developer.apple.com/documentation/swift/concurrency
