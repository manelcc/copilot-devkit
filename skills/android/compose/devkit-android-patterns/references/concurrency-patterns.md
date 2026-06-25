# Concurrency Patterns (Reference - Android/Kotlin)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-patterns/CONCURRENCY-PATTERNS.md

## Core patterns
- **Structured concurrency**: todos los coroutines tienen scope y cancelación definida.
- **Producer-Consumer**: Flow como productor, collector como consumidor.
- **Actor-style state isolation**: Mutex o Channel para estado mutable compartido.
- **Flow pipelines**: transformación con operators (map, filter, combine, debounce).

## Android idioms
```kotlin
// Structured cancellation
viewModelScope.launch {
    val result = withContext(Dispatchers.IO) { repository.fetch() }
    _state.update { it.copy(data = result) }
}

// Flow pipeline
repository.dataFlow
    .map { it.toDomainModel() }
    .catch { e -> _state.update { it.copy(error = e.message) } }
    .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
```

## Anti-pattern watch
- `GlobalScope` sin lifecycle: CRITICAL (leaks).
- `runBlocking` en main thread: CRITICAL (ANR).
- Coroutines lanzadas sin scope ni job padre.
- Mutaciones de UI fuera de `Dispatchers.Main`.

## Notes
- Prefer `StateFlow` + `stateIn` sobre LiveData en nuevos proyectos.
- `SharingStarted.WhileSubscribed(5000)` para flows de UI con timeout de 5s.
