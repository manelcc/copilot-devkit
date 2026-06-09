---
skills:
  - name: "Creational Design Patterns"
    description: "Kotlin and Android creational patterns for object creation, lifecycle, and dependency wiring"
    category: "Design Patterns"
---

# Creational Design Patterns in Kotlin/Android

## Core patterns
- Singleton: one instance with controlled access.
- Factory Method: defer exact type creation to specialized creators.
- Abstract Factory: produce families of related objects.
- Builder/DSL: construct complex objects with readable steps.
- Prototype: clone object instances safely.
- Dependency Injection: wire dependencies explicitly for testability.

## Android/Kotlin specifics
- Prefer DI containers or manual constructor injection over service locators.
- Use Kotlin DSL builders for complex immutable configuration objects.
- Keep singleton usage bounded to stateless services or clearly synchronized caches.
- Model factory outputs with sealed hierarchies when variants are finite.

## Real Android examples

### Factory Method for data source selection
```kotlin
sealed interface UserDataSource {
  suspend fun getUser(userId: String): User
}

class RemoteUserDataSource(
  private val api: UserApi
) : UserDataSource {
  override suspend fun getUser(userId: String): User = api.getUser(userId)
}

class LocalUserDataSource(
  private val dao: UserDao
) : UserDataSource {
  override suspend fun getUser(userId: String): User = dao.getUser(userId)
}

class UserDataSourceFactory(
  private val remote: RemoteUserDataSource,
  private val local: LocalUserDataSource
) {
  fun create(forceRefresh: Boolean): UserDataSource =
    if (forceRefresh) remote else local
}
```

### Dependency Injection through constructor graph
```kotlin
class UserRepository(
  private val factory: UserDataSourceFactory
) {
  suspend fun getUser(userId: String, forceRefresh: Boolean): User {
    return factory.create(forceRefresh).getUser(userId)
  }
}

class GetUserUseCase(
  private val repository: UserRepository
) {
  suspend operator fun invoke(userId: String, forceRefresh: Boolean): User {
    return repository.getUser(userId, forceRefresh)
  }
}
```

### Builder DSL for feature config
```kotlin
data class FeedConfig(
  val pageSize: Int,
  val preloadDistance: Int,
  val enableImages: Boolean
)

class FeedConfigBuilder {
  var pageSize: Int = 20
  var preloadDistance: Int = 5
  var enableImages: Boolean = true

  fun build(): FeedConfig {
    require(pageSize > 0)
    require(preloadDistance >= 0)
    return FeedConfig(pageSize, preloadDistance, enableImages)
  }
}

fun feedConfig(block: FeedConfigBuilder.() -> Unit): FeedConfig {
  return FeedConfigBuilder().apply(block).build()
}
```

## Selected references
- dbacinski/Design-Patterns-In-Kotlin: Builder/Assembler, Factory Method, Singleton, Abstract Factory
- JorgeAgulloM/DesignPatternsKotlin: Singleton, Builder, Factory Method, Prototype
- PacktPublishing/Kotlin-Design-Patterns-and-Best-Practices: idiomatic Kotlin implementations and anti-pattern guidance

## Selection matrix
| Problem | Pattern |
|---|---|
| Too many constructor params | Builder/DSL |
| Runtime variant creation | Factory Method |
| Family of related clients/services | Abstract Factory |
| Hard-to-test implicit dependencies | Dependency Injection |
| Single stateless coordination object | Singleton |

