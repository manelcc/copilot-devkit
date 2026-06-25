---
name: devkit-kmp-shared-module-patterns
description: "Design patterns and best practices for Kotlin Multiplatform shared modules: expect/actual, Ktor Client, SQLDelight, coroutines, and iOS interop"
triggers:
  - "how to structure expect/actual in KMP"
  - "set up Ktor Client in shared module"
  - "design shared Interactor for KMP"
  - "configure SQLDelight for multiplatform"
  - "iOS interop patterns in Kotlin"
  - "KMP module dependencies"
  - "handle platform-specific logic in shared code"
  - "where should ViewModels live in KMP?"
non_triggers:
  - "format my Kotlin code" (use linter)
  - "migrate Android to KMP" (use migration-specific skill)
  - "build iOS app UI in Compose" (use cmp-ui-patterns skill)
  - "debug runtime crash" (use debugger)
---

# KMP Shared Module Patterns

## Purpose

This skill provides battle-tested patterns for designing and implementing Kotlin Multiplatform shared modules. It covers the critical architectural decisions, API boundaries, and platform interop techniques needed to build sustainable, maintainable multiplatform logic (Android + iOS) without duplicating business code.

## When to use

- Starting a new KMP shared module and unsure about structure
- Designing APIs that bridge `commonMain` and platform-specific code
- Working with expect/actual declarations and need guidance on scope
- Setting up data access layer (SQLDelight or Exposed) for multiplatform
- Implementing shared business logic (repositories, use cases, interactors)
- Exposing reactive state (Flow/StateFlow) for UI consumption without tying to platform ViewModels
- Handling iOS interop requirements (@ObjCName, @Throws, nullability)
- Reviewing pull requests that modify shared module boundaries
- Troubleshooting circular dependencies or platform-specific leaks

**Trigger scenarios:**
- "I need to design a data repository that works on Android and iOS"
- "Where should I put expect/actual for a network client?"
- "How do I expose shared business logic (Flow/StateFlow) to platform ViewModels?"
- "What's the right way to configure SQLDelight in a shared module?"
- "Should my ViewModel be in commonMain or platform-specific code?"

## When NOT to use

- Debugging Compose UI crashes → use debugger skill
- Migrating existing Android code to KMP → use migration skill
- Implementing iOS UI in Compose Multiplatform → use cmp-ui-patterns skill
- Choosing between CMP vs declarative iOS UI → use iOS expert agent
- Code formatting or auto-fixes → use linter/formatter

## Inputs

**Required context:**
- Module topology: Is this a new shared module or existing codebase?
- Target platforms: Android + iOS, or other combinations?
- Data access tier: Need persistent storage (SQLDelight, Exposed, Room)?
- iOS integration style: How will iOS consume the shared code (KMP framework, SPM, CocoaPods)?

**Optional context:**
- Existing build.gradle.kts snippet (if modifying existing module)
- Current expect/actual declarations (if reviewing)
- Error messages or architectural pain points

## Steps

### 1. Validate Scope

Check if the request is truly about shared module patterns:
- ✅ "How do I design a repository visible to both platforms?"
- ✅ "What expect/actual pattern fits my serialization use case?"
- ❌ "Why is my Compose UI button not clickable?" → Debugger
- ❌ "How do I animate a transition in SwiftUI?" → iOS expert

### 2. Detect Architecture Risk

Identify the architectural tier the user is working in:

| Tier | Scope | Patterns |
|------|-------|----------|
| **Domain** | Business logic (entities, use cases) | Clean Architecture; no platform deps |
| Application | Interactors, use cases, shared state (Flow/StateFlow) | expect/actual for coroutines; NO platform ViewModels |
| **Infrastructure** | Data access (DB, network, file I/O) | SQLDelight, Ktor Client; platform-specific factories |
| **Entrypoint** | Android Activities, iOS ViewControllers | Platform-specific; imports from infrastructure layer |

### 3. Recommend Pattern

Based on the tier and use case:

#### Domain Patterns

**Entities & Use Cases (Pure Kotlin, no platform deps)**
```kotlin
// commonMain: No platform-specific imports
data class User(val id: String, val name: String)

interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun saveUser(user: User)
}
```

✅ **Best practices:**
- No `android.*` or `Foundation` imports in domain classes
- Use `kotlinx.coroutines.flow.Flow` for reactive updates
- Data classes remain serialization-agnostic (serializer injected at infrastructure layer)

#### Application Patterns

