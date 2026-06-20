---
name: "devkit-kmp"
description: "Kotlin Multiplatform coding standards: expect/actual patterns, architecture boundaries, iOS interop, testing"
applyTo: "multiplatform/**/*.kt"
version: "1.0"
---

# KMP Development Instructions

## Overview

This instruction set applies to **Kotlin Multiplatform shared modules** (`multiplatform/shared/**/*.kt`, `commonMain`, `androidMain`, `iosMain`). It enforces:
- Clean Architecture boundaries across platforms
- expect/actual pattern discipline
- iOS interop best practices (@ObjCName, @Throws)
- Testing standards (JUnit5 + MockK in commonTest)
- Dependency rules (no circular imports, platform isolation)

---

## 1. Source Set Boundaries

### Rule 1.1: No Platform Imports in commonMain

**❌ VIOLATION:**
```kotlin
// commonMain/kotlin/com/example/shared/UserRepository.kt
import android.content.Context          // ← FORBIDDEN
import android.database.sqlite.SQLite   // ← FORBIDDEN
import Foundation                        // ← FORBIDDEN
```

**✅ CORRECT:**
```kotlin
// commonMain/kotlin/com/example/shared/UserRepository.kt
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.Serializable
```

**Rationale:** commonMain compiles to all platforms. Android/Foundation imports create compilation errors on non-target platforms.

**Enforcement:** Use expect/actual pattern for platform-specific concerns.

### Rule 1.2: Source Set Visibility

| Source Set | Can Import From | Cannot Import From |
|---|---|---|
| commonMain | kotlinx.* (only portable libs) | android.*, Foundation, ios.* |
| androidMain | commonMain + android.* | iosMain |
| iosMain | commonMain + platform.* | androidMain |
| commonTest | commonMain | androidMain, iosMain |

**❌ VIOLATION:**
```kotlin
// androidMain/kotlin/com/example/android/AndroidUtils.kt
import com.example.shared.domain.User  // ✅ OK
import com.example.shared.ios.*        // ❌ FORBIDDEN (iosMain not accessible)
```

**✅ CORRECT:**
```kotlin
// androidMain/kotlin/com/example/android/AndroidUtils.kt
import com.example.shared.domain.User  // ✅ Can import from commonMain
// Use User type to avoid coupling to iOS-specific details
```

---

## 2. expect/actual Pattern Discipline

### Rule 2.1: Balanced Declarations

Every `expect` in `commonMain` **must** have exactly one `actual` in `androidMain` and one in `iosMain`.

**❌ VIOLATION:**
```kotlin
// commonMain
expect fun createDatabase(): Database

// androidMain (actual defined)
actual fun createDatabase(): Database = ...

// iosMain (MISSING actual → Compilation error)
```

**✅ CORRECT:**
```kotlin
// commonMain
expect fun createDatabase(): Database

// androidMain
actual fun createDatabase(): Database = AndroidDatabase()

// iosMain
actual fun createDatabase(): Database = iOSDatabase()
```

**Enforcement:** Compiler will fail if `actual` is missing. Use IDE inspection to catch before compilation.

### Rule 2.2: Signature Matching

The `expect` and `actual` declarations **must** have identical signatures (parameters, return type).

**❌ VIOLATION:**
```kotlin
// commonMain
expect suspend fun fetchUser(id: String): User

// androidMain
actual fun fetchUser(id: String, context: Context): User = ...  // ← WRONG signature
```

**✅ CORRECT:**
```kotlin
// commonMain
expect suspend fun fetchUser(id: String): User

// androidMain
actual suspend fun fetchUser(id: String): User = ...  // ← Matches signature

// iosMain
actual suspend fun fetchUser(id: String): User = ...  // ← Matches signature
```

### Rule 2.3: expect/actual Placement

- **expect** declarations in `commonMain` only
- **actual** implementations in platform-specific source sets (`androidMain`, `iosMain`)
- Never place both expect and actual in the same file

**❌ VIOLATION:**
```kotlin
// shared/src/main/kotlin/com/example/Utils.kt
expect fun doSomething()
actual fun doSomething() { }  // ← expect and actual in same file
```

