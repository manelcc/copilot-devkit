---
name: "cmp-ui-patterns"
description: "Compose Multiplatform UI design patterns: state management (MVI/MVVM), type-safe navigation, theming strategies, and performance optimization for Android & iOS"
triggers:
  - "how to structure state in Compose Multiplatform"
  - "set up type-safe navigation in CMP"
  - "design shared theming for Android and iOS"
  - "CMP performance optimization"
  - "manage Compose UI state across platforms"
  - "handle platform-specific UI in CMP"
  - "memory leaks in Compose Multiplatform"
non_triggers:
  - "debug a specific Compose crash" (use debugger)
  - "design KMP business logic" (use kmp-shared-module-patterns)
  - "format Compose code" (use linter)
  - "test UI components" (use testing skill)
---

# CMP UI Patterns

## Purpose

This skill provides battle-tested patterns for designing and implementing **Compose Multiplatform user interfaces**. It bridges the shared KMP business logic with platform-specific UI requirements, offering guidance on state management, navigation, theming, and performance optimization for both Android and iOS.

## When to use

- Designing UI state architecture for a CMP screen
- Setting up type-safe navigation that compiles for both Android and iOS
- Implementing shared theming (colors, typography) across platforms
- Troubleshooting memory leaks or performance issues in CMP
- Handling platform-specific UI requirements (system bars, keyboard, gestures)
- Reviewing CMP UI code for best practices
- Optimizing recomposition and LazyList performance

**Trigger scenarios:**
- "How do I manage UI state in Compose Multiplatform without creating circular deps?"
- "I need type-safe navigation that works on Android and iOS"
- "What's the best way to implement theming for Light/Dark mode across CMP?"
- "My CMP app is lagging on scrolling—how do I optimize?"

## When NOT to use

- Designing KMP shared logic → use kmp-shared-module-patterns skill
- Debugging a specific Compose crash → use debugger
- Code style or formatting issues → use linter/formatter
- Unit testing UI → use testing skill
- Android-only Compose UI → use android-compose-expert

## Inputs

**Required context:**
- Current UI state management approach (if any): ViewModel, MVI, Redux?
- Target platforms: Android + iOS via CMP, or Android only?
- Navigation complexity: Simple linear, nested, multi-stack?
- Theming requirements: Light/Dark, brand-specific colors, typography?

**Optional context:**
- Performance concerns: Recomposition issues, LazyList slowness, memory pressure?
- Platform-specific UI needs: System bar handling, keyboard, gestures?
- Existing code snippet (if reviewing)

## Steps

### 1. Validate Scope

Check if the request is truly about CMP UI:
- ✅ "How do I manage state in a CMP screen?"
- ✅ "Set up type-safe navigation for CMP"
- ✅ "Optimize recomposition in CMP"
- ❌ "How do I design the domain layer?" → KMP skill
- ❌ "Why is my Compose button not clickable?" → Debugger

### 2. Detect UI Pattern Category

Identify which UI pattern applies:

| Pattern | Scope | Use Case |
|---------|-------|----------|
| **State Management** | Local screen state, reactive updates | Login screen, list filter, form |
| **Navigation** | Route between screens type-safely | Stack nav, bottom tabs, deep links |
| **Theming** | Colors, typography, system bars | Light/Dark mode, branding |
| **Performance** | Recomposition, LazyList, memory | Scrolling laggy, memory growing |
| **Platform UI** | System bars, keyboard, gestures | Safe areas, IME insets, haptics |

### 3. Recommend Pattern

Based on category and use case:

#### State Management Patterns

**Local Screen State (MVI-inspired, no ViewModel)**
```kotlin
// shared/presentation/screens/LoginScreen.kt
data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val isSuccess: Boolean = false
)

sealed class LoginAction {
    data class UpdateEmail(val email: String) : LoginAction()
    data class UpdatePassword(val password: String) : LoginAction()
    object Submit : LoginAction()
    object ClearError : LoginAction()
}

fun loginReducer(state: LoginUiState, action: LoginAction): LoginUiState = when (action) {
    is LoginAction.UpdateEmail -> state.copy(email = action.email, error = null)
    is LoginAction.UpdatePassword -> state.copy(password = action.password, error = null)
    LoginAction.Submit -> state.copy(isLoading = true)
    LoginAction.ClearError -> state.copy(error = null)
}

@Composable
fun LoginScreen(interactor: UserInteractor) {
    var uiState by remember { mutableStateOf(LoginUiState()) }
    
    Column {
        TextField(
            value = uiState.email,
            onValueChange = { uiState = loginReducer(uiState, LoginAction.UpdateEmail(it)) }
        )
        Button(
            onClick = { 
                uiState = loginReducer(uiState, LoginAction.Submit)
                LaunchedEffect(Unit) {
                    try {
                        interactor.login(uiState.email, uiState.password)
                        uiState = uiState.copy(isSuccess = true)
                    } catch (e: Exception) {
                        uiState = uiState.copy(error = e.message, isLoading = false)
                    }
                }
            }
        ) { Text("Login") }
    }
}
```