**Shared Interactor (Pure Business Logic, No Platform ViewModels in commonMain)**
```kotlin
// commonMain: Pure business logic, no ViewModel
class UserInteractor(private val repository: UserRepository) {
    suspend fun loadUsers(): Flow<List<User>> = repository.observeUsers()
    suspend fun saveUser(user: User) = repository.saveUser(user)
}

// androidMain: Android ViewModel consumes interactor
class UserViewModel(private val interactor: UserInteractor) : ViewModel() {
    val uiState = interactor.loadUsers()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())
}

// iosMain: iOS ViewController/ViewModel consumes interactor
class UserViewModel {
    private let interactor: UserInteractor
    @Published var users: [User] = []
    
    func loadUsers() {
        // iOS-specific ViewModel logic
    }
}
```

**expect/actual for Serialization**
```kotlin
// commonMain
expect fun <T> parseJson(json: String, clazz: KClass<T>): T

// androidMain
actual fun <T> parseJson(json: String, clazz: KClass<T>): T =
    Gson().fromJson(json, clazz.java)

// iosMain
actual fun <T> parseJson(json: String, clazz: KClass<T>): T =
    JSONDecoder().decode(clazz, from: json.data(using: .utf8)!!)
```

**Ktor Client in Shared (Single instance)**
```kotlin
// commonMain
expect val httpClient: HttpClient

// androidMain
actual val httpClient: HttpClient = HttpClient(Android) {
    install(ContentNegotiation) { json() }
}

// iosMain
actual val httpClient: HttpClient = HttpClient(Darwin) {
    install(ContentNegotiation) { json() }
}
```

#### Infrastructure Patterns

**SQLDelight in Shared**
```
shared/
  build.gradle.kts
    sqldelight { database("AppDatabase") { schemaOutputDirectory = ... } }
  src/
    commonMain/sqldelight/
      com/example/User.sq
    androidMain/kotlin/
      com/example/persistence/AndroidDatabaseFactory.kt
    iosMain/kotlin/
      com/example/persistence/IosDatabaseFactory.kt
```

```kotlin
// commonMain
expect object DatabaseFactory {
    fun createDatabase(): AppDatabase
}

// androidMain
actual object DatabaseFactory {
    actual fun createDatabase(): AppDatabase =
        AppDatabase(
            AndroidSqliteDriver(AppDatabase.Schema, context, "app.db")
        )
}
```

**Exposed (Alternative to SQLDelight for shared business logic)**
- Use Exposed for query DSL in `commonMain` (database-agnostic SQL)
- Platform-specific drivers in `androidMain`/`iosMain`
- Caveat: Exposed is heavier; SQLDelight is lighter for mobile

#### iOS Interop Patterns

**@ObjCName for Public APIs**
```kotlin
// commonMain
@ObjCName("getUserAsync", "error")
suspend fun getUser(id: String): User // iOS sees this as Async method

// In Swift
let user = try await userRepository.getUserAsync(id: "123", error: &nsError)
```

**@Throws for Exception Handling in iOS**
```kotlin
// commonMain
@Throws(IOException::class, IllegalArgumentException::class)
fun parseData(json: String): Data

// In Swift: Throws automatically mapped to NSError
do {
    let data = try API.parseData(json: jsonString)
} catch {
    print("Error: \(error)")
}
```

**Nullability Conventions**
```kotlin
// commonMain
// ✅ Kotlin's null-safety translates naturally to Swift
data class Config(val apiKey: String, val timeout: Int?) // timeout can be nil in Swift

// ❌ Avoid: Optional<String> (redundant in Swift)
// ✅ Use: String? (clear in both languages)
```

### 4. Detect Dependency Violations

Check for common mistakes:

| ❌ Violation | ✅ Correct Pattern |
|---|---|
| `androidMain` imports in `commonMain` | Use expect/actual boundary |
| Circular deps: domain → infrastructure → domain | Single direction: domain ← application ← infrastructure |
| UI framework in shared module | Keep UI-agnostic; expose StateFlow<State> |
| Platform-specific exceptions in domain | Map to domain exceptions at infrastructure boundary |
| Multiple HTTP clients (Ktor + OkHttp + NSURLSession in shared) | Single httpClient expect/actual |

### 5. Validate Module Structure

Ensure clean source set boundaries:

