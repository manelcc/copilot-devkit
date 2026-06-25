# CMP UI Architecture Overview

## Compose Multiplatform Layer Architecture

```mermaid
graph TD
    subgraph "Shared KMP Module (Business Logic)"
        Interactor["Interactors<br/>(UserInteractor, etc)"]
        Flow["Flow/StateFlow<br/>(observeUsers, etc)"]
    end
    
    subgraph "CMP UI Layer (shared/presentation)"
        Screens["Composable Screens<br/>(LoginScreen, HomeScreen)"]
        Theme["Theme + Colors<br/>(AppTheme, LocalTheme)"]
        Navigation["Type-Safe Navigation<br/>(Destination sealed class)"]
    end
    
    subgraph "Platform Wrapping (Android + iOS)"
        AndroidVM["Android ViewModel<br/>(wraps Flow)"]
        iOSVM["iOS ViewModel<br/>(wraps Flow)"]
    end
    
    Interactor -->|exposes| Flow
    Flow -->|consumed by| Screens
    Screens -->|uses| Theme
    Screens -->|routes via| Navigation
    Flow -->|wrapped by| AndroidVM
    Flow -->|wrapped by| iOSVM
    AndroidVM -->|feeds| Screens
    iOSVM -->|feeds| Screens
    
    classDef kmp fill:#c8e6c9,stroke:#1b5e20
    classDef cmp fill:#bbdefb,stroke:#01579b
    classDef platform fill:#fff3e0,stroke:#e65100
    
    class Interactor,Flow kmp
    class Screens,Theme,Navigation cmp
    class AndroidVM,iOSVM platform
```

## State Management Options

### Option 1: Local Composable State (MVI-inspired)

```mermaid
graph LR
    UI["Composable UI"]
    Action["Action<br/>(UpdateEmail)"]
    Reducer["Reducer<br/>(state + action → new state)"]
    State["UiState<br/>(mutableState)"]
    
    UI -->|dispatch| Action
    Action -->|processed by| Reducer
    Reducer -->|updates| State
    State -->|observed by| UI
    
    style UI fill:#bbdefb
    style Action fill:#fff3e0
    style Reducer fill:#c8e6c9
    style State fill:#f3e5f5
```

### Option 2: Interactor + Flow (Reactive)

```mermaid
graph LR
    Interactor["Interactor<br/>(UserInteractor)"]
    Flow["Flow<UiState><br/>(observeUserState)"]
    Composable["Composable<br/>(collectAsState)"]
    
    Interactor -->|exposes| Flow
    Flow -->|collected by| Composable
    
    style Interactor fill:#c8e6c9
    style Flow fill:#c8e6c9
    style Composable fill:#bbdefb
```

## Navigation Type-Safe Pattern

```mermaid
graph TD
    App["App Composable"]
    NavController["NavController<br/>(currentDestination StateFlow)"]
    Destination["sealed class Destination<br/>- LoginScreen<br/>- HomeScreen<br/>- UserDetailScreen(userId)"]
    Screens["Screens<br/>(when(currentDest) {...})"]
    
    App -->|observes| NavController
    NavController -->|manages| Destination
    Destination -->|routed to| Screens
    Screens -->|navigate(dest)| NavController
    
    classDef control fill:#fff3e0
    classDef model fill:#f3e5f5
    classDef ui fill:#bbdefb
    
    class App,NavController control
    class Destination model
    class Screens ui
```

## Theming Strategy (Light/Dark Mode)

```mermaid
graph TD
    Colors["Colors Object<br/>- primary<br/>- secondary<br/>- background<br/>- error"]
    Typography["Typography Object<br/>- labelLarge<br/>- bodyMedium<br/>- headlineSmall"]
    Shapes["Shapes Object<br/>- corners<br/>- sizes"]
    
    Theme["Theme Data Class<br/>(colors + typography + shapes)"]
    LocalTheme["CompositionLocal<br/>(LocalTheme)"]
    Components["Composables<br/>(Button, Card, Text)"]
    
    Colors -->|composed in| Theme
    Typography -->|composed in| Theme
    Shapes -->|composed in| Theme
    
    Theme -->|provided via| LocalTheme
    LocalTheme -->|accessed by| Components
    
    style Colors fill:#ffe0b2
    style Typography fill:#f3e5f5
    style Shapes fill:#b2dfdb
    style Theme fill:#c8e6c9
    style LocalTheme fill:#bbdefb
    style Components fill:#f8bbd0
```

## Performance: Avoiding Recomposition

```mermaid
graph LR
    Data["Data Changes"]
    Key["LazyList key = { item.id }"]
    Remember["remember(dependency)"]
    Memoization["@Composable cached"]
    
    Data -->|with key()| Key
    Key -->|prevents recomp| Memoization
    
    Data -->|with remember()| Remember
    Remember -->|skips calc| Memoization
    
    style Data fill:#ffcdd2
    style Key fill:#c8e6c9
    style Remember fill:#c8e6c9
    style Memoization fill:#bbdefb
```

## Platform-Specific Handling

```mermaid
graph TB
    CMP["CMP Screen<br/>(commonMain)"]
    
    Android["Android Platform<br/>- IME insets<br/>- Back button<br/>- Vibration"]
    iOS["iOS Platform<br/>- Safe areas<br/>- Swipe back<br/>- Haptics"]
    
    CMP -->|platform check| Android
    CMP -->|platform check| iOS
    
    Note["Use expect/actual<br/>for platform specifics"]
    
    style CMP fill:#bbdefb
    style Android fill:#fff3e0
    style iOS fill:#f3e5f5
    style Note fill:#ffebee
```

## Complete Example: Login Flow

```mermaid
graph TD
    User["User Input<br/>(email, password)"]
    LoginAction["LoginAction<br/>(Submit)"]
    Interactor["Interactor.login()"]
    Flow["Flow<LoginState><br/>(Loading → Success/Error)"]
    Composable["LoginScreen<br/>(collectAsState)"]
    Navigate["navigate(HomeScreen)"]
    
    User -->|triggers| LoginAction
    LoginAction -->|calls| Interactor
    Interactor -->|emits via| Flow
    Flow -->|observed by| Composable
    Composable -->|shows loading/error| User
    Composable -->|on success| Navigate
    
    style User fill:#fff3e0
    style LoginAction fill:#fff3e0
    style Interactor fill:#c8e6c9
    style Flow fill:#c8e6c9
    style Composable fill:#bbdefb
    style Navigate fill:#bbdefb
```

## Checklist: Healthy CMP Architecture

- [ ] No platform-specific code in commonMain composables
- [ ] State flows from Interactors (business logic) → Composables (UI)
- [ ] Navigation is type-safe (sealed class Destination)
- [ ] Theming via CompositionLocal (no hardcoded colors)
- [ ] LazyList uses `key { item.id }` to optimize recomposition
- [ ] Heavy computations memoized with `remember()`
- [ ] No memory leaks (DisposableEffect cleanup)
- [ ] Platform-specific UI (IME, safe areas) via expect/actual
- [ ] Light/Dark mode theme switching works seamlessly
- [ ] Screenshot tests cover major screens
