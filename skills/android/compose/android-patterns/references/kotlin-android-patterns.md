# Kotlin and Android-Specific Patterns (Reference)

Source lineage:
- /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-patterns/KOTLIN-ANDROID-PATTERNS.md

## Core patterns
- **Sealed state reducer**: transiciones finitas de estado UI con `when` exhaustivo.
- **Repository + UseCase split**: aislar acceso a datos de reglas de negocio.
- **Delegation pattern**: componer comportamiento con `by` e interfaces focalizadas.
- **DSL builder**: construcción legible de objetos complejos de configuración/datos.
- **Unidirectional UI state flow**: intent → reducer → estado inmutable → render.

## Sealed state example
```kotlin
sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data class Success(val userId: String) : LoginUiState
    data class Error(val message: String) : LoginUiState
}
```

## Delegation example
```kotlin
interface Analytics { fun track(event: String) }
class LoggingAnalytics : Analytics {
    override fun track(event: String) = println("event=$event")
}
class CheckoutService(private val analytics: Analytics) : Analytics by analytics {
    fun completeOrder() { track("checkout_complete") }
}
```

## UDF blueprint (Intent → Reducer → StateFlow → Compose)
```kotlin
sealed interface LoginIntent {
    data class EmailChanged(val value: String) : LoginIntent
    data object Submit : LoginIntent
}
data class LoginState(val email: String = "", val isLoading: Boolean = false, val error: String? = null)

class LoginViewModel(private val loginUseCase: LoginUseCase) : ViewModel() {
    private val _state = MutableStateFlow(LoginState())
    val state: StateFlow<LoginState> = _state

    fun dispatch(intent: LoginIntent) {
        _state.update { reduce(it, intent) }
        if (intent is LoginIntent.Submit) {
            viewModelScope.launch {
                runCatching { loginUseCase(_state.value.email) }
                    .onSuccess { _state.update { it.copy(isLoading = false) } }
                    .onFailure { e -> _state.update { it.copy(error = e.message) } }
            }
        }
    }
}
```

## Android guidance
- Mantener reducers puros y side effects aislados.
- Usar repositorios como anti-corruption layers para SDK/red/local.
- No pasar colecciones mutables entre capas.
- Modelar eventos one-off de UI separados del estado persistente.

## Selection cues
- Estado UI complejo con transiciones definidas → Sealed state reducer.
- Lógica mezclada en ViewModel → Repository + UseCase split.
- Comportamiento composable sin herencia → Delegation.
- API de construcción fluida → DSL builder.
