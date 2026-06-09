---
skills:
  - name: "Kotlin and Android-Specific Patterns"
    description: "Patterns that leverage Kotlin language features and Android architectural constraints"
    category: "Design Patterns"
---

# Kotlin and Android-Specific Patterns

## Core patterns
- Sealed state reducer: finite UI state transitions with exhaustive `when`.
- Repository + Use Case split: isolate data access from business rules.
- Delegation pattern: compose behavior with `by` and focused interfaces.
- DSL builder: readable construction of complex configuration/data objects.
- Unidirectional UI state flow: intent -> reducer -> immutable state -> render.

## Kotlin examples
### Sealed state
```kotlin
sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data class Success(val userId: String) : LoginUiState
    data class Error(val message: String) : LoginUiState
}
```

### Delegation
```kotlin
interface Analytics {
    fun track(event: String)
}

class LoggingAnalytics : Analytics {
    override fun track(event: String) = println("event=$event")
}

class CheckoutService(private val analytics: Analytics) : Analytics by analytics {
    fun completeOrder() {
        track("checkout_complete")
    }
}
```

## Android guidance
- Keep reducers pure and side effects isolated.
- Use repositories as anti-corruption layers for SDK/network/local sources.
- Avoid passing mutable collections across layer boundaries.
- Model one-off UI events separately from persistent state.

## End-to-end Android blueprint

### Intent + reducer + immutable state (UDF)
```kotlin
sealed interface LoginIntent {
    data class EmailChanged(val value: String) : LoginIntent
    data class PasswordChanged(val value: String) : LoginIntent
    data object Submit : LoginIntent
}

data class LoginState(
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val isSuccess: Boolean = false
)

private fun reduce(state: LoginState, intent: LoginIntent): LoginState {
    return when (intent) {
        is LoginIntent.EmailChanged -> state.copy(email = intent.value, error = null)
        is LoginIntent.PasswordChanged -> state.copy(password = intent.value, error = null)
        LoginIntent.Submit -> state.copy(isLoading = true, error = null)
    }
}
```

### Repository + UseCase + ViewModel integration
```kotlin
interface AuthRepository {
    suspend fun login(email: String, password: String): UserSession
}

class LoginUseCase(
    private val repository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): UserSession {
        require(email.isNotBlank())
        require(password.isNotBlank())
        return repository.login(email, password)
    }
}

class LoginViewModel(
    private val loginUseCase: LoginUseCase
) : ViewModel() {

    private val _state = MutableStateFlow(LoginState())
    val state: StateFlow<LoginState> = _state

    fun dispatch(intent: LoginIntent) {
        _state.update { reduce(it, intent) }

        if (intent is LoginIntent.Submit) {
            val snapshot = _state.value
            viewModelScope.launch {
                runCatching { loginUseCase(snapshot.email, snapshot.password) }
                    .onSuccess {
                        _state.update { current ->
                            current.copy(isLoading = false, isSuccess = true)
                        }
                    }
                    .onFailure { throwable ->
                        _state.update { current ->
                            current.copy(
                                isLoading = false,
                                error = throwable.message ?: "Login failed"
                            )
                        }
                    }
            }
        }
    }
}
```

### Compose consumption pattern
```kotlin
@Composable
fun LoginRoute(viewModel: LoginViewModel) {
    val state by viewModel.state.collectAsStateWithLifecycle()

    LoginScreen(
        state = state,
        onEmailChanged = { viewModel.dispatch(LoginIntent.EmailChanged(it)) },
        onPasswordChanged = { viewModel.dispatch(LoginIntent.PasswordChanged(it)) },
        onSubmit = { viewModel.dispatch(LoginIntent.Submit) }
    )
}
```

## Selected references
- PacktPublishing/Kotlin-Design-Patterns-and-Best-Practices: idiomatic Kotlin and modern pattern usage
- dbacinski/Design-Patterns-In-Kotlin: Kotlin-first implementations (including delegation-heavy examples)
- JorgeAgulloM/DesignPatternsKotlin: broad pattern catalog useful for Android adaptation

