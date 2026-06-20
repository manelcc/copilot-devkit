---
name: "devkit-cmp"
description: "Compose Multiplatform coding standards: state management, type-safe navigation, theming, performance optimization, and platform interop"
applyTo: "multiplatform/**/*.kt"
version: "1.0"
---

# CMP Development Instructions

## Overview

This instruction set applies to **Compose Multiplatform UI code** (`multiplatform/*/src/commonMain/kotlin/**/*Screen.kt`, `*Navigation.kt`, `*Theme.kt`). It enforces:
- Reactive state management (Flow/StateFlow from Interactors)
- Type-safe navigation (sealed class Destination)
- Themeable colors and typography (CompositionLocal)
- Performance optimization (LazyList keys, memoization)
- Platform interop (expect/actual for IME, safe areas)

---

## 1. State Management Rules

### Rule 1.1: State Flows from Interactors (Not Polling)

**❌ VIOLATION:**
```kotlin
// commonMain/LoginScreen.kt
@Composable
fun LoginScreen(interactor: UserInteractor) {
    var user by remember { mutableStateOf(null) }
    
    // Polling - BAD
    LaunchedEffect(Unit) {
        while (true) {
            user = interactor.getUser()  // ← Blocking, not reactive
            delay(5000)
        }
    }
}
```

**✅ CORRECT:**
```kotlin
// commonMain/LoginScreen.kt
@Composable
fun LoginScreen(interactor: UserInteractor) {
    val user by interactor.observeUser().collectAsState()  // ← Reactive Flow
}
```

**Rationale:** Flow is reactive, non-blocking, and cancellable. Polling wastes CPU and battery.

### Rule 1.2: Local State with MVI-Inspired Reducer (Optional)

For local UI state (not from Interactors):

**✅ CORRECT:**
```kotlin
data class LoginUiState(val email: String = "", val isLoading: Boolean = false)

sealed class LoginAction {
    data class UpdateEmail(val email: String) : LoginAction()
    object Submit : LoginAction()
}

fun loginReducer(state: LoginUiState, action: LoginAction): LoginUiState = when (action) {
    is LoginAction.UpdateEmail -> state.copy(email = action.email)
    LoginAction.Submit -> state.copy(isLoading = true)
}

@Composable
fun LoginScreen(interactor: UserInteractor) {
    var uiState by remember { mutableStateOf(LoginUiState()) }
    
    TextField(
        value = uiState.email,
        onValueChange = { uiState = loginReducer(uiState, LoginAction.UpdateEmail(it)) }
    )
}
```

---

## 2. Navigation Rules

### Rule 2.1: Type-Safe Navigation with Sealed Class

**❌ VIOLATION:**
```kotlin
// commonMain/Navigation.kt
when (route) {
    "home" -> HomeScreen()
    "user/${id}" -> UserScreen(id)  // ← Magic strings, no type safety
}
```

**✅ CORRECT:**
```kotlin
// commonMain/Navigation.kt
sealed class Destination {
    data object HomeScreen : Destination()
    data class UserScreen(val userId: String) : Destination()
}

@Composable
fun AppNavigation(navController: NavController) {
    val current by navController.currentDestination.collectAsState()
    when (current) {
        Destination.HomeScreen -> HomeScreen(onNavigate = { navController.navigate(it) })
        is Destination.UserScreen -> UserScreen(current.userId)
    }
}
```

**Rationale:** Type safety prevents runtime errors. Sealed class ensures exhaustive when.

### Rule 2.2: No String-Based Routes

**❌ VIOLATION:**
```kotlin
// DON'T: Pass route as string
navController.navigate("user/123")  // ← No validation
```

**✅ CORRECT:**
```kotlin
// DO: Use sealed class
navController.navigate(Destination.UserScreen("123"))  // ← Type-checked
```

---

## 3. Theming Rules

### Rule 3.1: CompositionLocal for Theme Access (No Hardcoded Colors)

**❌ VIOLATION:**
```kotlin
// commonMain/MyButton.kt
@Composable
fun MyButton(text: String) {
    Button(
        colors = ButtonDefaults.buttonColors(
            containerColor = Color(0xFF6200EE)  // ← Hardcoded, not themeable
        )
    ) { Text(text) }
}
```

**✅ CORRECT:**
```kotlin
// commonMain/Theme.kt
val LocalTheme = compositionLocalOf<AppTheme> { error("No theme") }

data class AppTheme(
    val colors: Colors,
    val typography: Typography
)

// commonMain/MyButton.kt
@Composable
fun MyButton(text: String) {
    val theme = LocalTheme.current
    Button(
        colors = ButtonDefaults.buttonColors(
            containerColor = theme.colors.primary  // ← Themeable
        )
    ) { Text(text) }
}
```