```
shared/
├── build.gradle.kts (multiplatform config)
├── src/
│   ├── commonMain/kotlin/
│   │   ├── domain/          (pure Kotlin, no platform deps)
│   │   ├── application/     (expect/actual for coroutines, logging)
│   │   └── infrastructure/  (expect for data access)
│   ├── androidMain/kotlin/  (Android-specific impl)
│   ├── iosMain/kotlin/      (iOS-specific impl)
│   ├── commonTest/kotlin/   (JUnit5 + MockK, runs on JVM)
│   ├── androidTest/kotlin/  (Android-specific tests)
│   └── iosTest/kotlin/      (iOS-specific tests)
```

### 6. Generate Implementation Roadmap

Output a prioritized plan:
1. **Domain layer**: Define entities and repository interfaces
2. **expect/actual boundaries**: Identify platform-specific concerns
3. **Infrastructure**: Implement SQLDelight or Exposed setup
4. **iOS interop**: Add @ObjCName, @Throws where needed
5. **Testing**: Set up JUnit5 in commonTest, platform-specific tests

### 7. Validate Completeness

Checklist before closing:
- [ ] All public APIs in shared have @ObjCName for iOS visibility
- [ ] No `android.*` imports in commonMain
- [ ] No `Foundation` imports in commonMain
- [ ] expect/actual pairs are balanced (one per file)
- [ ] Repository layer has clear platform abstraction
- [ ] Logging/crashes expect/actual defined
- [ ] Database factory expect/actual defined
- [ ] HTTP client expect/actual defined
- [ ] Unit tests in commonTest, platform tests in androidTest/iosTest

## Expected outputs

**Primary output:** Structured architecture guidance with code examples for the identified tier (Domain, Application, or Infrastructure)

**Secondary outputs:**
- Code examples demonstrating the recommended pattern (expect/actual, repository interface, etc.)
- Architecture validation checklist (source set boundaries, dependency direction, iOS interop)
- Dependency diagram (if architectural risk detected)

**Completion signal:**
"✅ KMP pattern guidance complete. Your [tier] layer should follow [recommended pattern]. See code examples and validation checklist above."

## Validation

- Does the recommended pattern respect Clean Architecture boundaries? ✓
- Does the expect/actual placement prevent circular imports? ✓
- Are there platform-specific leaks visible in the public API? ✓
- Is the guidance applicable to Kotlin 2.0+ with stable memory model? ✓

## Examples

### Example 1: expect/actual HTTP Client

```kotlin
// commonMain
expect val httpClient: HttpClient

// androidMain
actual val httpClient: HttpClient = HttpClient(Android) {
    install(ContentNegotiation) { json() }
}

// iosMain
actual val httpClient: HttpClient = HttpClient(Darwin) {
    install(ContentNegotiation) { json() }
}
```

### Example 2: Shared Interactor Exposing Flow (Platform ViewModels Consume This)

```kotlin
// commonMain: Pure business logic, NO ViewModel here
class UserInteractor(private val repository: UserRepository) {
    suspend fun getUsers(): Flow<List<User>> = repository.observeUsers()
    suspend fun saveUser(user: User) = repository.saveUser(user)
}

// androidMain: Android ViewModel consumes Interactor
class UserViewModel(private val interactor: UserInteractor) : ViewModel() {
    val users = interactor.getUsers().stateIn(viewModelScope, SharingStarted.Lazily, emptyList())
}

// iosMain: iOS ViewController/MVVM consumes Interactor
class UserViewModel {
    private let interactor: UserInteractor
    @Published var users: [User] = []
    
    func onAppear() {
        // iOS-specific lifecycle, consume interactor
    }
}
```

### Example 3: iOS Interop with @ObjCName

```kotlin
// commonMain
@ObjCName("fetchUserAsync", "error")
@Throws(IOException::class)
suspend fun fetchUser(id: String): User

// In Swift:
do {
    let user = try await userAPI.fetchUserAsync(id: "123", error: &nsError)
} catch {
    print("Failed: \(error)")
}
```

## Related Skills

- `cmp-ui-patterns`: For Compose Multiplatform UI design (post-US-014)
- `devkit-clean-architecture-quality`: For architecture audit across platforms
- `devkit-clean-code-guardian`: For code style in shared modules

## References

- [Official KMP docs](https://kotlinlang.org/docs/multiplatform.html)
- [expect/actual declarations](https://kotlinlang.org/docs/multiplatform-expect-actual.html)
- [Ktor Client](https://ktor.io/docs/client-overview.html)
- [SQLDelight](https://github.com/cashapp/sqldelight)
- [iOS interop @ObjCName](https://kotlinlang.org/docs/native-objc-interop.html#names-and-name-mangling)