**✅ CORRECT:**
```kotlin
// commonMain/kotlin/com/example/Utils.kt
expect fun doSomething()

// androidMain/kotlin/com/example/Utils.kt
actual fun doSomething() { ... }

// iosMain/kotlin/com/example/Utils.kt
actual fun doSomething() { ... }
```

---

## 3. Architecture Layer Enforcement

### Rule 3.1: Clean Architecture Dependency Direction

```
Domain ← Application ← Infrastructure ← Platform-Specific
```

**Dependency flows inward; never outward.**

| Layer | Responsibility | Imports Allowed From |
|---|---|---|
| **Domain** | Entities, repository interfaces, use cases | Nothing (pure Kotlin) |
| **Application** | Orchestration, shared state, expect for coroutines | Domain |
| **Infrastructure** | Data access, platform factories, expect for DB/network | Domain, Application |
| **Platform** (androidMain/iosMain) | actual implementations, platform framework | All above |

**❌ VIOLATION:**
```kotlin
// domain/User.kt (Domain layer)
import com.example.app.infrastructure.UserRepositoryImpl  // ← WRONG direction

data class User(val id: String)
```

**✅ CORRECT:**
```kotlin
// domain/User.kt (Domain layer)
// No imports from other layers

data class User(val id: String)

// application/GetUserUseCase.kt (Application layer)
import domain.User
import domain.UserRepository

class GetUserUseCase(private val repo: UserRepository) {
    suspend fun execute(id: String): User = repo.getUser(id)
}

// infrastructure/UserRepositoryImpl.kt (Infrastructure layer)
import domain.User
import domain.UserRepository
import expect for database and network

actual class UserRepositoryImpl : UserRepository {
    actual override suspend fun getUser(id: String): User = ...
}
```

### Rule 3.2: No Circular Dependencies

If `A` imports from `B`, then `B` cannot import from `A`.

**❌ VIOLATION:**
```kotlin
// domain/UserRepository.kt
import domain.User
import infrastructure.UserRepositoryImpl  // ← Circular with Rule 3.1

// infrastructure/UserRepositoryImpl.kt
import domain.UserRepository
import domain.User
```

**✅ CORRECT:**
```kotlin
// domain/UserRepository.kt
interface UserRepository {
    suspend fun getUser(id: String): User
}

// infrastructure/UserRepositoryImpl.kt
import domain.UserRepository
import domain.User

class UserRepositoryImpl : UserRepository {
    override suspend fun getUser(id: String): User = ...
}
```

**Enforcement:** Use `devkit-clean-architecture-quality` skill for periodic audits.

---

## 4. iOS Interop Patterns (@ObjCName, @Throws)

### Rule 4.1: Public APIs Require @ObjCName

If the shared module is consumed by iOS (via KMP framework), all public APIs **must** have `@ObjCName` for clarity.

**❌ VIOLATION:**
```kotlin
// commonMain
suspend fun fetchUser(id: String): User  // No @ObjCName
```

**✅ CORRECT:**
```kotlin
// commonMain
@ObjCName("fetchUserAsync", "error")
suspend fun fetchUser(id: String): User
```

**Rationale:** Kotlin suspend functions automatically become async in Swift, but naming should be explicit for iOS developers.

### Rule 4.2: Exception Mapping with @Throws

Exceptions in shared code should be annotated with `@Throws` so iOS can catch them.

**❌ VIOLATION:**
```kotlin
// commonMain
fun parseJson(json: String): Data {
    // Throws IOException or JsonException
}
```

**✅ CORRECT:**
```kotlin
// commonMain
@Throws(IOException::class, JsonException::class)
fun parseJson(json: String): Data {
    // ...
}
```

**In Swift:**
```swift
do {
    let data = try API.parseJson(json: jsonString)
} catch {
    // Catches NSError wrapping IOException or JsonException
}
```

### Rule 4.3: Nullability Conventions

Use Kotlin's native `?` for optionals; avoid `Optional<T>` wrapper.

**❌ VIOLATION:**
```kotlin
// commonMain
data class Config(val timeout: Optional<Int>)  // Confusing in Swift
```

