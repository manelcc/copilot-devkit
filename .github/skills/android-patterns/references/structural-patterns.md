---
skills:
  - name: "Structural Design Patterns"
    description: "Kotlin and Android structural patterns for composition, integration, and boundary design"
    category: "Design Patterns"
---

# Structural Design Patterns in Kotlin/Android

## Core patterns
- Adapter: bridge incompatible interfaces.
- Decorator: add behavior without subclass explosion.
- Facade: expose a simplified API over complex subsystems.
- Proxy: control access, caching, or protection around target object.
- Composite: treat tree structures as a uniform abstraction.
- Bridge: split abstraction from implementation to avoid combinatorial growth.

## Android/Kotlin specifics
- Use adapter/facade to isolate third-party SDK volatility.
- Prefer Kotlin delegation for lightweight decorator implementations.
- Apply proxy for caching, metrics, permission checks, or throttling.
- Keep facades at module boundaries to reduce blast radius during migrations.

## Real Android examples

### Adapter around third-party analytics SDK
```kotlin
interface AnalyticsPort {
  fun track(event: String, params: Map<String, String>)
}

class VendorAnalyticsAdapter(
  private val sdk: VendorAnalyticsSdk
) : AnalyticsPort {
  override fun track(event: String, params: Map<String, String>) {
    sdk.logEvent(name = event, attributes = params)
  }
}
```

### Decorator for repository observability
```kotlin
interface OrdersRepository {
  suspend fun submit(order: Order)
}

class LoggingOrdersRepository(
  private val delegate: OrdersRepository,
  private val logger: Logger
) : OrdersRepository by delegate {

  override suspend fun submit(order: Order) {
    logger.info("submit:start id=${order.id}")
    runCatching { delegate.submit(order) }
      .onSuccess { logger.info("submit:success id=${order.id}") }
      .onFailure { logger.error("submit:error id=${order.id} message=${it.message}") }
      .getOrThrow()
  }
}
```

### Facade for startup sequence
```kotlin
class AppStartupFacade(
  private val remoteConfig: RemoteConfigInitializer,
  private val analytics: AnalyticsInitializer,
  private val crashReporting: CrashReportingInitializer
) {
  suspend fun initialize() {
    remoteConfig.init()
    analytics.init()
    crashReporting.init()
  }
}
```

## Selected references
- dbacinski/Design-Patterns-In-Kotlin: Adapter, Decorator, Facade, Protection Proxy, Composite
- JorgeAgulloM/DesignPatternsKotlin: Adapter, Bridge, Composite, Decorator, Facade, Proxy, Flyweight

## Selection matrix
| Problem | Pattern |
|---|---|
| Third-party API mismatch | Adapter |
| Need to hide subsystem complexity | Facade |
| Add cross-cutting behavior | Decorator or Proxy |
| Hierarchical tree operations | Composite |
| Platform-dependent implementations | Bridge |