**Rationale:** CompositionLocal allows dynamic theme switching (Light/Dark mode).

### Rule 3.2: Light and Dark Theme Variants

**✅ CORRECT:**
```kotlin
// commonMain/Theme.kt
val lightColors = Colors(
    primary = Color(0xFF6200EE),
    surface = Color.White,
    onSurface = Color.Black
)

val darkColors = Colors(
    primary = Color(0xFFBB86FC),
    surface = Color(0xFF121212),
    onSurface = Color.White
)

@Composable
fun AppTheme(isDarkMode: Boolean = false, content: @Composable () -> Unit) {
    val theme = AppTheme(
        colors = if (isDarkMode) darkColors else lightColors,
        typography = Typography()
    )
    CompositionLocalProvider(LocalTheme provides theme) {
        content()
    }
}
```

---

## 4. Performance Rules

### Rule 4.1: LazyList with Unique Keys

**❌ VIOLATION:**
```kotlin
// commonMain/UserList.kt
@Composable
fun UserList(users: List<User>) {
    LazyColumn {
        items(users.size) { index ->  // ← Index-based key (unstable)
            UserItem(users[index])
        }
    }
}
```

**✅ CORRECT:**
```kotlin
// commonMain/UserList.kt
@Composable
fun UserList(users: List<User>) {
    LazyColumn {
        items(users, key = { it.id }) { user ->  // ← Unique, stable key
            UserItem(user)
        }
    }
}
```

**Rationale:** Index-based keys break if list order changes. Unique keys prevent unnecessary recompositions.

### Rule 4.2: Memoize Heavy Computations

**❌ VIOLATION:**
```kotlin
// commonMain/FilteredList.kt
@Composable
fun FilteredList(users: List<User>, filter: String) {
    val filtered = users.filter { it.name.contains(filter) }  // ← Recomputed every render
    LazyColumn {
        items(filtered) { UserItem(it) }
    }
}
```

**✅ CORRECT:**
```kotlin
// commonMain/FilteredList.kt
@Composable
fun FilteredList(users: List<User>, filter: String) {
    val filtered = remember(users, filter) {
        users.filter { it.name.contains(filter) }  // ← Memoized
    }
    LazyColumn {
        items(filtered, key = { it.id }) { UserItem(it) }
    }
}
```

**Rationale:** `remember()` skips computation if dependencies haven't changed.

### Rule 4.3: Avoid Layout Thrashing (State in Correct Scope)

**❌ VIOLATION:**
```kotlin
// DON'T: Hoist state too high (unnecessary recompositions of siblings)
@Composable
fun Parent() {
    var count by remember { mutableStateOf(0) }  // ← ALL children recompose
    ExpensiveChild()
    CounterChild(count) { count++ }
}
```

**✅ CORRECT:**
```kotlin
// DO: Hoist only what's necessary
@Composable
fun Parent() {
    ExpensiveChild()
    CounterChild()
}

@Composable
fun CounterChild() {
    var count by remember { mutableStateOf(0) }  // ← Only this recomposes
    Button(onClick = { count++ }) { Text("$count") }
}
```

---

## 5. Platform Interop Rules

### Rule 5.1: Platform-Specific UI via expect/actual (Not In commonMain)

**❌ VIOLATION:**
```kotlin
// commonMain/HomeScreen.kt
@Composable
fun HomeScreen() {
    Column {
        Spacer(modifier = Modifier.height(24.dp))  // ← Should account for status bar on both platforms
        Text("Home")
    }
}
```

**✅ CORRECT:**
```kotlin
// commonMain/HomeScreen.kt
@Composable
fun HomeScreen() {
    val topPadding = TopSafeAreaPadding()  // ← expect function
    Column(modifier = Modifier.padding(top = topPadding)) {
        Text("Home")
    }
}

// commonMain/SafeArea.kt
expect fun TopSafeAreaPadding(): Dp

// androidMain/SafeArea.kt
actual fun TopSafeAreaPadding(): Dp = 0.dp  // ← Android status bar handled by Compose

// iosMain/SafeArea.kt
actual fun TopSafeAreaPadding(): Dp = 44.dp  // ← iOS safe area (notch, etc.)
```

**Rationale:** Platform differences (status bar, notch, safe areas) should use expect/actual.

### Rule 5.2: IME Insets Handling