**Shared ViewModel Pattern (Platform-specific Wrapper)**
```kotlin
// commonMain: Expose state for platform to consume
class UserInteractor(private val repo: UserRepository) {
    fun observeUserState(): Flow<UserState> = repo.observeUser()
}

// androidMain: Android ViewModel wraps interactor
class UserViewModel(private val interactor: UserInteractor) : ViewModel() {
    val uiState: StateFlow<UserState> = interactor.observeUserState()
        .stateIn(viewModelScope, SharingStarted.Lazily, UserState.Loading)
    
    fun onAction(action: UserAction) {
        // ViewModel-specific logic
    }
}

// CMP screen: Consume platform ViewModel or shared Flow
@Composable
fun UserScreen(interactor: UserInteractor) {
    val uiState by interactor.observeUserState().collectAsState()
    
    when (uiState) {
        UserState.Loading -> CircularProgressIndicator()
        is UserState.Success -> UserContent(uiState.user)
        is UserState.Error -> ErrorMessage(uiState.error)
    }
}
```

#### Navigation Patterns

**Type-Safe Navigation (Sealed Class Routing)**
```kotlin
// shared/navigation/Destination.kt
sealed class Destination {
    data object LoginScreen : Destination()
    data class UserDetailScreen(val userId: String) : Destination()
    data object HomeScreen : Destination()
    data object ProfileScreen : Destination()
}

// shared/navigation/NavController.kt (Interactor-like for navigation)
class NavController {
    private val _currentDestination = MutableStateFlow<Destination>(Destination.LoginScreen)
    val currentDestination = _currentDestination.asStateFlow()
    
    fun navigate(destination: Destination) {
        _currentDestination.value = destination
    }
    
    fun back() {
        // Handle back navigation
    }
}

// CMP App Screen
@Composable
fun AppNavigation(navController: NavController) {
    val currentDest by navController.currentDestination.collectAsState()
    
    when (currentDest) {
        Destination.LoginScreen -> LoginScreen(onLoginSuccess = {
            navController.navigate(Destination.HomeScreen)
        })
        Destination.HomeScreen -> HomeScreen(onNavigate = { dest ->
            navController.navigate(dest)
        })
        is Destination.UserDetailScreen -> UserDetailScreen(
            userId = currentDest.userId,
            onBack = { navController.back() }
        )
        Destination.ProfileScreen -> ProfileScreen()
    }
}
```

#### Theming Patterns

**Multiplatform Theme (No Platform-Specific Code in commonMain)**
```kotlin
// shared/ui/theme/Colors.kt
data class Colors(
    val primary: Color,
    val secondary: Color,
    val background: Color,
    val surface: Color,
    val onSurface: Color,
    val error: Color
)

val lightColors = Colors(
    primary = Color(0xFF6200EE),
    secondary = Color(0xFF03DAC6),
    background = Color.White,
    surface = Color.White,
    onSurface = Color.Black,
    error = Color(0xFFB00020)
)

val darkColors = Colors(
    primary = Color(0xFFBB86FC),
    secondary = Color(0xFF03DAC6),
    background = Color(0xFF121212),
    surface = Color(0xFF1E1E1E),
    onSurface = Color.White,
    error = Color(0xFFCF6679)
)

// shared/ui/theme/Theme.kt
data class Theme(
    val colors: Colors,
    val typography: Typography,
    val shapes: Shapes
)

val LocalTheme = compositionLocalOf<Theme> { error("No theme provided") }

@Composable
fun AppTheme(isDarkMode: Boolean = false, content: @Composable () -> Unit) {
    val theme = Theme(
        colors = if (isDarkMode) darkColors else lightColors,
        typography = Typography(),
        shapes = Shapes()
    )
    
    CompositionLocalProvider(LocalTheme provides theme) {
        content()
    }
}

// Usage
@Composable
fun MyButton(text: String, onClick: () -> Unit) {
    val theme = LocalTheme.current
    Button(
        onClick = onClick,
        colors = ButtonDefaults.buttonColors(
            containerColor = theme.colors.primary,
            contentColor = theme.colors.onSurface
        )
    ) {
        Text(text, style = theme.typography.labelMedium)
    }
}
```