**✅ CORRECT:**
```kotlin
// commonMain
data class Config(val timeout: Int? = null)  // Clear in both Kotlin and Swift (timeout: Int?)
```

---

## 5. expect/actual for Common Platform Concerns

### Rule 5.1: HTTP Client (Single Instance)

```kotlin
// commonMain
expect val httpClient: HttpClient

// androidMain
actual val httpClient: HttpClient = HttpClient(Android) {
    install(ContentNegotiation) { json() }
    install(Logging) {
        logger = Logger.DEFAULT
        level = LogLevel.ALL
    }
}

// iosMain
actual val httpClient: HttpClient = HttpClient(Darwin) {
    install(ContentNegotiation) { json() }
}
```

**Rationale:** Single HTTP client prevents resource waste and ensures consistency.

### Rule 5.2: Database Factory Pattern

```kotlin
// commonMain
expect object DatabaseFactory {
    fun createDatabase(): AppDatabase
}

// androidMain
actual object DatabaseFactory {
    actual fun createDatabase(): AppDatabase =
        AppDatabase(AndroidSqliteDriver(AppDatabase.Schema, context, "app.db"))
}

// iosMain
actual object DatabaseFactory {
    actual fun createDatabase(): AppDatabase =
        AppDatabase(NativeSqliteDriver(AppDatabase.Schema, "app.db"))
}
```

**Rationale:** Abstracts database driver selection from domain logic.

### Rule 5.3: Main Thread Dispatcher

```kotlin
// commonMain
expect val mainDispatcher: CoroutineDispatcher

// androidMain
actual val mainDispatcher: CoroutineDispatcher = Dispatchers.Main

// iosMain
actual val mainDispatcher: CoroutineDispatcher = Dispatchers.Main
```

**Rationale:** Suspend functions on shared ViewModels need the correct main dispatcher.

### Rule 5.4: Logging (Optional but Recommended)

```kotlin
// commonMain
expect fun log(level: LogLevel, message: String, throwable: Throwable? = null)

// androidMain
actual fun log(level: LogLevel, message: String, throwable: Throwable?) {
    val tag = "AppShared"
    when (level) {
        LogLevel.DEBUG -> Log.d(tag, message, throwable)
        LogLevel.INFO -> Log.i(tag, message, throwable)
        LogLevel.ERROR -> Log.e(tag, message, throwable)
    }
}

// iosMain
actual fun log(level: LogLevel, message: String, throwable: Throwable?) {
    NSLog("[${level.name}] $message", throwable?.message)
}
```

---

## 6. Testing Standards

### Rule 6.1: Unit Tests in commonTest (JUnit5 + MockK)

All testable logic in `commonMain` **must** have unit tests in `commonTest` using JUnit5 + MockK.

**✅ CORRECT:**
```kotlin
// commonTest/kotlin/com/example/shared/domain/GetUserUseCaseTest.kt
import org.junit.jupiter.api.Test
import io.mockk.coEvery
import io.mockk.mockk
import io.kotest.matchers.shouldBe

class GetUserUseCaseTest {
    private val repository = mockk<UserRepository>()
    private val useCase = GetUserUseCase(repository)

    @Test
    fun `should return user when repository succeeds`() {
        // Given
        val expectedUser = User("1", "John Doe")
        coEvery { repository.getUser("1") } returns expectedUser

        // When
        val result = runTest {
            useCase.execute("1")
        }

        // Then
        result shouldBe expectedUser
    }
}
```

**Coverage Requirement:** Minimum 40% of `commonMain` code (measured by JaCoCo).

### Rule 6.2: Platform-Specific Tests in androidTest / iosTest

Android-specific drivers, iOS framework calls, and expect/actual implementations belong in platform tests.

**✅ CORRECT (androidTest):**
```kotlin
// androidTest/kotlin/com/example/shared/infrastructure/AndroidDatabaseTest.kt
import org.junit.Test

class AndroidDatabaseTest {
    @Test
    fun `database should initialize with Android driver`() {
        val db = DatabaseFactory.createDatabase()
        // Assert Android-specific behavior
    }
}
```

