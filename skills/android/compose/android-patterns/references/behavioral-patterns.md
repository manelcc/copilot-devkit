# Behavioral Patterns (Reference - Android/Kotlin)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-patterns/BEHAVIORAL-PATTERNS.md

## Core patterns
- **Observer/Listener**: notificacion uno-a-muchos. En Android: StateFlow, SharedFlow, LiveData.
- **Strategy**: intercambio de algoritmos en runtime. En Kotlin: interfaces funcionales.
- **State**: comportamiento dependiente del estado. En Android: sealed interface + exhaustive when.
- **Command**: encapsular acciones. Util para undo/redo y colas de operaciones.
- **Mediator**: reducir dependencias cruzadas entre componentes.
- **Chain of Responsibility**: cadena de handlers. Util para middleware, interceptors.

## Selection cues
- Multiples observers de datos: StateFlow/SharedFlow (Observer).
- Reglas de negocio intercambiables: Strategy.
- Flujo de pantalla con estados definidos: sealed interface State.
- Acciones reversibles o en cola: Command.

## Anti-pattern watch
- Observer sin cancelación de suscripción (leaks de coroutine scope).
- State sin transitions explícitas.
- Strategy con demasiadas clases para casos triviales.

## Android idioms
- Prefer `Flow` sobre callbacks para comunicación asíncrona.
- `collectAsStateWithLifecycle` para observar en Compose con lifecycle-awareness.