#### Performance Patterns

**Efficient List Rendering (Avoid Recomposition)**
```kotlin
@Composable
fun UserList(users: List<User>, onUserClick: (User) -> Unit) {
    LazyColumn {
        items(users, key = { it.id }) { user ->  // Key prevents recomposition
            UserItem(
                user = user,
                onClick = { onUserClick(user) }
            )
        }
    }
}

@Composable
fun UserItem(user: User, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(16.dp)
    ) {
        Text(user.name)
        Text(user.email)
    }
}
```

**Memoization (Skip Recomposition)**
```kotlin
@Composable
fun ExpensiveComposable(data: List<String>) {
    // Remember prevents recomposition if data hasn't changed
    val transformedData = remember(data) {
        data.map { it.uppercase() }
    }
    
    Text(transformedData.joinToString())
}
```

### 4. Detect Platform-Specific Needs

Check for Android/iOS differences:

| Concern | Android | iOS |
|---------|---------|-----|
| **System Bars** | Status bar, navigation bar | Safe areas, notches |
| **Keyboard** | IME insets, soft keyboard | Keyboard avoidance |
| **Gestures** | Back button, swipe | Swipe back, tap |
| **Haptics** | Vibration | Haptic feedback |

### 5. Validate Performance

Check for common performance issues:
- [ ] LazyList using `key { }` to prevent recompositions
- [ ] Heavy computations memoized with `remember()`
- [ ] State lifts correctly (no over-wide scopes)
- [ ] No memory leaks (proper cleanup in DisposableEffect)
- [ ] Recomposition scope is narrow

### 6. Generate Implementation Plan

Output a prioritized roadmap:
1. Define UI state (MVI reducer or ViewModel wrapper)
2. Implement navigation type-safely
3. Set up theming (Colors, Typography, CompositionLocal)
4. Handle platform-specific UI (system bars, keyboard)
5. Optimize performance (LazyList keys, memoization)
6. Test on both Android and iOS

## Expected outputs

**Primary output:** Architecture recommendation with code examples for the identified UI pattern

**Secondary outputs:**
- State management design (reducer or ViewModel pattern)
- Navigation type-safe blueprint
- Theming strategy
- Performance checklist

**Completion signal:**
"✅ CMP UI pattern guidance complete. Your [pattern] should follow [recommended approach]. See code examples and validation checklist above."

## Validation

- Does the state management avoid platform-specific code in commonMain? ✓
- Is navigation type-safe and testable? ✓
- Is theming abstracted for Light/Dark mode? ✓
- Are there no circular dependencies between UI and business logic? ✓
- Is performance optimized (LazyList keys, memoization)? ✓
- Does the pattern work on both Android and iOS? ✓

## Examples

### Example 1: Simple Screen with Local State

```kotlin
@Composable
fun CounterScreen() {
    var count by remember { mutableStateOf(0) }
    
    Column {
        Text("Count: $count")
        Button(onClick = { count++ }) { Text("Increment") }
    }
}
```

### Example 2: Screen with Type-Safe Navigation

```kotlin
@Composable
fun HomeScreen(onNavigate: (Destination) -> Unit) {
    Button(onClick = { onNavigate(Destination.UserDetailScreen("123")) }) {
        Text("Go to User Details")
    }
}
```

### Example 3: Theme-Aware Component

```kotlin
@Composable
fun Card(content: @Composable () -> Unit) {
    val theme = LocalTheme.current
    Surface(
        color = theme.colors.surface,
        shape = RoundedCornerShape(8.dp)
    ) {
        content()
    }
}
```

## Related Skills & Agents

- **Skill:** `kmp-shared-module-patterns` — KMP business logic and data access patterns
- **Agent:** `devkit-cmp-expert` — Guided CMP architecture decisions
- **Agent:** `android-compose-expert` — Android-specific Compose details
- **Agent:** `ios-swiftui-expert` — iOS-specific UI patterns (for interop)

## References

- [Compose Multiplatform Documentation](https://www.jetbrains.com/help/compose-multiplatform/)
- [Jetpack Compose State Management](https://developer.android.com/develop/ui/compose/state)
- [Jetpack Compose Navigation](https://developer.android.com/develop/ui/compose/navigation)
- [Jetpack Compose Theming](https://developer.android.com/develop/ui/compose/designsystems/material)
- [Compose Performance](https://developer.android.com/develop/ui/compose/performance)