**✅ CORRECT:**
```kotlin
// commonMain/LoginScreen.kt
@Composable
fun LoginScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .imePadding()  // ← Handle keyboard automatically
    ) {
        TextField(...)
    }
}
```

---

## 6. Memory & Cleanup Rules

### Rule 6.1: DisposableEffect for Resource Cleanup

**❌ VIOLATION:**
```kotlin
// commonMain/LocationScreen.kt
@Composable
fun LocationScreen(locationManager: LocationManager) {
    LaunchedEffect(Unit) {
        locationManager.startListening()  // ← No cleanup
    }
}
```

**✅ CORRECT:**
```kotlin
// commonMain/LocationScreen.kt
@Composable
fun LocationScreen(locationManager: LocationManager) {
    DisposableEffect(Unit) {
        locationManager.startListening()
        onDispose {
            locationManager.stopListening()  // ← Cleanup on exit
        }
    }
}
```

**Rationale:** Prevents memory leaks; ensures resources released when composable exits.

---

## 7. Naming Conventions

### Rule 7.1: @Composable Functions End with "Screen" or "Dialog"

**✅ CORRECT:**
```kotlin
@Composable
fun LoginScreen() { }

@Composable
fun ConfirmDialog() { }

@Composable
fun UserCard() { }  // Smaller components: lowercase
```

### Rule 7.2: State Objects Named XxxUiState or XxxAction

**✅ CORRECT:**
```kotlin
data class LoginUiState(val email: String, val isLoading: Boolean)

sealed class LoginAction {
    data class UpdateEmail(val email: String) : LoginAction()
}
```

---

## 8. Documentation Requirements

### Rule 8.1: Document State Management Strategy

**✅ CORRECT:**
```kotlin
/**
 * Displays login form with reactive state from [UserInteractor].
 *
 * State flow:
 * - User input → LoginAction (reducer) → local UiState
 * - Submit → calls interactor.login()
 * - Success → navigate to HomeScreen
 *
 * @param interactor Provides user login business logic
 */
@Composable
fun LoginScreen(interactor: UserInteractor) {
    // ...
}
```

---

## 9. Anti-Patterns to Avoid

| ❌ Anti-Pattern | ✅ Solution |
|---|---|
| **Hardcoded colors in composables** | Use CompositionLocal<Theme> |
| **String-based navigation routes** | Use sealed class Destination |
| **LazyList without key** | Add unique key = { item.id } |
| **Heavy computation on every recompose** | Memoize with remember(dependency) |
| **No DisposableEffect cleanup** | Add onDispose { ... } block |
| **Polling instead of Flow** | Use Interactor.observeX().collectAsState() |
| **Platform code in commonMain** | Use expect/actual for platform-specific UI |
| **State hoisted to wrong scope** | Hoist only necessary state; keep local when possible |

---

## 10. Quality Gate Checklist

Before merging CMP changes to develop:

- [ ] **No hardcoded colors** (all via LocalTheme.current.colors)
- [ ] **Navigation is type-safe** (sealed class Destination, no magic strings)
- [ ] **State flows reactively from Interactors** (Flow/StateFlow, no polling)
- [ ] **LazyList uses unique key = { item.id }**
- [ ] **Heavy computations memoized** (remember() or derivedStateOf())
- [ ] **DisposableEffect for resource cleanup** (listeners, timers, streams)
- [ ] **Theme switching works** (Light/Dark mode via CompositionLocal)
- [ ] **Platform-specific UI via expect/actual** (IME, safe areas, gestures)
- [ ] **No platform-specific imports in commonMain**
- [ ] **Composable naming follows convention** (*Screen, *Dialog, etc.)
- [ ] **State objects documented** (KDoc explaining flow)

---

## Related Skills & Agents

- **Skill:** `cmp-ui-patterns` — Detailed patterns for state, navigation, theming, performance
- **Skill:** `kmp-shared-module-patterns` — Business logic and Interactor patterns
- **Agent:** `devkit-cmp-expert` — Guided CMP architecture decisions
- **Agent:** `devkit-kmp-expert` — Interactor and Flow patterns
- **Agent:** `android-compose-expert` — Android-specific Compose details

---

## References

- [Compose Multiplatform Documentation](https://www.jetbrains.com/help/compose-multiplatform/)
- [Jetpack Compose State Management](https://developer.android.com/develop/ui/compose/state)
- [Jetpack Compose Navigation](https://developer.android.com/develop/ui/compose/navigation)
- [Compose Theming](https://developer.android.com/develop/ui/compose/designsystems)
- [Compose Performance](https://developer.android.com/develop/ui/compose/performance)
