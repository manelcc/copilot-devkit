---
skills:
  - name: "Behavioral Design Patterns"
    description: "Kotlin and Android behavioral patterns for component communication and runtime behavior changes"
    category: "Design Patterns"
---

# Behavioral Design Patterns in Kotlin/Android

## Core patterns
- Observer/Listener: publish state changes to one-to-many subscribers.
- Strategy: swap algorithms dynamically at runtime.
- State: model explicit state-dependent behavior.
- Command: encapsulate requests for queueing, retries, or undo.
- Chain of Responsibility: route request through handlers.
- Mediator: centralize communication between feature components.
- Memento: snapshot/restore state for rollback and undo.
- Visitor: add operations over stable object structures.

## Android/Kotlin implementation tips
- Prefer sealed interfaces/classes for finite state machines.
- Use immutable UI state snapshots for screen rendering.
- For observer style, prefer cold/hot Flow based on delivery semantics.
- Keep command objects small and serializable when persistence is needed.

## Real Android examples

### Observer with StateFlow (ViewModel -> Compose)
```kotlin
data class ProfileUiState(
  val isLoading: Boolean = false,
  val name: String = "",
  val error: String? = null
)

class ProfileViewModel(
  private val getProfileUseCase: GetProfileUseCase
) : ViewModel() {

  private val _uiState = MutableStateFlow(ProfileUiState())
  val uiState: StateFlow<ProfileUiState> = _uiState

  fun load() {
    viewModelScope.launch {
      _uiState.update { it.copy(isLoading = true, error = null) }
      runCatching { getProfileUseCase() }
        .onSuccess { profile ->
          _uiState.update { it.copy(isLoading = false, name = profile.name) }
        }
        .onFailure { throwable ->
          _uiState.update {
            it.copy(isLoading = false, error = throwable.message ?: "Unknown error")
          }
        }
    }
  }
}
```

### Strategy for dynamic pricing
```kotlin
interface PricingStrategy {
  fun price(baseCents: Long): Long
}

class NoDiscount : PricingStrategy {
  override fun price(baseCents: Long): Long = baseCents
}

class VipDiscount : PricingStrategy {
  override fun price(baseCents: Long): Long = (baseCents * 0.85).toLong()
}

class CheckoutUseCase(
  private val strategyProvider: (isVip: Boolean) -> PricingStrategy
) {
  operator fun invoke(baseCents: Long, isVip: Boolean): Long {
    val strategy = strategyProvider(isVip)
    return strategy.price(baseCents)
  }
}
```

### Command for retry queue
```kotlin
fun interface SyncCommand {
  suspend fun execute()
}

class RetrySyncQueue {
  private val pending = ArrayDeque<SyncCommand>()

  fun enqueue(command: SyncCommand) {
    pending.addLast(command)
  }

  suspend fun drain() {
    while (pending.isNotEmpty()) {
      pending.removeFirst().execute()
    }
  }
}
```

## Selected references
- dbacinski/Design-Patterns-In-Kotlin: Observer/Listener, Strategy, Command, State, Chain, Mediator, Memento, Visitor examples
- JorgeAgulloM/DesignPatternsKotlin: broad behavioral catalog with Kotlin samples

## Selection matrix
| Problem | Pattern |
|---|---|
| Multiple runtime algorithms | Strategy |
| Complex screen mode transitions | State |
| Retryable user actions | Command |
| Cross-component notifications | Observer/Listener |
| Multi-step processing pipeline | Chain of Responsibility |