---

## 7. Naming Conventions

### Rule 7.1: Public APIs

Use camelCase for functions and variables, PascalCase for classes and interfaces.

**✅ CORRECT:**
```kotlin
// commonMain
interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun saveUser(user: User)
}

expect val httpClient: HttpClient
expect fun createDatabase(): AppDatabase
```

### Rule 7.2: Expect/Actual Clarity

Include context in names to avoid ambiguity (especially with multiple expect/actual declarations).

**❌ UNCLEAR:**
```kotlin
// commonMain
expect fun create(): Something  // Which something?
```

**✅ CLEAR:**
```kotlin
// commonMain
expect fun createDatabase(): AppDatabase
expect fun createHttpClient(): HttpClient
```

---

## 8. Documentation Requirements

### Rule 8.1: Public API Documentation

All public APIs in shared modules **must** be documented with KDoc, especially at platform boundaries.

**✅ CORRECT:**
```kotlin
// commonMain
/**
 * Fetches a user from the remote API.
 *
 * @param id The unique user identifier.
 * @return The [User] object, or throws [IOException] if the network fails.
 *
 * **iOS Note:** Becomes `fetchUserAsync(id:error:)` in Objective-C.
 */
@ObjCName("fetchUserAsync", "error")
@Throws(IOException::class)
suspend fun fetchUser(id: String): User
```

### Rule 8.2: Architecture Diagram

Shared modules with complex expect/actual logic should include a diagram (in `README.md` or skill references) showing:
- Source set boundaries
- expect/actual pairs
- Layer dependencies

---

## 9. Common Anti-Patterns to Avoid

| ❌ Anti-Pattern | ✅ Solution |
|---|---|
| expect in both commonMain and androidMain | Put expect only in commonMain |
| actual in commonMain | Put actual only in platform-specific source sets |
| Platform imports in commonMain | Use expect/actual abstraction |
| Circular imports: domain → infra and infra → domain | Use dependency inversion (interface in domain, impl in infra) |
| Multiple HTTP clients (Ktor + OkHttp) | Single httpClient expect/actual |
| Magic numbers in shared code | Extract as named constants |
| Untyped exceptions across platforms | Use @Throws annotation |
| No @ObjCName for iOS public APIs | Add @ObjCName for clarity |

---

## 10. Quality Gate Checklist

Before merging KMP changes to develop:

- [ ] No `android.*` or `Foundation` imports in `commonMain`
- [ ] All `expect` declarations have matching `actual` in `androidMain` and `iosMain`
- [ ] expect/actual signatures match exactly
- [ ] No circular dependencies detected
- [ ] Architecture layers respect dependency direction (domain ← app ← infra)
- [ ] Public iOS APIs have `@ObjCName` annotations
- [ ] Exceptions marked with `@Throws` where needed
- [ ] Unit tests in `commonTest` with ≥40% coverage (JaCoCo)
- [ ] Platform-specific tests in `androidTest/` and `iosTest/`
- [ ] Public APIs documented with KDoc
- [ ] Naming conventions applied (camelCase functions, PascalCase types)

---

## Related Skills & Agents

- **Skill:** `kmp-shared-module-patterns` — Architecture patterns and code examples
- **Agent:** `devkit-kmp-expert` — Guided KMP architecture decisions
- **Agent:** `devkit-clean-architecture-quality` — Comprehensive architecture audit
- **Agent:** `devkit-clean-code-guardian` — Style and SRP violations in shared code

---

## References

- [Official KMP Documentation](https://kotlinlang.org/docs/multiplatform.html)
- [expect/actual Declarations](https://kotlinlang.org/docs/multiplatform-expect-actual.html)
- [iOS Interop (@ObjCName, @Throws)](https://kotlinlang.org/docs/native-objc-interop.html)
- [Ktor Client Multiplatform](https://ktor.io/docs/client-overview.html)
- [SQLDelight](https://github.com/cashapp/sqldelight)
- [Kotlin Coroutines](https://kotlinlang.org/docs/coroutines-overview.html)
