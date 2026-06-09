---
skills:
  - name: "Concurrency Design Patterns"
    description: "Kotlin and Android concurrency patterns for safe parallelism and cancellation-aware flows"
    category: "Design Patterns"
---

# Concurrency Design Patterns in Kotlin/Android

## Core patterns
- Structured concurrency: hierarchy-bound coroutine lifetimes.
- Producer-consumer: channels/queues between producers and workers.
- Actor-style state isolation: single-writer mutable state.
- Flow pipelines: declarative stream transformation and backpressure handling.
- Retry/circuit boundaries: resilient access to flaky dependencies.

## Kotlin/Android specifics
- Tie coroutine scopes to lifecycle owners to prevent leaks.
- Propagate cancellation and avoid orphan jobs.
- Use `StateFlow` for state and `SharedFlow` for events where replay semantics are explicit.
- Keep blocking work off Main; use clear dispatcher boundaries.

## Real Android examples

### Structured concurrency in ViewModel
```kotlin
class DashboardViewModel(
  private val getProfile: GetProfileUseCase,
  private val getNotifications: GetNotificationsUseCase
) : ViewModel() {

  private val _state = MutableStateFlow(DashboardUiState())
  val state: StateFlow<DashboardUiState> = _state

  fun refresh() {
    viewModelScope.launch {
      _state.update { it.copy(isLoading = true) }

      val profileDeferred = async { getProfile() }
      val notificationsDeferred = async { getNotifications() }

      val profile = profileDeferred.await()
      val notifications = notificationsDeferred.await()

      _state.update {
        it.copy(
          isLoading = false,
          profileName = profile.name,
          unreadCount = notifications.unreadCount
        )
      }
    }
  }
}
```

### Producer-consumer with Channel
```kotlin
class SyncDispatcher(
  private val syncUseCase: SyncUseCase
) {
  private val queue = Channel<SyncRequest>(capacity = Channel.BUFFERED)

  fun start(scope: CoroutineScope): Job {
    return scope.launch {
      for (request in queue) {
        syncUseCase(request)
      }
    }
  }

  suspend fun enqueue(request: SyncRequest) {
    queue.send(request)
  }
}
```

### Lifecycle-aware Flow collection in Compose
```kotlin
@Composable
fun DashboardScreen(viewModel: DashboardViewModel) {
  val state by viewModel.state.collectAsStateWithLifecycle()

  if (state.isLoading) {
    CircularProgressIndicator()
  } else {
    Text(text = "Hello ${state.profileName}")
  }
}
```

## Selected references
- PacktPublishing/Kotlin-Design-Patterns-and-Best-Practices: reactive and concurrent design guidance
- dbacinski/Design-Patterns-In-Kotlin: composable Kotlin implementations used as baseline examples

## Selection matrix
| Problem | Pattern |
|---|---|
| Concurrent tasks with parent-child ownership | Structured concurrency |
| Background processing pipeline | Producer-consumer |
| Shared mutable state races | Actor-style isolation |
| Async transformation and fan-out | Flow pipelines |
| Unreliable external dependency | Retry/circuit boundary |

